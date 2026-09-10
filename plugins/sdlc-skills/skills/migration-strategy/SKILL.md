---
name: migration-strategy
description: "Use before planning or implementing a high-risk rewrite, migration, generated conversion, or wide behavior-preserving transformation — one whose output cannot be reviewed line by line, crosses ownership boundaries, or can fail at the platform, build, runtime, data, or cutover layer. Fires on port this to X, move us off Y, and regenerate this from Z, even if nobody says migration. Skip bounded changes."
---

# Migration Strategy

Write the contract under which a trusted source becomes the intended target
without losing behavior, data, control, or recoverability, and get it approved
before any target work starts.

## When to use

- The transformation is too broad, partitioned, preservation-heavy, or operationally risky for ordinary feature planning and line-by-line review.
- Classify before implementing, on risk evidence rather than line count.
  Answer four questions: can independent humans or gates inspect the result
  (**reviewability**); must behavior, compatibility, data, or operations match
  (**preservation**); how many owners, consumers, platforms, or modes change
  (**breadth**); can data, security, concurrency, resources, cutover, or
  recovery fail independently (**failure surfaces**)? If the ordinary route
  cannot make those surfaces reviewable and recoverable, hold target work
  until this contract is approved and `verification-strategy`'s entry gates
  have passed. Record uncertainty as pending classification; reclassify when
  inputs change.
- **Skip** for a bounded change whose behavior and diff remain directly reviewable — bounded reviewable work stays on its ordinary route.
- Write source facts and transition strategy here. Send target shape to
  `system-architecture`, proof to `verification-strategy`, and tasks to
  `writing-plans`.

## Step 1: Establish the ground truth

Open `assets/migration-contract.md` now. Each step fills the section it names.

1. Fill `Normative control`: source and target revisions, scope, one
   accountable owner or approval rule. Unsettled target → back to
   `system-architecture` first.
2. Fill `Source-fact inventory` from observable behavior and contracts, not
   from the source's structure: behavior, contracts, durable data, consumers,
   platforms and build modes, operational obligations, known deviations.
3. Classify every fact in `Preservation and deviation contract` or `Unknown
   contract`: preserved invariant, intentional deviation, or unknown.
4. Each deviation: attach the approved requirement or decision that owns it.
   A newly discovered choice goes back to that owner, never settled here.
5. Each unknown: blocked until proved irrelevant or approved with a
   compensating gate.

## Step 2: Design the transition

1. Fill `Transition and translation`: incremental, cutover, or hybrid;
   translation rules; legal intermediate and mixed-version states;
   compatibility direction; behavior of unmapped or invalid input.
2. Fill `Representative trial slice`: riskiest paths at useful scale over a
   stable coverage inventory; a disposition for every excluded cell; outcome,
   expansion decision, failure response. Commands and thresholds belong to
   the assurance matrix.
3. Fill `Partitions and ownership`: a stable shard inventory and ownership
   rules. Attempts, owners, heartbeats, transfers, and results go to an
   append-only external ledger, never into the contract.

## Step 3: Control what moves underneath you

1. Fill `Source evolution during migration`: freeze the source, or run one
   versioned change-intake contract and external queue. Every post-baseline
   change gets an identity and an exact terminal disposition.
2. Fill `Mutable live-state catch-up` wherever data or work keeps moving:
   boundary binding through maximum permitted lag and the owning gate. Every
   post-snapshot write lands in exactly one terminal disposition. "Probably
   applied" is unreconciled and blocks cutover.
3. Fill `Convergence and failure queue`: reconcile the external ledgers; every
   skip gets an approved disposition. Repeated failure *class* → pause the
   affected work, fix the shared rule, re-audit every impacted shard.
4. Fill `Pause, abort, cutover, and rollback`, `Retained artifacts`, and
   `Decommission and retained-source retirement` before anyone needs them:
   pause and abort, cutover authority, rollback target, point of no return,
   recovery time, fate of the retained source.
5. Enter decommission only when retention has elapsed, live use is provably
   zero, its gate passed, and its targets, authority, and recovery are
   written. A partial, failed, or validation-failed action there blocks
   release and cleanup.

## Step 4: Challenge, then decide

1. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` with two challenger
   roles before approval: one who knows the source and its domain, one who
   owns operations and data. They challenge fact completeness, mappings and
   mixed states, intake path and partitions, trial slice and recovery plan.
2. Record an accountable skip for any role left out. Bind each challenge to an
   exact attempt with a deadline. A required role without a current,
   successful, resolved report blocks approval.
3. Write the contract to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-migration.md`. Keep
   stable-ID delta, review, and execution state external.
4. Present the contract and stop:

   ```text
   Migration contract {{path}} — {{strategy}}
   Preserves: {{invariants}}. Trial: {{slice}}. Pause/abort/rollback: {{rules}}. Retirement: {{plan}}.

   1. Approve this exact version for planning
   2. Request changes
   3. Reject the strategy
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

5. Only an approved exact version, with predecessor-bound consumers
   reconciled, proceeds to `writing-plans`. Praise and silence decide nothing.
   Every normative change is a proposed successor.

## Common mistakes

- Calling the current implementation the contract instead of observable facts.
- Hiding or approving behavior changes only inside the migration contract.
- Parallelizing files without exclusive ownership, stable inventory, or
  convergence accounting.
- Letting source fixes land outside a reconciled freeze or change-intake queue.
- Defining rollback after irreversible cutover, or treating cutover as decommission authority.
- Putting target architecture or test commands here instead of handing them off.
