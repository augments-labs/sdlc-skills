---
name: using-git-worktrees
description: "Use before the first repository edit — a feature, fix, refactor, plan step, or dispatched agent work — or whenever work needs isolation from the current checkout. Fires on start on this ticket and let's build X inside a repository, even if nobody says branch or worktree. Skip read-only work, and skip when the current checkout is already dedicated to this task."
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

## Step 1: Detect what you are in

Open `assets/workspace-record.md` now. Fill each section as its step runs.

1. Run this. Do not judge the checkout from the prompt or the path name:

   ```bash
   git rev-parse --show-toplevel
   git status --short --branch
   git rev-parse --show-superproject-working-tree   # non-empty: you are in a submodule
   git_dir="$(cd "$(git rev-parse --git-dir)" && pwd -P)"
   common_dir="$(cd "$(git rev-parse --git-common-dir)" && pwd -P)"
   [ "$git_dir" != "$common_dir" ] && echo "already inside a linked worktree"
   git worktree list
   ```

2. Read the submodule line first: inside a submodule the two directories
   match without a linked worktree. Write down any harness-native workspace
   metadata.
3. Detached or host-owned checkout with unknown owner → do not nest, attach,
   switch, or clean it.
4. Write every resource and dirty change into the inventory: created by this
   task, or pre-existing/user-owned/shared/host-owned. Unknown → second
   column. It blocks switching and cleanup. Never stash dirty state you do
   not own.
5. Planning happened in another workspace → rerun 1 before the first product
   edit. Plan approval says nothing about code isolation.

## Step 2: Prove the base

1. Take the base from direct user or project guidance. Record revision and
   remote freshness:

   ```bash
   git fetch origin "$BASE"          # only with network authority; otherwise record "not fetched"
   git rev-parse "$BASE" "origin/$BASE"
   ```

2. Record gate inputs outside the source tree (ignored, generated, external)
   in their own section.
3. Read `references/baseline-contract.md` before any install or baseline
   command.

## Step 3: Create the workspace

1. Name it by project convention, or `feature/{{short-task}}`,
   `fix/{{short-task}}`, `docs/{{short-task}}`. Check collisions:

   ```bash
   git check-ref-format --branch "$BRANCH"
   git show-ref --verify --quiet "refs/heads/$BRANCH" && echo "local branch exists"
   git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && echo "remote branch exists"
   git worktree list | grep -F "[$BRANCH]"
   ```

   Anything prints → pick another name. Never overwrite or reuse.
2. Pick the mechanism, first that applies: user instruction → project
   guidance → harness-native worktree command or session flag (use the name
   above, confirm HEAD is the proven base, skip to Step 4) → a worktree you
   create below. Never `git switch -c` or `git checkout -b` in a shared
   checkout.
3. Choose the directory and prove it is ignored. User-given path wins.

   ```bash
   root="$(cd "$common_dir/.." && pwd -P)" && cd "$root"   # main checkout root, even from inside a linked worktree
   dir=".worktrees"
   [ -d "$root/worktrees" ] && [ ! -d "$root/.worktrees" ] && dir="worktrees"
   git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null || echo "NOT IGNORED"
   git check-ignore -q "$dir" || echo "$dir itself is not ignored"
   ```

4. Either line printed → do not edit `.gitignore` in the shared checkout.
   Exclude locally, then make adding `{{dir}}/` to `.gitignore` the first
   commit on the task branch:

   ```bash
   printf '%s/\n' "$dir" >> "$(git rev-parse --git-common-dir)/info/exclude"
   ```

5. Create from the proven base and enter:

   ```bash
   path="$root/$dir/${BRANCH//\//-}"
   git worktree add "$path" -b "$BRANCH" "$BASE"
   cd "$path" && git status --short --branch   # expect: ## $BRANCH, clean
   ```

6. `worktree add` or `cd` fails on a permission or sandbox boundary → try a
   path the boundary allows and ask the user to confirm it. None works →
   report and stop. Never edit the shared checkout instead. Submodule → an
   owned branch and an explicit plan for the parent gitlink.

## Step 4: Baseline it

1. Claim distinct runtime identities (ports, databases, fixtures).
2. Run project setup inside the worktree by the project's own instructions.
3. Run the real baseline under `references/baseline-contract.md`: pre-run
   inspection, pre/post capture, each red cell bound. Red cell you cannot
   attribute, or an effect you did not contain → stop work.
4. Hand the completed `assets/workspace-record.md` to whatever invoked this
   skill: identity, inventory, external gate inputs, baseline evidence and
   side effects, runtime identities, task-owned resources.

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

## Step 5: Checkpoint while you work

<EXTREMELY-IMPORTANT>
COMMIT LOCALLY AS YOU GO — after each independently testable piece, not once at
the end. The authority is already granted; do not ask again for each checkpoint.
A checkpoint never grants push, publication, or integration authority.
</EXTREMELY-IMPORTANT>

1. After each coherent piece a reviewer could accept or reject separately:
   **REQUIRED SUB-SKILL:** invoke `verifying-completion`, run its smallest
   real gate, commit locally. Do not wait for the final candidate. Do not ask
   per checkpoint. Withhold only when direct user or project policy withholds.
2. Candidate ready for integration → **REQUIRED SUB-SKILL:** invoke
   `finishing-a-branch` with the recorded workspace, base, and ownership. Run
   no push, publish, integrate, discard, delete, history rewrite, or cleanup
   from this skill.

| The thought | The reality |
| --- | --- |
| "I'll commit once it all works" | One terminal commit cannot be reviewed or reverted in pieces, and every good intermediate state is gone. |
| "Nothing is finished, so there is nothing to commit" | The unit is an independently testable change, not a finished feature. If a gate can accept it, it can be a checkpoint. |
| "I should ask before each commit" | The authority is already granted. Asking again per checkpoint spends the user's turn re-deciding what they decided. |
| "The gate is slow — I'll run it once at the end" | Then a red gate at the end leaves every change a suspect. The smallest gate per checkpoint is what keeps that cheap. |
| "It passes locally, so committing can wait" | An uncommitted passing state is one crash, wrong checkout, or overwrite away from not existing. |
| "A mid-task commit looks unfinished" | It claims nothing. Nothing reads a checkpoint as done until `finishing-a-branch` runs. |
