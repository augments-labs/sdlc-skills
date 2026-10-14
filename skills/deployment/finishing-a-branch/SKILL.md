---
name: finishing-a-branch
description: "Takes a branch through the transition the user chooses: push, PR, integration, keep, discard, close, or reopen. Use when implementation is complete and its gates are green but the branch choice is unsettled, even without a Git request, or when the user asks to push, integrate, keep, discard, close, or reopen the branch, what to do with this branch, to merge it, to open a PR, or whether we are done here. Skip mid-development checkpoints and an unchanged state whose branch choice is already settled unless a new transition is requested."
---

# Finishing a Branch

Take the state under check (the exact working tree or commit being finished;
the script calls it the candidate) or a named PR through one branch transition
the user chooses. Green checks and "seems done" authorize no change to history
or to a remote, and no discard or cleanup.

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

2. Identify the requested transition. If it is an explicit keep-as-is,
   discard, or PR-only close or reopen, apply that action's identity,
   ownership, and authority rules below; readiness evidence is not an entry
   condition for those actions.
3. For materialization (committing the reviewed working tree), publication,
   or integration, bind the `verification-before-completion` evidence record
   (the ledger: add to it, never rewrite it) and the `requesting-code-review`
   verdict (shallow `self-reviewed: ready`, or the required independent review
   with no blocker) to one identity for the state under check: the full
   revision when the script reports `dirty.clean: true`, the working-tree
   hash otherwise. Bind the live remote or PR state as well.
4. If a required readiness verdict is missing, keep the requested action
   pending; offer keep-as-is, or obtain the missing review under current
   authority.
5. For a PR-only close or reopen, record the live PR, its head and base refs,
   and the resources that stay in place.
6. List the resources this task created (branch, worktree, remote ref, PR)
   from the `using-git-worktrees` workspace record. Only those may be cleaned
   up. A task-looking path proves nothing.
7. For integration, read `base.resolved`. If it is `false`, resolve the base
   before acting. A direct instruction or the project's contribution rules
   override the detected default. Check remote freshness yourself; the script
   does not fetch. If the base is stale, has moved, or is ambiguous, do not
   integrate.
8. Read `candidate.published`. If it is `true` or `null`, or a `false` read
   from remote-tracking refs that were not refreshed under the network
   authority you hold now, get separate direct permission for each of squash,
   rebase, and amend. Never force-push as a repair. After any history change,
   rerun the script; if the content moved, go back to
   `requesting-code-review`.
9. For PR creation or update, prepare the description from the project's
   contribution rules and the template the base branch carries; if there is
   none, open `assets/pr-description.md` before writing it. Fill the evidence
   fields only from the bound ledger and verdict; if the project's template
   has no place for the check results, the review verdict, or what was not
   verified, add them. For other actions, prepare the fields that apply
   without inventing a PR.

## Step 2: Present the choices

1. Read `references/branch-state.md` before preparing the transition
   descriptor that applies (the reference's record of exactly what one
   transition will do). If a direct instruction, or proof it happened from a
   trusted source (the reference calls it a receipt), already covers the
   descriptor's current targets, action, and payload, record that choice and
   go on to Step 3. If no choice exists yet, offer only the entries the state
   permits, then stop (`Gates:` summarizes the checks bound in Step 1.3):

   ```text
   Branch {{branch}} → {{base}}. Gates: {{summary}}. Review: {{verdict}}.

   1. Commit and keep
   2. Push the branch
   3. Push and open a PR
   4. Integrate locally into {{base}}
   5. Keep as-is

   Recommendation: {{least-mutating option meeting the stated delivery intent}} — {{one sentence}}.
   ```

2. If the workspace is detached or host-owned, offer only *publish as a new
   branch* and *keep as-is*.
3. If a PR already exists, offer only the transitions its state and its
   policy permit. Never conflate, retarget, rewrite, delete, or duplicate a
   PR.
4. Never put discard on this menu.
5. Wait for one listed entry. If the reply is praise, a constraint, a partial
   answer, silence, "looks good", or a decision about something adjacent,
   present the menu again unchanged.
6. Bind the answer to the prepared descriptor. If the target or payload
   changes materially, show the changed choice; do not reuse the approval
   given for the old one.

## Step 3: Execute

1. Read `references/branch-state.md` before executing, and execute through it.
2. Run the required checks on the exact integrated result *before* the base
   advances. A failure after the advance is an `integrated-regression`;
   follow the reference's recovery for it.
3. Remove an owned worktree only after confirmed integration. Leave detached,
   shared, user-owned, and host-owned resources in place.
4. **REQUIRED SUB-SKILL:** if the result is a releasable or running
   artifact, invoke `release-readiness`. Canary, deploy, publish, and
   distribute are its verdict, not this skill's.

## Discard is a separate destructive path

Enter only on a direct request. Never offer discard because work looks
unwanted.

1. Rerun `bash scripts/branch-state.sh` before filling the block. If
   `base.resolved` is false, get the base from the user or the project, rerun
   with `--base`, and fill nothing until it resolves. Then fill the block from
   the output and print it:

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

2. Stop. If the reply is "yes", "go ahead", "get rid of it", or a numbered or
   clicked choice, touch nothing.
3. Only after that exact token, rerun with the same `--base`. A changed
   `candidate.id`, a non-zero exit, or no `candidate.id` voids the token.
   Otherwise close or delete the listed task-owned resources, and nothing else.

## Gotchas

- A local-only repository has no resolvable base: its commit counts are `null`,
  not 0, and a block filled from them hides commits.
- A tip-only check, a branch's own upstream taken as its base, or stale
  remote-tracking refs each read pushed history as unpublished.
