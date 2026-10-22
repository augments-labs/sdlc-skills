---
name: writing-plans
description: "Writes an executable plan: ordered tasks, their dependencies, and how each one is known to be done. Use when approved requirements or a clearly multi-step task need a per-task plan before implementation, or when the user says break this down, lay out the steps first, or this is too big to do in one go. Skip single-step or trivial work."
---

# Writing Plans

Leave the implementation to the executor: write what each task must make
true and how that is judged, not the code.

## When to use

- Detailed requirements are approved, or a precise task spans three or more
  steps or more than one file.
- **Skip** for single-step or trivial changes.
- If the intent is still ambiguous, invoke `clarifying-intent` first. If
  verifiable behavior is still missing, invoke `writing-specs` first. A
  precise task needs neither.
- Fill the classification block (the index's **High-risk classification**
  section). High-risk means any answer there leaves the ordinary route, or
  the user marks the work high-risk. For a high-risk target, read the
  approved migration and assurance contracts before writing a task. If they
  are missing, plan only the gate that is missing, taking the exact proposed
  contract as its input, and put no target work in the plan; record
  unsettled facts as
  evidence, never as accepted deviations.
- Write separate plans for independent subsystems unless one cutover or
  rollback makes them one initiative.

## Available scripts

- **`scripts/plan-version.sh`** — prints the plan's version.

## Step 1: Write the index

1. Open `assets/index-template.md` when starting the index. Fill the header
   first.
2. Leave `Integration cadence` at `plan end`. Write `per task` only when the
   user directly asked for per-task integration, and quote the instruction.
3. Leave `Out-of-task findings` at `log and report`. If the request says to
   fix whatever turns up along the way, write `fix when admitted`, quote the
   instruction, and fill its budget. Plan an instruction with no end as that
   bounded policy; never copy it into a task or the goal.
4. If the approved UI design carries **Selected visual references**, copy
   the complete keyed collection into the index, filling `Approved design
   artifact version` with the design's identity from its ledger row, and map
   every Reference ID to an owning task and a conformance evaluator ID in
   **Visual reference coverage**. If a reference is missing or an ID has no
   owner, return the plan to `ui-ux-design`.
5. Give every file and side effect exactly one owning task. If two tasks
   fall on the same one, add a dependency and name a single transition owner.
6. If one transformation runs across many items, bind the machine-readable
   inventory and the output pattern instead of listing the items.

## Step 2: Write the tasks

1. Slice vertically: one evaluable capability per task. Split only at a real
   check boundary. For high-risk target work, read
   `references/scalable-transformation.md` before slicing, and copy the
   transition policy from the migration contract.

   A request: let the existing `report` command also write CSV. Splitting it
   into "add a CSV serializer" and "wire a `--csv` flag" cuts one capability
   in two: neither half is the requested behavior its own Evaluator could
   accept. One task, "`report --csv` writes the report as CSV", judged by a
   test that runs the command and parses the file, is the slice. "`--csv`
   honours the `--since` filter" earns a second task: it has its own check.

2. Open `assets/task-template.md` before writing each task. Fill `Task ID`,
   `Depends on`, `Files`, `Exclusive ownership/effects`, `Context` as paths.
3. Fill **Consumes** from earlier tasks' exact **Produces** names and types.
   Put existing code and external input artifacts in **Context**; do not invent
   producer tasks for inputs that already exist.
4. Fill `Implementation disciplines` with `test-driven-development` and
   `yagni`, or with the exact carve-out that makes them inapplicable.
5. Fill `Evaluator`: a command that returns a verdict, or a rubric with its
   accountable judge and deciding observations. For a UI task, copy
   `Applicable visual references` and give every Reference ID a **Visual
   conformance gates** row.
6. Fill `Evaluator identity/owner` so the check lives outside what the task
   may change. If a task may edit its own check, write the permitted scope
   and require RED or deliberate falsification before GREEN counts.
7. Fill `Suggested tier` with the **Model selection** section of
   `dispatching-parallel-agents`.
8. Write `00-index.md` plus one file per task to
   `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`. No approval, execution
   state, or evidence goes in these files, except the task checkbox and its
   state label, which mirror the execution ledger. Every later change to
   what they specify is a successor file.

## Step 3: Self-review against the inputs, by name

1. Trace each requirement and each accepted risk gate (the index's Trace
   column keeps that name: the check that covers an accepted risk) to a task
   or phase. Fix each uncovered requirement; cut each task that traces to
   nothing.
2. Replace every `TBD`, `handle edge cases`, `similar to task N` with the
   task it hides. Replace an `Expected:` value that did not come from running
   the command on the current tree with the value the command printed, or
   with a rubric when the command cannot run yet.
3. Confirm every task has an executable Evaluator or a controlled rubric,
   and that the index has one top-level **Acceptance** check.
4. Resolve every Consumes to a Produces under the same name and type. Check
   the index's Constraints block against every task.
5. Confirm every selected Reference ID has a carrying task and a matching
   conformance evaluator.
6. Confirm independent tasks have disjoint files, data, effects, evaluators,
   and external state; every overlap has a dependency and one owner.
7. Fill **Review focus** with up to five spec-implied inputs or failure modes
   that no task Evaluator exercises, or mark it `none`; give every `none yet`
   row a check or name it in the PR.
8. **REQUIRED SUB-SKILL:** invoke `reviewing-plans` when the route is
   high-risk, and bring every blocker it returns to a recorded decision as
   that skill says; for any other plan, ask
   the offer question `reviewing-plans` states.

## Step 4: Present, then stop

1. Run `bash scripts/plan-version.sh` on the plan directory before presenting.
   Show the complete index and the printed version to the `Approval rule`
   owner:

   ```text
   Plan {{path}} — version {{printed version}}
   {{goal, architecture, constraints, acceptance, trace, task list, review findings}}

   1. Approve, then choose an execution mode
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
2. Do not invoke either executor, create a workspace, or write code in this
   turn.
3. Under a standing order, proceed without the pause only when its scope,
   owner, constraints, and mode explicitly cover unseen plan versions. First
   bind the exact version to that receipt.
4. On approval, in a separate turn, ask the mode question from
   `assets/mode-question.md` when this version's row in the
   `External decision ledger` (the ledger: add to it, never rewrite it; it
   sits outside the plan) records no `mode:`. That file owns the block, the
   subagent-action condition (when it may offer the delegated options), and
   how to ask it.
5. Add one row to that ledger: `Identity` = the printed version, `Location`
   = the index path, `State` = approved, `Bound evidence` = the
   `Approval rule` owner and their answer, any review report path, then the
   mode the Step 4.4 question records for the answer: `mode: inline`,
   `mode: delegated`, or `mode: delegated` plus `waves: yes`. Write nothing
   about approval into the index.
6. **REQUIRED SUB-SKILL:** on a direct mode answer, invoke the executor that
   mode names against the approved version before any workspace or
   implementation action: `executing-plans` for inline,
   `subagent-driven-development` for delegated. This skill writes no code.

## Gotchas

- A row keyed to the index's `Normative version` line survives a task-file
  edit; key rows to the printed version.
