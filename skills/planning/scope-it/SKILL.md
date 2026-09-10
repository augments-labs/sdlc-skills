---
name: scope-it
description: "Use after the goals are set and before design, to draw a project's boundary: what is in, what is explicitly out, and the smallest cut that still meets the goal. Fires on what goes in v1, what should we cut, and this is getting too big, even if nobody says scope. Skip a single feature, unresolved ambiguity about intent, and detailed feature requirements."
---

# Scope It

Scope is decided by what you say no to. An unbounded project never ships — name the boundary before anyone starts building.

## When to use

- After goals are approved—whether already present or produced by
  `define-goals`—and before an unresolved project boundary is consumed.
- When scope is unclear or creeping mid-project.
- **Skip** for a single feature. Use `interview-me` only when its intent or
  boundary is ambiguous; `spec-it` owns its detailed requirements and non-goals.

## Step 1: Cut the scope

Open `assets/scope-section.md` now. Each step fills its section.

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
   reopen approval, who decides.

## Step 2: Write and present

1. Write the immutable `## Scope` section to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it.
2. Present and end the turn:

   ```text
   Scope {{path}} — version {{identity}}
   In: {{n}} capabilities  Out: {{n}}  MVP: {{one line}}  Assumptions: {{n}} owned

   1. Approve this boundary
   2. Request a scope change
   3. Reject the cut
   4. Cancel

   Recommendation: {{thinnest answer that reaches the goal}} — {{one sentence}}.
   ```

3. Only option 1 hands off. Praise, constraints, silence, a partial reply →
   pending. Record lifecycle externally. Normative change → a replacement;
   an approved successor invalidates stale downstream bindings until owners
   revalidate. Never edit an issued identity.
4. **REQUIRED SUB-SKILL:** on option 1, invoke `spec-it` when detailed
   requirements are the next missing input. Never impose a phase already
   complete.

## Common mistakes

- No explicit out-of-scope list — then everything is in scope, and nothing ships.
- Scoping to what's interesting to build rather than what the goal needs.
- Hiding a large dependency as a one-word "assumption".
- Calling compatibility, rollback, accessibility, security, or data preservation
  “out of scope” to make the cut look smaller.
