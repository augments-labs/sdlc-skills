---
name: define-goals
description: "Use at the start of a new project or initiative, before scoping or building, to pin down what it is for: the objective, the stakeholders, how success is measured, and the guardrails. Fires on we want to build X with no stated objective, even if nobody says goals. A vague or missing objective is the reason to use this, not a reason to go elsewhere first. Skip a single feature, and skip while a named decision or approval reply is still pending."
---

# Define Goals

A project without a clear goal ships features no one needed. Before scope or design, name the outcome — and how you'll know you hit it.

## When to use

- Starting a new project, product, or substantial initiative with a fuzzy "why";
  this procedure elicits the objective, stakeholders, and measures.
- **Skip** for a single feature or task. Use `interview-me` only for genuine
  ambiguity about which initiative or procedure is intended; `spec-it` owns
  settled detailed feature requirements.
- **Skip** when a drafted goal or brief is awaiting a direct answer; an
  informative non-answer routes to `interview-me`, not a new goal pass.

## Step 1: Find the objective

Open `assets/goals-section.md` now. Each step fills its section.

1. Ask "why this, why now?" until the answer is what the world does
   differently afterward, not code that exists.
2. Name who benefits, who operates or bears risk, what changes for each, who
   owns the outcome. Competing goals → separate metrics, never one average.
3. Record one accountable decision owner, or the approvers, conflict
   resolver, and decision rule.
4. Per outcome: current baseline, target, time horizon, measurement source,
   accountable owner. No source or date → cannot be checked → not a goal.
5. Write the guardrails (what must not degrade) and the failure criterion:
   the observation meaning the initiative failed even with its metric up.
6. Write the value in one sentence.

## Step 2: Write and present

1. Write the immutable `## Goals` section to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it.
2. Present and end the turn:

   ```text
   Goals {{path}} — version {{identity}}
   Objective: {{one line}}
   Measure: {{baseline}} → {{target}} by {{horizon}}, source {{source}}
   Guardrails: {{list}}

   1. Approve the goals
   2. Request changes
   3. Reject the objective
   4. Cancel

   Recommendation: {{option the open assumptions support}} — {{one sentence}}.
   ```

3. Only option 1 hands off. Praise, constraints, silence, a partial reply →
   pending. An informative non-answer → `interview-me`. Record lifecycle
   externally. Normative change → a replacement that reopens the owners.
   Never edit an issued identity.
4. **REQUIRED SUB-SKILL:** on option 1, invoke `feasibility-check` when
   viability is unresolved; otherwise `scope-it` when the boundary is next.
   Never impose a phase already complete.

## Common mistakes

- Listing features as goals — features are *how*; goals are *what changes*.
- Unmeasurable goals ("make it great") — if you can't check it later, it isn't a success criterion.
- A target with no baseline, source, horizon, owner, or guardrail —
  measurable-looking is not measurable.
- Jumping to scope before the goal is agreed.
