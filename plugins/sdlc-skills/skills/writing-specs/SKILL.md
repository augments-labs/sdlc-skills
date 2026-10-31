---
name: writing-specs
description: "Writes a specification: detailed requirements and acceptance criteria for settled intent, or a revision to an existing spec. Use when settled intent needs detailed requirements and acceptance criteria before building, including a revision to an existing spec, or when the user asks for a spec, requirements, or acceptance criteria. Skip when current requirements already cover the work, when choosing implementation details, or while a material decision about what the user wants is still pending."
---

# Writing Specs

Turn an intent into a requirements spec. Requirements are the *what*; leave
the *how* (architecture, schemas, code) to design.

## When to use

- You have a goal, brief, or feature request and need its detailed
  requirements before designing or building.
- **Skip** a trivial change whose single requirement is obvious: state it and
  go.
- If the intent itself is unclear, invoke `clarifying-intent` first; this
  skill assumes what is wanted is roughly known.
- If a reply has not directly closed a pending decision, invoke
  `clarifying-intent`; this skill cannot turn that reply into approved
  requirements.

## Step 1: Gather and state

1. Pull the goal or brief, and read the relevant existing code. If a genuine
   gap is left, invoke `clarifying-intent`. Invent nothing you could have
   found.
2. State the problem in a line or two, and link the goal it serves.

## Step 2: Write the requirements

Open `assets/spec-template.md` before you start; each step below fills one of
its sections.

1. Write each functional requirement as an observable behavior with a stable
   ID that no successor spec ever gives to a different requirement:

   ```text
   Right: R-07 rejects an expired token with a 401
   Wrong: R-07 good auth
   ```

2. Carry every guardrail and obligation that applies: trust and data,
   security, accessibility, compatibility, operational and recovery,
   performance and resource, supported platforms and modes. Do not add a
   generic list of non-functional requirements.
3. Read `references/reference-forms.md` before choosing the first acceptance
   form. For each requirement, choose the cheapest form that can honestly
   judge it: an executable gate, a disposable mockup, a source-fact
   contract, a rubric, or prose.
4. If the form is an executable gate, write it as a proposed file beside the
   spec, never into the project; the implementer lands and runs it inside
   the task workspace as its `test-driven-development` check. If the interface, or the authority to change
   the project, is still open, write the observable, the intended gate, its
   owner, and the handoff. Never invent an interface.
5. List the edge cases and scenarios that break a naive build.
   Every sentence in the spec that states what the code does today (a
   command exists, a format carries a field, a path handles a case) names
   the path and symbol it was checked against at the current revision.
   Rewrite one you cannot cite to what is known, or move it to the open
   questions. A requirement built on an unchecked claim is planned against
   code that is not there.
6. Fill every column of the template's assumptions-and-dependencies table,
   one row per assumption or dependency.
7. List the open questions, the requirement-level risks, and what is out of
   scope this round.

## Step 3: Write and present

1. Write the spec to `.sdlc-skills/specs/{{YYYY-MM-DD}}-{{topic}}.md` or the
   user-set path. The spec is immutable: a change to it is a new spec that
   names this one as its predecessor, never an edit.
2. Fill the template's high-risk classification section. If any answer there
   is off the ordinary route, or the user marks the work high-risk, run the
   review in `assets/spec-review.md` before presenting, with a reviewer who is
   not the spec's sole author. That review is blocking: do not present the
   spec (Step 3.3) before it is done. A `NEEDS_CONTEXT` return keeps it
   pending: supply the path it names and run the review again.
3. Present:

   ```text
   Spec {{absolute path}} — version {{identity (per template)}}
   Requirements: {{n}}  Open questions: {{n}}  Out of scope: {{n}}

   1. Approve and hand off to design
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option the open-question state supports}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
4. **REQUIRED SUB-SKILL:** on option 1, invoke the next missing precondition:
   `ui-ux-design`, `system-architecture`, or `data-model` when a non-trivial
   shape is still unresolved; otherwise `writing-plans`. Never impose a phase
   that is already complete.

## Gotchas

- A claim about the current code that reads as settled is planned as
  settled: a spec that said a sign-in command existed and a lock format
  carried a licence field reached implementation before anyone found that
  neither held on the base, each as a plan successor mid-task. Step 2.5
  cites the path and symbol, or says it is unknown.
- A retired requirement ID reused for new work silently makes every earlier
  citation of it (test names, review comments, out-of-scope links) point at
  the new work.
- An executable gate written into the project while you are still specifying
  lands in whichever checkout is open, before any task workspace exists.
