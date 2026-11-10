# Scalable transformation plan extension

Use this only when an approved migration contract and assurance matrix describe
a high-risk or many-shard transformation. Those artifacts own preservation,
translation, thresholds, cadence, and failure policy. The plan references their
exact versions and turns them into executable work; it does not restate or
weaken them.
The normative plan declares queue derivation, schemas, state graphs, and policy;
append-only external execution ledgers own attempts, leases, progress, and results.

If an entry gate is `planned`, create a prerequisite task that makes that gate
executable and falsifies it. Gate-enabling work cannot claim or transform target
shards. The trial or target phase remains blocked until the real entry result
passes.

## Extend the index

Record:

- migration contract and assurance matrix versions;
- stable inventory source, item identity, digest, and raw count;
- source freeze/change-intake policy, queue identity/count, maximum lag, and
  rebaseline trigger;
- mutable-state snapshot/high-water mark, capture or dual-write task, ordering/
  idempotency rules, reconciliation gate, maximum lag, and cutover authority;
- role separation plus attempt/lease heartbeat, expiry, quiescence, reclaim,
  quarantine, and ownership-transfer rule;
- phase concurrency plus per-worker and aggregate CPU, memory, temporary
  storage, process/descriptor, socket/network, time, and cost envelopes,
  operating reserve, enforceable limits, monitoring, kill, and exact cleanup
  targets/effects/recoverability, authority, and disposition;
- a trial phase before fleet expansion;
- phase, queue, cutover, rollback, and decommission task links;
- predeclared external shard, source-change, live-state, and decommission ledgers;
- every requirement and risk-gate ID mapped to a task or phase.

Put the phase table in the index under a `## Phases` heading (`## Shards` or
`## Phase queues` for those): `scripts/plan-version.sh --verify` prints
`phases_or_shards=yes` only from one of these headings, and the mode question
and both executors read that line.

| Phase | Scope/inventory | Entry gates | Exit gates | Resource/concurrency envelope | Pause/abort | Expansion authority | Recovery target |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `trial` | `{{representative shards}}` | `{{gate IDs}}` | `{{gate IDs/thresholds}}` | `{{per-worker + aggregate limits/reserve}}` | `{{contract IDs}}` | `{{owner}}` | `{{target}}` |

No phase starts from an aggregate “green.” Its required gate evidence must match
the current revision, environment, platform/build cells, and maximum age.

## Define the queue

For thousands of homogeneous items, keep one shard task contract plus a
machine-derived queue—not thousands of copied markdown files. Record:

- the command/action deriving the inventory and queue;
- the action deriving every post-baseline source change and its affected
  facts/shards exactly once;
- the action reconciling every post-snapshot data/work change without gaps,
  duplicates, or ordering loss;
- stable shard and attempt identity; exclusive owner/lease with heartbeat,
  expiry, release/reclaim authority, old-writer quiescence, and partial-output quarantine;
- allowed states and ownership-transfer history;
- dependency and collision detection;
- resource class, maximum concurrency, aggregate reserve, measurement source,
  enforcement, monitor, stop/kill, and cleanup evidence;
- raw reconciliation invariant across queued, claimed, transformed, failed,
  verified, reopened, and intentionally skipped states;
- exact skip disposition: approved exclusion/deviation version, owner, evidence,
  expiry/revisit, and compensating gate; otherwise the skip blocks;
- per-shard evidence locations keyed to assurance gate IDs.

A summary percentage never replaces raw reconciled counts. Missing, duplicate,
unowned, or multiply owned shards stop the phase.

## Extend each phase or shard contract

- **Phase and shard selection:** `{{stable IDs/query and input digest}}`
- **Source baseline/intake:** `{{revision, change-queue digest, maximum lag}}`
- **Source terminal dispositions:** `{{applied and verified / source reverted or
  absent / approved deviation; generic rejection is blocking}}`
- **Live-state catch-up:** `{{watermark, capture range/digest, exact terminal
  dispositions, lag, reconciliation gate}}`
- **Exclusive owner:** `{{attempt, owner, lease/heartbeat/expiry, reclaim rule}}`
- **Entry gate references:** `{{assurance IDs and required freshness}}`
- **Produces:** `{{outputs, mapping evidence, retained artifacts}}`
- **Evaluator:** `{{gate IDs plus exact invocation from the matrix}}`
- **Failure classification:** `{{queue class and raw evidence}}`
- **Resource envelope:** `{{per-worker/aggregate limits, reserve, monitor,
  stop/kill, cleanup, time and cost}}`
- **State transition:** `{{allowed prior state → next state}}`

Repeated instances of one failure class pause the contract-defined scope. Update
the shared translation or execution rule once, derive the affected shard set,
reopen it, and re-audit before resuming; do not patch each shard independently.

## Make the endpoints executable

Create named tasks for trial evaluation, each phase promotion, cutover, rollback
drill, post-cutover verification, retained-artifact validation, and decommission
entry/action/post-action gates where the source contracts require them.
Irreversible actions remain behind separately named direct-authority boundaries.

Any normative change to requirements, interfaces, contract versions,
thresholds, phase boundaries, partition/ownership policy, pause/abort, cutover,
rollback, or decommission creates a successor with a stable-ID delta and needs
reapproval. Runtime attempt/lease transfers under that policy update only the
external execution ledger.
