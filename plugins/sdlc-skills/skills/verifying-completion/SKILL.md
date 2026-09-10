---
name: verifying-completion
description: "Use before any claim that work is complete, fixed, passing, done, or satisfactory, before any commit or PR, and when evidence may be stale, partial, or bound to another state. Fires on that should do it, it's working now, and all set, even if no formal claim is made."
---

# Verifying Completion

Run the gate, read its raw output, and claim only what that output supports
for the exact state it ran on. This skill produces evidence; it does not
design the gates, review the change, integrate the branch, or decide release.

## When to use

- Before any claim that work is complete, fixed, passing, or done; before any
  commit, push, or PR; before moving to the next task of a plan.
- **Never skip.** The gate set comes from Step 1.3, never from the size of
  the change. A one-line fix still runs the smallest gate that can fail.
- A candidate with an integrated UI adds `visual-ui-verification` to its gate
  set: automated checks passing does not make a screen visually correct.

## Available scripts

- **`scripts/state-identity.sh`** — captures the source state a gate runs
  against, and re-checks it afterwards. Read-only; `--help` documents the fields
  and exit codes.

## Step 1: Bind the claim

1. List every item the request asked for, including items added
   mid-conversation. Write a disposition beside each: delivered, pending,
   blocked, or declined with a reason. Four of five delivered is not done.
2. Open `assets/evidence-ledger.md`. Write the claim and its transition in
   `Claim`: task green, integrated acceptance, reviewed candidate, or
   releasable artifact.
3. List the required gates from the task or plan `Evaluator` rows and the
   assurance matrix's cadence for this transition, one row each in `Results`.
   A gate missing, planned, blocked, or omitted without a reason → claim
   pending before anything runs.
4. Capture the source state:

   ```bash
   before=$(bash scripts/state-identity.sh --quiet)
   ```

5. Fill `State` for what the script cannot see: generated and external
   inputs, configuration, build mode, gate version, pre-state of any data,
   process, or effect the gate touches.

## Step 2: Run the gates

1. Before each gate, write in its `Results` row what it may touch and under
   whose authority.
2. Run each required gate fresh. Shared effect boundary → in sequence.
   Disjoint → in parallel. Never reuse an earlier run.
3. Timeout or mid-run failure: wait until its processes and effects stop,
   move its leftovers out of the candidate, start a new linked run that
   ignores late output.
4. Unwanted mutation: restore and rerun, or record it as pending.
5. Read the raw output. Record the run in its row and its handling under
   `Evidence controls`. Redact only the copy shown to the user.
6. Read what the gate asserted, not its exit code. Assertions that could not
   have failed for this code: write that in the row; do not cite the green.
   Repairing such a gate belongs to `verification-strategy`.
7. Re-check the source state:

   ```bash
   bash scripts/state-identity.sh --compare "$before"
   ```

   Non-zero → the source moved; rerun from Step 1.4. Zero → reconcile the
   other `State` inputs yourself.

## Step 3: Claim and route

1. Fill `Inventory reconciliation`: compare what ran against Step 1.3. A
   required gate that did not run, or ran on another state, turns aggregate
   green red.
2. Return the ledger without touching the candidate. Keep failures and
   inconclusive results in it as they are.
3. Write the claim the rows support and nothing wider: what passed, on which
   state identity, what is pending. Any required row failed or unrun → not
   complete.
4. A checkpoint commit with an identical tree may reuse content-check rows.
   Commit, CI, and review gates bind to their own revision. A checkpoint is
   neither reviewed nor merge-ready.
5. **REQUIRED — route by the transition:**
   - task green in a plan, or a worktree checkpoint → return to the skill
     that sent you; nothing more here
   - completion or integration (the user will read it as done, or it is about
     to be pushed, published, or merged) → invoke `requesting-code-review`
   - releasable artifact → invoke `release-readiness`
6. Run no commit, push, PR, or merge from this skill.

## Manual acceptance

When the spec, plan, or user names a person as a requirement's acceptor, use
`references/manual-acceptance.md`. An unrun row is pending, and the agent cannot
self-certify a human-owned judgment.

## Hard stops

- Never report done while any requested item lacks a disposition.
- Never claim a test passes without seeing it pass for the recorded state.
- Never claim a bug fixed without a reproduction that failed before and passes
  after, with exact restoration/control evidence.
- Never turn a worker's “success” report into evidence; inspect its diff/state
  and raw output.
- Never mutate a candidate with the bookkeeping meant to prove that candidate.
- A never-falsified gate is suspect—see `references/hollow-verification.md`.
- A gate silenced is not a gate passed. Suppressing a finding, lowering a
  strictness setting, or excluding a path changes what ran, not what is true —
  and the claim that gate supported is now unproven.
- A flaky green is unexplained nondeterminism; route it through `debugging`.
- Verified is not reviewed. A candidate at a completion or integration
  boundary requires `requesting-code-review`; task-local evaluator
  status is not that boundary unless its plan says so.

## When tempted to skip

| Thought | Reality |
| --- | --- |
| "It should work" | Run the gate and make it a fact. |
| "I ran it earlier" | Earlier state or evidence age may not support this transition. |
| "The types pass" | Types, build, behavior, requirements, and release are distinct claims. |
| "The suite is green, so the code is covered" | Read what it asserted. A green that could not have been red covers nothing. |
| "The agent said green" | A report is a claim; inspect raw state and output. |
| "The summary says all passed" | Reconcile skipped tests, shards, and matrix cells. |
| "It's a false positive" | That judgement is itself unverified. Rewrite the code until the checker agrees, or record a deviation the gate's owner accepted in writing. |
| "That finding predates my change" | Silencing it now makes it yours. Leave it red and disposition it, or fix it. |
| "I committed it, so evidence is banked" | A checkpoint is neither review nor integration proof. |
| "All checks are green, so done" | Green supports only the checks; independent review challenges completeness. |
| "I did the main thing" | An unstarted item fails no gate; only the request inventory finds it. |
| "The rest was minor or implied" | Scaling the request down is the requester's call, not yours. |
