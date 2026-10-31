---
name: executing-plans
description: "Runs an approved plan task by task in this session, through each task's evaluator. Use when the user asks to execute, continue, or resume work governed by an approved plan directory in inline mode, including one remaining task or a reply choosing inline mode. Skip a standalone task with no plan directory, and a plan approved in delegated mode."
---

# Executing Plans

Run each task of an approved plan in this session through its evaluator, then
hand the integrated result to review and integration. This skill never decides
what happens to the branch.

## When to use

- The user asks to execute, continue, or resume a plan directory, or answers
  its execution-mode question with inline.
- **Skip** a single task with no plan directory: use `test-driven-development`
  and `yagni` directly.
- **Skip** a plan whose approval row records `mode: delegated`:
  `subagent-driven-development` owns it.

## Available scripts

- **`scripts/plan-version.sh`** — prints the plan's version, or with `--check-contract` and `--verify` checks task-contract invariants and the decision ledger.

## Step 1: Verify approval and mode

1. Run `bash scripts/plan-version.sh --verify` on the plan directory to verify
   the plan's version against the `External decision ledger` (the ledger: add
   to it, never rewrite it) and task-contract invariants. The index cannot
   approve itself; the last decision row (`Section` empty) for the printed
   version must record the `Approval rule` owner's approval and not be closed
   by a later row (`rejected`, `cancelled`, `superseded`, or `changes requested`).
2. If `--verify` fails, stop and name the missing version, the row that closed
   it, or the script's error; never substitute a version read from the index.
3. If `mode=unset`, ask `assets/mode-question.md` before any workspace action,
   and stop.
4. If `mode=delegated`, **REQUIRED SUB-SKILL:** invoke
   `subagent-driven-development`; this skill ends here and runs nothing.

## Step 2: Set up the workspace

If every task's `Files` lies outside any git-tracked project, or the index says
the deliverable is not a repository change, record `workspace: not applicable`
in the ledger, with `plan` in `Section`, and skip 2.2. If even one task is
inside a repository, Step 2.2 and Step 5.3 apply to the whole plan.

1. Record the approved plan directory by absolute path; read and mirror the
   plan only there.
2. **REQUIRED SUB-SKILL:** invoke `using-git-worktrees`. Fill its record from
   the workspace's own commands.

## Step 3: Check the plan contract

Confirm from Step 1's `--verify` output and the task files:

- `Consumes`, `Depends on`, and `Implementation disciplines` passed `--verify`
  (existing code and external input artifacts belong in `Context`, not an
  invented producer task)
- no task edits its judge unless the approved `Evaluator identity/owner`
  explicitly permits the exact change and requires pre-change RED or
  deliberate falsification; undeclared or weakened criteria block execution
- for a UI task, `Applicable visual references` match the index's `Selected
  visual references` field for field; run each freshness evaluator now

Record the checked input/output mappings and evaluator ownership in the
execution ledger (the index's `External execution ledger`) before the first
edit. If any check fails, report the field and the task; do not start it.

- Read `references/phase-queues.md` before the first task when the index
  holds phases or shards, and follow it.
- A high-risk task is blocked until its migration and assurance contracts are
  approved and their entry gates have passed. Report it; do not start it. A
  prerequisite task that only builds an entry gate and touches no target is
  not blocked by that gate.
- Read `Integration cadence`: `plan end` (default) or `per task`.

## Step 4: The task loop

Take the next task whose `Depends on` tasks are all `done`. Keep the approved
mode; switching needs the `Approval rule` owner's direct answer.

1. Read the task file, its `Context` paths, its evaluator, and the ledger's
   learnings. Never work from memory of the plan.
2. Write the attempt row before any edit: task ID, attempt ID, current
   revision, evaluator identity, expected observable.
3. **REQUIRED SUB-SKILLS:** invoke `test-driven-development` and `yagni`
   before the first edit or project command. The plan naming them is not
   invocation; the loading action must appear in this session.
4. Inspect the result yourself: diff against the attempt's starting revision;
   compare with `Files` and `Exclusive ownership/effects`. For a dispatched
   task, read
   its raw diff, result revision, and evaluator output, never its summary. A
   defect or gap outside the task's contract goes to *Findings outside the
   task*; never fix it inside this task.
5. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` on that
   exact state: the `Evaluator`, every `VCONF` row, and
   `visual-ui-verification` for an integrated UI.
6. Append the task state to the ledger and mirror the index checkbox:
   - `done`: every check passed on the inspected state
   - `done with concerns`: a check raised something not yet proved
     non-blocking; keep it out of the completion count
   - `blocked` or `needs context`: with the blocker, the owner, and the next
     check
   Mirror only the task row's checkbox and adjacent label. **Do not change the
   index's `Status` header or normalize it out of the plan's identity.**
7. After parallel work, rerun the combined check on the merged state before any
   of its tasks is `done`.
8. Under `per task` cadence only, **REQUIRED SUB-SKILLS:** invoke
   `requesting-code-review` on this task's revision, then
   `finishing-a-branch`. Return after it records its decision.
