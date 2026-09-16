---
name: verification-before-completion
description: "Runs the checks and reads their output before any claim that work is done. Use when work is about to be called complete, fixed, passing, done, or satisfactory, before any commit or PR, when evidence may be stale, partial, or bound to another state, or before saying that should do it, it's working now, or all set, even if no formal claim is made."
---

# Verification Before Completion

## When to use

- **Never skip**, including before the next task of a plan. The gate set comes
  from Step 1.3, not the size of the change: a one-line fix still runs the
  smallest gate that can fail.
- An integrated UI adds `visual-ui-verification` to that set.

## Available scripts

- **`scripts/state-identity.sh`** — the capture and re-check of Steps 1.4 and
  2.5; `--help` documents its exit codes.

## Step 1: Bind the claim

1. List every item the request asked for, including any added
   mid-conversation, each with a disposition: delivered, pending, blocked, or
   declined with a reason.
2. Open `assets/evidence-ledger.md` before the first gate runs, filling each
   field as its step runs — a ledger (append-only, outside the candidate).
   `Claim` names the transition under evaluation.
3. One `Results` row per gate the task, plan, or assurance cadence requires
   here; missing, planned, blocked, or unreasoned → claim pending before
   anything runs. A named human acceptor → read
   `references/manual-acceptance.md` before its row.
4. Capture the source state; add `--committed` when the candidate is a commit:

   ```bash
   before=$(bash scripts/state-identity.sh --quiet)
   ```

5. Fill `State` for what the script cannot see.

## Step 2: Run the gates

1. Reuse a row only while the ledger's `Invalidation` list leaves it valid
   here, and record why. Run the rest fresh. Shared effects → in sequence;
   disjoint → in parallel.
2. Timeout or mid-run failure: wait until its processes and effects stop,
   record the result, reject late output. Repeated failure under unchanged
   conditions → diagnose or return pending, never rerun until a sample passes.
3. Unwanted mutation: restore and rerun, or record it as pending.
4. Read the raw output, not the exit code, and record the run in its row;
   redact only the copy shown to the user. An assertion that could not have
   failed for this code: say so, and do not cite the green.
   Repairing such a gate belongs to `verification-strategy`.
5. Re-check with the flags used at capture:

   ```bash
   bash scripts/state-identity.sh --compare "$before"
   ```

   `1`, or `5` for content outside the commit → the source moved: identify the
   writer or normalization and recapture from Step 1.4, never committing here.
   `2`–`4` → no identity. Any nonzero leaves the claim pending.
   Zero → reconcile the other `State` inputs yourself.

## Step 3: Claim and return

1. Fill `Inventory reconciliation`: a required gate that did not run, or ran
   on another state, turns aggregate green red.
2. Return the ledger without touching the candidate, failures and inconclusive
   rows intact.
3. Write the claim the rows support and nothing wider: what passed, on which
   state identity, what is pending. A required row failed or unrun → not
   complete.
4. A checkpoint commit reuses content-check rows only when
   `--compare "$before" --committed` exits 0. Commit, CI, and review gates
   bind to their own revision.
5. **REQUIRED — return the ledger; this skill routes nowhere.** Every unmet
   gate goes back with it, to the pending step of whatever asked; never invoke
   that caller recursively. `using-sdlc-skills`' done rule routes what follows;
   only `release-readiness` decides release.
6. Run no commit, push, PR, or merge from this skill.

## Gotchas

- A reused row binds to the state it ran on: a partial commit leaves reviewed
  files uncommitted while the digest still matches, and only `--committed`
  proves otherwise.

## Hard stops

- Never report done while any requested item lacks a disposition.
- Never claim a test passes without seeing it pass for the recorded state.
- Never claim a bug fixed without a reproduction that failed before and passes
  after, with exact restoration/control evidence.
- Never turn a worker's “success” report into evidence; inspect its diff/state
  and raw output.
- Never mutate a candidate with the bookkeeping meant to prove that candidate.
- A never-falsified gate is suspect. Read
  `references/hollow-verification.md` before citing its green.
- A gate silenced is not a gate passed. Suppressing a finding, lowering a
  strictness setting, or excluding a path changes what ran, not what is true —
  and the claim that gate supported is now unproven.
- A flaky green is unexplained nondeterminism; route it through `debugging`.
- Verified is not reviewed. A candidate at a completion or integration
  boundary requires `requesting-code-review`; task-local gate status
  is not that boundary unless its plan says so.

## When tempted to skip

| Thought | Reality |
| --- | --- |
| "It should work" | Run the gate and make it a fact. |
| "I ran it earlier" | Earlier state or evidence age may not support this transition. |
| "The types pass" | Types, build, behavior, requirements, and release are distinct claims. |
| "The suite is green, so the code is covered" | Read what it asserted. A green that could not have been red covers nothing. |
