---
name: executing-plans
description: "Runs an approved plan task by task through each task's evaluator. Use when the user asks to execute, continue, or resume work governed by an approved plan directory, including one remaining task or a reply choosing inline or delegated mode. Skip a standalone task with no plan directory."
---

# Executing Plans

Run each task of an approved plan through its evaluator (the check it must
pass), then hand the integrated result to review and integration. This skill
never decides what happens to the branch.

## When to use

- The user asks to execute, continue, or resume a plan directory written by
  `writing-plans`, or answers its execution-mode question.
- **Skip** a single task with no plan directory: use `test-driven-development`
  and `yagni` directly.

## Available scripts

- **`scripts/plan-version.sh`** — prints the plan's version.

## Step 1: Verify approval and mode

1. Run `scripts/plan-version.sh` on the plan directory before reading the
   `External decision ledger`, a ledger (append-only). Read every row for this
   index whose `Identity` is the printed version, in ledger order. The last of
   them must be the row whose `Bound evidence` names the `Approval rule`
   owner's approval: a later row that rejects, cancels, or supersedes this
   version closes it, and an append-only ledger keeps the approval visible
   above it. The index cannot approve itself.
2. No such row, a later row closed the version, or the script fails → stop and
   name the missing version, the row that closed it, or the script's error;
   never substitute a version read from the index.
3. No mode in that row (`mode: inline` or `mode: delegated`) → ask the mode
   question from `assets/mode-question.md` before any workspace action, and
   stop.

## Step 2: Set up the workspace

1. Record the approved plan directory by absolute path; read and mirror the
   plan only there.
2. **REQUIRED SUB-SKILL:** invoke `using-git-worktrees`. Fill its record from
   the workspace's own commands.

## Step 3: Check the plan contract

For every task, confirm:

- each `Consumes` names an earlier task's exact `Produces`; existing code and
  external input artifacts belong in `Context`, not an invented producer task
- each `Depends on` names a task that is not cancelled
- the task does not edit its judge unless the approved `Evaluator identity/owner`
  explicitly permits the exact change and requires pre-change RED or deliberate
  falsification; undeclared or weakened criteria block execution
- `Implementation disciplines` is filled
- UI task: `Applicable visual references` match the index's `Selected visual
  references` field for field; run each freshness evaluator now

Record the checked input/output mappings and evaluator ownership in the existing
execution ledger before the first edit. Any failure: report the field and task;
do not start it under an invalid contract.

- Phases or shards in the index: read `references/phase-queues.md` before the first
  task and follow it.
- High-risk task: blocked until its migration and assurance contracts are
  approved and their entry gates passed. Report it; do not start it.
- Read `Integration cadence`: `plan end` (default) or `per task`. It decides
  loop step 8.

## Step 4: The task loop

Take the next task whose `Depends on` tasks are all `done`. Keep the approved
mode; switching needs the user's direct answer.

1. Read the task file, its `Context` paths, its evaluator, and the ledger's
   learnings. Never work from memory of the plan.
2. Write the attempt row before any edit: task ID, attempt ID, current
   revision, evaluator identity, expected observable.
3. **REQUIRED SUB-SKILLS:** invoke `test-driven-development` and `yagni`
   before the first edit or project command. The plan naming them is not
   invocation; the loading action must appear in this session.
   - Delegated mode: **REQUIRED SUB-SKILL:** invoke
     `subagent-driven-development`; it returns at Step 5.
   - Approved parallel work: invoke `dispatching-parallel-agents`.
4. Inspect the result yourself: diff against the attempt's starting revision;
   compare with `Files` and `Exclusive ownership`. Dispatched task: read its
   raw diff, result revision, and evaluator output, never its summary.
5. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` on that exact state:
   the `Evaluator`, every `VCONF` row, `visual-ui-verification` for an
   integrated UI.
6. Append the task state to the ledger and mirror the index checkbox:
   - `done` — every gate passed on the inspected state
   - `done with concerns` — a gate raised something not yet proved
     non-blocking; keep it out of the completion count
   - `blocked` or `needs context` — with blocker, owner, next gate
   Mirror only the task row's checkbox and adjacent label. **Do not change the
   index's `Status` header or normalize it out of the plan's identity.**
7. After parallel work: rerun the combined gate on the merged state before any
   of its tasks is `done`.
8. `per task` cadence only — **REQUIRED SUB-SKILLS:** invoke
   `requesting-code-review` on this task's revision, then
   `finishing-a-branch`. Return after it records its decision.
9. Go to step 1 with the next ready task. Do not report, ask, or pause at `done`.
   Later `todo` tasks are expected. A blocked task does not block independent
   ready work; retain its blocker and skip it until its entry condition changes.
   Leave the loop only when:
   - every task is `done`, or `cancelled`/`superseded` with its approved
     ledger decision → Step 5
   - no authorized ready task can advance → report the unresolved states,
     their blockers and required next conditions
   - a task needs a change to what was approved (scope, interface, evaluator,
     phase, ownership, mode) → write the proposed successor, ask for
     reapproval, end the turn
   - a high-risk entry gate has not passed → report it, end the turn

## Step 5: Finish the plan

In the task workspace recorded in Step 2, in order:

1. **REQUIRED SUB-SKILL:** invoke `verification-before-completion`: the index's
   `Acceptance` check plus every done task's evaluator, on the HEAD that combines
   every task (`per task`: the base after the last integration). Task ledgers are
   not evidence for this state.
2. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` on that revision.
   Reading the diff yourself is not this step.
3. **REQUIRED SUB-SKILL:** invoke `finishing-a-branch` with the workspace
   record from Step 2. It asks the integration question and executes the
   answer. Run no push, PR, merge, or delete here.

| Thought | Reality |
| --- | --- |
| "All tasks are done, so the plan is done" | Tasks are done inside the plan. The plan is done after Acceptance, review, and the integration decision — three skills you have not invoked yet. |
| "The user said not to ask per action, so I'll open the PR" | Standing authorization covers the plan's tasks. Integration was never a task; `finishing-a-branch` owns that decision and asks its own question. |
| "Tests are green — a PR is the natural next step" | Green is task-local evidence. Review and integration are separate gates with their own owners. |
| "The plan says approved, so it is" | A plan cannot authenticate itself. Read the ledger entry or get the answer in this conversation. |
| "Task done — I'll check in before the next" | `done` is a ledger entry, not a decision point. Take the next task. |

## Gotchas

- A task file edited after approval leaves the index unchanged; only the
  printed version moves.
- A workspace created from HEAD lacks an uncommitted plan, or holds an older,
  unapproved committed copy.

## Failures and the circuit breaker

- Failed attempt: append it with its raw evidence and a stable failure-class
  ID; start a new attempt that links to it.
- Worker past its deadline: write `cancellation requested`, wait until it and
  everything it started have stopped, quarantine its output, reject its late
  results.
- Three attempts in one class without convergence: write `blocked` with the
  class and the attempts; end the turn. Never patch shard failures one at a
  time.
- Cancelled or superseded task: needs the approved plan decision in the
  ledger. Neither is `done`.

## Stopping and resuming

- Remaining work will not fit this session: finish the current ledger row,
  then invoke `handoff`.
- On resume, rerun `scripts/plan-version.sh`, then re-read before trusting: the
  latest decision ledger row for the printed version, the workspace's base,
  HEAD, and dirty state through `using-git-worktrees`, the execution ledger,
  and whether each `done` row still matches the current revision.
- Reality contradicts the plan: a change to what was approved → proposed
  successor and direct reapproval; runtime facts → execution ledger only.
