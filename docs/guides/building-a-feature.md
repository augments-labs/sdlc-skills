# Building a feature

You want a change that adds or alters behavior: a new endpoint, a new option,
a different rule. This page follows one request from the first message to a
reviewed branch, and shows what the agent does at each step.

The example request:

```text
Add an expiry check to session tokens. A request with an expired token
should get a 401 instead of being served.
```

For work that needs a design or a plan first, see
[Planning larger work](planning-larger-work.md). The steps below are what
happens for a change the agent can start on directly.

If the work is already written up as a ticket, hand the agent the ticket:
paste it, or give the link or identifier if the agent has a tool to read it.
`working-from-a-ticket` records the ticket and its acceptance criteria as
written, so the plan and the tests bind to that record rather than to a
summary, and the agent re-reads the ticket before it calls the work done.

## 1. It settles what you mean, if anything is open

If the request leaves something open that the code cannot answer (which
tokens, what "expired" means at the boundary, what the response body holds),
the agent uses `clarifying-intent` and asks. It asks one question at a time
and waits for your answer rather than building on a guess.

If the request is clear, it moves on.

## 2. It isolates the work

Before the first edit, `using-git-worktrees` checks what kind of checkout it
is in. In a shared checkout it creates a branch and a git worktree for the
task, named after the task (for example `feature/token-expiry`), under a
`.worktrees/` directory that it excludes from git locally. It runs your
project's setup inside the worktree and checks that the baseline is green
before it changes anything.

It also asks, once per task, whether it may commit locally as it works. If
you say yes, it checkpoints after each piece that could be reviewed on its
own. A checkpoint is only a local commit; it never pushes.

If you would rather the agent stayed in the current checkout, say so:

```text
Stay in this checkout, no worktree.
```

If your team always works this way, write it once in your project's agent
instructions file instead; [Setting up for a team](setting-up-for-a-team.md)
shows the line.

## 3. It writes a failing test first

`test-driven-development` writes one test for the behavior, runs it with
your project's real test command, and reads the failure. It checks that the
test failed for the right reason, at the assertion it was meant to hit, and
not because of an import error or a skipped test. Then it writes the code
that makes the test pass, runs the whole suite, and refactors under green.

You will see the failing run and the passing run in the transcript. The
agent keeps those outputs as evidence.

`yagni` runs alongside it and keeps the change to what you asked for. If the
agent is tempted to add a flag, an abstraction, or a configuration option
nobody asked for, this is the skill that stops it. It also makes sure the
part you did ask for is complete rather than stubbed.

## 4. It checks the work before it says it is done

When the change looks finished, `verification-before-completion` runs the
checks your project requires and reads the raw output, not just the exit
code. It reports what passed, on which version of the code, and what is
still pending. A check that did not run, or ran on an earlier state, keeps
the claim open.

"That should do it" with nothing behind it is exactly what this step
prevents.

## 5. It asks for a review

`requesting-code-review` freezes the change and sends it to an independent
reviewer. On agents that can run a subagent, that reviewer is a fresh agent
that reads the whole change and returns a report. The default is one breadth
reviewer; a specialist joins when the change touches something that calls
for it, such as a new interface or error handling that could swallow a
failure.

On agents without a subagent tool, the agent tells you it cannot dispatch a
review and asks you once whether to do a self-review (labelled as one), to
hand the change to a reviewer you name, or to leave the work pending.

The agent then reads the review through `receiving-code-review`, which
checks each piece of feedback on its merits before acting on it.

## 6. It asks what to do with the branch

With the checks green and the review back, `finishing-a-branch` shows you a
menu like this one:

```text
Branch feature/token-expiry → main. Gates: all green. Review: ready.

1. Commit and keep
2. Push the branch
3. Push and open a PR
4. Integrate locally into main
5. Keep as-is

Recommendation: ...
```

Nothing is pushed, merged, or opened until you pick an entry. Discarding the
work is never on this menu; it is a separate path you have to ask for by
name. [Reviewing and shipping](reviewing-and-shipping.md) covers that
step in more detail.

## Variations

- **Unfamiliar code.** If the change touches code the agent has not mapped,
  it uses `mapping-the-codebase` first to find the callers and boundaries,
  so a change does not stop short of a caller reached through configuration
  or reflection.
- **A quick experiment.** Ask for a prototype and `prototyping` builds a
  throwaway to answer the question, outside the test discipline. Behavior
  you keep is rebuilt under a test afterwards.
- **No test framework.** The agent still looks for the smallest executable
  check that can fail. If none is possible, it says so instead of claiming
  the change is tested.
- **A staged rollout.** If your release policy, the plan, or you ask for a
  feature flag, kill switch, canary, or staged rollout, `rollout-controls`
  builds the switch (off by default, in front of every path the change adds)
  and the signals the rollout's thresholds read, under your release policy's
  terms. Where there is no policy, or a term is missing, it drafts the terms
  and asks the release or decision owner to accept them before building
  anything. This is not the flag `yagni` stops:
  someone asked for it. `release-readiness` later binds those terms instead
  of inventing them.
- **A change to stored data.** If the feature adds, renames, or drops a
  column or field, adds an index or constraint, or backfills data on a store
  your running system reads, `changing-a-live-schema` builds it in phases:
  expand first, then backfill in batches, then switch, and only later drop
  the old shape. Each phase is its own deploy with its own rollback, so the
  old and new versions of your code both keep working during the deploy and
  after a rollback. The drop is the point of no return; the agent asks the
  data owner to accept it before it ships. A whole-store migration or a
  rewrite goes through `migration-strategy` instead.
