---
name: writing-specs
description: "Writes a specification: detailed requirements and acceptance criteria for settled intent, or a revision to an existing spec. Use when settled intent needs detailed requirements and acceptance criteria before building, including a revision to an existing spec, or when the user asks for a spec, requirements, or acceptance criteria. Skip when current requirements already cover the work, when choosing implementation details, or while a material decision about what the user wants is still pending."
---

# Writing Specs

Turn an intent into a requirements spec (SRS): gather and analyze what the software must do, how each requirement is verified, and the assumptions, dependencies, and risks involved. Requirements are the *what* — keep the *how* (architecture, schemas, code) for design.

## When to use

- You have a goal, brief, or feature request and need its detailed requirements before designing or building.
- **Skip** for a trivial change whose single requirement is obvious — just state it and go.
- If the intent itself is unclear, grill it first with `clarifying-intent`; this skill assumes you roughly know what you want.
- A reply that has not directly closed a pending decision routes to
  `clarifying-intent`; this skill cannot convert it into approved requirements.

## Step 1: Gather and state

1. Pull the goal or brief. Read the relevant existing code. Genuine gap →
   invoke `clarifying-intent`. Invent nothing you could have found.
2. State the problem in a line or two. Link the goal it serves.

## Step 2: Write the requirements

Open `assets/spec-template.md` before starting; each step fills its section.

1. Write each functional requirement as an observable behavior with a stable
   ID that successors never recycle:

   ```text
   Right: R-07 rejects an expired token with a 401
   Wrong: R-07 good auth
   ```

2. Carry every applicable guardrail and obligation: trust and data, security,
   accessibility, compatibility, operational and recovery, performance and
   resource, supported platforms and modes. No generic NFR list.
3. Read `references/reference-forms.md` before choosing the first acceptance
   form. Per requirement, choose the cheapest honest form: executable gate,
   disposable mockup, source-fact contract, rubric, or prose.
4. Executable gate → write it as a proposed file beside the spec, never into
   the project; `test-driven-development` lands and runs it inside the task
   workspace. Interface or mutation authority open → write the observable,
   intended gate, owner, handoff. Never invent an interface.
5. List the edge cases and scenarios that break a naive build: empty input,
   concurrency, unhappy paths.
6. Per assumption and dependency: stable ID, evidence or state, validation
   action, owner, expiry, failure response. Unresolved state that would change
   a requirement → an open decision, never a hidden premise.
7. List open questions, requirement-level risks, and what is out of scope
   this round.

## Step 3: Write and present

1. Write the immutable spec to `.sdlc-skills/specs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path.
2. Fill the classification block. Any answer off the ordinary route, or the
   user marks the work high-risk → run `assets/spec-review.md` before
   presenting, with a reviewer who is not the sole author. Blocking.
3. Present:

   ```text
   Spec {{path}} — version {{identity (per template)}}
   Requirements: {{n}}  Open questions: {{n}}  Out of scope: {{n}}

   1. Approve and hand off to design
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option the open-question state supports}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `clarifying-intent` owns what closes it.
4. **REQUIRED SUB-SKILL:** on option 1, invoke the next missing precondition:
   `ui-ux-design`, `system-architecture`, or `data-model` for unresolved
   non-trivial shape; otherwise `writing-plans`. Never impose a phase already
   complete.

## Gotchas

- A retired requirement ID reused for new work silently repoints every earlier
  citation of it: test names, review comments, out-of-scope links.
- A gate written into the project while specifying lands in whichever checkout
  is open, before any task workspace exists.

## Common mistakes

- Requirements with no criterion — "fast", "secure", "intuitive" prove nothing.
- **Promising verification you never wrote** — name the real artifact, or state
  the future gate and owner plainly.
- Prose by reflex — restating a behaviour in a sentence when a failing test would have pinned it exactly.
- Smuggling design or mutation in — a guessed endpoint, schema, internal call, or
  project edit is not made safe by calling it an acceptance criterion.
- A thin happy-path spec with no edge cases, assumptions, or risks — that's exactly where builds break.
