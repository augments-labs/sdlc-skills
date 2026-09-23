---
name: subagent-driven-development
description: "Runs an approved plan's tasks through fresh subagents: one implementer per task, a reviewer on its diff, and a bounded fix loop, with the controller keeping every decision. Use when an approved plan is about to be built by dispatched workers rather than in this session, when the user asks for subagents or workers to do the building, or when the user replies choosing delegated mode. Skip a lone task with no plan directory, and independent tasks that want concurrent fan-out."
---

# Subagent-Driven Development

You are the controller. Fresh workers build and review one task at a time; you
hold the plan, the ledger, and every decision they may not take. This skill
never decides what happens to the branch.

## When to use

- An approved plan is about to be built by dispatched workers rather than
  here: the user asked for workers, or answered the execution-mode question
  with delegated. Prefer this mode wherever the harness has a subagent action.
- **Skip** building the tasks in this session — `executing-plans` owns that
  — a lone task with no plan directory, and independent tasks that should run
  at the same time — that fan-out belongs to `dispatching-parallel-agents`.
- **Skip** a plan whose index holds phases or shards: its queues, leases, and
  capacity envelope run inline through `executing-plans`, never through a
  slim brief. Its row says delegated → Step 1.5 first.

## Available scripts

- **`scripts/plan-version.sh`** — prints the plan's version.
- **`scripts/sdd-workspace.sh`** — opens the plan-scoped ledger and re-checks
  that it still binds to the plan. Run it before the first dispatch, and again
  after every compaction.
- **`scripts/task-brief.sh`** — renders a role brief from a task file, and
  refuses one with a script slot left unfilled. Run it for every dispatch.
- **`scripts/review-package.sh`** — assembles one task's diff and file list for
  a reviewer. Run it when an implementer reports.

## Step 1: Verify approval and mode

1. Run `bash scripts/plan-version.sh` on the plan directory before reading the
   `External decision ledger`, a ledger (append-only). Read every row for this
   index whose `Identity` is the printed version, in ledger order. The last of
   them must be the row whose `Bound evidence` names the `Approval rule`
   owner's approval; a later row that rejects, cancels, or supersedes this
   version closes it. The index cannot approve itself.
2. No such row, a later row closed the version, or the script fails → stop and
   name the missing version, the row that closed it, or the script's error;
   never substitute a version read from the index.
3. No mode in that row → ask `assets/mode-question.md` before any workspace
   action, and stop. A request for workers made before approval is not the
   answer; rendering the question collects it.
4. `mode: inline` in that row → stop; `executing-plans` owns it, and only the
   user's direct answer changes the mode.
5. `mode: delegated` on an index with phases or shards → this skill cannot
   run it and `executing-plans` will not: ask the `Approval rule` owner for a
   direct inline answer, append it as a new approved row for this version in
   the shape `writing-plans` Step 4.5 gives, with `mode: inline`, and stop.
   The last row's mode is the one 1.1 reads.

## Step 2: Open the run

1. Record the approved plan directory by absolute path; read the plan only
   there.
2. **REQUIRED SUB-SKILL:** invoke `using-git-worktrees`. One worktree holds the
   whole plan and every worker writes inside it. Never hand a worker the shared
   checkout.
3. Open the ledger:

   ```bash
   bash scripts/sdd-workspace.sh --plan {{plan-dir}}
   ```

   Line 1 is the plan's identity. After a compaction, read the ledger before
   anything else and re-check it with `--check`: the ledger, not your memory of
   the conversation, is where the run resumes. It is this run's execution
   ledger; the decision ledger stays where the index points.
4. Check the plan contract before the first dispatch: every `Consumes` names
   an earlier task's exact `Produces`; every `Depends on` names a task that is
   not cancelled; no task edits its own judge unless its approved `Evaluator
   identity/owner` permits the exact change; `Implementation disciplines` is
   filled; a UI task's `Applicable visual references` match the index's
   `Selected visual references` field for field, and each freshness evaluator
   runs now. Any failure → report the field and task; dispatch nothing under
   an invalid contract.
5. High-risk task: blocked until its migration and assurance contracts are
   approved and their entry gates passed. Report it; dispatch nothing for it.
6. Scan for conflicts. List the files each task claims, and write every pair
   claiming the same file into the ledger as an ordering.
7. Read `Integration cadence`: `plan end` (default) or `per task`. It decides
   Step 5.6.

## Step 3: Rule, don't stall

A worker that asks a question gets an answer and a ledger row, not a pause. Stop
and ask the user only when the next act would be:

- irreversible — data, history, or something already published;
- security-sensitive — secrets, credentials, permissions, a trust boundary;
- effective outside the worktree;
- or the plan is broken on every path you can see, not merely the first one.

Everything else is a ruling. Write it in the ledger with its reason and carry it
into the next brief, so the next worker inherits the decision instead of
re-litigating it. A change to what was approved — scope, interface, evaluator,
ownership, mode — is never a ruling: write the proposed successor, ask for
reapproval, end the turn.

## Step 4: Dispatch one task

1. Take the next task whose dependencies are done.
2. Batch tasks into one dispatch only when they are small and the same shape —
   same kind of file, same act. Different shapes go separately, whatever their
   size.
