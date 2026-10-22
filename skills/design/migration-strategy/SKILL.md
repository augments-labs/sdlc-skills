---
name: migration-strategy
description: "Plans how a rewrite or migration preserves behavior through cutover and recovery. Use when a rewrite, migration, or broad preservation-sensitive transformation is about to be planned or implemented and its behavior, cutover, or recovery cannot be established by ordinary review and gates. Skip bounded changes whose diff, behavior, and recovery remain directly reviewable."
---

# Migration Strategy

## When to use

- The transformation is too broad, too split into parts, too heavy in what it
  must preserve, or too risky operationally for ordinary feature planning and
  line-by-line review.
- Classify the change before implementing anything, from evidence of risk,
  not from the line count. Answer four questions: can independent people or
  checks inspect the result (**reviewability**); must behavior,
  compatibility, data, or operations match (**preservation**); how many
  owners, consumers, platforms, or modes change (**breadth**); can data,
  security, concurrency, resources, cutover, or recovery each fail on its own
  (**failure surfaces**)? If the ordinary route cannot make those surfaces
  reviewable and recoverable, hold work on the target until this contract
  is approved and `verification-strategy`'s entry gates have passed. If the
  answers are uncertain, record the change as pending classification.
  Classify it again whenever the inputs change.
- **Skip** a bounded change whose behavior and diff can still be reviewed
  directly; such work stays on its ordinary route.
- Write the facts about the source and the strategy for the transition here.
  Send the shape of the target to `system-architecture`, the proof to
  `verification-strategy`, and the tasks to `writing-plans`.

## Step 1: Establish the ground truth

Open `assets/migration-contract.md` before the steps below; each step fills
the section of it that the step names.

1. Fill `Normative control`: the source and target revisions, the scope, and
   one accountable owner or an approval rule. If the target is not settled,
   go back to `system-architecture` first.
2. Fill `Source-fact inventory` from observable behavior and contracts, not
   from how the source is built: behavior, contracts, durable data,
   consumers, platforms and build modes, operational obligations, known
   deviations.
3. Classify every fact, in `Preservation and deviation contract` or in
   `Unknown contract`, as one of: a preserved invariant, an intentional
   deviation, or an unknown.
4. For each deviation, attach the approved requirement or decision that owns
   it. A newly discovered choice goes back to that owner; never settle it
   here.
5. Each unknown blocks until it is proved irrelevant or approved with a
   compensating gate.

## Step 2: Design the transition

1. Fill `Transition and translation`: the approach (incremental, cutover, or
   hybrid); the translation rules; which intermediate and mixed-version
   states are allowed; the compatibility direction; and what happens to
   unmapped or invalid input.
2. Fill `Representative trial slice`: the riskiest paths at a useful scale,
   drawn from a stable coverage inventory; a recorded decision for every cell
   left out (the template's `Uncovered cells`); the outcome, the expansion
   decision, and the failure response. Commands and thresholds belong to the
   assurance matrix.
3. Fill `Partitions and ownership`: a stable inventory of shards and the
   rules for who owns each. Attempts, owners, heartbeats, transfers, and
   results go into a ledger (a record kept outside the contract: add to it,
   never rewrite it), never into the contract.

## Step 3: Control what moves underneath you

1. Fill `Source evolution during migration`: either freeze the source, or run
   one versioned change-intake contract and an external queue. Every source
   change after the baseline gets an identity and an exact terminal
   disposition, with its evidence.
2. Fill `Mutable live-state catch-up` wherever data or work keeps moving:
   from how the boundary is bound through to the maximum permitted lag and
   the gate that owns that limit. Every write after the snapshot lands in
   exactly one terminal disposition, with its evidence.
   "Probably applied" is not reconciled and blocks cutover.
3. Fill `Convergence and failure queue`: reconcile the external ledgers, and
   give every skip an approved recorded decision. If one *class* of failure
   repeats, pause the affected work, fix the shared rule, and re-audit every
   impacted shard.
4. Fill `Pause, abort, cutover, and rollback`, `Retained artifacts`, and
   `Decommission and retained-source retirement` before anyone needs them:
   when to pause and when to abort, who holds authority for cutover, the
   rollback target, the point of no return, the recovery time, and what
   becomes of the retained source.
5. Enter decommission only when the retention period has elapsed, live use is
   provably zero, its gate has passed, and its targets, authority, and
   recovery are written down. A decommission action that is partial, failed,
   or failed its validation blocks release and cleanup.

## Step 4: Write, challenge, then decide

1. Write the contract to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-migration.md`. Keep the
   review state, the decision state, and the execution state outside it.
   Compute its identity now, as the template says; the challengers bind to
   this path and this identity.
2. Fill `assets/migration-challenger.md` with that path and identity before
   approval, then dispatch two read-only challengers as
   `dispatching-parallel-agents` Step 2 says, bound to the contract's
   `Independent challenge contract`: one who knows the source and its domain,
   and one who owns operations and data. They challenge whether the facts are
   complete, the mappings and mixed states, the intake path and the
   partitions, and the trial slice and the recovery plan.
3. For any role left out, record an accountable skip; the template's
   `Independent challenge coverage` field says what one carries. Bind each
   challenge to one exact attempt with a deadline. A required role blocks
   approval until its current report on this contract identity reads
   `clear`.
4. Present the contract:

   ```text
   Migration contract {{path}} version {{identity (per template)}} — {{strategy}}
   Preserves: {{invariants}}. Trial: {{slice}}. Pause/abort/rollback: {{rules}}. Retirement: {{plan}}.

   1. Approve this exact version for planning
   2. Request changes
   3. Reject the strategy
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
5. Only an approved exact version, with the consumers bound to its
   predecessor reconciled, proceeds to `writing-plans`.

## Gotchas

- Code review judges the exact version under review against an approved
  contract. Before approval neither exists, so a challenge sent to code
  review has nothing to bind to and returns no verdict.
- The trial slice's coverage inventory (Step 2) is only as stable as the
  source is frozen or its changes are taken in under control (Step 3). A new
  consumer, platform, or path that lands in the middle of the migration
  silently turns a cell that already has its recorded decision into one
  nobody audited, so “every excluded cell has a recorded decision” can be
  true at the trial and false by cutover without either step's owner
  noticing.
- “Live use is provably zero” (Step 3) is usually checked against recent
  traffic, and a periodic consumer, a monthly batch job or an annual report,
  can pass that check while it is simply between runs. Decommissioning on that
  reading retires a source that a consumer from Step 1's inventory is still
  going to call.
