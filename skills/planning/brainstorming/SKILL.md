---
name: brainstorming
description: "Generates several distinct approaches to a settled goal, each under a different design constraint and checked against the same facts about the current code, then compares them so one is chosen before anything is specified or built. Use when the goal is clear but the approach is open, when the user says brainstorm, what are our options, how should we do this, which approach, or compare alternatives, or before a spec or design when only one approach has been considered. Skip when the approach is already fixed, when the goal itself is open, and while a decision reply is pending."
---

# Brainstorming

The first approach that comes to mind becomes the spec unless something
generates a second one. Produce several under different constraints, check
each against the same facts, and let the comparison pick.

## When to use

- The objective is known and more than one way to reach it is plausible,
  including the way that builds nothing.
- Only one approach has been written down and nobody has argued against it.
- **Skip** when the user has already chosen the approach, or one
  implementation is the only reasonable one. State that in one sentence and
  move on.
- **Skip** when the open question is what to build or why. `define-goals`
  owns a new initiative's objective; `clarifying-intent` owns an ambiguous
  request. Return here once that is settled.
- **Skip** when the approach is settled and only its reversibility is in
  question: `architecture-decisions` owns that.
- **Skip** when the question is which layout, arrangement, or visual
  direction to take: `ui-ux-design` owns a comparison the user judges by
  seeing it.
- **Skip** while a presented section awaits a direct answer.

## Step 1: Fix the question and the facts

Open `assets/approaches-section.md` before starting; each step fills a part
of it.

1. Write the question as one sentence: the decision this section settles.
   Take the objective from the brief's Goals section, the captured ticket, or
   the user's words, and quote it. If no objective is settled, **REQUIRED
   SUB-SKILL:** invoke `clarifying-intent` for a feature and resume here when
   it returns, or `define-goals` for a new initiative; that skill hands off
   onward, not back, so start this skill again once its Goals section is
   approved. Never re-ask what that skill already answered.
2. Take the decision owner from the Goals section's decision rule. If there
   is none and the user is the only stakeholder, the user owns it; otherwise
   ask once, and never invent one.
3. Fill the shared facts table: every fact about the current code,
   environment, and constraints that an approach could rest on. Cite each
   against a path and symbol at the current revision, or a quoted
   constraint. If a boundary is unfamiliar, invoke `mapping-the-codebase`
   first. A fact you cannot cite goes in the open questions, not the table.
4. Fill the criteria table from the Goals section's outcomes, guardrails,
   and failure criteria, and from any constraint the user stated. Each row
   names where it came from. If the brief has no Goals section, write the
   criteria from the user's words and quote them.
5. Record the base revision the facts were checked against, then write the
   question, facts, criteria, and base revision to
   `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/approach-inputs.md`. The
   writers read that file, never this conversation.

## Step 2: Produce the approaches

1. Choose the perspectives. Each approach is written under one constraint,
   so the set differs by construction rather than by luck:

   | Perspective | The approach must |
   | --- | --- |
   | Smallest change | Meet the criteria with the least new code and the fewest touched files. |
   | Clean slate | Be the shape chosen with no existing code to protect, so the cost of fitting in is visible. |
   | Do not build | Meet the criteria by configuring, buying, removing a requirement, or a manual step. |
   | Lowest running cost | Be cheapest to operate, monitor, and keep working for a year. |
   | Most reversible | Be the one whose undo is cheapest if the criteria turn out wrong. |

   Default to the first three. Add a row only when a criterion names its
   concern, and stop at five: each approach is one `large`-tier run.
2. Fill `assets/approach-prompt.md` once per perspective before any
   approach is written. Every fill names the same inputs file, brief, base
   revision, and report directory; only the perspective line differs. The
   workspace is the project root at the base revision, read-only. The
   report path is `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/approach-{{perspective}}.md`,
   the one write a fill allows.
3. If a dispatch action is callable, freeze the packet count, the deadline,
   and the cancel owner as `dispatching-parallel-agents` Step 1.4 says, then
   dispatch each fill as its Step 2 says: `large` tier, one packet per
   perspective, all in one wave. Record each returned ID in the approach's
   `Produced by` line.
4. If the action is unavailable, is refused, or returns no ID, ask the
   question `dispatching-parallel-agents` Step 2 states, once: the set is
   one work item. End the turn. On option 1, write the approaches yourself,
   one perspective at a time, each under its own fill, and finish writing
   one before opening the next perspective; label every one `self pass, not
   independent`. Options 2 and 3 follow that step.
5. Accept a returned approach only when it answers every heading the prompt
   asks for and passes the fact check in Step 3.1. Return one that fails
   either to its writer once, naming every missing heading and quoting
   every contradicted fact; after a second failure, record it under
   Rejected as `incomplete`, or with the claim it rested on. A perspective
   whose packet failed or timed out goes under Rejected as `not produced`
   with the attempt named; the comparison runs over the approaches that
   returned, and the recommendation says the set is short.
