---
name: writing-plans
description: "Writes an executable plan: ordered tasks, their dependencies, and how each one is known to be done. Use when approved requirements or a clearly multi-step task need a per-task plan before implementation, or when the user says break this down, lay out the steps first, or this is too big to do in one go. Skip single-step or trivial work."
---

# Writing Plans

Write a small durable index plus one thin contract per task, get the exact
version approved, then hand it to `executing-plans`. Leave the implementation
to the executor: write what each task must make true and how that is judged,
not the code.

## When to use

- Detailed requirements are approved, or a precise task spans ≥3 steps or multiple files.
- **Skip** for single-step or trivial changes — planning them costs more than doing them.
- Intent still ambiguous: invoke `clarifying-intent` first. Verifiable behavior
  still missing: invoke `writing-specs` first. A precise task needs neither.
- Fill the classification block. High-risk means any answer is off the
  ordinary route, or the user marks the work so. For a
  high-risk target, read the approved migration and assurance contracts
  before writing a task. If they are missing, plan only the gate that is
  missing, consuming the exact proposed contract, and put no target work in
  the plan; record unsettled facts as evidence, never as accepted deviations.
- Write separate plans for independent subsystems unless one cutover or
  rollback makes them one initiative.

## Available scripts

- **`scripts/plan-version.sh`** — prints the plan's version.

## Step 1: Write the index

1. Open `assets/index-template.md` when starting the index. Fill the header
   first: exact identity of every approved input, the rule that makes each
   stale, the `Approval rule`, the `Integration cadence`.
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
   `references/scalable-transformation.md` before slicing; copy transition
   policy from the migration contract.
2. Open `assets/task-template.md` before writing each task. Fill `Task ID`
   (stable, non-positional), `Depends on`, `Files`, `Exclusive
   ownership/effects`, `Context` as paths.
3. Fill **Consumes** from earlier tasks' exact **Produces** names and types.
   Put existing code and external input artifacts in **Context**; do not invent
   producer tasks for inputs that already exist.
4. Fill `Implementation disciplines`: `test-driven-development` + `yagni`, or
   the exact carve-out.
5. Include exact code only where precision is fragile: a tricky regex, a
   security check, a migration statement.
6. Fill `Evaluator`. The evaluator — the check this task must pass — is a
   command that returns a verdict, or a rubric with its accountable judge and
   deciding observations. UI task → copy `Applicable visual references` and
   give every Reference ID a **Visual conformance gates** row.
7. Fill `Evaluator identity/owner` so the gate lives outside what the task
   may mutate. A task that may edit its own gate → write the permitted scope
   and require RED or deliberate falsification before GREEN counts.
8. Fill `Suggested tier` with the **Model selection** section of
   `dispatching-parallel-agents`, with the reason.
9. Write `00-index.md` plus one file per task to
   `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`. No approval, execution
   state, or evidence in these files. Every later change to what they specify
   is a successor file.

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
7. Run `assets/plan-review.md` when the recorded answers are high-risk;
   resolve every blocker.

## Step 4: Present, then stop

1. Run `scripts/plan-version.sh` on the plan directory before presenting.
   Show the complete index and the printed version to the `Approval rule` owner:

   ```text
   Plan {{path}} — version {{printed version}}
   {{goal, architecture, constraints, acceptance, trace, task list}}

   1. Approve, then choose an execution mode
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `clarifying-intent` owns what closes it.
2. Do not invoke `executing-plans`, create a workspace, or write code in this
   turn.
3. Standing order → proceed unpaused only when its scope, owner, constraints,
   and mode explicitly cover unseen plan versions. Bind the exact version to
   that receipt first.
4. On approval, in a separate turn, ask the mode question from
   `assets/mode-question.md` when the ledger row for this version records no
   `mode:`. That file owns the block, the subagent-action condition, and how
   to ask it.
5. Append one row to the `External decision ledger`, a ledger (append-only,
   outside the plan): `Identity` = the printed
   version, `Location` = the index path, `State` = approved, `Bound evidence` =
   the `Approval rule` owner and their answer, then `mode: inline` or
   `mode: delegated`. Write nothing about approval into the index.
6. **REQUIRED SUB-SKILL:** on a direct mode answer, invoke `executing-plans`
   against the approved version before any workspace or implementation
   action. This skill writes no code.

## Gotchas

- A row keyed to the index's `Normative version` line survives a task-file
  edit; key rows to the printed version.
