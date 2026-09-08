---
name: writing-plans
description: "Use when approved requirements or a clearly multi-step task need an executable, per-task plan before implementation — ordered tasks, their dependencies, and how each one is known to be done. Fires on break this down, lay out the steps first, and this is too big to do in one go, even if nobody says plan. Skip single-step or trivial work."
---

# Writing Plans

Turn an aligned intent into an executable plan: a small durable **map** plus thin per-task **contracts**. Be ambitious on scope, light on implementation — pre-written code rots and produces a plan too long to read. The executor writes code at run time, with the most context.

## When to use

- Detailed requirements are approved, or a precise task spans ≥3 steps or multiple files.
- **Skip** for single-step or trivial changes — planning them costs more than doing them.
- If intent is ambiguous, route to `interview-me`; if detailed verifiable behavior is missing, route to `spec-it`. A precise task needs neither ritual.
- A high-risk target plan waits for approved, current migration and assurance
  contracts. A plan you were authorized to write for the missing gate alone may
  consume the exact proposed contract, but must exclude every piece of target
  work. Unsettled facts stay recorded as evidence and are never promoted to
  accepted deviations; establishing a gate neither approves the contract nor
  satisfies the target's entry conditions.
- Use separate plans for independent subsystems unless one cutover or rollback makes them one initiative.

## Procedure

1. **Bind the inputs before anything else.** Record the exact identity of every
   approved input this plan consumes, and the rule that says when that identity
   goes stale. Fill the header of `assets/index-template.md` first — it names the
   bound inputs, the invalidation triggers, and the approval rule the plan owes.

   When an approved UI design contains **Selected visual references**, bind that
   complete keyed collection in the index. Every UI-bearing task copies only its
   applicable subset, field for field: Reference ID, Decision ID, Medium,
   Approved design artifact version, Artifact locator, Artifact version, Content
   digest, Selection ID, Rendering-input identity, Freshness evaluator,
   Normative conditions, and Distinguishing invariants. Map every Reference ID
   in the index to one or more owning task IDs and conformance evaluator IDs. A
   UI plan with a missing approved reference or uncovered Reference ID is not
   executable; return it to `ui-ux-design` instead of reconstructing a preference
   from prose or conversation.

   Give every file and every side effect exactly one owning task. Where two tasks
   would touch the same one, order them with an explicit dependency and name a
   single transition owner. For homogeneous work — one transformation applied
   across many items — bind the machine-readable inventory and the output
   pattern instead of enumerating the items by hand.

2. **Slice vertically, and size each task to its gate.** A task is one coherent
   capability that can be evaluated on its own. Split only where a real gate
   boundary falls; a split that leaves both halves sharing one verdict is not a
   split.

   For approved high-risk target work, read
   `references/scalable-transformation.md` before slicing, and never redefine
   transition policy the migration contract already owns. A plan limited to
   gate-enabling prerequisites contains no target work at all.

3. **Write a contract, not a transcript.** Each task gets a stable,
   non-positional ID that is never renumbered or recycled, the files and effects
   it exclusively owns, the tasks it depends on, and an interface stated as exact
   **Consumes** and **Produces** names and types. That interface line is all a
   later task's executor will see of this one.

   Do not pre-write the implementation — the executor has the most context at run
   time. Include exact code only where precision is fragile: a tricky regular
   expression, a security check, a migration statement.

4. **Give every task a precommitted evaluator.** Prefer one that executes and
   returns a verdict on its own. Where nothing executable exists, name the rubric
   and the observations that decide it, so the judgement is bound before the work
   starts rather than argued after it.

   Give every applicable Reference ID a stable implementation conformance
   evaluator ID in the task and index. Its executable check or controlled rubric
   judges the Distinguishing invariants. Functional tests may share the gate,
   but cannot replace those visual and structural invariants.

   The evaluator's identity and owner live outside whatever the implementation
   may mutate. If a task is allowed to edit its own gate, say so explicitly and
   bound the permitted scope, and require a RED run or a deliberate falsification
   before any GREEN result counts.

5. **Write the immutable proposal** to
   `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`. Build `00-index.md` from
   `assets/index-template.md`, and one thin task file per task from
   `assets/task-template.md`. Both carry the identity, ledger, and successor
   fields. Keep decision state, execution state, and evidence out of the
   normative files, and make every normative change a successor rather than an
   edit.

6. **Tag a capability tier per task.** Apply the **Model selection** section of
   `dispatching-parallel-agents` to the decisions that remain in that task.
   Record the suggested tier and reason; the dispatcher binds it to an available
   model when the task runs.

### Self-review before saving (inline, ~30s)

- **Trace each requirement and accepted risk gate to a task or phase by name** — don't skim from memory. An uncovered requirement/risk is a silent gap; a task tracing to neither is scope creep.
- No undefined *scope*: `TBD`, `handle edge cases`, `similar to task N` each mean a task you haven't written. (Deferring *implementation* is fine; deferring *scope* is not.)
- Every task has an executable Evaluator or controlled rubric; the plan has one top-level **Acceptance** check.
- **Every Consumes resolves to a Produces** under the *same* name and type — a `clearLayers()` consumed but only `clearFullLayers()` produced is a build-time break — and no task violates a rule in the index's Constraints block.
- Every UI-bearing task carries its applicable references from the approved
  **Selected visual references** collection and has a conformance evaluator for
  their Distinguishing invariants.
- Every selected Reference ID appears in Visual reference coverage with at least
  one owning task and matching conformance evaluator; no reference is orphaned.
- Independent tasks have disjoint files, data, effects, evaluators, and external
  state; every overlap has an explicit dependency and single transition owner.

### Present, then stop — the plan/execution handoff

Only the user can confirm the plan's *direction*, and this is the cheapest moment to redirect. A hard gate, not a formality:

Show the complete index and exact plan version — goal, architecture,
Constraints, Acceptance, trace, and task/phase list. Send them to the accountable
owner or complete approver set. Ask one conversational question offering
approve and then choose an execution mode, request changes, reject the plan, or
cancel. Recommend the answer supported by the plan review and unresolved risks,
with one sentence of reasoning, then stop.

Only on approval, and in a separate turn, ask one conversational mode question.
Offer inline execution in this session or delegated execution by one fresh
subagent per task in sequence. Explain the context trade-off briefly and
recommend the mode supported by the harness capability and task boundaries.

Offer delegated only where the harness actually provides a subagent action; if
it does not, say so and execute inline. Independent tasks do not select the
mode — the user does. Conflicts follow the plan's decision rule.
- A direct mode answer completes the handoff. Immediately invoke
  `executing-plans` against the approved plan version before any workspace or
  implementation action; choosing a mode is not execution by itself.
- **Presenting and executing are separate turns**; require the direct version-and-mode approval above between them. Do not invoke `executing-plans`, create a task branch/workspace, or write code in the presentation turn.
- **Not a go:** prior approval, praise, comments, constraints, partial answers,
  silence, or a non-interactive session. Revise and re-ask.
- **Proceed unpaused only** under a direct standing order whose scope, owner,
  constraints, and mode explicitly cover unseen plan versions; bind the exact
  produced version to that receipt before execution.

Record approval/mode externally with the current user-role answer or trusted
version-bound receipt; the index cannot authenticate itself. Every normative
change creates a proposed successor. An approved successor invalidates
predecessor-bound reviews, tasks, and evidence until owner reconciliation;
runtime state stays in its ledger.

Before presenting a high-risk plan, run `references/plan-review.md` and resolve every blocker.
