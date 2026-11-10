# Running without someone to answer

Some runs have nobody at the keyboard: a scheduled job, a step in a
pipeline, a batch of tasks left overnight. The skills put certain decisions
to you and end the turn. With nobody there, the run ends at the first of
them, with the question as its last message. This page shows how to answer
those decisions before the run starts, and what an answer given beforehand
cannot do.

## "Don't ask" answers nothing

Telling the agent not to ask, or starting it in a mode where it cannot,
gives it no authority to choose for you. It still puts the decision and
stops, because answering would ship a choice nobody made. It also still
checks the result before it calls the work done, and has the change
reviewed before anything is pushed or merged.

A general "go ahead with everything" works the same way. It answers no
choice it does not name.

## Answer each decision by name

A decision closes on your explicit answer, or on a default you granted
beforehand for that kind of decision. So say which kind of decision you
mean and what the answer is, in the prompt that starts the run:

```text
Fix the rounding error in invoice totals. Nobody will answer during this
run, so:
- If a layer has no test harness, record its wiring as an unverified
  exception. Do not add a harness.
- If you cannot dispatch a reviewer, review the change in this session and
  label it a self-review.
- When the checks and the review pass, push the branch and open a pull
  request against `dev`. Otherwise keep the branch as it is.
```

Each line covers only the decision it names. These are the ones a single
change most often meets:

| Decision | Which skill asks | What to say beforehand |
| --- | --- | --- |
| Where to work, the base branch, and whether the agent may commit locally | `using-git-worktrees` | Put the lines in your agent instructions file; [Setting up for a team](setting-up-for-a-team.md) has them |
| A layer with no test harness | `test-driven-development` | Add a harness, or accept the wiring as an unverified exception |
| Work that needs an independent agent when none can be dispatched | `dispatching-parallel-agents` | Do it in this session, labelled not independent; or name who will do it; or keep it pending |
| What happens to the branch | `finishing-a-branch` | The action, the branch, and the base it goes to |

The branch line has to cover what is sent and where. If the target or the
content changes materially after you wrote it, the instruction no longer
covers the action, and the agent shows the changed choice instead of
acting.

## Larger work: approve it while you are there

A brief, a spec, a design, and a plan are each approved at an exact
version, and an approval covers only the version you were shown. A default
given beforehand stands in for a plan's approval only when it explicitly
covers a plan you have not seen: its scope, who owns the approval, its
constraints, and how it is executed. The agent then quotes your line as the
answer in the plan's record.

The simpler route is to split the work in two:

1. With you there, the agent writes the plan. You approve it and choose how
   it is executed. [Planning larger work](planning-larger-work.md) covers
   this part.
2. The unattended run starts from that plan:

   ```text
   Execute the plan in .sdlc-skills/plans/2031-04-02-invoice-rounding/.
   When every task is done and the review passes, push the branch and open
   a pull request against `dev`.
   ```

The agent first checks the plan's current version against the approval on
record. If they differ, or no execution mode was chosen, it stops there.
Otherwise it works through the tasks without pausing after each one. It
stops early in three cases:

- No remaining task can advance. It reports what blocks each one.
- A task needs a change to the plan's goal, a requirement, its acceptance,
  or its constraints. It writes the proposed new version and asks you to
  approve it.
- A high-risk task's entry check has not passed and nothing else can
  proceed without it.

## What an answer given beforehand cannot do

- **Discard work.** The agent discards only on a direct request, and only
  after you type a confirmation that names an identity it computes when it
  prints the list of what would be deleted. With no reply, it touches
  nothing.
- **Make a self-review independent.** Where independence is required (a
  security clear, a role a skill requires to be independent, or an audit
  you asked to be independent), doing the work in the same session is not
  offered. The work stays pending until someone outside the session does
  it.
- **Accept risks nobody listed.** Permission to draft the project's checks
  is not permission to accept thresholds, omissions, or exceptions you have
  not seen.
- **Promote a release.** The agent reports whether the release is ready and
  promotes nothing itself. Promotion is a separate action that needs its
  own authority.
- **Stand in for authority on a live system.** During an incident, the
  agent acts on a system only where you, the incident owner, or a runbook
  your project designates gives it authority for that action on that
  target. Having the access is not having the authority, so it escalates
  instead.

## When the run stops anyway

The last message is the question, with its choices and a recommendation.
Nothing was chosen, and the work it controls is still pending.

To continue, start a session and give the answer there. A note in a file
saying a document is approved does not count in a new session: the agent
needs your answer, or a record that your project or the agent's own
tooling issued, tying the answer to you and to that exact version. For a
plan, the agent re-reads the plan's record and the workspace before it
trusts what the earlier run left.
