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

One repository, one checkout per task. A worktree is the default because it
adds a checkout instead of rewiring the one everyone else is in.

## When to use

- You are about to edit files, implement a feature/fix/refactor, execute a plan, or dispatch agents.
- Runtime or review isolation matters: parallel agents, risky changes, separate ports, databases, fixtures, or long-running app state.
- **Skip** for read-only investigation, when the user explicitly says to stay in the current checkout, or when the current branch/workspace is already dedicated to this task with known ownership, base, and baseline.

## Procedure

Each step fills the matching section of `assets/workspace-record.md`. Open it
now and write as you go — the fields it asks for are the ones a later step, and
whatever finishes the branch, cannot re-derive from the repository alone.

### Understand what you are already in

1. **Detect the real checkout.** Run it; do not judge it from the prompt or the
   path name:

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
   even though it is not a linked worktree. Also note any harness-native
   workspace metadata.

   A detached or host-owned checkout may already be isolated. Until you know its
   owner and permitted lifecycle, do not nest inside it, attach to it, switch it,
   or clean it.

2. **Classify ownership** of every resource and dirty change: created by this
   task, or pre-existing, user-owned, shared, or host-owned. Unknown provenance
   counts as the latter, and blocks switching or cleanup. Dirty state in the
   shared checkout does not follow you into a worktree and is not yours to
   stash.

3. **Separate planning state from implementation state.** Planning may stay in
   an approved planning or native workspace. Before the first product edit,
   re-run this check and bind implementation to its own branch or workspace and
   its own exact base. Plan approval says nothing about code isolation.

### Establish the base

4. **Prove the intended base** from direct user or project guidance, and record
   its revision and remote freshness:

   ```bash
   git fetch origin "$BASE"          # only with network authority; otherwise record "not fetched"
   git rev-parse "$BASE" "origin/$BASE"
   ```

   Gate inputs that live outside the source tree — ignored, generated,
   external — belong in the record too; the revision does not capture them.

   Any install or baseline command runs under the contract in
   `references/baseline-contract.md`. Read it before running anything, not
   after: it decides whether the command may run in the current checkout at all.

### Create the workspace

5. **Validate the name and its collisions.** Follow project naming, or use
   `feature/{{short-task}}`, `fix/{{short-task}}`, or `docs/{{short-task}}`.
   Validate the ref, then check local branches, remote-tracking refs, and
   attached worktrees. Never overwrite or silently reuse a collision.

   ```bash
   git check-ref-format --branch "$BRANCH"
   git show-ref --verify --quiet "refs/heads/$BRANCH" && echo "local branch exists"
   git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && echo "remote branch exists"
   git worktree list | grep -F "[$BRANCH]"
   ```

6. **Pick the mechanism, in this order.** User instruction wins, then project
   guidance, then a harness-native worktree command or session flag when the
   harness offers one — it owns the path, the ignore rule, and cleanup, so use
   it with the name from step 5, confirm inside it that HEAD is the proven
   base, and skip to step 9. Failing those, create a worktree yourself — do
   not `git switch -c` or `git checkout -b` in a shared checkout: switching
   rewires it, so the user, a second agent, or a running app working in it is
   blocked or collides until you switch back. Switch branches in place only in
   a checkout dedicated to this task alone.

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

   Both lines must be silent: the first is the gate, the second proves the
   directory you actually chose, because the gate passes when either name is
   ignored. If it is not ignored, do not fix `.gitignore` in the shared
   checkout — that is an edit on the branch the hard stop protects. Exclude it
   locally, which `git check-ignore` honours and nothing commits:

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
   report it and stop: a failure to isolate does not authorize editing the
   shared checkout. A submodule needs an owned branch and an explicit plan
   for the parent gitlink.

### Baseline it

9. **Isolate runtime state, then run the real baseline in the chosen
   workspace.** Project setup — dependency install, generated files — runs
   inside the worktree, following the project's own instructions.
   `references/baseline-contract.md` owns what "real" requires here: the
   pre-run inspection, the distinct runtime identities, the pre/post capture,
   and how each red cell is bound before work continues.

   The rule that survives without the reference: a red cell you cannot
   attribute blocks work. So do uncontained effects.

10. **Report the record.** Hand over the completed
    `assets/workspace-record.md` — identity, inventory, external gate inputs,
    baseline evidence and side effects, runtime identities, and the task-owned
    resources that may later be cleaned up.

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

Committing is not the last step of the task. It is a step you owe after each
independently testable piece, and the authority for it already exists: local
task-branch commits are authorized repository edits unless higher-priority user
or project policy withholds them or requires approval not yet given.

11. **After each coherent piece a reviewer could accept or reject separately**,
    invoke `verifying-completion`, run its smallest real gate, and commit
    locally. Do not wait for the final candidate, and do not ask again for each
    checkpoint.
12. **Stop there.** A checkpoint is neither reviewed nor done and grants no
    push, publication, or integration authority. `finishing-a-branch` may
    rewrite its history only with authority established there. Hand it the
    recorded workspace, base, and ownership; do not integrate, discard, delete,
    or clean here.

| The thought | The reality |
| --- | --- |
| "I'll commit once it all works" | One terminal commit cannot be reviewed or reverted in pieces, and every good intermediate state is gone. |
| "Nothing is finished, so there is nothing to commit" | The unit is an independently testable change, not a finished feature. If a gate can accept it, it can be a checkpoint. |
| "I should ask before each commit" | The authority is already granted. Asking again per checkpoint spends the user's turn re-deciding what they decided. |
| "The gate is slow — I'll run it once at the end" | Then a red gate at the end leaves every change a suspect. The smallest gate per checkpoint is what keeps that cheap. |
| "It passes locally, so committing can wait" | An uncommitted passing state is one crash, wrong checkout, or overwrite away from not existing. |
| "A mid-task commit looks unfinished" | It claims nothing. Nothing reads a checkpoint as done until `finishing-a-branch` runs. |
