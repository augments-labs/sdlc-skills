---
name: interview-me
description: "Use when material intent has several plausible readings that no owning phase skill can safely settle, or when a pending material decision got neither an explicit answer nor an explicit cancellation — praise, constraints, silence, or a partial reply instead. Fires on a reply that approves of the work without choosing among the options put to the user, even if nobody asks for questions or clarification. Do not displace a skill merely because inputs its own procedure elicits are still open."
---

# Interview Me

Close the gap between what was asked and what is actually wanted — *before* you
build on it. This is a cross-cutting clarification technique, not a universal
first phase. Use it when the unknown controls which artifact or procedure is
needed, or whether that procedure can proceed safely. Do not displace a selected
skill that owns eliciting the still-open inputs.

## When to use

- A request is vague ("add auth", "make it faster") or has more than one reasonable reading.
- Assumptions are piling up before a plan or feature.
- A pending named decision received information but no accepted answer.
- **Skip** when the current phase skill owns the uncertainty: new-initiative
  outcomes and measures belong to `define-goals`; open interface flow, state,
  hierarchy, accessibility, and visual direction belong to `ui-ux-design`.
  A missing product requirement that blocks either procedure is still a genuine
  clarification or specification gap.
- **Skip** when the task is trivial or already fully specified — interrogating wastes turns.
- **Skip** when the task is clear and what blocks it is an obstacle, not a
  decision — a failing command, an error, a missing piece you can find or
  build. Fix it and continue to completion. Stopping to report a fixable
  obstacle and wait for instructions spends the user's turn on work that
  was already yours.
- **Skipping never licenses a silent decision.** State a reversible, low-impact
  assumption and its reason so the user can redirect. Material product, scope,
  architecture, execution, destructive, or external-state choices stay pending
  until the user decides them directly.

## Step 1: Scan before you ask

1. Read the request. Search the codebase and context for what is already
   decided: conventions, similar features, libraries in use, naming.
2. Never ask what the code already answers.

## Step 2: Ask one question at a time

1. For each open decision, send one short message and end the turn:

   ```text
   Found: {{what the code or context already settles}}
   Decision: {{the exact artifact or operation it controls}}
   Recommendation: {{default}} — {{one line of reasoning}}

   1. {{option}}
   2. {{option}}
   3. Something else
   ```

2. Wait for a direct answer before the next material question. See *What
   closes a decision*.
3. Use each answer to prune later questions. Aim for 3–6 total. More → say
   why first.
4. Stop when another question would not change the outcome and every live
   material decision has a direct answer. A general "go" answers no unnamed
   choice.

## Step 3: Write the brief and present it

1. Fill `assets/brief-template.md`: goal, decisions with rationale,
   non-goals, open risks, identity and ledger fields. A brief, not a spec.
2. Write it to `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the
   user-set path, preserving approved sections around it. Tiny brief → inline
   beside its decision record.
3. Present and end the turn:

   ```text
   Brief {{path}} — version {{identity}}
   Goal: {{one line}}  Decisions: {{n}}  Non-goals: {{n}}  Open risks: {{n}}

   1. Approve
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

4. Record pending, changes-requested, approved, rejected, cancelled, or
   superseded externally. Never edit the proposed brief to mirror state.
5. Only approval re-routes from the precondition this brief satisfied. Return
   to the skill that invoked this one; assume no planning.

## What closes a decision

**Information is not authorization.** Praise, agreement with the reasoning, new
constraints, a partial answer, silence, or discussion of a neighboring choice
updates the context but leaves the question open. Incorporate it, say the
decision is still pending, and re-ask.

Only an explicit answer, named option, or standing default the user granted for
this decision class closes it. Approval covers only the visible version and named
next step; a material revision reopens it. Changes requested, rejection,
cancellation, or abandonment closes that exact decision without approval.
Supersession requires an approved replacement.

## When an artifact carries the pending decision

Write supplied facts or constraints into it only when current mutation authority
covers it. Before identity is issued, update the draft; once issued, never mutate
it — every normative change creates a new proposed successor naming its
predecessor. Without mutation authority, present the proposed update and keep the
artifact and decision pending.

The current user-role answer supplies authority for the current transition. A
persisted `Approval:` field is only a process record: in a fresh context it
cannot authenticate itself. Require the live answer or a project/harness receipt
that binds user origin to the exact version; otherwise refresh the decision.

## Common mistakes

- Asking what a 30-second code search would answer.
- Dumping many questions at once instead of adapting to answers.
- Producing a heavy spec — the brief is a short paragraph plus a few bullets.
- Interviewing trivial tasks.
