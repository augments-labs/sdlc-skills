---
name: subagent-driven-development
description: "Runs an approved plan's tasks through fresh subagents: one implementer per task, a reviewer on its diff, and a bounded fix loop, with the controller keeping every decision. Use when an approved plan is about to be built by dispatched workers rather than in this session, when the user asks for subagents or workers to do the building, or when the user replies choosing delegated mode. Skip a lone task with no plan directory."
---

# Subagent-Driven Development

You are the controller. Fresh workers build and review one task, or one
approved wave, at a time; you hold the plan, the ledger, and every decision
they may not take. This skill never decides what happens to the branch.

## When to use

- An approved plan is about to be built by dispatched workers rather than
  here: the user asked for workers, or answered the execution-mode question
  with delegated.
- **Skip** building the tasks in this session (`executing-plans` owns that)
  and a lone task with no plan directory.
- **Skip** a plan whose index holds phases or shards: its queues, leases, and
  capacity envelope run inline through `executing-plans`, never through a
  slim brief. If its row says delegated, go to Step 1.5 first.

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
   `External decision ledger` (a ledger: add to it, never rewrite it). Read
   every decision row for this index whose `Identity` is the printed
   version, in ledger order: a decision row leaves `Section` empty, and an
   execution row carries a task ID there. The last of them must be the row
   whose `Bound evidence` names the `Approval rule` owner's approval; a
   later row that rejects, cancels, or supersedes this version closes it.
   The index cannot approve itself.
2. If there is no such row, if a later row closed the version, or if the
   script fails, stop and name the missing version, the row that closed it,
   or the script's error; never substitute a version read from the index.
3. If that row records no mode, ask `assets/mode-question.md` before any
   workspace action, and stop. A request for workers made before approval is
   not the answer; rendering the question collects it.
4. If that row says `mode: inline`, stop; `executing-plans` owns it, and only
   the `Approval rule` owner's direct answer changes the mode.
5. If that row says `mode: delegated` and the index has phases or shards,
   this skill cannot run it and `executing-plans` will not: ask the
   `Approval rule` owner for a direct inline answer, append it as a new
   approved row for this version in the shape `writing-plans` Step 4.5 gives,
   with `mode: inline`, and stop. The last decision row's mode is the one 1.1
   reads.

## Step 2: Open the run

1. Record the approved plan directory by absolute path; read the plan only
   there.
2. **REQUIRED SUB-SKILL:** invoke `using-git-worktrees`. One worktree holds the
   whole plan; a worker writes inside it, or inside the wave worktree the
   controller cut for it from that worktree's HEAD. Never hand a worker the
   shared checkout. Before the first dispatch, confirm that the workspace
   record's `Local commit authority` holds a yes; if it holds none, ask the
   checkpoint question `using-git-worktrees` gives and record the answer. On
   a no, stop: review packages need commits, so this mode cannot run; hand
   the mode back to the `Approval rule` owner.
3. Open the ledger:

   ```bash
   bash scripts/sdd-workspace.sh --plan {{plan-dir}}
   ```

   Line 1 is the plan's identity. After a compaction, read the ledger before
   anything else and re-check it with `--check`: the ledger, not your memory of
   the conversation, is where the run resumes. It lives at
   `.sdlc-skills/evidence/{{plan directory name}}/sdd-ledger.md` and holds
   this run's dispatches, rulings, and findings; task states go to the
   index's `External execution ledger`, one row per task state as
   `artifact-layout.md` maps an execution row, and the decision ledger stays
   where the index points.
4. Check the plan contract before the first dispatch: every `Consumes` names
   an earlier task's exact `Produces`; every `Depends on` names a task that is
   not cancelled; no task edits its own judge unless its approved `Evaluator
   identity/owner` permits the exact change; `Implementation disciplines` is
   filled; a UI task's `Applicable visual references` match the index's
   `Selected visual references` field for field, and each freshness evaluator
   runs now. If any of these fails, report the field and task; dispatch
   nothing under an invalid contract.
