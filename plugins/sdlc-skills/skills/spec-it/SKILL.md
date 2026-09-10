---
name: spec-it
description: "Use when settled intent for a goal or feature needs detailed requirements before design — what it must do, how each requirement is verified, and the assumptions and risks behind it. Fires on write up what this needs to do and what are the acceptance criteria, even if nobody says spec or requirements. Skip how it is built, skip when requirements already exist, and skip while a decision or approval reply is pending."
---

# Spec It

Turn an intent into a requirements spec (SRS): gather and analyze what the software must do, how each requirement is verified, and the assumptions, dependencies, and risks involved. Requirements are the *what* — keep the *how* (architecture, schemas, code) for design.

## When to use

- You have a goal, brief, or feature request and need its detailed requirements before designing or building.
- **Skip** for a trivial change whose single requirement is obvious — just state it and go.
- If the intent itself is unclear, grill it first with `interview-me`; this skill assumes you roughly know what you want.
- A reply that has not directly closed a pending material decision routes to
  `interview-me`; this skill cannot convert it into approved requirements.

## Step 1: Gather and state

1. Pull the goal or brief. Read the relevant existing code. Genuine gap →
   invoke `interview-me`. Invent nothing you could have found.
2. State the problem in a line or two. Link the goal it serves.

## Step 2: Write the requirements

Open `assets/spec-template.md` now. Each step fills its section.

1. Write each functional requirement as an observable behavior with a stable
   ID that successors never recycle:

   ```text
   Right: R-07 rejects an expired token with a 401
   Wrong: R-07 good auth
   ```

2. Carry every applicable guardrail and obligation: trust and data, security,
   accessibility, compatibility, operational and recovery, performance and
   resource, supported platforms and modes. No generic NFR list.
3. Per requirement, choose the cheapest honest acceptance form from
   `references/reference-forms.md`: executable gate, disposable mockup,
   source-fact contract, rubric, or prose.
4. Executable gate authorized now → write it in the project's real gate and
   run it. New behavior → fails. Preserved behavior → green now, falsified
   later by TDD. Interface or mutation authority open → write the
   observable, intended gate, owner, handoff. Never invent an interface or
   edit the project silently.
5. List the edge cases and scenarios that break a naive build: empty input,
   concurrency, unhappy paths.
6. Per assumption and dependency: stable ID, evidence or state, validation
   action, owner, expiry, failure response. Unresolved material state → an
   open decision, never a hidden premise.
7. List open questions, requirement-level risks, and what is out of scope
   this round.

## Step 3: Write and present

1. Write the immutable spec to `.sdlc-skills/specs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path.
2. Classified high-risk on any of `migration-strategy`'s four questions
   (reviewability, preservation, breadth, failure surfaces), or marked so
   by the user → run `references/spec-review.md` with a reviewer who is not
   the sole author. Blocking.
3. Present and end the turn:

   ```text
   Spec {{path}} — version {{identity}}
   Requirements: {{n}}  Open questions: {{n}}  Out of scope: {{n}}

   1. Approve and hand off to design
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option the open-question state supports}} — {{one sentence}}.
   ```

4. Only option 1 hands off. Praise, silence, a partial reply → pending. A
   reply that does not close a pending material decision → `interview-me`.
   Record lifecycle externally. Normative change → a proposed successor with a
   per-ID `added / changed / removed / preserved` delta. Never edit an issued
   identity.
5. **REQUIRED SUB-SKILL:** on option 1, invoke the next missing precondition:
   `ui-ux-design`, `system-architecture`, or `data-model` for unresolved
   non-trivial shape; otherwise `writing-plans`. Never impose a phase already
   complete.

## Common mistakes

- Requirements with no criterion — "fast", "secure", "intuitive" prove nothing.
- **Promising verification you never wrote** — name the real artifact, or state
  the future gate and owner plainly.
- Prose by reflex — restating a behaviour in a sentence when a failing test would have pinned it exactly.
- Smuggling design or mutation in — a guessed endpoint, schema, internal call, or
  project edit is not made safe by calling it an acceptance criterion.
- A thin happy-path spec with no edge cases, assumptions, or risks — that's exactly where builds break.
