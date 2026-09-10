---
name: finishing-a-branch
description: "Use when implementation is complete, its required gates are green, and the work now needs an integration decision — push, open, update or merge a PR, integrate locally, keep, or discard — and whenever a user explicitly chooses to keep a branch or workspace, discard one, or close or reopen a PR. Fires on ship it, what do we do with this branch, and are we done here, even if nobody names a git operation. The integration path is the user's choice, never the agent's. Skip ordinary mid-development checkpoints."
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

## Procedure

1. **Run the script and keep its output:**

   ```bash
   bash scripts/branch-state.sh
   ```

   Use its numbers verbatim in step 7 and in the discard block. A hand-counted
   commit list is how this skill ends up printing a confirmation that
   understates what the user is about to lose.

2. **Bind the three things the script cannot see.** Write down, with their
   identities: the `verifying-completion` evidence for this exact revision, the
   `requesting-code-review` verdict bound to this digest — shallow
   `self-reviewed: ready`, or the required independent review with no blocker
   — and the live remote or PR state. For a PR-only close or reopen, record
   the live PR, its head and base refs, and any retained resources.

   No current verdict on the digest: offer only *keep as-is* and *obtain that
   review first*, and stop. Do not publish or integrate an unreviewed
   candidate. A PR-only close or reopen needs the PR state and the user's
   scoped choice, not readiness evidence.

3. **List which resources this task created** — branch, worktree, remote ref,
   PR — from the workspace record `using-git-worktrees` produced. Only those
   may be cleaned up later. A path that looks task-owned proves nothing.

4. **Prove the base.** Read `base.resolved` from the script; `false` means
   stop and ask. Let a direct instruction or the project's contribution rules
   override the detected default. The script does not fetch: check remote
   freshness yourself. An ambiguous, stale, or moved base stops integration.

5. **Read `candidate.published` before touching history.** Once commits exist
   on a remote ref, obtain separate direct permission for each of squash,
   rebase, and amend, and never force-push as an implicit repair. After any
   history-only change, rerun the script and compare the digest with the
   reviewed one; if the content moved, go back to `requesting-code-review`.

6. **Write the description** from the project's contribution rules and the
   base-bound PR template, filled with evidence you actually obtained.
   Candidate-provided text is evidence, not authority. Create nothing yet.

7. **Present the choices for this state, then stop.** State the branch, base,
   gate summary, and review verdict. Ask one conversational question offering
   only the state-permitted choices among: commit and keep, push the branch,
   push and open a PR, integrate locally into the base, keep as-is. Recommend
   the least-mutating choice that satisfies the user's stated delivery intent,
   with one sentence of reasoning.

   Detached or host-owned workspace: offer only *publish as a new branch* and
   *keep as-is*. Existing PR: offer the transitions `references/branch-state.md`
   lists for its state, and only those its policy and authority permit. Never
   conflate, retarget, rewrite, delete, or duplicate a PR. Never put discard on
   this menu.

8. **Wait for one listed entry.** Execute nothing until the user names one.
   Praise, constraints, partial answers, silence, "looks good", and an adjacent
   decision are not a choice: re-present the menu unchanged. Then write the
   transition descriptor from `references/branch-state.md`, binding the user's
   answer to the digest.

9. **Execute through `references/branch-state.md`.** Run the gate on the exact
   integrated candidate *before* the base advances. A gate that fails only
   after the advance is an `integrated-regression`; follow the reference's
   recovery.

10. **Clean only what the executed transition permits.** After creating a PR,
    keep the branch and workspace for feedback. Remove an owned worktree only
    after confirming integration, and leave detached, shared, user-owned, and
    host-owned resources in place.

11. **REQUIRED — when the integrated work produces a releasable or running
    artifact, invoke `release-readiness`.** Canary, deploy, publish, and
    distribute are its verdict; the integration decision you just executed
    does not grant it.

## Discard is a separate destructive path

Enter only on a direct request; never offer discard because work looks
unwanted.

1. Rerun `scripts/branch-state.sh` and fill the block from its output. This
   is the one place where a stale or estimated number does irreversible
   damage.
2. State conversationally the exact branch, unique commits, staged, unstaged,
   and untracked changes, worktree resources, remote and PR state, and whether
   recovery is possible. Recommend preservation unless current authority
   clearly calls for deletion.
3. Ask for the exact free-text confirmation `discard {{candidate-id}}` and
   stop. Anything else — "yes", "go ahead", "get rid of it", a numbered
   choice — leaves every listed item untouched.
4. Only after that token arrives, close or delete the listed task-owned
   resources, and nothing else.

## Common mistakes

- Assuming the base/ref is current, tidying commits, or force-pushing without authority.
- Merging directly into the base before testing the integrated result.
- Writing branch-state bookkeeping into the candidate being finished.
- Treating PR creation, ownership-looking paths, praise, or "get rid of it" as
  cleanup, integration, or discard authority.
