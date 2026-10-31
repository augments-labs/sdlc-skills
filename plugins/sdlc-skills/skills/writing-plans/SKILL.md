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
  rollback makes them one initiative. If the approved design orders the
  work in dependency-ordered slices (a later part builds on what an earlier
  one lands), write the first slice's plan now and each later one after its
  predecessor lands, against the base then current; the index's `Plan set`
  line names the order.

## Available scripts

- **`scripts/plan-version.sh`** — prints the plan's version, or with `--check-contract` and `--verify` checks task-contract invariants and the decision ledger.

## Step 1: Write the index

1. Open `assets/index-template.md` when starting the index. Fill the header
   first.
2. Fill `Plan set`: `none`, or the slices in order, this plan's position,
   its predecessor plan's path, and the next slice's name. Write only this
   slice's tasks; the next slice is planned when this one lands.
3. Leave `Integration cadence` at `plan end`. Write `per task` only when the
   user directly asked for per-task integration, and quote the instruction.
4. Leave `Out-of-task findings` at `log and report`. If the request says to
   fix whatever turns up along the way, write `fix when admitted`, quote the
   instruction, and fill its budget. Plan an instruction with no end as that
   bounded policy; never copy it into a task or the goal.
5. If the approved UI design carries **Selected visual references**, copy
   the complete keyed collection into the index, filling `Approved design
   artifact version` with the design's identity from its ledger row, and map
   every Reference ID to an owning task and a conformance evaluator ID in
   **Visual reference coverage**. If a reference is missing or an ID has no
   owner, return the plan to `ui-ux-design`.
6. Give every file and side effect exactly one owning task. If two tasks
   fall on the same one, add a dependency and name a single transition owner.
7. If one transformation runs across many items, bind the machine-readable
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
   List the plan's `00-index.md` in every task's `Context`, so a dispatched
   worker reads the Constraints and Review focus the task inherits.
3. Fill **Consumes** from earlier tasks' exact **Produces** names and types.
   Put existing code and external input artifacts in **Context**; do not invent
   producer tasks for inputs that already exist.
4. Fill `Implementation disciplines` with `test-driven-development` and
   `yagni`, or with the exact carve-out that makes them inapplicable.
5. Fill `Evaluator`: a command that returns a verdict, or a rubric with its
   accountable judge and deciding observations. For a UI task, copy
   `Applicable visual references` and give every Reference ID a **Visual
   conformance gates** row.

   Before writing a custom check, look in the repository and its runtime for
   an existing deterministic checker of that surface (test runner, linter,
   type checker, schema or config validator, the project's check command),
   and use it when it verifies the claim. Add a heavy new tool only with a
   stated reason.

   If the task's claim rests on a security boundary (path filter, allowlist,
   rate limit, lock), the Evaluator tries to get past it through the real
   component chain: encoded separators, dot segments, case variants, input
   sent without the client's normalisation. For a counting limit, it also
   sends more simultaneous attempts than the limit and expects at most the
   limit to pass.
6. Fill `Evaluator identity/owner` so the check lives outside what the task
   may change. If a task may edit its own check, write the permitted scope
   and require RED or deliberate falsification before GREEN counts.
7. Fill `Suggested tier` with the **Model selection** section of
   `dispatching-parallel-agents`.
8. Write `00-index.md` plus one file per task to
   `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/` or the user-set path. No
   approval, execution state, or evidence goes in these files, except the
   task checkbox and its state label, which mirror the execution ledger.
   Every later change to what they specify is a successor file.

## Step 3: Self-review against the inputs, by name

1. Trace each requirement and each accepted risk gate (the index's Trace
   column keeps that name: the check that covers an accepted risk) to a task
   or phase. Fix each uncovered requirement; cut each task that traces to
   nothing.
2. If you find a gap or contradiction in the approved spec, here or while
   writing tasks, stop planning. No task lists the spec among its `Files` or
   edits it. **REQUIRED SUB-SKILL:** invoke `writing-specs` for a successor
   spec that names the approved one as its predecessor, and plan against the
   successor once it is approved.
