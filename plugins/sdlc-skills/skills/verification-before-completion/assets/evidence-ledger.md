# Completion evidence ledger

Create one row per required gate or controlled action in a predeclared external
user/project-approved location or return it directly. Never place mutable
evidence in an immutable plan/review artifact or frozen candidate; a deliberate
repository evidence record is a separately verified/reviewed successor candidate.

## Claim

- **Claim/transition:** `{{exact statement being evaluated}}`
- **Candidate/source tree:** `{{revision or working-tree digest}}`
- **Base and HEAD:** `{{immutable identities}}`
- **Artifact:** `{{path/ID and digest, or N/A}}`
- **Required gate source:** `{{task/plan/assurance version}}`
- **Evidence controls:** `{{data class, access/storage/egress authority,
  integrity/digest, retention/expiry, exact cleanup targets/effects/
  recoverability, cleanup authority, and disposition}}`

## State

- **Repository/workspace and cwd:** `{{identities}}`
- **Workspace inventory:** `{{staged/unstaged/untracked/relevant ignored paths,
  generated inputs, and digest/list reference}}`
- **External gate inputs:** `{{controlled identities/digests; never secret values}}`
- **Environment/configuration:** `{{non-secret identity}}`
- **Platform/architecture/runtime:** `{{matrix cell}}`
- **Build mode/features/packaging:** `{{matrix cell}}`
- **Dependencies/generated inputs:** `{{lock/digest/version identities}}`
- **Controlled pre/post state:** `{{candidate, data, processes, external effects,
  mutation delta, restoration/recovery evidence, and residue}}`

## Development-cycle evidence

- **New behavior:** `{{RED candidate/test/evaluator identity, discovery,
  intended failure, unchanged-judge GREEN, or N/A}}`
- **Preservation:** `{{source GREEN, gate/corpus identity, authorized deliberate
  divergence RED, complete restoration comparison/GREEN, transformed GREEN}}`

## Results

| Gate/attempt ID | Exact command/action and effect authority | Time/operator | Exit/status/counts and terminal quiescence | Threshold | Raw output/artifact | Evidence age | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `{{G-001}}` | `{{invocation}}` | `{{timestamp/actor}}` | `{{exit + pass/fail/skip}}` | `{{required vs actual}}` | `{{location/digest}}` | `{{fresh/stale}}` | `pass/fail/pending/inconclusive` |

## Inventory reconciliation

- **Required suites/cases/corpora/shards/cells:** `{{source and digest}}`
- **Shard attempts/leases/results:** `{{one accepted result plus all attempt states}}`
- **Source-change/live-state queues:** `{{digests, counts, lag, reconciliation}}`
- **Observed execution inventory:** `{{source and digest}}`
- **Added/changed/skipped/quarantined/deleted:** `{{derived delta; each skip/
  quarantine binds approved exclusion/deviation version, owner, evidence,
  expiry/revisit, and compensating gate; otherwise blocking}}`
- **Missing/duplicate/empty work:** `{{none or blocking list}}`
- **Plan terminal states/concerns:** `{{every done-with-concerns, cancelled, or
  superseded item and its owning non-blocking/deviation decision; unresolved blocks}}`

## Invalidation

List source, test, configuration, dependency, generated artifact, environment,
integration, contract, threshold, or evidence-age changes that force each row to
run again. Do not delete stale or failing evidence; mark it superseded and link
the replacement.

## Supported conclusion

`{{exact claim supported, or explicit failing/pending statement}}`

Separate fields record:

- verification state;
- independent review candidate/verdict;
- branch integration state;
- release-readiness state.

One cannot be inferred from another.
