---
name: prototyping
description: "Builds a throwaway prototype to answer an uncertain design or feasibility question faster than arguing about it. Use when the user says let's just try it and see, spike this, or quick and dirty, I'll throw it away, or when a tricky bit of logic, a layout choice, or a library's real behaviour is genuinely uncertain and cheaper to settle with a throwaway. Skip when the answer is already known."
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

1. Store the question, evidence, limitations and decision consequences. With a
   pending caller → return them for its artifact's ledger (append-only,
   outside that artifact). With none → write
   them to `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/prototype.md` unless
   the user names another path. A settled load-bearing choice with no pending
   caller → **REQUIRED SUB-SKILL:** invoke `architecture-decisions` and apply
   its entry conditions.
2. Return observations to the caller's pending decision. A UI experiment informs
   `ui-ux-design`; it does not select the product direction or authorize its
   implementation. Before scratch cleanup, retain any frame or artifact the
   approved design binds as immutable evidence. Product implementation, when
   authorized, rebuilds behavior under its normal gates; never lift prototype code.
3. Remove only pre-registered scratch artifacts inside the disposable
   boundary, under current authority for those exact targets. Repository
   branch, worktree, ref, or workspace disposal → `finishing-a-branch`.
   External or destructive cleanup → its own current scoped choice.
   Otherwise preserve and report cleanup pending.
4. Never delete pre-existing, shared, user-owned, or ownership-uncertain
   state.

## Gotchas

- A prototype's answer kept only in the conversation dies with the session, and
  the settled question gets argued again.
- A probe that wrote outside its registered scratch targets leaves those writes
  behind when cleanup removes only the registered ones.