5. A high-risk task is blocked until its migration and assurance contracts
   are approved and their entry gates have passed. Report it; dispatch
   nothing for it. A prerequisite task that only builds an entry gate and
   touches no target is not blocked by that gate.
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
- settling a requirement clause with two readings, or a product or
  architecture choice the approved artifacts do not settle;
- or the plan is broken on every path you can see, not merely the first one.

Everything else is a ruling. Write it in the ledger with its reason and carry it
into the next brief. A change to what was approved — scope, interface, evaluator,
ownership — is never a ruling: write the proposed successor, ask for
reapproval, end the turn. A mode change is never a ruling either: it takes the
`Approval rule` owner's direct answer, as Step 1.4 says.

## Step 4: Dispatch one task

1. Take the next task whose dependencies are done. If the approval row says
   `waves: yes`, take every ready task that passes the independence test of
   `dispatching-parallel-agents` Step 1. Before each dispatch row, cut that
   task a branch and worktree from the plan worktree's HEAD yourself under
   the plan worktree's commit authority; `using-git-worktrees` run by the
   worker would reuse yours. The brief grants the worker local commit
   authority on that branch, and no push. Dispatch them together through
   `dispatching-parallel-agents` Step 2; sequence a failing pair.
2. Batch tasks into one dispatch only when they are small and the same shape:
   same kind of file, same act.
3. Fill `assets/implementer.md` when dispatching an implementer, rendering it
   with `bash scripts/task-brief.sh`, which pastes the task contract and
   inserts `assets/implementer-report.md` before dispatch. Pass with
   `--input` each path the worker would otherwise search for: the plan index,
   whose `Constraints` every task inherits; the task's `Context`; the
   instructions file and the nearest test of the module it edits where they
   exist; and a file, written beside the report, of the ledger rulings that
   touch this task. Paths the worker opens for itself;
   never pasted history.
4. Set the tier explicitly, from the Model selection table in
   `dispatching-parallel-agents`.
5. Bind the role to a runtime: where the harness exposes a named agent whose
   contract covers the role, dispatch that agent with the role brief; otherwise
   dispatch a general subagent with the role prompt. Name mappings belong in
   the adapters, never here.
6. Write the dispatch row before dispatching: task ID, attempt, base
   revision, evaluator identity, tier. Then dispatch per
   `dispatching-parallel-agents` Step 2. It owns the dispatch receipt, the
   not-dispatched rule, and cancellation. When an implementer cannot be
   dispatched, its question omits option 1: the controller never edits, and
   building a task inline is a mode change, which only the `Approval rule`
   owner's direct answer makes, as Step 1.4 says. Until a worker's report
   arrives, run only read-only git in its worktree; an add, commit, or reset
   there races its writes.

## Step 5: Review the diff, then fix

1. If a worker ends without its report file, ask that same worker for the
   report once before treating it as stalled under
   `dispatching-parallel-agents` Step 2.4. Before packaging, confirm the
   implementer and everything it started have stopped, and that `git status`
   shows nothing changed after the reported revision; otherwise stop the
   stragglers and rebuild the range. Build the package with
   `bash scripts/review-package.sh`, then fill `assets/task-reviewer.md` when
   the implementer reports, rendering it with `bash scripts/task-brief.sh`,
   which inserts `assets/task-reviewer-report.md` before dispatch. Pass the
   plan index with `--input` for its `Review focus`.