9. Go to step 1 with the next ready task. Do not report, ask, or pause at
   `done`. Later `todo` tasks are expected. A blocked task does not block
   independent ready work; retain its blocker and skip it until its entry
   condition changes. Leave the loop only in these cases:
   - If every task is `done`, or `cancelled` or `superseded` with its approved
     ledger decision, go to Step 5.
   - If no authorized ready task can advance, report the unresolved states,
     their blockers, and the next conditions they require.
   - If a task needs a change to what was approved (scope, interface,
     evaluator, phase, ownership), write the proposed successor, ask for
     reapproval, and end the turn. A successor proposed because a task
     cannot be built as written (a consumer no task owns, a path or claim
     that does not hold on the base) is a `gap` row in the ledger. On the
     second `gap` row in one run, start no task: walk every remaining task
     against the current base as `writing-plans` Step 3.6 and 3.7 say, in
     one pass, and propose one successor carrying every gap found. On a
     high-risk route, **REQUIRED SUB-SKILL:** invoke `reviewing-plans` on a
     proposed successor before asking for reapproval; it binds the
     predecessor's report and reviews the delta and what depends on it
     (its Step 1.6).
   - If a high-risk entry gate has not passed and no ready task can advance
     without it, report it and end the turn.

## Step 5: Finish the plan

In the task workspace recorded in Step 2, in order:

1. **REQUIRED SUB-SKILL:** invoke `verification-before-completion`: the
   index's `Acceptance` check plus every done task's evaluator, on the HEAD
   that combines every task (`per task`: the base after the last
   integration), or, when `workspace: not applicable`, on the deliverable
   files identified by their content hash. Task ledgers are not evidence for
   this state.
2. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` on that revision, or
   on that hash in working-tree mode. Reading the diff yourself is not this
   step.
3. If `workspace: not applicable` is recorded, hand the result to the user.
   Otherwise, **REQUIRED SUB-SKILL:** invoke `finishing-a-branch` with the
   workspace record from Step 2. It asks the integration question and
   executes the answer. Run no push, PR, merge, or delete here.
4. Close with "Findings not built": every `finding` row with no `admitted`
   row, with its evidence, one line each. The user decides which become work.

| Thought | Reality |
| --- | --- |
| "All tasks are done, so the plan is done" | Tasks are done inside the plan. The plan is done after Acceptance, review, and the integration decision — three skills you have not invoked yet. |
| "Tests are green — a PR is the natural next step" | Green is task-local evidence. Review and integration are separate checks with their own owners. |
| "The plan says approved, so it is" | A plan cannot authenticate itself. Read the ledger entry or get the answer in this conversation. |
| "Subagents are available, but inline is what I'm already in" | The row's mode decides, and the `Approval rule` owner chose it. A delegated row here is a redirect, not a loop to run. |

## Gotchas

- A gap found mid-task reads as one successor to write now, and the next
  task finds the next: one run wrote fifteen successors this way, each
  reapproved on the earlier reviews, before the plan was walked against the
  base once. The second `gap` row batches the rest.
- An instruction to fix whatever turns up reads as licence to queue every
  advisory as a task, and each fix's review then raises more — reproduced
  by a plan run that carried that instruction with no budget: its 14-row
  list grew to 91. Admit by observed failure, inside the budget.
- A task file edited after approval leaves the index unchanged; only the
  printed version moves.
- A workspace created from HEAD lacks an uncommitted plan, or holds an older,
  unapproved committed copy.

## Failures and the circuit breaker

- If an attempt fails, append it with its raw evidence and a stable
  failure-class ID, and start a new attempt that links to it.
- If a worker is past its deadline, write `cancellation requested`, wait
  until it and everything it started have stopped, set its output aside
  unused, and reject its late results.
- After three attempts in one class without convergence, write `blocked`
  with the class and the attempts, and skip the task under Step 4.9; the
  turn ends only through Step 4.9's exits. Never patch shard failures one
  at a time.

## Findings outside the task

A defect or gap outside the current task's contract is never an edit in this
task. One a later listed task's contract covers is left to that task. Any
other, whether you or a review raised it, is a `finding` row in the
execution ledger, with `plan` in `Section` when no task covers it: where,
what, the evidence. It is never a task because someone wrote it down.

1. If the index's `Out-of-task findings` field says `log and report`, or is
   absent, every finding waits for Step 5.4.
2. Read `references/admitted-findings.md` when the index's `Out-of-task findings` field says `fix when admitted`.

## Stopping and resuming

- If the remaining work will not fit this session, finish the current ledger
  row, then invoke `handoff`.
- On resume, rerun `bash scripts/plan-version.sh`, then re-read before
  trusting: the latest decision row (empty `Section`) for the printed
  version, the workspace's base, HEAD, and dirty state through
  `using-git-worktrees`, the execution ledger, and whether each `done` row
  still matches the current revision.
- When reality contradicts the plan: a change to what was approved gets a
  proposed successor and direct reapproval; a runtime fact goes into the
  execution ledger only.
