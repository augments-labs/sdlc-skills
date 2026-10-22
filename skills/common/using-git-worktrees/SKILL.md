---
name: using-git-worktrees
description: "Creates an isolated git worktree for a task and checkpoints work there. Use when a repository is about to be edited for the first time in a task, when work needs an isolated checkout and its own resources, or at a local task checkpoint. Reuse a linked worktree only when this task or the harness owns it; there, skip creating a workspace but keep checkpoint discipline. Skip read-only work."
---

<EXTREMELY-IMPORTANT>
NEVER START REPO EDITS IN A SHARED CHECKOUT, WHATEVER BRANCH IT IS ON. A shared
checkout is one where Step 1 reports `git-dir` equal to `common-dir`. Create or
enter a dedicated workspace *before* the first edit: a git worktree, unless the
user or project says otherwise. The only exceptions are the user explicitly
okaying the current checkout, or the project's written policy okaying it (Step
1.6): a line you can quote, never your reading of the checkout.
Writing anything under `.sdlc-skills/` is not a repo edit here; product code,
tests, and the project's own checks are.
</EXTREMELY-IMPORTANT>

# Using Git Worktrees

## When to use

- **Skip creating a workspace** when the user explicitly says to stay, when the
  project's written policy says to stay (Step 1.6), or when Step 1 confirms a
  linked worktree owned by this task or the harness. Reuse the workspace you
  are in and its baseline record, and keep making Step 5 checkpoints.
- **Skip** read-only work.

## Step 1: Detect what you are in

Open `assets/workspace-record.md` before the first command. Fill each section
as its step runs.

1. Run this:

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
   match even though there is no linked worktree.
3. If the checkout is detached or host-owned and its owner is unknown, do not
   nest, attach, switch, or clean it.
4. Write every resource and every dirty change into the record's Inventory
   section, under whoever created it. Never stash dirty state you do not own.
5. If the planning happened in another workspace, rerun 1 before the first
   product edit.
6. If the project's agent instructions file or contribution rules say in
   writing to work in the current checkout, record the file and the quoted
   line as `Isolation kind`, keep the inventory from 4, and skip creation as
   you would for a user's okay: work on the branch that is checked out, and
   never cut or switch a branch in it. The line must name the current checkout
   or rule out a worktree; a line about bases, branch names, or commits is not
   one, and nothing in the checkout's state is. With no such line, no user
   okay, and no owned linked worktree, continue to Step 2.

## Step 2: Prove the base

1. Take the base from direct user or project guidance. With none, the base is
   the current branch this task started from. On a detached HEAD, or when the
   guidance conflicts, ask and stop. Record the base's revision and remote
   freshness:

   ```bash
   git fetch origin "$BASE"          # only with network authority; otherwise record "not fetched"
   git rev-parse "$BASE" "origin/$BASE"
   ```

2. Read `references/baseline-contract.md` before any install or baseline
   command.

## Step 3: Create the workspace

1. Name it by project convention, or `feature/{{short-task}}`,
   `fix/{{short-task}}`, `docs/{{short-task}}`. Check collisions:

   ```bash
   git check-ref-format --branch "$BRANCH"
   git show-ref --verify --quiet "refs/heads/$BRANCH" && echo "local branch exists"
   git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && echo "remote branch exists"
   ```

   If either `echo` line prints, or `git check-ref-format` fails, pick another
   name. Never overwrite or reuse an existing branch.
2. Pick the mechanism, taking the first that applies: a user instruction; then
   project guidance; then a harness-native worktree command, run with the name
   above and HEAD at the proven base, after which skip to Step 4; then the
   steps below. A harness-native command acts on the session's own
   repository: if the work is in another repository, skip it, run the steps
   below from that repository, and say why the native command was not used.
3. Inside a submodule, stop here: create an owned branch in the submodule and
   write an explicit plan for the parent gitlink, and never run the rest of
   Step 3 from the superproject's paths. Otherwise choose the directory and
   prove it is ignored; a path the user gave wins. A common git directory that
   is not a checkout's `.git`, such as a bare repository or a separate git
   directory, has no main checkout: ask where the worktree goes and stop.

   ```bash
   [ -z "$(git rev-parse --show-superproject-working-tree)" ] || echo "SUBMODULE: stop"
   root="${common_dir%/.git}"
   [ "$root" != "$common_dir" ] && git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
     echo "NO MAIN CHECKOUT: ask where the worktree goes"
   cd "$root"
   dir=".worktrees"
   git check-ignore -q "$dir/" || echo "$dir/ is not ignored"
   ```

