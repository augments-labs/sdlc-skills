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

## Procedure

1. **Fill the header of `assets/index-template.md` first.** Write the exact
   identity of every approved input this plan consumes, the rule that makes
   each stale, the `Approval rule`, and the `Integration cadence`. Leave the
   cadence at `plan end` unless the user directly asked for per-task
   integration; then write `per task` and quote the instruction.

   When the approved UI design carries **Selected visual references**, copy the
   complete keyed collection into the index and map every Reference ID to an
   owning task and conformance evaluator ID in **Visual reference coverage**.
   If a reference is missing or a Reference ID has no owner, return the plan to
   `ui-ux-design`; do not reconstruct a preference from prose.

   Give every file and every side effect exactly one owning task. Where two
   tasks would touch the same one, add an explicit dependency and name a single
   transition owner. For one transformation applied across many items, bind the
   machine-readable inventory and the output pattern instead of listing items.

2. **Slice vertically, one evaluable capability per task.** Split only where a
   real gate boundary falls; do not split where both halves would share one
   verdict.

   For approved high-risk target work, read
   `references/scalable-transformation.md` before slicing, and copy transition
   policy from the migration contract rather than restating it.

3. **Write each task from `assets/task-template.md` as a contract.** Fill
   `Task ID` with a stable, non-positional ID; `Depends on`; `Files` and
   `Exclusive ownership/effects`; `Context` as paths, not paraphrase; and the
   interface as exact **Consumes** and **Produces** names and types — a later
   task's executor sees only that line. Fill `Implementation disciplines` with
   `test-driven-development` + `yagni`, or the exact carve-out.

   Include exact code only where precision is fragile: a tricky regular
   expression, a security check, a migration statement.

4. **Write a precommitted `Evaluator` for every task.** Prefer a command that
   returns a verdict on its own; otherwise name the rubric, the evaluator, and
   the observations that decide it. For a UI-bearing task, copy its
   `Applicable visual references` field for field and give every Reference ID
   a row in **Visual conformance gates**.

   Fill `Evaluator identity/owner` so the gate lives outside what the task may
   mutate. If a task may edit its own gate, write the permitted scope and
   require a RED run or deliberate falsification before any GREEN counts.

5. **Fill `Suggested tier` per task** by applying the **Model selection**
   section of `dispatching-parallel-agents` to the decisions that remain in
   that task, with the reason.

6. **Write the immutable proposal** to
   `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`: `00-index.md` plus one task
   file per task. Keep approval, execution state, and evidence out of these
   files; make every later normative change a successor file, never an edit.

### Self-review before saving

7. **Check the plan against its inputs, by name, not from memory:**

   - Trace each requirement and accepted risk gate to a task or phase; fix any
     uncovered requirement and cut any task tracing to nothing.
   - Replace every `TBD`, `handle edge cases`, and `similar to task N` with the
     task it hides; deferring implementation is fine, deferring scope is not.
   - Confirm every task has an executable Evaluator or controlled rubric and the
     index has one top-level **Acceptance** check.
   - Resolve every Consumes to a Produces under the *same* name and type, and
     check no task violates the index's Constraints block.
   - Confirm every selected Reference ID appears in Visual reference coverage
     with a carrying task and a matching conformance evaluator.
   - Confirm independent tasks have disjoint files, data, effects, evaluators,
     and external state, and every overlap has a dependency and one owner.

8. **For a high-risk plan, run `references/plan-review.md`** and resolve every
   blocker before presenting.

### Present, then stop

9. **Show the complete index and its exact `Normative version`** — goal,
   architecture, Constraints, Acceptance, trace, and task/phase list — to the
   owner the `Approval rule` names. Ask one conversational question offering:
   approve and then choose an execution mode, request changes, reject, or
   cancel. Recommend the answer the review and open risks support, with one
   sentence of reasoning. Then end the turn. Do not invoke `executing-plans`,
   create a workspace, or write code in this turn.

10. **Treat as not a go, and revise and re-ask:** earlier approval of another
    version, praise, comments, constraints, partial answers, silence, or a
    non-interactive session. Proceed unpaused only under a direct standing
    order whose scope, owner, constraints, and mode explicitly cover unseen
    plan versions; bind the exact produced version to that receipt first.

11. **On approval, in a separate turn, ask one conversational mode question:**
    inline in this session, or delegated to one fresh subagent per task in
    sequence. Say the context trade-off in a sentence and recommend the mode
    the harness supports. Offer delegated only if the harness has a subagent
    action; otherwise say so and offer inline. The user picks the mode, not
    the task shape.

12. **Write the approval and the mode into the `External decision ledger`**
    against the exact `Normative version`, with the user's answer or a
    version-bound receipt. Write nothing about approval into the index itself.

13. **REQUIRED — on a direct mode answer, invoke `executing-plans`** against
    the approved version before any workspace or implementation action. A mode
    reply is not execution, and this skill writes no code.
