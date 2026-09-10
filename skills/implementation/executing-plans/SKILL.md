---
name: executing-plans
description: "Use when asked to execute, run, continue, or resume a multi-task plan directory, and immediately after the user selects an execution mode for an approved plan—even through a terse reply such as inline, delegated, option 1, or option 2. Verify claimed approval, version, mode, and entry state first. Fires on pick up where we left off when a plan directory holds the work. Skip a single task."
---

# Executing Plans

Run every task of an approved plan through its own evaluator, then hand the
integrated result to the skills that review and integrate it. This skill moves
task state; it never decides what happens to the branch.

## When to use

- The user asks to execute, continue, or resume a plan directory written by
  `writing-plans`, or answers its execution-mode question.
- **Skip** a single task with no plan directory: implement it directly under
  `test-driven-development` and `yagni`.

## Before the first task

1. **Open the plan index and read its decision-ledger entry** for the exact
   `Normative version` shown in the index. Confirm the entry records approval
   by the owner the `Approval rule` names, and an execution mode, `inline` or
   `delegated`. The index itself is not evidence of either; only the ledger
   or the user's direct answer in this conversation is.

   Missing approval: stop and say which version needs it. Missing mode: ask
   one question — inline in this session, or one fresh subagent per task in
   sequence — recommend the one the harness supports, and stop. Offer
   `delegated` only if the harness has a subagent action; otherwise say so and
   run inline.

2. **Invoke `using-git-worktrees`** and complete its record: workspace owner,
   HEAD, the intended base, a clean tree, the baseline gate's actual output,
   and the runtime identities in use. Read each from the workspace with its
   commands, not from what the plan says should be true.

3. **Check every task file against the plan contract before editing code.**
   For each task confirm: every `Consumes` names a `Produces` from an earlier
   task; every `Depends on` points at a task that is not cancelled; the task
   does not edit the evaluator that judges it; `Implementation disciplines` is
   filled. For a UI-bearing task, confirm its `Applicable visual references`
   match the index's `Selected visual references` field for field, and run each
   freshness evaluator now. Any failure stops here: report the field and the
   task, and do not start the loop.

4. **Choose the loop.** Bounded tasks use the loop below. If the index carries
   phases or shards, read `references/phase-queues.md` and follow it; never
   copy a queue into individual tasks. A high-risk task stays blocked until its
   migration and assurance contracts are approved and their entry gates have
   passed; report that instead of starting it.

5. **Read `Integration cadence` from the index.** Absent or `plan end`: tasks
   end at `done` and nothing is pushed, published, or merged until *Finishing
   the plan*. `per task`: each task's `done` runs loop step 8.

## The task loop

Take the next task whose `Depends on` tasks are all `done`. Keep the approved
mode; switching between inline and delegated needs the user's direct answer.

1. **Read the task file, its `Context` paths, and its evaluator.** Read the
   ledger's learnings for this plan. Do not start from memory of the plan.

2. **Write the attempt row before any edit:** task ID, a new attempt ID, the
   current revision, the evaluator's identity, and the observable the task
   will change. This row is what a later resume reconciles against.

3. **REQUIRED — invoke `test-driven-development` and `yagni`** through the
   harness's skill-loading action before the first project command or code
   edit of a behavior-affecting task. The plan naming them is routing, not
   invocation; the loading action has to appear in this session. Then run
   their RED or preservation cycle and scope challenge on this task.

   Delegated mode: build the packet from `references/subagent-dispatch.md`
   and send it. Approved parallel work: invoke `dispatching-parallel-agents`.

4. **Inspect the result yourself.** Diff the workspace against the attempt's
   starting revision and compare it with the task's `Files` and `Exclusive
   ownership` lines. For a dispatched task, read its raw diff, its result
   revision, and its evaluator output; never its summary.

5. **REQUIRED — invoke `verifying-completion`** and run the task's full gate
   set on that exact state: the `Evaluator`, every `VCONF` row, and
   `visual-ui-verification` for an integrated UI. Keep its ledger; this skill
   keeps only the task state.

6. **Append the task state to the external ledger.** Write `done` only when
   every required gate passed on the state you inspected. Write `done with
   concerns` when a gate raised something not yet proved non-blocking, and keep
   it out of the completion count until it is. Write `blocked` or `needs
   context` with the blocker, its owner, and the next gate. Mirror the row to
   the index checkbox.

7. **After parallel work, rerun the combined gate** on the merged state before
   any of its tasks is `done`.

8. **`per task` cadence only: REQUIRED — invoke `requesting-code-review` on
   this task's revision, then `finishing-a-branch`.** Return here after that
   skill has recorded its decision. Under `plan end` cadence skip this step.

9. **Go to step 1 with the next task.** Do not report, ask, or pause at
   `done`: the approved plan authorizes every task in it. Leave the loop only
   when one of these is true, and say which:

   - every task is `done` → go to *Finishing the plan*;
   - the ledger holds any other state for a task → report it and end the turn;
   - a task needs a normative change (scope, interface, evaluator, phase,
     ownership, mode) → write the proposed successor, ask for reapproval, end
     the turn;
   - a high-risk task's entry gate has not passed → report it, end the turn.

## Finishing the plan

The last task's `done` closes the loop, not the plan, and it opens no PR. Run
these in order, in the authoritative workspace; each loading action has to
appear in this session.

1. **REQUIRED — invoke `verifying-completion`** and run the index's
   `Acceptance` check on the exact integrated revision, plus every task
   evaluator again on that revision. Task ledgers are not evidence for this
   state.

2. **REQUIRED — invoke `requesting-code-review`** on that revision. A task
   evaluator never stood in for review, and reading the diff yourself is not
   this step.

3. **REQUIRED — invoke `finishing-a-branch`** with the workspace record from
   step 2 of *Before the first task*. It asks the user the integration
   question and executes the answer. Run no push, PR, merge, or delete from
   this skill, and do not choose for the user.

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

- **A failed attempt:** append it with its raw evidence, give the failure a
  stable class ID, and start a new attempt that links to it.
- **A worker that misses its deadline:** write `cancellation requested`, wait
  until it and everything it started have stopped, quarantine what it
  produced, and let the retry reject any late result from it.
- **Three attempts in one failure class without convergence:** stop the task,
  write `blocked` with the class and the three attempts, and end the turn.
  High-risk contracts set their own thresholds; never patch shard failures one
  at a time.
- **Cancelled or superseded tasks** need the approved plan decision that
  removed them, written in the ledger; neither counts as done.

## Stopping and resuming

- **When the remaining work will not fit this session** — context pressure,
  an approaching limit — finish the current task's ledger row, then invoke
  `handoff`. Do not continue into a truncated context.
- **On resume, re-read before trusting:** the plan's decision ledger, the
  workspace's base, HEAD, and dirty state through `using-git-worktrees`, the
  execution ledger, and whether each `done` row's evidence still matches the
  current revision. A later task file existing says nothing about an earlier
  task having passed.
- **A resumed plan whose tasks are all `done`** enters *Finishing the plan*
  directly; a done ledger is not evidence that any of its three steps ran.
- **When reality contradicts the plan,** update the owner of what changed:
  a normative change gets a proposed successor and direct reapproval; runtime
  facts go only to the execution ledger.
