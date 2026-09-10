---
name: using-git-worktrees
description: "Use before the first repository edit — a feature, fix, refactor, plan step, or dispatched agent work — or whenever work needs isolation from the current checkout, so an owned git worktree on a proven base exists, or the workspace the user or project prefers instead. Fires on start on this ticket and let's build X inside a repository, even if nobody says branch or worktree. Skip read-only work, and skip when the current checkout is already dedicated to this task."
---

<EXTREMELY-IMPORTANT>
NEVER START REPO EDITS ON `main`/`master`, `dev`/`develop`, A RELEASE BRANCH, OR
AN UNRELATED TASK BRANCH. Create or enter a dedicated workspace — a git
worktree unless the user or project says otherwise — *before* the first edit,
unless the user explicitly okayed the current checkout.
</EXTREMELY-IMPORTANT>

# Using Git Worktrees

Give every task its own checkout, prove the base it starts from, and write
down what you found there before you change anything.

## When to use

- You are about to edit files, implement a feature/fix/refactor, execute a plan, or dispatch agents.
- Runtime or review isolation matters: parallel agents, risky changes, separate ports, databases, fixtures, or long-running app state.
- **Skip** for read-only investigation, when the user explicitly says to stay in the current checkout, or when the current branch/workspace is already dedicated to this task with known ownership, base, and baseline.

## Procedure

Open `assets/workspace-record.md` now and fill each section as its step runs.
`finishing-a-branch` reads this record later and cannot re-derive its fields
from the repository.

### Understand what you are already in

1. **Detect the real checkout by running this**, not by reading the prompt or
   the path name:

   ```bash
   git rev-parse --show-toplevel
   git status --short --branch
   git rev-parse --show-superproject-working-tree   # non-empty: you are in a submodule
   git_dir="$(cd "$(git rev-parse --git-dir)" && pwd -P)"
   common_dir="$(cd "$(git rev-parse --git-common-dir)" && pwd -P)"
   [ "$git_dir" != "$common_dir" ] && echo "already inside a linked worktree"
   git worktree list
   ```

   Read the submodule line first: inside a submodule the two directories match
   even though it is not a linked worktree. Write down any harness-native
   workspace metadata you see.

   In a detached or host-owned checkout whose owner and lifecycle you have not
   established, do not nest a worktree inside it, attach to it, switch it, or
   clean it.

2. **Write every resource and dirty change into the inventory** under one
   column: created by this task, or pre-existing, user-owned, shared, or
   host-owned. Put unknown provenance in the second column; it blocks
   switching and cleanup. Leave dirty state in the shared checkout where it is;
   do not stash it.

3. **Re-run step 1 before the first product edit** when planning happened in
   another workspace, and bind implementation to its own branch and exact
   base. Plan approval says nothing about code isolation.

### Establish the base

4. **Prove the intended base** from direct user or project guidance, and
   record its revision and remote freshness:

   ```bash
   git fetch origin "$BASE"          # only with network authority; otherwise record "not fetched"
   git rev-parse "$BASE" "origin/$BASE"
   ```

   Record gate inputs that live outside the source tree — ignored, generated,
   external — in the record's own section; the revision does not capture them.

   Read `references/baseline-contract.md` before any install or baseline
   command: it decides whether the command may run in the current checkout at
   all.

### Create the workspace

5. **Validate the name and its collisions.** Follow project naming, or use
   `feature/{{short-task}}`, `fix/{{short-task}}`, or `docs/{{short-task}}`.
   Never overwrite or silently reuse a collision.

   ```bash
   git check-ref-format --branch "$BRANCH"
   git show-ref --verify --quiet "refs/heads/$BRANCH" && echo "local branch exists"
   git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && echo "remote branch exists"
   git worktree list | grep -F "[$BRANCH]"
   ```

6. **Pick the mechanism in this order** and stop at the first that applies:
   the user's instruction; project guidance; a harness-native worktree command
   or session flag — use it with the name from step 5, confirm inside it that
   HEAD is the proven base, and skip to step 9; a worktree you create in steps
   7–8. Do not `git switch -c` or `git checkout -b` in a shared checkout; switch
   in place only in a checkout dedicated to this task alone.

7. **Choose the directory and prove it is ignored.** A user-given path wins.
   Otherwise reuse an existing `.worktrees/` or `worktrees/` at the project
   root (`.worktrees/` wins when both exist), and default to `.worktrees/`
   when neither does.

   ```bash
   root="$(cd "$common_dir/.." && pwd -P)" && cd "$root"   # main checkout root, even from inside a linked worktree
   dir=".worktrees"
   [ -d "$root/worktrees" ] && [ ! -d "$root/.worktrees" ] && dir="worktrees"
   git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null || echo "NOT IGNORED"
   git check-ignore -q "$dir" || echo "$dir itself is not ignored"
   ```

   Both lines must be silent. If either prints, do not edit `.gitignore` in
   the shared checkout. Exclude the directory locally instead:

   ```bash
   printf '%s/\n' "$dir" >> "$(git rev-parse --git-common-dir)/info/exclude"
   ```

   Then make adding `{{dir}}/` to `.gitignore` the first commit on the task
   branch. A path outside the repository needs no ignore rule.