3. Replace every `TBD`, `handle edge cases`, `similar to task N` with the
   task it hides. Replace an `Expected:` value that did not come from running
   the command on the current tree with the value the command printed, or
   with a rubric when the command cannot run yet. A user-facing string the
   plan fixes (message, label, help text, doc sentence) that states a
   location, condition, or number names the file and symbol it was checked
   against; rewrite a claim with no such citation to what is known, or
   remove it.
4. Run `bash scripts/plan-version.sh --check-contract` on the plan directory to verify that every `Consumes` resolves to an earlier task's `Produces`, every `Depends on` names an existing non-cancelled task, `Implementation disciplines` is filled, and any file overlap across tasks has a dependency and one owner. Also confirm every task has an executable Evaluator or a controlled rubric, that the index has one top-level **Acceptance** check, and that the index's Constraints block holds across every task.
5. Name in the index's **Architecture** the one type or module that owns
   each domain fact more than one task consumes: a type, a set of kinds and
   where their traits live, the error type that crosses a module boundary.
   If two tasks each define the same fact, give it one owner and make the
   others consume it.
6. Walk the tasks in dependency order against the bound base revision, not
   against the design's description of it. At each task boundary, confirm
   that every path in `Files` exists at the base or is created by this or an
   earlier task, that every input the next task reads already exists, that
   every deleted or renamed artifact has no surviving consumer, and that the
   task's own Evaluator can run on that state.
7. For every interface a task changes or removes (a type, a kind in a set of
   kinds, a trait, a signature, an exported name, a stored format), search
   the base revision for its consumers: callers, exhaustive matches,
   implementations, serialized copies, in every package of the repository.
   Confirm each consumer sits in this task's `Files` or in a dependent
   task's. A consumer no task owns is a gap: fix it before presenting. A
   task whose `Objective` rests on a claim about the current code (a command
   exists, a format carries a field) resolves that claim against the base
   revision; if it does not hold, stop planning: a spec claim gets a
   successor through Step 3.2, and a design claim returns to the owner of
   `system-architecture` for a successor design before planning resumes.
8. Resolve every path and symbol the plan cites against the current
   revision, and replace any that does not resolve. Cite a path or a
   symbol, never a line number.
9. Confirm every selected Reference ID has a carrying task and a matching
   conformance evaluator.
10. Fill **Review focus** with up to five spec-implied inputs or failure
   modes that no task Evaluator exercises, or mark it `none`; give every
   `none yet` row a check or name it in the PR. If a task tells things
   apart by the shape of a string (a key, slug, name, or path used as an
   identity), name two different inputs that produce the same string and
   the task test that separates them, or have the task carry the identity
   as structured data.
11. **REQUIRED SUB-SKILL:** invoke `reviewing-plans` when the route is
    high-risk, and bring every blocker it returns to a recorded decision as
    that skill says; for any other plan, ask
    the offer question `reviewing-plans` states.

## Step 4: Present, then stop

1. Run `bash scripts/plan-version.sh` on the plan directory before presenting.
   Show the complete index and the printed version to the `Approval rule`
   owner:

   ```text
   Plan {{absolute path of the plan directory}} — version {{printed version}}
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
   sits outside the plan) records no `mode:`. Because the approved plan and
   its ledger row live on disk, delegated mode (or starting the executor from
   the plan path in a fresh session) leaves planning-phase context behind.
   That file owns the block, the subagent-action condition (when it may offer
   the delegated options), and how to ask it.
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
- One plan for a design of several slices plans every later slice against
  a base the earlier slices will change: a 37-task plan over a sliced
  design grew through successors until it finished. A slice
  planned after its predecessor lands is planned against the code it will
  meet.
- A `Files` list written from the design names the files the design
  discusses, not the ones the change breaks: a plan that added a kind to a
  set of kinds listed its owning module and missed seven exhaustive matches
  in another package, each found by a worker mid-task and each a successor
  version. Step 3.7 searches the base, not the design.
