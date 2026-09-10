---
name: prototyping
description: "Use when a design or feasibility question is genuinely uncertain and cheaper to answer by building a throwaway than by arguing about it — a tricky bit of logic, a layout choice, a library's real behaviour. Fires on let's just try it and see, spike this, and quick and dirty, I'll throw it away, even if nobody says prototype. Skip when you already know the answer."
---

# Prototyping

A prototype answers one question and dies. Its only job is to turn an uncertainty into a fact cheaply — the code is disposable; the *answer* is what you keep.

## When to use

- A specific question is uncertain and faster to *build* than to argue: does this algorithm work, does this layout read, does this library do what its docs claim.
- Reached from `feasibility-check` (a killer risk) or `ui-ux-design` (a layout choice).
- **Skip** when you already know the answer, or the question is vague — a prototype that answers the wrong question is pure waste.

## Step 1: Pre-register

1. Write one question, the falsifiable pass/fail observation, the time-box
   and size-box, and what decision each result changes. Vague → do not build.
2. Name the workspace and artifacts this probe owns, its environment, the
   data class it touches. Prefer isolated synthetic data.
3. Bind disposal before building: allowed access and effects, evidence
   retention, exact cleanup targets and their recoverability, cleanup owner,
   current authority for creating and removing.
4. Production-like data, real services, live traffic, running systems,
   destructive cleanup → explicit authorization each, protections
   proportional to risk.

## Step 2: Build and observe

1. Build the smallest disposable probe: driver, fixtures, instrumentation
   only. No reusable abstraction, production integration, or generality.
2. Logic → a tiny driver or executable assertion on the uncertain behavior.
   UI → only the structurally different populated variants the registered
   question needs.
3. Stop at the declared boundary. Record raw observations, environment,
   limitations, and `passed / failed / inconclusive` against the predeclared
   criterion. Never move the threshold after seeing the result.

## Step 3: Retain the result, dispose of the code

1. Store question, evidence, and decision durably. Load-bearing choice
   settled → invoke `architecture-decisions`.
2. Rebuild accepted behavior in the real code under its normal tests, review,
   and verification gates. Never lift prototype code.
3. Remove only pre-registered scratch artifacts inside the disposable
   boundary, under current authority for those exact targets. Repository
   branch, worktree, ref, or workspace disposal → `finishing-a-branch`.
   External or destructive cleanup → its own current scoped choice.
   Otherwise preserve and report cleanup pending.
4. Never delete pre-existing, shared, user-owned, or ownership-uncertain
   state.

## Common mistakes

- No written question — you can't tell when you're done, and the code becomes "real" by accident.
- Building production-grade tests or generality instead of the smallest
  executable observation.
- Variants that differ only in colour — that's a tweak, not an answer.
- Quietly probing a real service or sensitive data because “it is only a spike.”
- Keeping or copying the prototype “as a base” — rebuild the learned behavior
  under the product's real gates.
