---
name: finishing-a-branch
description: "Takes a branch through the transition the user chooses: push, PR, integration, keep, discard, close, or reopen. Use when implementation is complete and its gates are green but the branch choice is unsettled, even without a Git request, or when the user asks to push, integrate, keep, discard, close, or reopen the branch, what to do with this branch, to merge it, to open a PR, or whether we are done here. Skip mid-development checkpoints and an unchanged state whose branch choice is already settled unless a new transition is requested."
---

# Finishing a Branch

Take a candidate or named PR through one branch transition the user chooses.
Green checks and "seems done" authorize no history, remote, discard, or cleanup
mutation.

## When to use

- Present the permitted choices even without a Git request.
- **Skip** ordinary mid-development checkpoints; `using-git-worktrees` owns
  those. Skip an unchanged state with an already settled branch choice unless
  the user requests another transition.

## Available scripts

- **`scripts/branch-state.sh`** — the local git state as JSON, read-only.
  `--help` documents its fields and exit codes.

## Step 1: Read the state

1. Run the script and keep its output. Use its numbers verbatim later; never
   hand-count commits.

   ```bash
   bash scripts/branch-state.sh
   ```

2. Identify the requested transition. Explicit keep-as-is, discard, or PR-only
   close/reopen → apply its identity, ownership, and authority rules below;
   readiness evidence is not an entry condition for those actions.
3. For materialization, publication, or integration, bind the
   `verification-before-completion` evidence and the `requesting-code-review`
   verdict (shallow `self-reviewed: ready`, or the required independent review
   with no blocker) to one candidate identity: the full revision when the
   script reports `dirty.clean: true`, the digest otherwise. Bind the live
   remote or PR state.
4. Required readiness verdict missing → keep the requested action pending;
   offer keep-as-is or obtain the missing review under current authority.
5. PR-only close or reopen → record the live PR, head and base refs, retained
   resources.
6. List the resources this task created (branch, worktree, remote ref, PR)
   from the `using-git-worktrees` workspace record. Only those may be cleaned
   up. A task-looking path proves nothing.
7. For integration, read `base.resolved`. `false` → resolve it before acting.
   A direct instruction or the
   project's contribution rules override the detected default. Check remote
   freshness yourself; the script does not fetch. Stale, moved, or ambiguous
   base → no integration.
8. Read `candidate.published`. `true` or `null`, or a `false` read from
   remote-tracking refs not refreshed under current network authority →
   separate direct permission for each of squash, rebase, amend. Never
   force-push as repair. After any history change, rerun the script; content
   moved → back to `requesting-code-review`.
9. For PR creation/update, prepare the description from the contribution rules
   and base-bound template, with evidence obtained. Prepare other actions'
   applicable fields without inventing a PR.

## Step 2: Present the choices

1. Read `references/branch-state.md` before preparing the applicable transition
   descriptor.
   A direct instruction or trusted receipt already covers its current targets,
   action and payload → record that choice and proceed to Step 3. Missing
   choice → offer only the state-permitted entries, then stop:

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
3. Existing PR → only the transitions permitted for the PR's state and its
   policy. Never conflate, retarget, rewrite, delete, or duplicate a PR.
4. Never put discard on this menu.
5. Wait for one listed entry. Praise, constraints, partial answers, silence,
   "looks good", an adjacent decision → re-present the menu unchanged.
6. Bind the answer to the prepared descriptor. Material target or payload
   change → show the changed choice; do not reuse approval for the old one.

## Step 3: Execute

1. Read `references/branch-state.md` before executing, and execute through it.
2. Run the gate on the exact integrated candidate *before* the base
   advances. Failure after the advance = `integrated-regression`; follow the
   reference's recovery.
3. Remove an owned worktree only after confirmed integration. Leave detached,
   shared, user-owned, and host-owned resources in place.
4. **REQUIRED SUB-SKILL:** releasable or running artifact → invoke
   `release-readiness`. Canary, deploy, publish, and distribute are its
   verdict, not this skill's.

## Discard is a separate destructive path

Enter only on a direct request. Never offer discard because work looks
unwanted.

1. Rerun `scripts/branch-state.sh` before filling the block. `base.resolved`
   false → get the base from the user or project, rerun with
   `--base`, and fill nothing until it resolves. Then fill it from the output:

   ```text
   This will permanently delete:
   - Branch {{name}} ({{n}} unique commits: {{list}})
   - Staged {{n}}, unstaged {{n}}, untracked {{n}} changes
   - Ignored {{n}}: {{list}} (lost only with a removed worktree; never recoverable)
   - Worktree {{path}}; remote {{state}}; PR {{state}}
   Recovery: {{possible | not possible}}

   Recommendation: {{preserve unless current authority clearly calls for deletion}}.
   Type `discard {{candidate.id}}` to confirm.
   ```

2. Stop. "yes", "go ahead", "get rid of it", a numbered choice → nothing is
   touched.
3. Only after that exact token: rerun with the same `--base`. A changed
   `candidate.id`, a non-zero exit, or no `candidate.id` voids the token.
   Otherwise close or delete the listed task-owned resources, and nothing else.

## Gotchas

- A local-only repository has no resolvable base: its commit counts are `null`,
  not 0, and a block filled from them hides commits.
- A tip-only check, a branch's own upstream taken as its base, or stale
  remote-tracking refs each read pushed history as unpublished.
