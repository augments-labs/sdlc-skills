---
name: define-goals
description: "Pins down what a new project or initiative is for: the objective, the stakeholders, how success is measured, and the guardrails. Use when a new project or initiative starts before scoping or building, or when the user wants to build X with no stated objective, or when the objective is vague or missing. Skip a single feature, and skip while a decision or approval reply is pending."
---

# Define Goals

Before scope or design, name the outcome, and how you will know you reached
it.

## When to use

- Starting a new project, product, or substantial initiative with a fuzzy
  "why".
- **Skip** for a single feature or task. Use `clarifying-intent` only for
  genuine ambiguity about which initiative or procedure is intended;
  `writing-specs` owns settled, detailed feature requirements.
- **Skip** when a drafted goal or brief is awaiting a direct answer. If the
  reply informs but does not answer, handle it with `clarifying-intent`, not
  with a new goal pass.

## Step 1: Find the objective

Open `assets/goals-section.md` before starting; each step fills its section.

1. Ask "why this, why now?" until the answer is what the world does
   differently afterward, not code that exists.
2. Name who benefits, who operates or bears risk, what changes for each, and
   who owns the outcome. If goals compete, give each its own metric, never
   one averaged metric.
3. Record one accountable decision owner, or else the approvers, the conflict
   resolver, and the decision rule. If the user is the only stakeholder (a
   solo owner), the user is the decision owner; leave the approver, conflict,
   and decision-rule fields out.
4. For each outcome, record its current baseline, target, time horizon,
   measurement source, and accountable owner. If an outcome has no source or
   date, it cannot be checked, so it is not a goal.
5. Write the guardrails (what must not degrade) and the failure criterion:
   the observation that would mean the initiative failed even with its
   metric up.
6. Write the value in one sentence.

## Step 2: Write and present

1. Write the `## Goals` section, which is never edited once its identity is
   issued, to `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the
   user-set path, leaving the approved sections around it untouched.
2. Present:

   ```text
   Goals {{path}} — version {{identity (per template)}}
   Objective: {{one line}}
   Measure: {{baseline}} → {{target}} by {{horizon}}, source {{source}}
   Guardrails: {{list}}

   1. Approve the goals
   2. Request changes
   3. Reject the objective
   4. Cancel

   Recommendation: {{option the open assumptions support}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
3. **REQUIRED SUB-SKILL:** on option 1, invoke `feasibility-check` if
   viability is unresolved; otherwise, if the boundary is next, invoke
   `scoping`. Never impose a phase that is already complete.

## Gotchas

- A guardrail can look complete just because it is written down while no
  observation could ever show it broken. `scoping` treats every goal
  guardrail as a non-negotiable constraint on each cut, so a guardrail with
  no observable threshold lets a cut violate it with nothing in place to
  catch that.
- Naming several approvers for the objective without also naming a conflict
  resolver and a decision rule leaves no way to settle it when they disagree
  about what the goal actually is; the brief then stalls on a tie nobody is
  placed to break.
