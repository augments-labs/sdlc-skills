# Running without someone to answer

Some runs have nobody at the keyboard: a scheduled job, a step in a
pipeline, a batch of tasks left overnight. The skills put certain decisions
to you and end the turn. With nobody there, the run ends at the first of
them, with the question as its last message. This page shows how to answer
those decisions before the run starts, and what a line given beforehand
does not cover.

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
- You may commit locally as you go.
- If a layer has no test harness, record its wiring as an unverified
  exception. Do not add a harness.
- If you cannot dispatch a reviewer, review the change in this session and
  label it a self-review.
- When the checks and the review pass, push the branch to `origin` and
  open a pull request against `dev`. Otherwise keep the branch as it is.
```

Each line covers only the decision it names. Among the decisions a single
change can meet:

| Decision | Which skill asks | What to say beforehand |
| --- | --- | --- |
| Whether the agent may commit locally as it works | `using-git-worktrees` | Yes or no, in the prompt or in your agent instructions file; [Setting up for a team](setting-up-for-a-team.md) has the line |
| A layer with no test harness | `test-driven-development` | Add a harness, or accept the wiring as an unverified exception |
| Work that needs an independent agent when none can be dispatched | `dispatching-parallel-agents` | Do it in this session, labelled not independent; or name who will do it; or keep it pending |
| What happens to the branch | `finishing-a-branch` | The action, the branch, the remote, and the base it goes to |
| Where a handoff note goes, when the work will not fit one session | `handoff` | `.sdlc-skills/handoffs/` in the project, a path you name, or the reply only |

Other stops depend on what the run finds: a valid review finding that
contradicts an approved document, or a file the task changed that already
had uncommitted edits before it began.

Where the agent works and which branch it starts from have defaults: a new
worktree, cut from the branch the task began on. Lines in your instructions
file change them. A checkout on a detached HEAD has no such branch: with no
base named in your prompt or your instructions file, the agent asks for it
and stops.

The branch line has to describe what is sent and where. If what is about to
be sent, or where it goes, is not what your line describes (another remote
or base, a new branch name, a merge method), the agent shows that choice
instead of acting.

## Larger work: approve it while you are there

A brief, a spec, a design, and a plan are each approved at an exact
version, and an approval covers only the version you were shown. A default
given beforehand stands in for a plan's approval only when it explicitly
covers a plan you have not seen: its scope, who owns the approval, its
constraints, and how it is executed. The agent then quotes your line as the
answer in the plan's record.

The simpler route is to split the work in two:

1. With you there, the agent writes the plan.
   [Planning larger work](planning-larger-work.md) covers this part.
   Approve it with the entry `Approve — inline, in a new session`. The
   agent records the approval, prints a prompt, and runs nothing. Every
   other approve entry starts the run at once, in the session where you
   answered.
2. Start the unattended run with the prompt it printed, and add your
   branch line:

   ```text
   Run the approved plan at /work/shop/.sdlc-skills/plans/2031-04-02-invoice-rounding in inline mode.
   When the checks and the review pass, push the branch to `origin` and
   open a pull request against `dev`.
   ```

The agent first checks the plan's current version against the approval on
record. If they differ, or no execution mode was chosen, it stops there.
Otherwise it does not stop to check in after each task. The branch decision
comes up when the plan ends, or after each task where the plan integrates
per task. The run stops before the plan ends when:

- A task needs a change to the plan's goal, a requirement, its acceptance
  check, its constraints, or an approved migration or assurance contract,
  or, on a high-risk plan, any change its migration rules treat as
  normative. It writes the proposed new version and asks you to approve it.
- No remaining task can move forward. It reports what blocks each one.
- A high-risk task's entry check has not passed and nothing else can
  proceed without it.
- The remaining work will not fit the session. It writes a handoff for the
  next session to resume from.

A delegated run, one subagent per task, stops in more cases. It needs
commits, so unless permission to commit locally is on record it asks before
the first task and, on a no, does not run. It never builds a task in the
session itself: when a subagent cannot be dispatched for a task, doing the
work in this session is not among the choices. It also stops before an act
that cannot be undone, one that touches secrets, permissions, or a trust
boundary, one that takes effect outside the worktree, a requirement that
reads two ways or a product or architecture choice the approved documents
do not settle, and when the plan is broken on every path it can see.

## What a line given beforehand does not cover

- **Discarding work.** The agent discards only on a direct request, and
  only after you type a confirmation that names an identity it computes
  when it prints the list of what would be deleted. With no reply, it
  touches nothing.
- **Making a self-review independent.** Where independence is required (a
  security clear, a role a skill requires to be independent, or an audit
  you asked to be independent), doing the work in the same session is not
  offered. The work stays pending until someone outside the session does
  it.
- **Accepting risks nobody listed.** Permission to draft the project's
  checks is not permission to accept thresholds, omissions, or exceptions
  you have not seen.
- **Promoting a release.** The agent reports whether the release is ready
  and waits for you to choose promote, hold, or cancel. Even on promote,
  the promotion is a separate action that needs its own authority, never
  the verdict alone.
- **Acting on a live system.** During an incident, a general line gives the
  agent no authority. It acts only where you, the incident owner, or a
  runbook your project designates gives it authority for that action on
  that target. Having the access is not having the authority; without it,
  the agent escalates instead.

## When the run stops anyway

The last message is the question the skill put, with its choices, a report
of what blocks the work, or a handoff for the next session. No decision was
made for you, and the work it controls is still pending.

To continue, start a session and give the answer there. A line inside a
document saying it is approved does not count in a new session: the agent
needs your answer, or a record that your project or the agent's harness
issued, tying the answer to you and to that exact version. For a plan, the
agent re-reads the plan's record and the workspace before it trusts what
the earlier run left.
