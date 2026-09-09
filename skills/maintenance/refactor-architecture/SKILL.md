---
name: refactor-architecture
description: "Use when the structure of existing code is what makes change expensive, and that structure itself needs redesigning — tangled boundaries, logic sitting in the wrong layer, one small change touching many files. Fires on this codebase is a mess, everything imports everything, and every feature makes the next one slower, even if nobody says refactor or architecture. Skip designing a new system, quick local cleanups, and read-only audits that change nothing."
---

# Refactor Architecture

Improve the structure of code that already exists. The goal is **deep modules** — a lot of behaviour behind a small interface — and **locality**, so a change lives in one place. This is maintenance; for designing new structure, use `system-architecture`. The vocabulary these steps lean on — module, interface, depth, seam, adapter, leverage, and the deletion test — is defined in `references/vocabulary.md`.

## When to use

- An existing codebase has friction: a change bounces you across many files, modules are thin wrappers, tests couple to internals, seams leak.
- **Skip** for greenfield design (`system-architecture`) or a one-off local fix.

## Procedure

1. **Classify the transformation.** A bounded, reviewable structural refactor
   stays here.

   If preservation breadth or the failure surfaces make it high risk, work on
   the target waits for an approved, current migration and assurance contract and
   for its entry gates to pass. A prerequisite you were directly authorized to
   build consumes only its exact proposed contract: it cannot edit the target,
   approve the contract, or satisfy entry on its own.

2. **Walk and measure the friction.** Pin what you are measuring against — the
   exact source revision, the contracts it must honour, and the external inputs
   it consumes. Inventory the surface and the friction with stable IDs, so a
   later slice can name what it changed.

   Trace the callers, the behavior, the performance and resource profile, and the
   compatibility surface. Friction you have not measured is a preference.
3. **Establish the preservation gate.** Use
   `test-driven-development`'s preservation cycle: accepted baseline green,
   deliberate representative divergence red, exact restoration green. A
   compile-only or target-derived oracle is insufficient.
4. **Apply the deletion test** to suspect modules. Keep a module if removal
   spreads complexity to callers; collapse it if complexity merely relocates.
5. **Find real seams.** Repeated behavior with a stable owner and measured change
   friction may justify substitution. One real volatile or external boundary
   can also justify a seam when it contains measured impedance, failure policy,
   or test isolation. Implementation count alone and hypothetical variation do
   not justify one.
6. **Present the structural decision.** Fill `assets/structural-proposal.md`: it
   carries the comparison of distinct structures, the removals and where their
   invariants now live, the slice table, and the approver rule. Its identity
   covers the proposal only — decision outcome and slice progress are recorded
   outside it, so tracking progress never rewrites the proposal.

   Never self-select a material structure. State the proposal identity, current
   measured friction, target, alternatives, slice count, and rollback. Ask one
   conversational question offering approve under the preservation gate,
   request changes, reject and retain the current structure, or cancel.
   Recommend the answer supported by the friction and recovery evidence, with
   one sentence of reasoning, then stop.

   Any input or normative drift requires an approved successor and invalidates
   affected slices. Hard-to-reverse choices use `architecture-decisions`.
7. **Transform under preservation.** Only after exact scope/decision authority,
   invoke `test-driven-development` paired with `yagni`; multi-step slices use
   `writing-plans`/`executing-plans`. Each stable slice migrates its callers,
   runs the bound and project gates, compares accepted floors, and retains the
   known-green state. Checkpoint each coherent slice under
   `using-git-worktrees`. A behavior delta stops and returns to its
   requirement/new-behavior cycle.
8. **Retire only proven redundancy.** Before removing a surface, inventory every
   path that could still reach it: static calls, dynamic registration,
   reflection, configuration, generated inputs, tests, and external consumers.
   A path you are unsure about keeps the surface alive, or waits for a completed
   deprecation and migration.

   Map every invariant the surface carried to the coverage that survives it,
   falsify that surviving gate so you know it can fail, and keep the rollback
   recoverable until integration.

## Common mistakes

- Refactoring for tidiness, not leverage — change structure only where it cuts real friction.
- Adding a port for hypothetical variation with no real impedance or volatility.
- Removing old tests because the new suite is green without mapping the
  invariants and falsifying the surviving gate.
- Combining so many structural moves that behavior, performance, compatibility,
  or rollback can no longer be attributed to one slice.