2. Verify each finding on its merits first, as `receiving-code-review` Step 2
   says; one that fails the check goes to the ledger with its evidence and
   opens no round. Then sort the findings before any round opens, first by
   what each one touches, whatever the reviewer rated it:
   - an edit the diff makes outside the contract, the implementer report's
     `Done beyond the contract` line included, is `blocking`: a fix round
     removes it, unless a ruling names the contract clause that needs it.
   - a defect or gap outside the contract, in code the diff does not touch,
     in the review or under the implementer report's `Defects noticed and
     not edited` line and `## Gaps outside this task`, goes to *Findings
     outside the task*. It never enters a round.
   - a `blocking` finding opens a fix round.
   - an `advisory` finding gets one recorded decision in the ledger:
     accepted as it stands, folded into a round a blocking finding opened,
     or ruled blocking with the failure it causes. It never opens a round or
     a task by itself.
   - a `## Declined to judge` or `## Limitations` entry gets one recorded
     decision before the task is `done`. On a main user flow, run the check
     or remove the dependency on the unrun environment; "check at deploy" is
     no decision.
   - a `## Discoveries for later tasks` entry is copied into the ledger as a
     ruling naming the later task; one that changes that task's approved
     contract goes to Step 3's reapproval instead.

   The rounds are the task's repair budget from `receiving-code-review`:
   five unless the user or the plan sets another number, and the `per task`
   review rounds of 5.6 count against the same budget. All but the last two
   rounds go back to the same implementer, which still holds the task. The
   last two go to a fresh implementer one tier up, briefed from the findings
   file; it has read nothing. Every round gets its findings by file path,
   never pasted, and when the same implementer's context has grown large, a
   fresh one at its tier takes the round from that file. A round may answer a
   finding with no change and evidence that the claim is false: the re-review
   weighs it once and withdraws the finding or upholds it, and an upheld
   finding stays in the loop, counted against the budget.
3. Fill `assets/re-reviewer.md` when a fix round returns, so the second look
   judges the fix and its blast radius rather than the task again, rendering it
   with `bash scripts/task-brief.sh`, which inserts
   `assets/re-reviewer-report.md` before dispatch.
4. When the budget is spent without convergence, stop dispatching, write the
   adjudication in the ledger (the finding, what each round changed, why it
   did not converge), record the task `blocked` as `unconverged`, and hand
   the user that row. Never open a round past the budget.
