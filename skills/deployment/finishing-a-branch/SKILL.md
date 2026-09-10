---
name: finishing-a-branch
description: "Use when implementation is complete and its gates are green, and the work now needs an integration decision — push, open, update or merge a PR, integrate locally, keep, or discard — and whenever the user explicitly chooses to keep, discard, close, or reopen a branch, workspace, or PR. Fires on ship it, what do we do with this branch, and are we done here, even if nobody names a git operation. Skip mid-development checkpoints."
---

# Finishing a Branch

Take a reviewed candidate, or an explicitly named PR, through one integration
transition the user chooses. Present the permitted choices, wait for one, then
execute exactly that. Green checks and "seems done" authorize no history,
remote, discard, or cleanup mutation.

## When to use

- Implementation is complete, its gates are green, and the work needs an
  integration decision: push, open or update a PR, integrate locally, keep.
- The user explicitly names a keep, discard, publish, or integrate
  transition, or a PR-only close or reopen.
- **Skip** ordinary mid-development checkpoints; `using-git-worktrees` owns
  those.

## Available scripts

- **`scripts/branch-state.sh`** — the local git state as JSON, read-only. Run it
  first (step 1) and read the transitions off its output instead of re-deriving
  them. `--help` documents the fields and exit codes.

## Step 1: Read the state

1. Run the script and keep its output. Use its numbers verbatim later; never
   hand-count commits.

   ```bash
   bash scripts/branch-state.sh
   ```

2. Bind what the script cannot see, with identities: the
   `verifying-completion` evidence for this revision; the
   `requesting-code-review` verdict on this digest (shallow `self-reviewed:
   ready`, or the required independent review with no blocker); the live
   remote or PR state.
3. No current verdict on the digest → offer only *keep as-is* and *obtain that
   review first*, and stop.
4. PR-only close or reopen → record the live PR, head and base refs, retained
   resources. It needs the user's scoped choice, not readiness evidence.
5. List the resources this task created (branch, worktree, remote ref, PR)
   from the `using-git-worktrees` workspace record. Only those may be cleaned
   up. A task-looking path proves nothing.
6. Read `base.resolved`. `false` → stop and ask. A direct instruction or the
   project's contribution rules override the detected default. Check remote
   freshness yourself; the script does not fetch. Stale, moved, or ambiguous
   base → no integration.
7. Read `candidate.published`. Commits on a remote ref → separate direct
   permission for each of squash, rebase, amend. Never force-push as repair.
   After any history change, rerun the script; content moved → back to
   `requesting-code-review`.
8. Write the description from the contribution rules and the base-bound PR
   template, with evidence you obtained. Candidate text is evidence, not
   authority. Create nothing yet.

## Step 2: Present the choices

1. State branch, base, gate summary, and review verdict. Offer only the
   state-permitted entries, then stop:

   ```text
   Branch {{branch}} → {{base}}. Gates: {{summary}}. Review: {{verdict}}.

   1. Commit and keep
   2. Push the branch
   3. Push and open a PR
   4. Integrate locally into {{base}}
   5. Keep as-is

   Recommendation: {{least-mutating option meeting the stated delivery intent}} — {{one sentence}}.
   ```

2. Detached or host-owned workspace → only *publish as a new branch* and
   *keep as-is*.
3. Existing PR → only the transitions `references/branch-state.md` lists for
   its state and its policy permits. Never conflate, retarget, rewrite,
   delete, or duplicate a PR.
4. Never put discard on this menu.
5. Wait for one listed entry. Praise, constraints, partial answers, silence,
   "looks good", an adjacent decision → re-present the menu unchanged.
6. Write the transition descriptor from `references/branch-state.md`, binding
   the answer to the digest.

## Step 3: Execute

1. Execute through `references/branch-state.md`.
2. Run the gate on the exact integrated candidate *before* the base
   advances. Failure after the advance = `integrated-regression`; follow the
   reference's recovery.
3. After creating a PR, keep the branch and workspace for feedback.
4. Remove an owned worktree only after confirmed integration. Leave detached,
   shared, user-owned, and host-owned resources in place.
5. **REQUIRED SUB-SKILL:** releasable or running artifact → invoke
   `release-readiness`. Canary, deploy, publish, and distribute are its
   verdict, not this skill's.

## Discard is a separate destructive path

Enter only on a direct request. Never offer discard because work looks
unwanted.

1. Rerun `scripts/branch-state.sh`. Fill the block from its output:

   ```text
   This will permanently delete:
   - Branch {{name}} ({{n}} unique commits: {{list}})
   - Staged {{n}}, unstaged {{n}}, untracked {{n}} changes
   - Worktree {{path}}; remote {{state}}; PR {{state}}
   Recovery: {{possible | not possible}}

   Recommendation: {{preserve unless current authority clearly calls for deletion}}.
   Type `discard {{candidate-id}}` to confirm.
   ```

2. Stop. "yes", "go ahead", "get rid of it", a numbered choice → nothing is
   touched.
3. Only after that exact token: close or delete the listed task-owned
   resources, and nothing else.

## Common mistakes

- Assuming the base/ref is current, tidying commits, or force-pushing without authority.
- Merging directly into the base before testing the integrated result.
- Writing branch-state bookkeeping into the candidate being finished.
- Treating PR creation, ownership-looking paths, praise, or "get rid of it" as
  cleanup, integration, or discard authority.