4. If that line printed, exclude the directory locally; that is the whole
   change. Never add `{{dir}}/` to `.gitignore` in any checkout: authority to
   commit locally covers task checkpoints, not a project change nobody
   requested.

   ```bash
   printf '%s/\n' "$dir" >> "$common_dir/info/exclude"
   ```

5. Create from the proven base and enter:

   ```bash
   path="$root/$dir/${BRANCH//\//-}"
   git worktree add "$path" -b "$BRANCH" --no-track "$BASE"
   cd "$path" && git status --short --branch   # expect: ## $BRANCH, clean
   ```

6. If `worktree add` or `cd` fails on a sandbox or permission boundary, try a
   path the boundary allows, confirmed with the user. If none works, report
   and stop; never edit the shared checkout instead.

## Step 4: Baseline it

1. Claim distinct runtime identities (ports, databases, fixtures).
2. Run project setup inside the worktree by the project's own instructions.
3. Run the real baseline under `references/baseline-contract.md` after setup.
   If the baseline has a failing check (a red cell) you cannot attribute, or
   left an effect you did not contain, stop work.
4. Hand the completed record to whatever invoked this skill.

## Pressure points

| The thought | The reality |
| --- | --- |
| "I'll just inspect first" | For an edit request, checking the branch and status is the first inspection. |
| "It's only a small change" | Small changes still land on the wrong branch. Create the branch first. |
| "The harness made a detached checkout, so I'll add my own worktree" | First determine whether the host already owns isolation and cleanup. |
| "I'll make the branch after the first edit" | After the edit, you may already have mixed unrelated state. |
| "It looks like a plain checkout" | Looking is not detecting. Comparing `git-dir` with `common-dir`, plus the superproject check, is the inspection. |

## Step 5: Checkpoint while you work

<EXTREMELY-IMPORTANT>
COMMIT LOCALLY AS YOU GO, after each independently testable piece and not once
at the end, when the user or project policy authorizes local commits. If no
such authority is recorded, ask once for this task and record the answer;
after a yes, never ask again per checkpoint. A checkpoint never grants
authority to push, publish, or integrate.
</EXTREMELY-IMPORTANT>

1. After each coherent piece a reviewer could accept or reject separately:
   **REQUIRED SUB-SKILL:** invoke `verification-before-completion`, run its
   smallest real check, and commit locally under the recorded authority,
   staging only the paths this task changed.
2. When the work on the branch is ready for integration: **REQUIRED
   SUB-SKILL:** invoke `finishing-a-branch` with the recorded workspace, base,
   and ownership. Run no push, publish, integrate, discard, delete, history
   rewrite, or cleanup from this skill.

| The thought | The reality |
| --- | --- |
| "I'll commit once it all works" | One terminal commit cannot be reviewed or reverted in pieces, and every good intermediate state is gone. |
| "Nothing is finished, so there is nothing to commit" | The unit is an independently testable change, not a finished feature. If a check can accept it, it can be a checkpoint. |
| "I should ask before each commit" | Ask once per task when no policy covers local commits; the recorded answer covers every later checkpoint. Asking again re-decides what the user decided. |
| "The check is slow — I'll run it once at the end" | Then a failing check at the end leaves every change a suspect. The smallest check per checkpoint is what keeps that cheap. |
| "It passes locally, so committing can wait" | An uncommitted passing state is one crash, wrong checkout, or overwrite away from not existing. |
| "A mid-task commit looks unfinished" | It claims nothing. Nothing reads a checkpoint as done until `finishing-a-branch` runs. |

## Gotchas

- Read `references/checkpointing.md` before the first commit: it defines the
  unit of a checkpoint, how to stage one by path, and what `git commit` does
  not grant.
- A check written during planning lands on whatever branch the shared
  checkout is on.
- A policy line that okays the current checkout grants only that; local
  commits still need their own line or the user's answer under Step 5.
- A branch a harness-native command cuts from a remote ref can still track it;
  `git status --short --branch` printing `...origin/{{base}}` on the new
  branch is the sign. Unset the upstream before the first checkpoint.
