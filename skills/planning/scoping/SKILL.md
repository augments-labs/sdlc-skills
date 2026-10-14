---
name: scoping
description: "Defines a project's delivery boundary: what is in, what is out, and what is sufficient for the goal. Use when a project's goals are set and its scope needs defining or revising, including scope growth during delivery. Skip single-feature requirements, unresolved intent, and speculative additions at the implementation level."
---

# Scoping

Name the boundary before anyone starts building.

## When to use

- After the goals are approved, whether they were already present or
  `define-goals` produced them, and before a project boundary that is still
  unresolved is used as an input.
- When scope is unclear, or growing, part-way through a project.
- **Skip** for a single feature. Use `clarifying-intent` only when the
  feature's intent or boundary is ambiguous; `writing-specs` owns its detailed
  requirements and non-goals.

## Step 1: Cut the scope

Open `assets/scope-section.md` before starting; each step fills its section.

1. Carry the non-negotiables forward first: goal guardrails, existing
   contracts, preserved behavior and data, security, accessibility,
   compatibility, operability, recovery. They are constraints on every cut,
   never items up for exclusion.
2. Put in scope the smallest set of capabilities that reaches the approved
   outcome under those constraints.
3. Put out of scope each deferred capability, with a stable ID, the
   rationale, its impact on the goal, an owner, and the trigger for
   revisiting it. Never list a preserved invariant or an existing commitment
   there.
4. Write the MVP as the thinnest version that meets the goal and every
   non-negotiable. A version that is smaller but unsafe or incompatible is
   not an MVP.
5. For each assumption and each dependency, record its validation action,
   its owner, and its expiry or decision point. A hidden project inside
   "assumes X" is scope, not an assumption.
6. Write the change rules: the observations that abort this cut, the changes
   that reopen approval, and who decides. If the user is the only
   stakeholder (a solo owner), they decide, and no approver matrix is
   recorded.

## Step 2: Write and present

1. Write the `## Scope` section to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   keeping the approved sections around it as they are. Once its identity is
   issued, the section is never edited.
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

   Ask this and end the turn; `clarifying-intent` owns what closes it.
3. **REQUIRED SUB-SKILL:** on option 1, invoke `writing-specs` when detailed
   requirements are the next missing input. Never impose a phase that is
   already complete.

## Gotchas

- If a later rescoping pass reuses a deferred capability's stable ID for a
  different item, an old reference to that ID, such as a linked task or a
  review note, silently points at the wrong decision. An ID retires; it is
  never reissued.
- An assumption recorded with a validation action but no expiry or decision
  point reads as settled forever. Nothing then re-checks it once whatever it
  depended on changes underneath it.
