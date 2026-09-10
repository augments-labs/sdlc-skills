---
name: executing-plans
description: "Use when asked to execute, run, continue, or resume a multi-task plan directory, and immediately after the user selects an execution mode for an approved plan—even through a terse reply such as inline, delegated, option 1, or option 2. Verify claimed approval, version, mode, and entry state first. Fires on pick up where we left off when a plan directory holds the work. Skip a single task."
---

# Executing Plans

Run each task of an approved plan through its evaluator, then hand the
integrated result to review and integration. This skill never decides what
happens to the branch.

## When to use

- The user asks to execute, continue, or resume a plan directory written by
  `writing-plans`, or answers its execution-mode question.
- **Skip** a single task with no plan directory: use `test-driven-development`
  and `yagni` directly.

## Step 1: Verify approval and mode

1. Open the plan index. Note its `Normative version`.
2. Read the `External decision ledger` entry for that version.
3. Confirm it records approval by the `Approval rule` owner and a mode:
   `inline` or `delegated`. The index cannot approve itself.
4. No approval: stop and say which version needs it.
5. No mode: ask one question and stop.

   ```text
   Plan {{version}} is approved. How should I run it?

   1. Inline — every task in this session
   2. Delegated — one fresh subagent per task, in sequence

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Offer `delegated` only if the harness has a subagent action.

## Step 2: Set up the workspace

**REQUIRED SUB-SKILL:** invoke `using-git-worktrees`. Fill its record from the
workspace's own commands: owner, HEAD, base, clean tree, baseline output,
runtime identities.

## Step 3: Check the plan contract

For every task, confirm:

- each `Consumes` names an earlier task's `Produces`
- each `Depends on` names a task that is not cancelled
- the task does not edit the evaluator that judges it
- `Implementation disciplines` is filled
- UI task: `Applicable visual references` match the index's `Selected visual
  references` field for field; run each freshness evaluator now

Any failure: report the field and the task. Do not start the loop.

- Phases or shards in the index: read `references/phase-queues.md` and follow it.
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
   - Delegated mode: build the packet from `references/subagent-dispatch.md`
     and send it.
   - Approved parallel work: invoke `dispatching-parallel-agents`.
4. Inspect the result yourself: diff against the attempt's starting revision;
   compare with `Files` and `Exclusive ownership`. Dispatched task: read its
   raw diff, result revision, and evaluator output, never its summary.
5. **REQUIRED SUB-SKILL:** invoke `verifying-completion` on that exact state:
   the `Evaluator`, every `VCONF` row, `visual-ui-verification` for an
   integrated UI.
6. Append the task state to the ledger and mirror the index checkbox:
   - `done` — every gate passed on the inspected state
   - `done with concerns` — a gate raised something not yet proved
     non-blocking; keep it out of the completion count
   - `blocked` or `needs context` — with blocker, owner, next gate
7. After parallel work: rerun the combined gate on the merged state before any
   of its tasks is `done`.
8. `per task` cadence only — **REQUIRED SUB-SKILLS:** invoke
   `requesting-code-review` on this task's revision, then
   `finishing-a-branch`. Return after it records its decision.
9. Go to step 1 with the next task. Do not report, ask, or pause at `done`.
   Leave the loop only when:
   - every task is `done` → Step 5
   - the ledger holds any other state → report it, end the turn
   - a task needs a normative change (scope, interface, evaluator, phase,
     ownership, mode) → write the proposed successor, ask for reapproval,
     end the turn
   - a high-risk entry gate has not passed → report it, end the turn

## Step 5: Finish the plan

The last `done` closes the loop, not the plan. It opens no PR. In the
authoritative workspace, in order:

1. **REQUIRED SUB-SKILL:** invoke `verifying-completion`: the index's
   `Acceptance` check plus every task evaluator, on the exact integrated
   revision. Task ledgers are not evidence for this state.
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
| "I'll name the review skill in the PR description" | Naming a skill is not invoking it. Its loading action has to be in the session. |
| "Verified at the last task, no need to rerun" | Evidence binds to a state. The integrated revision is a new state. |
| "Finishing is one command; a skill for it is ceremony" | The command is cheap. The decision it executes — whose branch, which base, reviewed or not — is what the skill gates. |
| "The plan says approved, so it is" | A plan cannot authenticate itself. Read the ledger entry or get the answer in this conversation. |
| "Task done — I'll check in before the next" | `done` is a ledger entry, not a decision point. Take the next task. |

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
- On resume, re-read before trusting: the decision ledger, the workspace's
  base, HEAD, and dirty state through `using-git-worktrees`, the execution
  ledger, and whether each `done` row still matches the current revision.
- All tasks already `done` on resume: go to Step 5. A done ledger is no
  evidence that its three steps ran.
- Reality contradicts the plan: normative change → proposed successor and
  direct reapproval; runtime facts → execution ledger only.
