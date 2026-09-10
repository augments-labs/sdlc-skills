---
name: writing-plans
description: "Use when approved requirements or a clearly multi-step task need an executable, per-task plan before implementation — ordered tasks, their dependencies, and how each one is known to be done. Fires on break this down, lay out the steps first, and this is too big to do in one go, even if nobody says plan. Skip single-step or trivial work."
---

# Writing Plans

Write a small durable index plus one thin contract per task, get the exact
version approved, then hand it to `executing-plans`. Leave the implementation
to the executor: write what each task must make true and how that is judged,
not the code.

## When to use

- Detailed requirements are approved, or a precise task spans ≥3 steps or multiple files.
- **Skip** for single-step or trivial changes — planning them costs more than doing them.
- Intent still ambiguous: invoke `interview-me` first. Verifiable behavior
  still missing: invoke `spec-it` first. A precise task needs neither.
- For a high-risk target, read the approved migration and assurance contracts
  before writing a task. If they are missing, plan only the gate that is
  missing, consuming the exact proposed contract, and put no target work in
  the plan; record unsettled facts as evidence, never as accepted deviations.
- Write separate plans for independent subsystems unless one cutover or
  rollback makes them one initiative.

## Step 1: Write the index

1. Open `assets/index-template.md`. Fill the header first: exact identity of
   every approved input, the rule that makes each stale, the `Approval rule`,
   the `Integration cadence`.
2. Leave `Integration cadence` at `plan end`. Write `per task` only when the
   user directly asked for per-task integration, and quote the instruction.
3. Approved UI design with **Selected visual references** → copy the complete
   keyed collection into the index; map every Reference ID to an owning task
   and conformance evaluator ID in **Visual reference coverage**. Missing
   reference or unowned ID → return the plan to `ui-ux-design`.
4. Give every file and side effect exactly one owning task. Two tasks on the
   same one → add a dependency and name a single transition owner.
5. One transformation across many items → bind the machine-readable
   inventory and the output pattern instead of listing items.

## Step 2: Write the tasks

1. Slice vertically: one evaluable capability per task. Split only at a real
   gate boundary. High-risk target work → read
   `references/scalable-transformation.md` first; copy transition policy from
   the migration contract.
2. Open `assets/task-template.md` for each task. Fill `Task ID` (stable,
   non-positional), `Depends on`, `Files`, `Exclusive ownership/effects`,
   `Context` as paths.
3. Fill **Consumes** and **Produces** with exact names and types. A later
   executor sees only that line.
4. Fill `Implementation disciplines`: `test-driven-development` + `yagni`, or
   the exact carve-out.
5. Include exact code only where precision is fragile: a tricky regex, a
   security check, a migration statement.
6. Fill `Evaluator`: a command that returns a verdict, or the rubric,
   evaluator, and deciding observations. UI task → copy `Applicable visual
   references` and give every Reference ID a **Visual conformance gates** row.
7. Fill `Evaluator identity/owner` so the gate lives outside what the task
   may mutate. A task that may edit its own gate → write the permitted scope
   and require RED or deliberate falsification before GREEN counts.
8. Fill `Suggested tier` with the **Model selection** section of
   `dispatching-parallel-agents`, with the reason.
9. Write `00-index.md` plus one file per task to
   `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`. No approval, execution
   state, or evidence in these files. Every later normative change is a
   successor file.

## Step 3: Self-review against the inputs, by name

1. Trace each requirement and accepted risk gate to a task or phase. Fix
   uncovered requirements; cut tasks tracing to nothing.
2. Replace every `TBD`, `handle edge cases`, `similar to task N` with the
   task it hides.
3. Confirm every task has an executable Evaluator or controlled rubric, and
   the index has one top-level **Acceptance** check.
4. Resolve every Consumes to a Produces under the same name and type. Check
   the index's Constraints block against every task.
5. Confirm every selected Reference ID has a carrying task and a matching
   conformance evaluator.
6. Confirm independent tasks have disjoint files, data, effects, evaluators,
   and external state; every overlap has a dependency and one owner.
7. High-risk plan → run `references/plan-review.md`; resolve every blocker.

## Step 4: Present, then stop

1. Show the complete index and its exact `Normative version` to the
   `Approval rule` owner, then end the turn:

   ```text
   Plan {{path}} — version {{Normative version}}
   {{goal, architecture, constraints, acceptance, trace, task list}}

   1. Approve, then choose an execution mode
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

2. Do not invoke `executing-plans`, create a workspace, or write code in this
   turn.
3. Not a go → revise and re-ask: approval of another version, praise,
   comments, constraints, partial answers, silence, a non-interactive session.
4. Standing order → proceed unpaused only when its scope, owner, constraints,
   and mode explicitly cover unseen plan versions. Bind the exact version to
   that receipt first.
5. On approval, in a separate turn, ask the mode question and end the turn:

   ```text
   How should the plan run?

   1. Inline — every task in this session
   2. Delegated — one fresh subagent per task, in sequence

   {{one sentence on the context trade-off}}
   Recommendation: {{the mode the harness supports}}.
   ```

   Offer delegated only if the harness has a subagent action.
6. Write the approval and the mode into the `External decision ledger`
   against the exact `Normative version`. Write nothing about approval into
   the index.
7. **REQUIRED SUB-SKILL:** on a direct mode answer, invoke `executing-plans`
   against the approved version before any workspace or implementation
   action. This skill writes no code.

