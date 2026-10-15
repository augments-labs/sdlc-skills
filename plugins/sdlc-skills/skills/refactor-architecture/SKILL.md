---
name: refactor-architecture
description: "Redesigns the structure of existing code when that structure makes change expensive: tangled boundaries, logic in the wrong layer, one small change touching many files. Use when the structure of existing code is what makes change expensive and needs redesigning, or when the user says this codebase is a mess, everything imports everything, or every feature makes the next one slower. Skip designing a new system, quick local cleanups, and read-only audits."
---

# Refactor Architecture

Improve the structure of code that already exists. The goal is **deep
modules**, a lot of behaviour behind a small interface, and **locality**, so
a change lives in one place. Read `references/vocabulary.md` when a term
below reads unfamiliar; it defines the words these steps lean on: module,
interface, depth, seam, adapter, leverage, and the deletion test.

## When to use

- An existing codebase has friction: a change bounces you across many files,
  modules are thin wrappers, tests couple to internals, seams leak.
- **Skip** for greenfield design (`system-architecture`) or a one-off local
  fix.

## Step 1: Classify and measure

1. Fill the classification block (the structural proposal's **High-risk
   classification** section). If all four answers are on the ordinary route,
   stay here. If any answer is not, wait for an approved, current migration
   and assurance contract and for the entry gates to pass. Work authorized as a
   prerequisite takes in only its exact proposed contract; it cannot edit
   the target, approve the contract, or satisfy entry.
2. Pin down the exact source revision, the contracts it must honour, and the
   external inputs it consumes.
3. Inventory the surface and the friction, giving each item a stable ID.
   Trace callers, behavior, the performance and resource profile, and the
   compatibility surface. Friction that has not been measured is a
   preference.
4. **REQUIRED SUB-SKILLS:** invoke `using-git-worktrees`, then
   `test-driven-development` for the preservation cycle in that workspace:
   the baseline green, a deliberate divergence red, the exact restoration
   green. An oracle that is compile-only or derived from the target is not
   enough.

## Step 2: Decide the structure

1. Run the deletion test on each suspect module. If removing it would spread
   complexity to its callers, keep it. If the complexity would merely
   relocate, collapse it.
2. Add a seam only for repeated behavior with a stable owner and measured
   change friction, or for one real volatile or external boundary with
   measured impedance, failure policy, or test isolation. Never add one for
   implementation count or for hypothetical variation.
3. Fill `assets/structural-proposal.md` before presenting it: the distinct
   structures compared, the removals and where their invariants now live,
   the slice table, and the approver rule. The decision outcome and the
   slice progress stay outside it.
4. If a choice is hard to reverse, invoke `architecture-decisions`.
5. Present the proposal. Never pick the structure yourself:

   ```text
   Structural proposal {{identity (per template)}}
   Friction: {{measured, one line}}  Target: {{one line}}
   Alternatives: {{list}}  Slices: {{n}}  Rollback: {{one line}}

   1. Approve under the preservation gate
   2. Request changes
   3. Reject and retain the current structure
   4. Cancel

   Recommendation: {{option the friction and recovery evidence support}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
6. If the inputs drift, or what was approved changes, that needs an approved
   successor, and the slices it affects are invalid.

## Step 3: Transform under preservation

1. Only after the exact scope and the decision authority are in place,
   **REQUIRED SUB-SKILLS:** invoke `test-driven-development` and `yagni`. If
   the slices take more than one step, invoke `writing-plans`; its mode
   answer names the executor.
2. For each slice: migrate its callers, run the bound gate and the project
   gate (the checks its row of the slice table names), compare against the
   accepted floors, and retain the known-green state. Checkpoint under
   `using-git-worktrees`.
3. If a behavior delta appears, stop. Return to its requirement or to a
   new-behavior cycle.
4. Before removing a surface, inventory every path that could still reach
   it: static calls, dynamic registration, reflection, configuration,
   generated inputs, tests, and external consumers. If unsure, it stays, or
   waits for a completed deprecation and migration.
5. Map every invariant the surface carried to the coverage that survives.
   Falsify that surviving gate. Keep the rollback recoverable until
   integration.

## Gotchas

- A surface with zero static callers can still be reached through dynamic
  registration, reflection, or a generated config — a plain call-site search
  finds none of those and reads as proof the surface is dead when it is only
  unproven.
- The deletion test's "removal spreads complexity to callers" branch is only
  as good as the caller trace behind it: run it against a guessed caller set
  and a genuinely load-bearing module reads as a thin wrapper worth
  collapsing.

## Common mistakes

- Refactoring for tidiness, not leverage: change structure only where it
  cuts real friction.
- Combining so many structural moves that behavior, performance,
  compatibility, or rollback can no longer be attributed to one slice.