8. **Create only from the proven base, then enter it.**

   ```bash
   path="$root/$dir/${BRANCH//\//-}"
   git worktree add "$path" -b "$BRANCH" "$BASE"
   cd "$path" && git status --short --branch   # expect: ## $BRANCH, clean
   ```

   If `worktree add` or `cd` fails on a permission or sandbox boundary, try a
   path the boundary allows and ask the user to confirm it. If none works,
   report it and stop; do not edit the shared checkout instead. A submodule
   needs an owned branch and an explicit plan for the parent gitlink.

### Baseline it

9. **Claim distinct runtime identities, then run the real baseline inside the
   workspace.** Run project setup — dependency install, generated files — in
   the worktree, following the project's own instructions. Follow
   `references/baseline-contract.md` for the pre-run inspection, the pre/post
   capture, and how each red cell is bound. Stop work on any red cell you
   cannot attribute, and on any effect you did not contain.

10. **Hand over the completed `assets/workspace-record.md`** — identity,
    inventory, external gate inputs, baseline evidence and side effects,
    runtime identities, and the task-owned resources that may later be cleaned
    up — to whatever invoked this skill.

## Pressure points

| The thought | The reality |
| --- | --- |
| "I'll just inspect first" | For edit requests, branch/status is the first inspection. |
| "It's only a small change" | Small changes still land on the wrong branch. Create the branch first. |
| "git switch -c is lighter than a worktree" | Switching rewires the shared checkout — anyone else working in it is blocked until you switch back. A worktree is the default; switch in place only in a checkout dedicated to this task. |
| "The harness made a detached checkout, so I'll add my own worktree" | First determine whether the host already owns isolation and cleanup. |
| "I'll make the branch after the first edit" | After the edit, you may already have mixed unrelated state. |
| "It looks like a plain checkout" | Looking is not detecting. `git-dir` against `common-dir`, plus the superproject check, is the inspection. |
| "The harness has a worktree tool, but plain git is simpler" | The native tool owns the path, the ignore rule, and cleanup. A hand-made worktree beside it is a second thing to clean up. |
| "`.worktrees` is surely ignored" | Surely is not `git check-ignore`. An unignored worktree appears in every status, grep, and commit from then on. |
| "I'll add `.worktrees/` to `.gitignore` and commit it here" | That is an edit on the shared branch. Exclude it locally, then commit the ignore rule on the task branch. |
| "`worktree add` failed in the sandbox, so I'll switch in place" | Failing to isolate grants nothing. Report it; the user decides what the current checkout may carry. |

## Checkpoint while you work

<EXTREMELY-IMPORTANT>
COMMIT LOCALLY AS YOU GO — after each independently testable piece, not once at
the end. The authority is already granted; do not ask again for each checkpoint.
A checkpoint never grants push, publication, or integration authority.
</EXTREMELY-IMPORTANT>

11. **After each coherent piece a reviewer could accept or reject separately,
    invoke `verifying-completion`**, run its smallest real gate, and commit
    locally. Do not wait for the final candidate, and do not ask again for
    each checkpoint. Withhold a commit only when direct user or project policy
    withholds it.

12. **REQUIRED — stop at the checkpoint and hand the record to
    `finishing-a-branch`** when the candidate is ready for integration. Give
    it the recorded workspace, base, and ownership. Run no push, publish,
    integrate, discard, delete, history rewrite, or cleanup from this skill;
    that skill establishes the authority for each.

| The thought | The reality |
| --- | --- |
| "I'll commit once it all works" | One terminal commit cannot be reviewed or reverted in pieces, and every good intermediate state is gone. |
| "Nothing is finished, so there is nothing to commit" | The unit is an independently testable change, not a finished feature. If a gate can accept it, it can be a checkpoint. |
| "I should ask before each commit" | The authority is already granted. Asking again per checkpoint spends the user's turn re-deciding what they decided. |
| "The gate is slow — I'll run it once at the end" | Then a red gate at the end leaves every change a suspect. The smallest gate per checkpoint is what keeps that cheap. |
| "It passes locally, so committing can wait" | An uncommitted passing state is one crash, wrong checkout, or overwrite away from not existing. |
| "A mid-task commit looks unfinished" | It claims nothing. Nothing reads a checkpoint as done until `finishing-a-branch` runs. |
