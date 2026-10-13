---
name: verification-before-completion
description: "Runs the checks and reads their output before any claim that work is done. Use when work is about to be called complete, fixed, passing, done, or satisfactory, before any commit or PR, when evidence may be stale, partial, or bound to another state, or before saying that should do it, it's working now, or all set, even if no formal claim is made."
---

# Verification Before Completion

## When to use

- **Never skip**, even before a plan's next task. Step 1.3 decides which
  checks run, not the size of the change: a one-line fix still runs the
  smallest check that could fail.
- An integrated UI adds `visual-ui-verification` to that set.

## Available scripts

- **`scripts/state-identity.sh`** — captures and re-checks the state identity
  (the commit, or a hash of the uncommitted files) in Steps 1.4 and 2.4.

## Step 1: Pin down the claim

1. List every item the request asked for, including anything added later,
   and mark each delivered, pending, blocked, or declined with a reason.
2. Keep an evidence record. One task with one required check: one row in
   your reply holds the claim, the check, the state identity, and the raw
   result. An integration, a release, or more than one check: open the full
   evidence record, `assets/evidence-ledger.md`, before the first check runs
   and fill every field.
3. Add one `Results` row per check the task, the plan, or a standing project
   rule requires here. A required check that is missing, unwritten, blocked, or
   unexplained makes the claim pending before anything runs. If a person
   must accept the work by hand, read `references/manual-acceptance.md` before
   its row.
4. Capture the state the checks will run on; add `--committed` when that
   state is a commit:

   ```bash
   before=$(bash scripts/state-identity.sh --quiet)
   ```

5. Fill `State` with what the script cannot see.

## Step 2: Run the checks

1. Reuse an earlier result only while the record's `Invalidation` list still
   allows it, and record why. Run the rest fresh.
2. If a check times out, fails partway, runs in the background, or changes
   something it should not, read `references/unsettled-runs.md` before
   recording its row. Never count late output, or a log from before this
   attempt or another run. If it fails again with nothing changed, diagnose
   or return pending; never rerun until one passes.
3. Read the raw output, not the exit code, and record the run in its row;
   redact only the copy you show your human partner. If an assertion could
   not have failed for this code, say so and do not count its green;
   repairing it belongs to `verification-strategy`.
4. Re-check the state with the flags used at capture:

   ```bash
   bash scripts/state-identity.sh --compare "$before"
   ```

   Any nonzero exit leaves the claim pending; read
   `references/unsettled-runs.md` before recapturing, and never commit to
   make the identities match. On 0, compare the other `State` inputs
   yourself.

## Step 3: Claim and return

1. Fill `Inventory reconciliation`. A required check that failed, did not
   run, or ran on another state makes the whole result red: not complete.
2. Return the record with its failed and inconclusive rows intact.
3. Write the claim the rows support and nothing wider: what passed, on which
   state identity, what is pending.

   An off-by-one fix to `due_date`: `pytest tests/test_due.py::test_last_day`
   on commit `4f2a9c1` prints `1 passed`. That supports "the task's test
   passes on `4f2a9c1`", not "done": the full suite, review, and integration
   have not run.

4. A checkpoint commit reuses rows only when
   `--compare "$before" --committed` exits 0. Commit, CI, and review checks
   bind to their own revision.
5. **REQUIRED — return the record; this skill routes nowhere.** Every unmet
   check goes back with it to the pending step of whatever asked; never
   invoke that caller from here. `using-sdlc-skills`' done rule routes what
   follows; only `release-readiness` decides release.
6. Run no commit, push, PR, or merge from this skill.

## Gotchas

- A partial commit leaves reviewed files uncommitted while the hash still
  matches; only `--committed` proves a commit holds a row's state.

## Hard stops

- Never report done while any requested item has no recorded decision.
- Never claim a test passes without seeing it pass on the recorded state.
- Never claim a bug fixed without a reproduction that failed before and
  passes after, plus exact evidence of the restored before state and the
  control.
- Never turn a worker's "success" report into evidence; inspect its diff,
  state, and raw output.
- Never change the files under review with the bookkeeping meant to prove
  them.
- A check that has never been seen to fail is suspect. Read
  `references/hollow-verification.md` before counting its green.
- A check silenced is not a check passed. Suppressing a finding, lowering a
  strictness setting, or excluding a path changes what ran, not what is true;
  the claim that check supported is now unproven.
- A flaky green is unexplained nondeterminism; send it through `debugging`.
- Verified is not reviewed. Work at a completion or integration boundary
  needs `requesting-code-review`; a task's checks passing is not that
  boundary unless its plan says so.

## When tempted to skip

| Thought | Reality |
| --- | --- |
| "It should work" | Run the check and make it a fact. |
| "I ran it earlier" | The code may have moved since, or that result is too old. |
