---
name: define-goals
description: "Pins down what a new project or initiative is for: the objective, the stakeholders, how success is measured, and the guardrails. Use when a new project or initiative starts before scoping or building, or when the user wants to build X with no stated objective, or when the objective is vague or missing. Skip a single feature, and skip while a decision or approval reply is pending."
---

# Define Goals

Before scope or design, name the outcome — and how you'll know you hit it.

## When to use

- Starting a new project, product, or substantial initiative with a fuzzy "why";
  this procedure elicits the objective, stakeholders, and measures.
- **Skip** for a single feature or task. Use `clarifying-intent` only for genuine
  ambiguity about which initiative or procedure is intended; `writing-specs` owns
  settled detailed feature requirements.
- **Skip** when a drafted goal or brief is awaiting a direct answer; an
  informative non-answer routes to `clarifying-intent`, not a new goal pass.

## Step 1: Find the objective

Open `assets/goals-section.md` before starting; each step fills its section.

1. Ask "why this, why now?" until the answer is what the world does
   differently afterward, not code that exists.
2. Name who benefits, who operates or bears risk, what changes for each, who
   owns the outcome. Competing goals → separate metrics, never one average.
3. Record one accountable decision owner, or the approvers, conflict
   resolver, and decision rule. Solo owner — the user is the only
   stakeholder → they are the decision owner; leave the approver, conflict,
   and decision-rule fields out.
4. Per outcome: current baseline, target, time horizon, measurement source,
   accountable owner. No source or date → cannot be checked → not a goal.
5. Write the guardrails (what must not degrade) and the failure criterion:
   the observation meaning the initiative failed even with its metric up.
6. Write the value in one sentence.

## Step 2: Write and present

1. Write the immutable `## Goals` section to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it.
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

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `clarifying-intent` owns what closes it.
3. **REQUIRED SUB-SKILL:** on option 1, invoke `feasibility-check` when
   viability is unresolved; otherwise `scoping` when the boundary is next.
   Never impose a phase already complete.

## Gotchas

- A guardrail can look complete just by being written down while staying
  unfalsifiable. `scoping` treats every goal guardrail as a non-negotiable
  constraint on each cut, so one with no observable threshold lets a cut
  violate it with nothing positioned to catch that.
- Naming several approvers for the objective without also naming a conflict
  resolver and a decision rule leaves no way to settle it when they disagree
  about what the goal actually is — the brief then stalls on a tie nobody is
  positioned to break.
