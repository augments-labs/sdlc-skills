# Setting up for a team

Your team already has a way of working: a base branch, a branch naming
convention, a rule about commits, a pull request template. Several skills
read that from your project's agent instructions file (`AGENTS.md`,
`CLAUDE.md`, `GEMINI.md`, or whatever your agent reads) and from your
contribution rules, so nobody has to repeat it in every session. This page
says what you can settle there once, and what stays with you.

## What you can settle once

Each row names the skill that reads it. Without a line, the agent starts
from the branch the task began on, names a new branch `feature/<topic>`,
`fix/<topic>`, or `docs/<topic>` by the kind of task, and asks before it
commits. It never reads a rule to stay in the checkout out of the state of
the checkout; only a written line counts.

| What you settle | Which skill reads it |
| --- | --- |
| Work in the current checkout instead of creating a worktree | `using-git-worktrees`. It records the file and the line in its workspace record, still takes its inventory of the checkout before the first edit, and then works on the branch that is checked out. It never cuts or switches a branch in your checkout, so switch to your task branch before you start |
| The base branch for new work | `using-git-worktrees`, when it creates a worktree, and `finishing-a-branch`, when it integrates a branch or opens the pull request |
| How branches are named | `using-git-worktrees`, only when it creates a worktree. With the stay line in place the branch is the one you made |
| Whether the agent may commit locally as it works | `using-git-worktrees`. Without this line it asks you once per task. A checkpoint is only a local commit; it never pushes |
| Self-review as the review depth | `requesting-code-review`. Without this line the agent sends the change to an independent reviewer unless you or the plan assign self-review. A self-review that finds a trust-boundary issue still needs an independent security clear, and one that finds the assignment did not fit goes to an independent review |
| Your contribution rules and PR template | `finishing-a-branch`, when it prepares a pull request description |

A line about one of these covers only that one. Saying the agent may stay in
the checkout does not let it commit; that needs its own line.

## A block to paste

Put this in your instructions file and edit it to match your process. Remove
any line you would rather decide per task.

```text
Work in the current checkout, on the branch that is checked out; do not
create a git worktree.
Start new work from the `dev` branch.
Name branches `feature/<topic>`, `fix/<topic>`, or `docs/<topic>`.
You may commit locally after each independently testable piece. Never push
without being asked.
Self-review is the assigned review depth for this project; a person reviews
every pull request before it merges.
Pull requests follow CONTRIBUTING.md and the template in
.github/PULL_REQUEST_TEMPLATE.md.
```

With the first line in place, switch to your task branch before you ask
for work; the naming line then matters only if you drop the first one, so
remove it if you keep that line. The base line still tells
`finishing-a-branch` where the branch goes. The second half of the
self-review line is a promise to your team, not something a skill reads.

If your project keeps planning out of the repository, add `.sdlc-skills/` to
`.gitignore`. The agent still writes its briefs, plans, and records there;
git just does not see them. [The `.sdlc-skills/` folder](../concepts/project-artifacts.md)
says what the folder holds if you decide to commit it instead.

## If your team works from tickets

Connecting your tracker is done in the agent, not in the instructions file:
the agent reads a linked ticket or an identifier only through a tool the
harness already provides for that tracker and you are entitled to use.
Without one, it asks you to paste the ticket, to name a tool it may use, or
to continue from what it read, recorded as partial. Either way,
`working-from-a-ticket` records the ticket
and its acceptance criteria as written, and re-reads it before calling the
work done.

## What the file does not switch off

For any change to behavior, the agent still writes a failing test before the
code and builds only what was asked for, and for every change it checks the
result before it says the work is done. These are not preferences a team
chooses; they are how a claim about the code gets something behind it, and
a line in a file cannot stand in for the test or the check.
