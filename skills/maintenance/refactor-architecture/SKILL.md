---
name: refactor-architecture
description: "Use when the structure of existing code is what makes change expensive and that structure itself needs redesigning — tangled boundaries, logic in the wrong layer, one small change touching many files. Fires on this codebase is a mess, everything imports everything, and every feature makes the next one slower, even if nobody says refactor or architecture. Skip designing a new system, quick local cleanups, and read-only audits."
---

# Refactor Architecture

Improve the structure of code that already exists. The goal is **deep modules** — a lot of behaviour behind a small interface — and **locality**, so a change lives in one place. This is maintenance; for designing new structure, use `system-architecture`. The vocabulary these steps lean on — module, interface, depth, seam, adapter, leverage, and the deletion test — is defined in `references/vocabulary.md`.

## When to use

- An existing codebase has friction: a change bounces you across many files, modules are thin wrappers, tests couple to internals, seams leak.
- **Skip** for greenfield design (`system-architecture`) or a one-off local fix.

## Step 1: Classify and measure

1. Classify: bounded, reviewable structural refactor → stay here. High risk
   by preservation breadth or failure surfaces → wait for an approved,
   current migration and assurance contract and passed entry gates. An
   authorized prerequisite consumes only its exact proposed contract; it
   cannot edit the target, approve the contract, or satisfy entry.
2. Pin the exact source revision, the contracts it must honour, the external
   inputs it consumes.
3. Inventory the surface and the friction with stable IDs. Trace callers,
   behavior, performance and resource profile, compatibility surface.
   Unmeasured friction is a preference.
4. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for the
   preservation cycle: baseline green, deliberate divergence red, exact
   restoration green. Compile-only or target-derived oracle → insufficient.

## Step 2: Decide the structure

1. Deletion test per suspect module: removal spreads complexity to callers →
   keep; complexity merely relocates → collapse.
2. Seam only for repeated behavior with a stable owner and measured change
   friction, or one real volatile or external boundary with measured
   impedance, failure policy, or test isolation. Never for count or
   hypothetical variation.
3. Fill `assets/structural-proposal.md`: distinct structures compared,
   removals and where their invariants now live, slice table, approver rule.
   Decision outcome and slice progress stay outside it.
4. Hard-to-reverse choice → invoke `architecture-decisions`.
5. Present and end the turn. Never self-select a material structure:

   ```text
   Structural proposal {{identity}}
   Friction: {{measured, one line}}  Target: {{one line}}
   Alternatives: {{list}}  Slices: {{n}}  Rollback: {{one line}}

   1. Approve under the preservation gate
   2. Request changes
   3. Reject and retain the current structure
   4. Cancel

   Recommendation: {{option the friction and recovery evidence support}} — {{one sentence}}.
   ```

6. Input or normative drift → an approved successor; affected slices invalid.

## Step 3: Transform under preservation

1. Only after exact scope and decision authority: **REQUIRED SUB-SKILLS:**
   invoke `test-driven-development` and `yagni`. Multi-step slices → invoke
   `writing-plans`, then `executing-plans`.
2. Per slice: migrate its callers, run the bound and project gates, compare
   accepted floors, retain the known-green state. Checkpoint under
   `using-git-worktrees`.
3. Behavior delta → stop. Return to its requirement or new-behavior cycle.
4. Before removing a surface, inventory every path that could still reach it:
   static calls, dynamic registration, reflection, configuration, generated
   inputs, tests, external consumers. Unsure → it stays, or waits for a
   completed deprecation and migration.
5. Map every invariant the surface carried to surviving coverage. Falsify
   that surviving gate. Keep the rollback recoverable until integration.

## Common mistakes

- Refactoring for tidiness, not leverage — change structure only where it cuts real friction.
- Adding a port for hypothetical variation with no real impedance or volatility.
- Removing old tests because the new suite is green without mapping the
  invariants and falsifying the surviving gate.
- Combining so many structural moves that behavior, performance, compatibility,
  or rollback can no longer be attributed to one slice.
