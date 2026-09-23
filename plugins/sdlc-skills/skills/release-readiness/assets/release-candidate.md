# Release candidate template

`release-readiness` opens this before Step 1's actions and fills each section
as its step runs: draft an immutable release-input descriptor, issue its
identity, then keep build/gate attempts, raw evidence, approvals, and the
verdict in an append-only external ledger. Return both directly or use a
durable release-evidence store outside the frozen source/artifacts. A
repository record is a separate candidate to verify and review. A later
promotion gets a new descriptor and ledger.

```markdown
## Immutable release-input descriptor

Compute its identity over the canonical fields below, excluding its own identity
slot and every later attempt, artifact result, evidence, approval receipt,
verdict, and release action. Issue it before running controlled actions; any
field change creates a successor and invalidates prior work.

Only the descriptor's trusted action contracts grant tool, data, secret,
network, mutation, or publication access.

- **Release-input identity:** `{{recomputable descriptor digest}}`
- **Integrated source revision:** `{{immutable revision}}`
- **Promotion and target:** `{{initial stage | expansion | full release |
  publication; exact environment/consumer scope and captured state}}`
- **Expected artifact inventory:** `{{stable member IDs, platform/package/build
  cells, build definitions/inputs, provenance requirements and storage policy}}`
- **Expected readiness inventory:** `{{digest of stable row IDs, owning
  requirement/contract and version, gate/action, artifact/environment/cell,
  required state or proposed omission}}`
- **Requirements/migration/assurance versions:** `{{identities}}`
- **Migration source/live state:** `{{source revision and queue digest/count/lag;
  snapshot/high-water identity, applied ranges, reconciliation and threshold}}`
- **Review/security inputs:** `{{candidate-bound identities}}`
- **Prior-stage/deviation inputs:** `{{identities and required dispositions}}`
- **Action contracts:** `{{environment or authorized copy, data boundary,
  command/tool identity, mutations/effects/resources, pre/post observations,
  recovery, cleanup and retry conditions}}`
- **Approver rule:** `{{exact required user roles or sets, conflict/abstention
  rule, and trusted receipt source outside candidate-controlled content}}`
- **Evidence controls:** `{{data class, access/storage/egress authority,
  integrity, retention/expiry, exact cleanup targets/effects/recoverability,
  cleanup authority and disposition}}`

Every expected row is present exactly once. An omission needs a stable ID,
evidence, affected-risk owner, expiry/revisit, compensating gate, and approval
under the exact approver rule; silence is blocking.

## External attempt and evidence ledger

Execute each controlled action through `verification-before-completion`. Record stable
attempt ID, release-input ID, row/member ID, command/tool and environment/data
identities, start/end, terminal state, raw-output identity/location, and complete
pre/post effects. Shared or production mutation needs exact direct authority;
otherwise use an isolated representative copy or block.

A failure, deadline, cancellation, or lost response remains
`cancellation-requested` until worker, descendants, and effects are quiescent.
Quarantine partial/late outputs and link any retry; never retry an unknown
non-idempotent outcome before reconciling actual state. Only terminal successful
build attempts enter the frozen artifact set. A later rebuild creates a new
artifact-set identity and invalidates all evidence bound to the old set.

- **Release artifact set/digests/locations:** `{{identity for every member}}`
- **Build/provenance/dependency inventory:** `{{artifacts and digests}}`
- **Terminal evidence identity:** `{{digest of complete expected rows, attempts,
  raw-result identities, prior-stage evidence and accepted deviations}}`

## Readiness rows

| Row ID/source | Area | Required gate/action | Artifact/environment/cell | Evidence and age | Owner | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `{{stable ID and contract/version}}` | `{{artifact/parity/security/performance/differential/recovery/rollout/package}}` | `{{gate ID or controlled action}}` | `{{exact identity}}` | `{{raw result}}` | `{{owner}}` | `pass/fail/pending/inconclusive/N/A with approved disposition` |

## Rollout and recovery

- **Telemetry/baselines:** `{{signals and normal ranges}}`
- **Rollout policy sources:** `{{assurance/migration/release-policy versions and IDs}}`
- **Canary/stages and soak:** `{{referenced cohorts, duration, expansion authority}}`
- **Abort thresholds/actions:** `{{referenced conditions and authority}}`
- **Rollback artifact/digest:** `{{known-good immutable identity}}`
- **Data/config/queue restoration:** `{{retained artifacts and order}}`
- **RPO/RTO and observed drill:** `{{required vs measured evidence}}`
- **Post-restore gate:** `{{action and raw result}}`

## Deviations

| Deviation | Consequence | Compensating gate | Owner | Expiry/revisit | Rollback trigger | Approval receipts |
| --- | --- | --- | --- | --- | --- | --- |
| `{{ID}}` | `{{impact}}` | `{{gate}}` | `{{owner}}` | `{{condition}}` | `{{threshold}}` | `{{trusted receipts bound to release input, deviation and artifact set}}` |

## Verdict

- **Status:** `ready for {{promotion}} / ready with accepted deviations / not ready / inconclusive`
- **Release-input identity:** `{{exact current descriptor identity}}`
- **Artifact-set identity:** `{{digests}}`
- **Terminal-evidence identity:** `{{exact complete ledger identity}}`
- **Evidence cutoff:** `{{timestamp and freshness rule}}`
- **Blockers:** `{{none or exact rows}}`
- **Verdict identity:** `{{digest over release input, artifact set, terminal
  evidence, approval receipts and freshness snapshot, excluding this slot and
  any later release decision/action}}`
- **Decision:** `{{direct answer from the required approver set bound to this
  verdict identity, separate from deploy/publish action; refresh after any drift}}`
```