6. A `NEEDS_CONTEXT` return is not a failure and uses no retry: the inputs
   are ambiguous for every writer. Answer its question, asking the user
   once when the inputs file cannot settle it, write a successor inputs
   file, and dispatch the whole wave again from Step 2.2.

## Step 3: Check facts, then compare

1. Check every claim each approach makes about the current code or
   environment, including those under its `Claims not checked` heading,
   against the shared facts and the base revision. A claim that contradicts
   a fact, or cites a path or symbol that does not resolve, fails the fact
   check; name it in the approach's `Fact check` line. A claim nobody can
   check goes to Open questions. Two approaches that disagree about design
   are not a failure; that is the point.
2. Fill the comparison table: one row per criterion, one column per
   surviving approach, each cell an observation that cites the approach's
   own text. Never a score or a rank. If a criterion cannot be judged
   without a fact nobody can cite, name it in Open questions and say that
   `prototyping` can answer it.
3. Move an approach that breaks a guardrail or a stated constraint to
   Rejected with the row it broke. If one approach survives, say so in the
   recommendation: the finding is that no real alternative exists.
4. Write the recommendation: one approach, one sentence why, and what
   would change the pick. The clean-slate approach is a reference point, so
   recommend it only when the comparison shows the fit cost is worth paying.

## Step 4: Present, then stop

1. Append the section to `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path, keeping every approved section already there.
   The section is immutable once presented: a change is a successor section
   with a heading of its own, as the template says, that names this one as
   its predecessor.
2. Add a `pending` row for it to the brief's ledger, then present:

   ```text
   Approaches {{absolute path}} — section identity {{identity}}
   Question: {{one sentence}}
   Compared: {{n}}  Rejected: {{n}}  Produced by: {{dispatched | self pass | named agent}}

   1. Choose {{recommended approach}} and hand off to {{next skill}}
   2. Choose another approach: name it
   3. Request changes: another perspective, a missing fact, a different question
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it. This
   skill writes no spec, design, plan, prototype, or code, and the
   recommendation is never the choice. If the user asks to see the
   approaches as a page, **REQUIRED SUB-SKILL:** invoke `viewing-artifacts`;
   it shows each approach's state inside the Brief node. When it returns,
   present the block above again as the one open question, and offer to
   serve the page only after an option is named.
3. On option 1 or 2, add an `approved` row whose `Bound evidence` names
   the chosen approach by the name after the colon in its heading; the
   rejected ones stay in the section as the record of what was not chosen.
   Naming a rejected approach is a change: treat it as option 3.
   **REQUIRED SUB-SKILL:** when the choice is hard to reverse, invoke
   `architecture-decisions` with the chosen approach and every other one,
   rejected included, as its options. If the record it returns rejects the
   choice in favor of another approach, add a superseding `approved` row
   naming that approach and the record's identity. On any outcome other
   than accepted or rejected in favor of another approach, the choice is
   not settled: add a `changes requested` or `cancelled` row naming the
   record's identity and end the turn.
4. Once the choice is settled, invoke the next missing precondition:
   `feasibility-check` for an initiative, unless an existing Feasibility
   section fills every dimension row from evidence and no row is unknown;
   `scoping` for an initiative whose boundary is not yet approved; else
   `writing-specs`.
5. On option 3, write a successor section from Step 1 with the change named,
   add a `superseded` row to the predecessor naming the successor, and
   present it again. Each round ends the turn; the user decides when the
   question is settled.

## Gotchas

- Three approaches written from one context with no constraint are one
  approach three times with different names, and the comparison then
  confirms the first idea; the perspective line in each fill is what makes
  them differ. Reproduced by asking for "three options" with no constraint.
- A comparison judges design, so an approach resting on a wrong claim about
  the current code wins on elegance. Reproduced by filling the table before
  Step 3.1 with one approach citing a symbol absent at the base revision;
  Step 3.1 runs before the table is filled, never after.
- Writing the second approach with the first one open converges on the
  first. Reproduced by a self pass that writes two approaches in one
  context; it finishes each approach before opening the next perspective,
  and the comparison waits until all are written.
- A recommendation with no objection reads as a choice. Reproduced by a
  reply of "makes sense" to the decision block; the ledger row stays
  `pending` until the user names an option, and nothing downstream reads a
  pending row.

## Common mistakes

- Instead of scoring approaches with numbers, write what each one does
  against each criterion; a number hides the observation the user needs.
- Instead of carrying a rejected approach into the spec as a later phase,
  leave it under Rejected with its reason; a later initiative can cite it.
- Instead of brainstorming the goal, settle it first; approaches to an
  unsettled objective compare nothing.
