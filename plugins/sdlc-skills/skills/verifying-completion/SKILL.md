---
name: verifying-completion
description: "Use before any claim that work is complete, fixed, passing, done, or satisfactory, and before any commit or PR. Fires on that should do it, it's working now, and all set, even when no formal claim is made. Also use when evidence may be stale, partial, or bound to another state, and when a gate the claim depends on is unavailable."
---

# Verifying Completion

Run the gate, read its raw output, and claim only what that output supports
for the exact state it ran on. This skill produces evidence; it does not
design the gates, review the change, integrate the branch, or decide release.

## When to use

- Before any claim that work is complete, fixed, passing, or done; before any
  commit, push, or PR; before moving to the next task of a plan.
- **Never skip.** Scale the gate set down for a small change; do not scale the
  discipline down. A one-line fix still runs the smallest gate that can fail.
- A candidate with an integrated UI adds `visual-ui-verification` to its gate
  set: automated checks passing does not make a screen visually correct.

## Available scripts

- **`scripts/state-identity.sh`** — captures the source state a gate runs
  against, and re-checks it afterwards. Read-only; `--help` documents the fields
  and exit codes.

## The gate

1. **List every item the request asked for** — from the user's messages, the
   task contract, or the dispatch packet, including items added
   mid-conversation — and write a disposition beside each: delivered, pending,
   blocked, or declined with a reason. Four of five delivered is not done.

2. **Write the claim you are about to make, and its transition,** in the
   `Claim` section of `assets/evidence-ledger.md`. Pick one: task green,
   integrated acceptance, reviewed candidate, releasable artifact. Each is a
   different state with a different gate set.

3. **List the required gates** from the task or plan `Evaluator` rows and the
   assurance matrix's cadence for this transition. Write each as a row in the
   ledger's `Results`. A gate that is missing, planned, blocked, or omitted
   without a recorded reason makes the claim pending before anything runs.

4. **Capture the source state before the first gate runs:**

   ```bash
   before=$(bash scripts/state-identity.sh --quiet)
   ```

   Then fill the ledger's `State` section yourself for everything the script
   cannot see: generated and external inputs, configuration, build mode, gate
   version, and the pre-state of any data, process, or effect the gate will
   touch.

5. **Run each required gate fresh, one effect boundary at a time.** Before
   starting an action, write in its `Results` row what it may touch and under
   whose authority. Run gates that share an effect boundary in sequence; run
   only disjoint ones in parallel. Do not reuse an earlier run, and count a
   cache only under its own gate contract.

   If a gate times out or fails mid-run, do not record a result yet: wait
   until its processes and effects have stopped, move what it left behind out
   of the candidate, and start a new linked run that ignores any late output
   from the first. If a gate mutated something it should not have, restore it
   and rerun, or record the mutation as pending.

6. **Read the raw output, and record it.** Write the run into its `Results`
   row and its handling under `Evidence controls`. Redact only the copy you
   present to the user.

   Read what the gate asserted, not only its exit code. If the assertions it
   passed could not have failed for this code, write that in the row and do
   not cite the green. Repairing such a gate belongs to
   `verification-strategy`; do not patch it in passing.

7. **Re-check the source state immediately after the last gate:**

   ```bash
   bash scripts/state-identity.sh --compare "$before"
   ```

   Non-zero exit: the source moved while a gate ran, so rerun from step 4.
   Zero exit: the source held; reconcile the other `State` inputs yourself.

8. **Compare what ran against what step 3 required,** in the ledger's
   `Inventory reconciliation` section. A required gate that did not run, or
   ran on a different state, turns an aggregate green into red.

9. **Return the ledger without touching the candidate.** Write it where the
   ledger's opening says it may live. Keep failures and inconclusive results
   in it as they are.

10. **Write the claim the rows support, and nothing wider.** State what
    passed, on which state identity, and what is pending. If any required row
    failed or did not run, do not say complete. A commit with an identical
    source tree may reuse content-check rows; commit, CI, and review gates
    bind to their own revision, and a checkpoint commit banks work without
    making it reviewed or merge-ready.

11. **REQUIRED — route by the transition from step 2.** Task green inside a
    plan or a worktree checkpoint: return to the skill that sent you, and do
    nothing more here. Completion or integration — the user will read the
    work as done, or it is about to be pushed, published, or merged: invoke
    `requesting-code-review` next; verified is not reviewed. Releasable
    artifact: invoke `release-readiness`. Run no commit, push, PR, or merge
    from this skill.

## Manual acceptance

When a requirement genuinely needs human judgment, use
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
- Verified is not reviewed. A non-trivial candidate at a completion or
  integration boundary requires `requesting-code-review`; task-local evaluator
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
| "It's a false positive" | That judgement is itself unverified. Rewrite the code until the checker agrees, or record an accepted deviation. |
| "That finding predates my change" | Silencing it now makes it yours. Leave it red and disposition it, or fix it. |
| "I committed it, so evidence is banked" | A checkpoint is neither review nor integration proof. |
| "All checks are green, so done" | Green supports only the checks; independent review challenges completeness. |
| "I did the main thing" | An unstarted item fails no gate; only the request inventory finds it. |
| "The rest was minor or implied" | Scaling the request down is the requester's call, not yours. |
