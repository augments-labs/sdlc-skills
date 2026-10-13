# Schema change record template

`changing-a-live-schema` opens this in its first step, writes the Inputs and
every phase before the first one ships, and completes the Tests, evidence,
and Status once the phase's tests are green; `release-readiness` receives it
as evidence for its recovery and compatibility checks. Write it to
`.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-schema-change-{{phase}}.md`
unless the user names another place; the data owner's acceptance of the
contract phase is a row in the ledger beside it, and nowhere else. No secret
value, credential, or row of personal data goes in it. A phase this change
does not need reads `not needed` with its reason, which is distinct from
empty: a section left empty means the thing was not bound, not built, or not
verified, so say which, and the release decision treats it as missing rather
than fine.

```markdown
# Schema change record — {{change-short-name}}

- **Change:** {{branch or revision this phase is built into}}
- **Predecessor:** {{the record of the earlier phase of the same change, or none}}
- **Inputs:** {{the data-model section's identity, path, and recorded route, or "no data-model section" with the reason; the plan task or request}}
- **Owner:** {{the data owner who accepts the contract phase; the deploy owner for ordering}}
- **Status:** `{{planned | expanded | dual-writing | backfilled | reads-switched | old-writes-stopped | contracted}}`
- **Decision ledger:** {{the ledger path beside this record and the identity of the contract-acceptance row; "no row" until contract is accepted}}

## Inputs

| Input | Value | Source |
| --- | --- | --- |
| Migration tool and conventions | {{tool, where migrations live, how they are versioned}} | {{path or document}} |
| Deploy step that runs migrations | {{before the code starts, after, or a separate job}} | {{deploy definition}} |
| Code versions live during a roll | {{number, and for how long}} | {{deploy model}} |
| Rollback target | {{the exact version that will run against the changed store if this deploy is reverted}} | {{release record}} |
| Store engine and version | {{engine and exact version in the shared environments}} | {{where read}} |
| Affected data | {{rows or volume, write rate, replicas}} | {{query or metric, and when}} |

## Phases

| Phase | Migration or code change | Order | Gate to advance | Rollback |
| --- | --- | --- | --- | --- |
| Expand | {{the additive change, or not needed: reason}} | {{migration before code}} | {{old version runs against it; compatibility test}} | {{revert code; expansion stays}} |
| Dual-write and tolerant reads | {{what writes both, what reads either, or not needed: reason}} | {{code only}} | {{tests in Tests}} | {{previous version}} |
| Backfill | {{the job, or not needed: reason}} | {{job under the deploy process}} | {{remaining rows zero; verification passed}} | {{stop the job; rows already written stay valid}} |
| Switch reads | {{the read path change, or not needed: reason}} | {{code only}} | {{reads correct on backfilled and unbackfilled rows}} | {{previous change}} |
| Stop old writes | {{the write path change, or not needed: reason}} | {{code only}} | {{no old-shape writes observed for the stated period}} | {{previous change, which writes both}} |
| Contract | {{the drop, or not needed: reason}} | {{code before migration}} | {{the conditions in Point of no return}} | {{restore from backup, with its recovery time; application rollback to the target ends here}} |

## Backfill

- **Batch key and size:** {{the indexed key the batches range over, and the batch size}}
- **Cursor:** {{where the last completed batch is recorded, so a restart resumes}}
- **Throttle:** {{the lag or lock-wait signal it reads, and the pause rule}}
- **Progress:** {{where remaining rows, rate, and errors are read}}
- **Verification:** {{the count or checksum comparing old and new shape, and its result}}

## Lock and rewrite evidence

| Operation | Engine documentation says | Measured on | Duration, lock held, rewritten |
| --- | --- | --- | --- |
| {{index build, default, type change, constraint, drop}} | {{what the documentation states for this engine and version, with the page}} | {{production-sized copy, or "none: unverified"}} | {{result, or "unverified"}} |

## Tests

New behaviour, each red before its code existed:

| Test | Path and name | RED seen on | GREEN seen on |
| --- | --- | --- | --- |
| Migration applies to the previous schema version | {{path::test}} | {{revision}} | {{revision}} |
| Backfill run twice changes nothing the second time | {{path::test}} | {{revision}} | {{revision}} |
| Backfill resumes after interruption | {{path::test}} | {{revision}} | {{revision}} |
| Reads handle a row not yet backfilled | {{path::test}} | {{revision}} | {{revision}} |

Preserved behaviour, under the preserved-behaviour cycle:

| Test | Suite and version it ran | Seen green on | Deliberate red: divergence and revision | Green again on |
| --- | --- | --- | --- | --- |
| Previous code version passes against the expanded schema | {{suite, and the version}} | {{revision}} | {{the expansion the old version cannot tolerate, and the revision}} | {{revision}} |

## Point of no return

- **Phase:** contract, dropping {{old column, table, or field}}
- **No live version reads the old shape:** {{evidence and date}}
- **Rollback target does not read it:** {{the target version and how that was checked}}
- **Verification re-run after old writes stopped:** {{result and date}}
- **Retention allows:** {{the retention rule and how it is met}}
- **Restore path:** {{the backup or snapshot and its recovery time}}
- **Accepted:** {{the Decision ledger row identity; "no row" until accepted}}

## Not verified

{{Each input not bound, lock or rewrite not measured, or test not run, and
why. "Nothing" is a valid entry.}}

## Next action

{{The single next step and its owner: the release decision for this phase
through `release-readiness`, or the next phase as its own change.}}
```