5. Read the diff yourself against the task, then **REQUIRED SUB-SKILL:** invoke
   `verification-before-completion` on the result revision, with the task's
   `Evaluator`, every `VCONF` row, and `visual-ui-verification` for an
   integrated UI.

   For a wave: once every unblocked wave diff has passed 5.1 to 5.4, merge
   those branches into the plan worktree (a blocked task's branch stays out)
   and run this check on the merged HEAD before any wave task is `done`. If
   that check on the merged HEAD is red, open a fix round in the plan
   worktree on the task it names, counted against that task's repair budget
   and ending in 5.4's adjudication, then merge and check again. The wave
   worktrees and branches are task-owned resources in the workspace record
   for `finishing-a-branch`.

   Then append the task's state to the index's `External execution ledger`:
   done, done with concerns, blocked, or needs context. Mirror only the task
   row's checkbox and adjacent label. **Do not change the index's `Status`
   header or normalize it out of the plan's identity.**
6. Under `per task` cadence only, **REQUIRED SUB-SKILLS:** invoke
   `requesting-code-review` on this task's revision, then `finishing-a-branch`.
   Return after it records its decision.
7. Go to Step 4 with the next ready task. Do not report, ask, or pause at
   `done`. When every task is `done`, or `cancelled`/`superseded` with its
   approved ledger decision, go to Step 6. If no ready task can advance, or a
   high-risk entry gate has not passed and no ready task can advance without
   it, report the unresolved states and their blockers and end the turn.

## Step 6: Finish the plan

In the worktree from Step 2, in order:

1. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` on the
   integrated revision (`per task`: the base after the last integration): the
   index's `Acceptance` check plus every done task's evaluator. Worker reports
   are claims; this is the evidence.
2. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` on the whole branch.
   Its fix rounds run under `receiving-code-review`'s convergence check and
   plan-end budget. You run only the triage and the budget: each fix set goes
   to a fresh implementer through the Step 4 brief and the Step 5 review loop,
   with every round a fresh implementer, counted against the plan-end budget,
   not a task's. When that budget is spent, write the adjudication in the
   ledger and hand the user that row; no task is recorded `blocked`.
3. **REQUIRED SUB-SKILL:** invoke `finishing-a-branch` with the workspace
   record from Step 2. It asks the integration question and executes the
   answer. Run no push, PR, merge, or delete here.
4. Close with "Rulings I made": every ruling in the ledger, one line each,
   then "Findings not built": every `finding` row with no `admitted` row,
   with its evidence, one line each. The user decides which become work.

| Thought | Reality |
| --- | --- |
| "Every worker returned DONE, so the plan is done" | DONE is a claim per task. The plan is done after Acceptance, review, and the integration decision — three skills you have not invoked yet. |
| "The reviewer subagent passed it, so review is covered" | That reviewed one task's diff against its contract. The branch review is a separate check on the integrated state. |

## Findings outside the task

A defect or gap outside the current task's contract is never an edit in this
task. One a later listed task's contract covers is left to that task. Any
other, whoever reports it, is a `finding` row in the ledger: where, what,
the evidence. It is never a task because someone wrote it down.

1. If the index's `Out-of-task findings` field says `log and report`, or is
   absent, every finding waits for Step 6.4.
2. If it says `fix when admitted`, admit only an observed failure: wrong
   output, a crash, a shipped statement that is false, a test that passes on
   broken code. Write the admitted finding a task file shaped like the plan's
   own under `{{plan-dir}}/added/`, unlisted in the index so the plan's
   identity holds, and append an `admitted` row that repeats the finding
   row's where-text and names that file.
3. The approved field authorizes an added task inside its budget, and
   nothing else. Its `Evaluator` reproduces the observed failure and is red
   before the fix; its `Depends on` names every listed task that owns a file
   it edits; it passes Step 2.4. A finding whose fix would change a listed
   task's contract or `Evaluator` is not admitted: it waits for Step 6.4.
4. Run an added task through Steps 4 and 5 before Step 6. It has no index
   row to mirror: its state lives in the execution ledger only, and Step 6.1
   runs its evaluator with the listed tasks'.
5. A finding raised while building or reviewing an added task, or by the
   Step 6.2 review outside every task's contract, waits for Step 6.4. It
   never becomes another task.
6. When added tasks reach the field's budget, admit nothing more; the rest
   wait for Step 6.4. If no budget is recorded, the budget is a quarter of
   the listed tasks, rounded up.

## Gotchas

- An instruction to fix whatever turns up reads as licence to queue every
  advisory as a task, and each fix's review then raises more — reproduced
  by a plan run that carried that instruction with no budget: its 14-row
  list grew to 91. Admit by observed failure, inside the budget.
- A worker's status is not a verdict on the task — reproduced whenever a `DONE`
  arrives with a diff that edits a file the brief never named. Read the diff
  yourself; that is what Step 5.5 is for.
- A fresh implementer in a late round has read nothing. "Fix the findings"
  names a file it does not have; give it the findings path and the task path.
- A worker that dispatches its own workers returns a diff nobody reconciled and
  dispatch receipts you never held. Every brief here prohibits subdispatch;
  keep it.
- The controller never edits, so `test-driven-development` and `yagni` load in
  the implementer, where the brief requires them; loading them here proves
  nothing about the worker's session.

## Stopping and resuming

- If the remaining work will not fit this session, finish the current ledger
  row, then invoke `handoff`.
- On resume, rerun `bash scripts/plan-version.sh` and re-read the latest
  decision row (empty `Section`) for the printed version before `--check` on
  the run ledger: the run ledger detects an amended plan, not a row that
  closed the version.
- For a dispatch row with no result row, confirm that worker has stopped, as
  `dispatching-parallel-agents` Step 2.4 says, then run `git log` from the
  row's base in its worktree. If commits exist, build their review package
  and dispatch only the reviewer. If none exist, set any uncommitted output
  aside and dispatch the task again as a new attempt linked to that row.
