# Schema change record template

`changing-a-live-schema` opens this in its first step and fills one section
per step, so the whole plan of phases exists before the first one ships;
`release-readiness` reads it to exercise the recovery and bind the rollback
target. Write it to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-schema-change.md`
unless the user names another place, and record the data owner's acceptance
of the contract phase as a row in the ledger beside it, naming who accepted,
when, and the evidence they saw. No secret value, credential, or row of
personal data goes in it. A section left empty means the thing was not bound,
not built, or not verified: say which, and the release decision treats it as
missing rather than fine.

```markdown
# Schema change record — {{change-short-name}}

- **Change:** {{branch or revision this phase is built into}}
- **Predecessor:** {{the record of the earlier phase of the same change, or none}}
- **Inputs:** {{the data-model section's identity and path; the plan task or request}}
- **Owner:** {{the data owner who accepts the contract phase; the deploy owner for ordering}}
- **Status:** `{{planned | expanded | dual-writing | backfilled | switched | contracted}}`
- **Decision ledger:** {{the ledger path beside this record and the row recording the contract acceptance; "no row" until contract is accepted}}

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
| Expand | {{the additive change}} | {{migration before code}} | {{old version runs against it; compatibility test}} | {{revert code; expansion stays}} |
| Dual-write and tolerant reads | {{what writes both, what reads either}} | {{code only}} | {{tests in Tests}} | {{previous version}} |
| Backfill | {{the job}} | {{job under the deploy process}} | {{remaining rows zero; verification passed}} | {{stop the job; rows already written stay valid}} |
| Switch reads | {{the read path change}} | {{code only}} | {{reads correct on backfilled and unbackfilled rows}} | {{previous change}} |
| Stop old writes | {{the write path change}} | {{code only}} | {{no old-shape writes observed for {{period}}}} | {{previous change, which writes both}} |
| Contract | {{the drop}} | {{code before migration, in separate deploys}} | {{the conditions in Point of no return}} | {{none; see Point of no return}} |

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

| Test | Path and name | RED seen on | GREEN seen on |
| --- | --- | --- | --- |
| Migration applies to the previous schema version | {{path::test}} | {{revision}} | {{revision}} |
| Previous code version passes against the expanded schema | {{path::test, and the version it ran}} | {{revision}} | {{revision}} |
| Backfill run twice changes nothing the second time | {{path::test}} | {{revision}} | {{revision}} |
| Backfill resumes after interruption | {{path::test}} | {{revision}} | {{revision}} |
| Reads handle a row not yet backfilled | {{path::test}} | {{revision}} | {{revision}} |

## Point of no return

- **Phase:** contract, dropping {{old column, table, or field}}
- **No live version reads the old shape:** {{evidence and date}}
- **Rollback target does not read it:** {{the target version and how that was checked}}
- **Verification passed:** {{the Backfill verification result}}
- **Retention allows:** {{the retention rule and how it is met}}
- **Accepted by:** {{the data owner, when, and the ledger row; "not accepted" until it is}}

## Not verified

{{Each input not bound, lock or rewrite not measured, or test not run, and
why. "Nothing" is a valid entry.}}

## Next action

{{The single next step and its owner: the release decision for this phase
through `release-readiness`, or the next phase as its own change.}}
```
