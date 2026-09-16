---
name: scoping
description: "Defines a project's delivery boundary: what is in, what is out, and what is sufficient for the goal. Use when a project's goals are set and its scope needs defining or revising, including scope growth during delivery. Skip single-feature requirements, unresolved intent, and speculative additions at the implementation level."
---

# Scoping

Scope is decided by what you say no to. An unbounded project never ships — name the boundary before anyone starts building.

## When to use

- After goals are approved—whether already present or produced by
  `define-goals`—and before an unresolved project boundary is consumed.
- When scope is unclear or creeping mid-project.
- **Skip** for a single feature. Use `clarifying-intent` only when its intent or
  boundary is ambiguous; `writing-specs` owns its detailed requirements and non-goals.

## Step 1: Cut the scope

Open `assets/scope-section.md` before starting; each step fills its section.

1. Carry the non-negotiables first: goal guardrails, existing contracts,
   preserved behavior and data, security, accessibility, compatibility,
   operability, recovery. Constraints on every cut, never candidates to
   exclude.
2. In scope → the smallest capability set that reaches the approved outcome
   under those constraints.
3. Out of scope → each deferred capability with stable ID, rationale, goal
   impact, owner, revisit trigger. Never a preserved invariant or existing
   commitment.
4. MVP → the thinnest version meeting the goal and every non-negotiable.
   Smaller but unsafe or incompatible → not an MVP.
5. Per assumption and dependency: validation action, owner, expiry or
   decision point. A hidden project inside "assumes X" is scope.
6. Write the change rules: observations that abort this cut, changes that
   reopen approval, who decides. Solo owner — the user is the only
   stakeholder → they decide, and no approver matrix is recorded.

## Step 2: Write and present

1. Write the immutable `## Scope` section to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it.
2. Present:

   ```text
   Scope {{path}} — version {{identity (per template)}}
   In: {{n}} capabilities  Out: {{n}}  MVP: {{one line}}  Assumptions: {{n}} owned

   1. Approve this boundary
   2. Request a scope change
   3. Reject the cut
   4. Cancel

   Recommendation: {{thinnest answer that reaches the goal}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `clarifying-intent` owns what closes it.
3. **REQUIRED SUB-SKILL:** on option 1, invoke `writing-specs` when detailed
   requirements are the next missing input. Never impose a phase already
   complete.

## Gotchas

- A deferred capability's stable ID reused for a different item in a later
  rescoping pass makes an old reference to that ID — a linked task, a
  review note — silently point at the wrong decision. IDs retire; they
  don't get reissued.
- An assumption recorded with a validation action but no expiry or decision
  point reads as settled forever. Nothing then re-checks it once whatever
  it depended on changes underneath it.

## Common mistakes

- No explicit out-of-scope list — then everything is in scope, and nothing ships.
- Scoping to what's interesting to build rather than what the goal needs.
- Hiding a large dependency as a one-word "assumption".
- Calling compatibility, rollback, accessibility, security, or data preservation
  “out of scope” to make the cut look smaller.