3. Fill `assets/implementer.md` when dispatching an implementer — every input a
   file path the worker opens for itself, the task contract pasted and nothing
   else — rendering it with `bash scripts/task-brief.sh`, which inserts
   `assets/implementer-report.md` before dispatch.
4. Set the tier explicitly, from the Model selection table in
   `dispatching-parallel-agents`. A brief written as prose starts at the middle
   tier; use the small tier only when the brief carries the literal code to
   apply.
5. Bind the role to a runtime: where the harness exposes a named agent whose
   contract covers the role, dispatch that agent with the role brief; otherwise
   dispatch a general subagent with the role prompt. Name mappings belong in
   the adapters, never here.
6. Write the dispatch row before dispatching: task ID, attempt, base
   revision, evaluator identity, tier. Then dispatch per
   `dispatching-parallel-agents` Step 2 — it owns the receipt, the
   not-dispatched rule, and cancellation.

## Step 5: Review the diff, then fix

1. Build the package with `bash scripts/review-package.sh`, then fill
   `assets/task-reviewer.md` when the implementer reports, rendering it with
   `bash scripts/task-brief.sh`, which inserts
   `assets/task-reviewer-report.md` before dispatch.
2. Findings open a fix round. Rounds 1 to 3 go back to the same implementer,
   which still holds the task. Rounds 4 and 5 go to a fresh implementer one tier
   up, briefed from the findings file — it has read nothing.
3. Fill `assets/re-reviewer.md` when a fix round returns, so the second look
   judges the fix and its blast radius rather than the task again, rendering it
   with `bash scripts/task-brief.sh`, which inserts
   `assets/re-reviewer-report.md` before dispatch.
4. Five rounds without convergence trips the breaker. Stop dispatching, write
   the adjudication in the ledger — the finding, what each round changed, why it
   did not converge — and then either decide it yourself under Step 3 or hand
   the user that row. Never open a sixth round.
5. Read the diff yourself against the task, then **REQUIRED SUB-SKILL:** invoke
   `verification-before-completion` on the result revision: the task's
   `Evaluator`, every `VCONF` row, `visual-ui-verification` for an integrated
   UI. Then record its state: done, done with concerns, blocked, or needs
   context. Mirror only the task row's checkbox and adjacent label. **Do not
   change the index's `Status` header or normalize it out of the plan's
   identity.**
6. `per task` cadence only — **REQUIRED SUB-SKILLS:** invoke
   `requesting-code-review` on this task's revision, then `finishing-a-branch`.
   Return after it records its decision.
7. Go to Step 4 with the next ready task. Do not report, ask, or pause at
   `done`. Every task `done`, or `cancelled`/`superseded` with its approved
   ledger decision → Step 6. No ready task can advance, or a high-risk entry
   gate has not passed → report the unresolved states and their blockers, end
   the turn.

## Step 6: Finish the plan

In the worktree from Step 2, in order:

1. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` on the
   integrated revision (`per task`: the base after the last integration): the
   index's `Acceptance` check plus every done task's evaluator. Worker reports
   are claims; this is the evidence.
2. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` on the whole branch,
   once, and let it drive a single fix wave.
3. **REQUIRED SUB-SKILL:** invoke `finishing-a-branch` with the workspace
   record from Step 2. It asks the integration question and executes the
   answer. Run no push, PR, merge, or delete here.
4. Close with "Rulings I made": every ruling in the ledger, one line each, so
   the person reading the result sees the decisions taken on their behalf.

| Thought | Reality |
| --- | --- |
| "Every worker returned DONE, so the plan is done" | DONE is a claim per task. The plan is done after Acceptance, review, and the integration decision — three skills you have not invoked yet. |
| "The reviewer subagent passed it, so review is covered" | That reviewed one task's diff against its contract. The branch review is a separate gate on the integrated state. |
| "The user said not to ask, so I'll open the PR" | Standing authorization covers the plan's tasks. Integration was never a task; `finishing-a-branch` owns that decision. |

## Gotchas

- A worker's status is not a verdict on the task — reproduced whenever a `DONE`
  arrives with a diff that edits a file the brief never named. Read the diff
  yourself; that is what Step 5.5 is for.
- Resuming from the conversation after a compaction re-runs finished tasks and
  loses every ruling, because by then neither is in the conversation. Line 1 of
  the ledger exists for exactly that moment.
- A fresh implementer in round 4 has read nothing. "Fix the findings" names a
  file it does not have; give it the findings path and the task path.
- A worker that dispatches its own workers returns a diff nobody reconciled and
  receipts you never held. Every brief here prohibits subdispatch; keep it.
- The controller never edits, so `test-driven-development` and `yagni` load in
  the implementer, where the brief requires them; loading them here proves
  nothing about the worker's session.

## Stopping and resuming

- Remaining work will not fit this session: finish the current ledger row,
  then invoke `handoff`.
- On resume, rerun `bash scripts/plan-version.sh` and re-read the latest decision
  ledger row for the printed version before `--check` on the run ledger: the
  run ledger detects an amended plan, not a row that closed the version.

## Common mistakes

- Editing a worker's diff yourself instead of opening a fix round — now nobody
  has reviewed the state that ships.
