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
- **Skip** while a presented section awaits a direct answer.

## Step 1: Fix the question and the facts

Open `assets/approaches-section.md` before starting; each step fills a part
of it.

1. Write the question as one sentence: the decision this section settles.
   Take the objective from the brief's Goals section, the captured ticket, or
   the user's words, and quote it. If no objective is settled, **REQUIRED
   SUB-SKILL:** invoke `define-goals` for a new initiative or
   `clarifying-intent` for a feature, and resume here when it returns. Never
   re-ask what that skill already answered.
2. Fill the shared facts table: every fact about the current code,
   environment, and constraints that an approach could rest on. Cite each
   against a path and symbol at the current revision, or a quoted
   constraint. If a boundary is unfamiliar, invoke `mapping-the-codebase`
   first. A fact you cannot cite goes in the open questions, not the table.
3. Fill the criteria table from the Goals section's outcomes, guardrails,
   and failure criteria, and from any constraint the user stated. Each row
   names where it came from. If the brief has no Goals section, write the
   criteria from the user's words and quote them.
4. Record the base revision the facts were checked against.

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
   approach is written. Every fill carries the same question, facts,
   criteria, and base revision; only the perspective line differs. The writer reads the brief from disk and never
   this conversation.
3. If a dispatch action is callable, dispatch each fill as
   `dispatching-parallel-agents` Step 2 says: read-only, `large` tier, one
   packet per perspective, all in one wave. Record each returned ID in the
   approach's `Produced by` line.
4. If the action is unavailable, is refused, or returns no ID, ask the
   question `dispatching-parallel-agents` Step 2 states, once for the whole
   set, and end the turn. On option 1, write the approaches yourself, one
   perspective at a time, each under its own fill, and finish writing one
   before opening the next perspective; label every one `self pass, not
   independent`. On option 2, hand each fill to the named agent and accept
   only a report that arrives from outside this session. On option 3, the
   section stays pending.
5. Accept a returned approach only when it answers every heading the prompt
   asks for. Return one that is missing a heading to its writer once, with
   the missing heading named; after that, record it as `incomplete` under
   Rejected.

## Step 3: Check facts, then compare

1. Check every claim each approach makes about the current code or
   environment against the shared facts and the base revision. A claim that
   contradicts a fact, or cites a path or symbol that does not resolve, fails
   the approach's fact check. Name the claim in its `Fact check` line, give
   the writer one correction round with the fact quoted, and compare only
   the corrected version. A second failure moves it to Rejected. Two
   approaches that disagree about design are not a failure; that is the
   point.
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
   naming this one as its predecessor.
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
   recommendation is never the choice.
3. On option 1 or 2, add an `approved` row naming the chosen approach, and
   the rejected ones stay in the section as the record of what was not
   chosen. **REQUIRED SUB-SKILL:** when the choice is hard to reverse, invoke
   `architecture-decisions` with the surviving approaches as its options;
   otherwise invoke the next missing precondition, `feasibility-check` for
   an initiative whose Feasibility section is not yet written, else
   `writing-specs`.
4. On option 3, write a successor section from Step 1 with the change named
   and present it again, at most twice; after that, report the question as
   unresolved and end the turn.

## Gotchas

- Three approaches written from one context with no constraint are one
  approach three times with different names, and the comparison then
  confirms the first idea; the perspective line in each fill is what makes
  them differ. Reproduced by asking for "three options" with no constraint.
- A comparison judges design, so an approach resting on a wrong claim about
  the current code wins on elegance: one that assumed a lookup existed in
  the service ranked first until the claim was checked. Step 3.1 runs
  before the table is filled, never after.
- Writing the second approach with the first one open converges on the
  first; a self pass finishes each approach before opening the next
  perspective, and the comparison waits until all are written.
- A recommendation with no objection reads as a choice; the ledger row
  stays `pending` until the user answers, and nothing downstream reads a
  pending row.

## Common mistakes

- Instead of scoring approaches with numbers, write what each one does
  against each criterion; a number hides the observation the user needs.
- Instead of carrying a rejected approach into the spec as a later phase,
  leave it under Rejected with its reason; a later initiative can cite it.
- Instead of brainstorming the goal, settle it first; approaches to an
  unsettled objective compare nothing.
