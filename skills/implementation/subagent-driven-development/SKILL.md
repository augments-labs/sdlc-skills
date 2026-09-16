---
name: subagent-driven-development
description: "Runs an approved plan's tasks through fresh subagents: one implementer per task, a reviewer on its diff, and a bounded fix loop, with the controller keeping every decision. Use when an approved plan is about to be built by dispatched workers rather than in this session, or when the user asks for subagents or workers to do the building. Skip a lone task with no plan directory, and independent tasks that want concurrent fan-out."
---

# Subagent-Driven Development

You are the controller. Fresh workers build and review one task at a time; you
hold the plan, the ledger, and every decision they may not take.

## When to use

- An approved plan is about to be built by dispatched workers rather than here.
- **Skip** building the tasks in this session, a lone task with no plan
  directory, and independent tasks that should run at the same time — that
  fan-out belongs to `dispatching-parallel-agents`.

## Available scripts

- **`scripts/sdd-workspace.sh`** — opens the plan-scoped ledger and re-checks
  that it still binds to the plan. Run it before the first dispatch, and again
  after every compaction.
- **`scripts/task-brief.sh`** — renders a role brief from a task file, and
  refuses one with a placeholder still in it. Run it for every dispatch.
- **`scripts/review-package.sh`** — assembles one task's diff and file list for
  a reviewer. Run it when an implementer reports.

## Step 1: Open the run

1. **REQUIRED SUB-SKILL:** invoke `using-git-worktrees`. One worktree holds the
   whole plan and every worker writes inside it. Never hand a worker the shared
   checkout.
2. Open the ledger:

   ```bash
   bash scripts/sdd-workspace.sh --plan {{plan-dir}}
   ```

   Line 1 is the plan's identity. After a compaction, read the ledger before
   anything else and re-check it with `--check`: the ledger, not your memory of
   the conversation, is where the run resumes.
3. Scan for conflicts before the first dispatch. List the files each task
   claims, and write every pair claiming the same file into the ledger as an
   ordering.

## Step 2: Rule, don't stall

A worker that asks a question gets an answer and a ledger row, not a pause. Stop
and ask the user only when the next act would be:

- irreversible — data, history, or something already published;
- security-sensitive — secrets, credentials, permissions, a trust boundary;
- effective outside the worktree;
- or the plan is broken on every path you can see, not merely the first one.

Everything else is a ruling. Write it in the ledger with its reason and carry it
into the next brief, so the next worker inherits the decision instead of
re-litigating it.

## Step 3: Dispatch one task

1. Take the next task whose dependencies are done.
2. Batch tasks into one dispatch only when they are small and the same shape —
   same kind of file, same act. Different shapes go separately, whatever their
   size.
3. Fill `assets/implementer.md` when dispatching an implementer, rendering it
   with `scripts/task-brief.sh`. Every input is a file path the worker opens for
   itself; paste the task contract, and nothing else.
4. Set the tier explicitly, from the Model selection table in
   `dispatching-parallel-agents`. A brief written as prose starts at the middle
   tier; use the small tier only when the brief carries the literal code to
   apply.
5. Bind the role to a runtime: where the harness exposes a named agent whose
   contract covers the role, dispatch that agent with the role brief; otherwise
   dispatch a general subagent with the role prompt. Name mappings belong in
   the adapters, never here.
6. Then dispatch per `dispatching-parallel-agents` Step 2 — it owns the receipt,
   the not-dispatched rule, and cancellation.

## Step 4: Review the diff, then fix

1. Build the package with `scripts/review-package.sh`, then fill
   `assets/task-reviewer.md` when the implementer reports.
2. Findings open a fix round. Rounds 1 to 3 go back to the same implementer,
   which still holds the task. Rounds 4 and 5 go to a fresh implementer one tier
   up, briefed from the findings file — it has read nothing.
3. Fill `assets/re-reviewer.md` when a fix round returns, so the second look
   judges the fix and its blast radius rather than the task again.
4. Five rounds without convergence trips the breaker. Stop dispatching, write
   the adjudication in the ledger — the finding, what each round changed, why it
   did not converge — and then either decide it yourself under Step 2 or hand
   the user that row. Never open a sixth round.
5. Read the diff yourself against the task before recording its state: done,
   done with concerns, blocked, or needs context.

## Step 5: Finish the branch

1. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` on the
   integrated revision. Worker reports are claims; this is the evidence.
2. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` on the whole branch,
   once, and let it drive a single fix wave.
3. Close with "Rulings I made": every ruling in the ledger, one line each, so
   the person reading the result sees the decisions taken on their behalf.

## Gotchas

- A worker's status is not a verdict on the task — reproduced whenever a `DONE`
  arrives with a diff that edits a file the brief never named. Read the diff
  yourself; that is what Step 4.5 is for.
- Resuming from the conversation after a compaction re-runs finished tasks and
  loses every ruling, because by then neither is in the conversation. Line 1 of
  the ledger exists for exactly that moment.
- A fresh implementer in round 4 has read nothing. "Fix the findings" names a
  file it does not have; give it the findings path and the task path.
- A worker that dispatches its own workers returns a diff nobody reconciled and
  receipts you never held. Every brief here prohibits subdispatch; keep it.

## Common mistakes

- Editing a worker's diff yourself instead of opening a fix round — now nobody
  has reviewed the state that ships.
