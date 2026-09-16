# Executing phase and shard queues

Use this only for a plan created with the scalable transformation extension.
The approved migration contract owns partitions, pause/abort, cutover, rollback,
and decommission policy. The approved assurance matrix owns gates, thresholds, cadence,
environments, and failure response. Execution consumes their exact versions and
records append-only state in the predeclared external ledgers; it does not
rewrite normative contracts or improvise replacements.

Every packet a phase dispatches is a controlled one: beside the slim packet,
fill the controlled fields `dispatching-parallel-agents` ships as
dispatch-packet-controlled.md, so workspace, sharing, checkpoints, routing, stop
conditions, isolation, data, capacity, sub-dispatch, and terminal control are
bound before a shard is claimed.

## Enter a phase

Before claiming work:

1. Match plan approval/version and the referenced migration and assurance
   versions.
2. Run every phase-entry gate and confirm evidence revision, environment,
   platform/build cells, and freshness.
3. Derive raw shard, post-baseline source-change, and mutable-state catch-up
   queues through declared actions; join their external-ledger identities,
   digests, and reconciled counts to the exact plan/migration versions.
4. Confirm every shard has one stable identity, one current attempt, one
   unexpired exclusive owner/lease with heartbeat, valid dependencies, and one state.
5. Confirm measured per-worker demand, aggregate host capacity and operating
   reserve, maximum concurrency, enforceable limits, monitoring, time/cost
   ceiling, kill procedure, exact cleanup targets/effects/recoverability,
   cleanup authority, and disposition match the approved phase envelope.

Any mismatch, missing shard, duplicate, owner collision, stale gate, unknown
capacity, or unenforceable required isolation blocks entry.

## Advance a shard

Use only declared, append-only transitions:

`queued → claimed → transformed → verified`

`failed`, `reopened`, and `intentionally skipped` remain accounted states. A skip
requires its approved exclusion/deviation version, owner, evidence, expiry/
revisit, and compensating gate; otherwise it blocks. Record base/result, owner,
input, attempt/lease, artifacts, exact gates, raw outputs, and timestamps. The
coordinator independently inspects them before `verified`; prose cannot advance state.

An expired or released lease does not make a second writer safe. Under the
current named stop/reap authority, stop and reap
the old writer and children, preserve and quarantine its partial result, record
the terminal attempt state, then let the named reclaim authority issue a new
attempt/lease from the immutable input. A late old result is rejected.

Reconcile raw counts after every batch. The stable total equals the sum of all
exclusive states, identities remain unique, and state history never moves
backward except through an explicit `reopened` event. Every new source change
appears exactly once and reopens each affected verified shard until reverified;
every post-baseline source change ends applied-and-verified, source-reverted/
absent with exact evidence, or approved deviation. Every post-snapshot data/work
change ends applied once and reconciled, reversed/absent with source evidence, or
an owning-contract-approved rejection/deviation. Generic rejection blocks.

## Protect execution capacity

Observe actual CPU, memory, temporary storage, processes/descriptors,
sockets/network, time, and cost at the declared cadence. Compare per-worker and
aggregate use with limits and operating reserve. Stop claiming new shards,
terminate through the approved kill path, and reap child processes and temporary
state before exhaustion. Reduce concurrency or sequence work when isolation
cannot be enforced; a fast queue that destabilizes its host is not converging.

Resource-limit or cleanup failures enter the raw failure queue. Repeated classes
pause the contract-defined scope and follow the shared-rule repair below.

## Learn from repeated failures

Classify failures from raw evidence. When a migration- or assurance-defined
threshold is met:

1. pause the affected phase or fleet;
2. preserve every failing input and result;
3. correct the shared translation, generator, or execution rule once;
4. create a successor for any normative owning-contract/plan change and obtain
   required review/approval;
5. derive all previously and currently affected shards;
6. reopen and re-audit that set under the corrected rule;
7. re-run phase-entry gates before the named resume authority continues.

Do not let separate workers patch symptoms independently or reset failed items
to queued without history.

## Promote or resume

Phase exit uses raw reconciled counts plus every required current assurance
result; aggregate green cannot hide failed, generically skipped, unowned, or
untested cells. An intentional skip counts only with its complete approved
disposition and compensating evidence.
On resume, refresh plan/contract versions, approval, workspace/base/HEAD, shard,
source-change, and live-state queue digests, leases, lag, failure classes, and
evidence freshness before any claim.

Cutover, rollback, and decommission tasks execute only at named authority
boundaries and exact targets. Decommission records every transition externally;
`partial`, `failed`, `executed awaiting validation`, or `validation failed`
blocks release/cleanup until recovered, rolled back, or freshly authorized
remaining work reaches verified post-action evidence.
