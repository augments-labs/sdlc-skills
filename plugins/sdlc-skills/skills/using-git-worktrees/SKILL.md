---
name: using-git-worktrees
description: "Creates an isolated git worktree for a task and checkpoints work there. Use when a repository is about to be edited for the first time in a task, when work needs an isolated checkout and its own resources, or at a local task checkpoint. Reuse a linked worktree only when this task or the harness owns it; there, skip creating a workspace but keep checkpoint discipline. Skip read-only work."
---

<EXTREMELY-IMPORTANT>
NEVER START REPO EDITS IN A SHARED CHECKOUT — one where Step 1 reports
`git-dir` equal to `common-dir` — WHATEVER BRANCH IT IS ON. Create or enter a
dedicated workspace — a git worktree unless the user or project says otherwise —
*before* the first edit, unless the user explicitly okayed the current checkout.
Writing the `.sdlc-skills/` artifact trail (briefs, specs, designs, plans) is
not a repo edit here; product code, tests, and project gates are.
</EXTREMELY-IMPORTANT>

# Using Git Worktrees

Give every task its own checkout, prove the base it starts from, and write
down what you found there before you change anything.

## When to use

- **Skip creation** when the user explicitly says to stay, or Step 1 confirms
  a linked worktree owned by this task or the harness. Reuse its current workspace
  and baseline record; retain Step 5 checkpoints and handoff. Skip read-only work.

## Step 1: Detect what you are in

Open `assets/workspace-record.md` before the first command. Fill each section as its step runs.

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
   column. It blocks cleanup. Never stash dirty state you do
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
   create below.
3. Inside a submodule → stop here. Create an owned branch in the submodule and
   write an explicit plan for the parent gitlink; never run Steps 3.3–3.5 from
   the superproject's paths. Otherwise choose the directory and prove it is
   ignored. User-given path wins.

   ```bash
   [ -z "$(git rev-parse --show-superproject-working-tree)" ] || echo "SUBMODULE: stop; follow the submodule rule"
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
   report and stop. Never edit the shared checkout instead.

## Step 4: Baseline it

1. Claim distinct runtime identities (ports, databases, fixtures).
2. Run project setup inside the worktree by the project's own instructions.
3. Run the real baseline under `references/baseline-contract.md` after setup: pre-run
   inspection, pre/post capture, each red cell bound. Red cell you cannot
   attribute, or an effect you did not contain → stop work.
4. Hand the completed `assets/workspace-record.md`, after the baseline, to
   whatever invoked this skill.

## Pressure points

| The thought | The reality |
| --- | --- |
| "I'll just inspect first" | For edit requests, branch/status is the first inspection. |
| "It's only a small change" | Small changes still land on the wrong branch. Create the branch first. |
| "The harness made a detached checkout, so I'll add my own worktree" | First determine whether the host already owns isolation and cleanup. |
| "I'll make the branch after the first edit" | After the edit, you may already have mixed unrelated state. |
| "It looks like a plain checkout" | Looking is not detecting. `git-dir` against `common-dir`, plus the superproject check, is the inspection. |
| "The harness has a worktree tool, but plain git is simpler" | The native tool owns the path, the ignore rule, and cleanup. A hand-made worktree beside it is a second thing to clean up. |

## Step 5: Checkpoint while you work

<EXTREMELY-IMPORTANT>
COMMIT LOCALLY AS YOU GO — after each independently testable piece, not once at
the end — when the user or project policy authorizes local commits. None
recorded → ask once for this task and record the answer; after a yes, never ask
per checkpoint. A checkpoint never grants push, publication, or integration
authority.
</EXTREMELY-IMPORTANT>

1. After each coherent piece a reviewer could accept or reject separately:
   **REQUIRED SUB-SKILL:** invoke `verification-before-completion`, run its smallest
   real gate, and commit locally under the recorded authority. Do not wait for
   the final candidate. None recorded → keep it uncommitted until the answer
   arrives.
2. Candidate ready for integration → **REQUIRED SUB-SKILL:** invoke
   `finishing-a-branch` with the recorded workspace, base, and ownership. Run
   no push, publish, integrate, discard, delete, history rewrite, or cleanup
   from this skill.

| The thought | The reality |
| --- | --- |
| "I'll commit once it all works" | One terminal commit cannot be reviewed or reverted in pieces, and every good intermediate state is gone. |
| "Nothing is finished, so there is nothing to commit" | The unit is an independently testable change, not a finished feature. If a gate can accept it, it can be a checkpoint. |
| "I should ask before each commit" | Ask once per task when no policy covers local commits; the recorded answer covers every later checkpoint. Asking again re-decides what the user decided. |
| "The gate is slow — I'll run it once at the end" | Then a red gate at the end leaves every change a suspect. The smallest gate per checkpoint is what keeps that cheap. |
| "It passes locally, so committing can wait" | An uncommitted passing state is one crash, wrong checkout, or overwrite away from not existing. |
| "A mid-task commit looks unfinished" | It claims nothing. Nothing reads a checkpoint as done until `finishing-a-branch` runs. |

## Gotchas

- Being able to run `git commit` is not authority to commit: a commit runs hooks
  and signing and shapes history.
- A gate written during planning lands on whatever branch the shared checkout
  is on.
