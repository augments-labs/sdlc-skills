---
name: clarifying-intent
description: "Asks the questions that settle what the user actually wants before work is built on a guess. Use when what the user wants has several plausible readings that would change the work and no phase skill's own procedure can settle it, or when a pending material decision got praise, constraints, silence, or a partial reply instead of an explicit answer or an explicit cancellation, including a reply that approves of the work without choosing among the options put to the user, even if nobody asks for questions or clarification. Skip inputs that another skill's own procedure asks for."
---

# Clarifying Intent

Close the gap between what was asked and what is actually wanted, *before* you
build on it. When a skill already selected owns asking for the inputs still
open, leave that to it.

## When to use

- A request is vague ("add auth", "make it faster") or has more than one reasonable reading.
- Assumptions are piling up before a plan or feature.
- A named decision still pending received information but no answer that
  settles it.
- **Skip** when the current phase skill owns the uncertainty: new-initiative
  outcomes and measures belong to `define-goals`; open interface flow, state,
  hierarchy, accessibility, and visual direction belong to `ui-ux-design`.
  A missing product requirement that blocks either procedure is still a genuine
  clarification or specification gap.
- **Skip** when the task is trivial or already fully specified.
- **Skip** when the task is clear and what blocks it is an obstacle, not a
  decision: a failing command, an error, a missing piece you can find or
  build. Fix it and continue to completion.
- **Skipping never permits a silent decision.** State an assumption that
  falls in none of the categories that follow, with its reason, so the user can
  redirect. Product, scope, architecture, execution-mode, destructive, or
  external-state choices stay pending until the user decides them directly.

## Step 1: Scan before you ask

1. Read the request. Search the codebase and context for what is already
   decided: conventions, similar features, libraries in use, naming.
2. Never ask what the code already answers.
3. If a caller invoked this one to settle a decision it named, keep that
   decision and the step waiting on it. When a direct answer settles it
   without changing the approved scope, record the answer and return to that
   step; do not write another alignment brief or run another approval round.
   If the answer brings new intent that changes that scope, continue below.

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

2. Wait for a direct answer before the next question. See *What
   closes a decision*.
3. Use each answer to prune later questions. Ask only what could change the
   outcome; a caller's decision, once settled, returns under Step 1.3.
4. Stop when another question would not change the outcome and every live
   decision in a category named under *When to use* has a direct answer. A
   general "go" answers no choice it does not name.

## Step 3: Write the brief and present it

1. Fill `assets/brief-template.md` after Step 2.4's stop condition holds:
   goal, decisions with their reasons, non-goals, open risks, the brief's
   identity (a hash of its own text; the template says how), and the fields
   that name its decision record (the ledger: add to it, never rewrite it,
   and keep it outside the brief). A brief, not a spec.
2. Write it to `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the
   user-set path, preserving approved sections around it. If the brief is
   tiny, write it inline beside its decision record instead.
3. Present and end the turn:

   ```text
   Brief {{path}} — version {{identity (per template)}}
   Goal: {{one line}}  Decisions: {{n}}  Non-goals: {{n}}  Open risks: {{n}}

   1. Approve
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

4. Record its state (pending, changes-requested, approved, rejected,
   cancelled, or superseded) in that record outside the brief. Never edit the
   proposed brief to show its state.
5. Only approval moves the work past the precondition this brief satisfies.
   Return to the skill that invoked this one; do not assume planning follows.

## What closes a decision

**Information is not authorization.** Praise, agreement with the reasoning, new
constraints, a partial answer, silence, or discussion of a neighboring choice
updates the context but leaves the question open. Incorporate it, say the
decision is still pending, and re-ask.

Only an explicit answer, a named option, or a standing default the user
granted for this kind of decision closes it. Approval covers only the version
shown and the next step named with it; a revision to any decision, non-goal,
or named next step reopens it. Changes requested, rejection, cancellation, or
abandonment closes that exact decision without approving anything.
Supersession requires an approved replacement.

The question offered three places to keep session data and recommended the
second. The reply: "Nice, the recommendation makes sense. Also, it has to work
offline." Nothing was chosen: that is agreement with the reasoning plus a new
constraint. Fold "works offline" into Found, say the decision is still
pending, and re-ask. "Sounds good" to a numbered question closes no more than
this did.

## When an artifact carries the pending decision

Write supplied facts or constraints into it only when the
authority you hold now covers changing it. While its identity is not yet
issued, update the draft. Never edit an artifact once its identity is issued,
whether its decision is pending or closed: every change to what downstream
work relies on from it creates a new proposed successor that names its
predecessor, with a per-ID list of what was `added / changed / removed /
preserved`, and removing an ID needs its owner's approval.

When a successor is approved, list everything bound to its predecessor and
mark each binding invalid until its owner validates it again. Record its
state (approved or accepted, rejected, cancelled, superseded) outside the
artifact, with evidence of the exact version each state applies to. Without
authority to change it, present the proposed update and keep both the
artifact and the decision pending.

The user's answer in this conversation is the authority for the current
transition. An `Approval:` field saved in a document is only a process record:
in a fresh context it cannot prove itself. Require the live answer, or a record
the project or harness issued that ties the answer to the user and to the
exact version; otherwise put the decision to the user again.

## Gotchas

- An `Approval:` line copied forward into a successor draft looks like proof
  of approval, but it belongs to the predecessor's version; in a fresh context
  it approves nothing about the successor.
