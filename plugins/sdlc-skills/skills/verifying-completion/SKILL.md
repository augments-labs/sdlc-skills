---
name: verifying-completion
description: "Use before any claim that work is complete, fixed, passing, done, or satisfactory, and before any commit or PR. Fires on that should do it, it's working now, and all set, even when no formal claim is made. Also use when evidence may be stale, partial, or bound to another state, and when a gate the claim depends on is unavailable."
---

# Verifying Completion

Evidence before claims. A green result proves only the exact state, gate,
environment, and transition it actually checked. Confidence, summaries, and a
nearby run do not widen that evidence.

## When to use

Every completion claim, every commit, every PR. This discipline never scales
down; only the required gate set does.

When the candidate bears an integrated UI, its gate set includes
`visual-ui-verification`: automated checks passing does not make a screen
visually correct, and a done claim on UI work without that verdict is
unverified.

## Available scripts

- **`scripts/state-identity.sh`** — captures the source state a gate runs
  against, and re-checks it afterwards. Read-only; `--help` documents the fields
  and exit codes.

## The gate

1. **Reconcile the request inventory first.** List every item the request
   asked for—the user's message, task contract, or dispatch packet, including
   items added mid-conversation—and give each an explicit disposition:
   delivered, pending, blocked, or declined with a reason. Four of five
   delivered is not done.

2. **Name the exact claim and transition.** Task green, integrated acceptance,
   reviewed candidate, and releasable artifact are different states.

3. **Resolve the required gate set** from the task/plan Evaluators and the
   applicable assurance-matrix cadence. Missing, planned, blocked, or
   unjustifiably omitted gates make the claim pending.

4. **Capture state identity, before the gate runs.**

   ```bash
   before=$(bash scripts/state-identity.sh --quiet)
   ```

   That digest is the source the gate is about to read, and `--help` details
   what it covers. The script sees the source and nothing else. Whatever else *this* gate depends
   on — generated and external inputs, artifacts, configuration, build mode, gate
   version, the pre-state of any controlled data, process, or effect — you record
   yourself, under `State` in `assets/evidence-ledger.md`.

5. **Contain and run each required action.** Bind the attempt to its identity,
   authority, and effect boundary before it starts, and run fresh; the ledger's
   `Results` and `Controlled pre/post state` fields name what to bind.

   Sequence overlapping gates, and parallelize only disjoint effect boundaries. A
   timeout or failure is *cancellation-requested*, not a result, until processes
   and effects quiesce — quarantine whatever partials it left behind. A rerun is
   a linked successor attempt and rejects its predecessor's late output. Any
   unintended mutation invalidates the evidence: restore and re-run, or surface
   it pending. A cache counts only under its own gate contract.

6. **Read and protect the raw output.** Record the run in the ledger's `Results`
   row and its handling under `Evidence controls`. Redact only the copy you
   present.

   Read what the gate asserted, not only how it exited. A gate that went green
   over assertions that could not have gone red has said nothing about the code
   it covers, so its green is not evidence you may cite for that code. Where
   that is what you find, say so in the claim: repairing the gate is separate
   scope, owned by `verification-strategy`, and is not yours to patch in
   passing.

7. **Audit execution completeness** against the ledger's `Inventory
   reconciliation` section: what was required to run, against what observably
   ran. Aggregate green is red when required work did not run or did not
   reconcile.

8. **Return evidence without changing the candidate** — the ledger's own opening
   says where it may live. Keep failures and inconclusive results rather than
   green-washing them.

9. **Make only the supported claim.** State what passed, on which identity, and
   what remains pending. If any required row failed or did not run, do not say
   complete.

10. **Route by the transition you named in step 2.** Task green inside a plan or
    a worktree checkpoint returns to the skill that sent it, and nothing more
    happens here. A completion or integration claim — the user will read the
    work as done, or it is about to be pushed, published, or merged — invokes
    `requesting-code-review` next; verified is not reviewed. A releasable
    artifact goes to `release-readiness`. This skill never commits to a
    branch's fate: no push, no PR, no merge.

Any change to a gate's inputs invalidates the evidence it produced; the ledger's
`Invalidation` section is where they are listed. For the source half, check
rather than recall — immediately after the gate, before any claim:

```bash
bash scripts/state-identity.sh --compare "$before"
```

A non-zero exit means the source moved while the gate ran, so the result
describes a state that no longer exists: rerun it. A zero exit proves only that
the source held — the other inputs are still yours to reconcile.

A commit with an identical source tree may retain content-check evidence, but
commit, CI, and review gates bind to their own revision. An authorized
checkpoint banks work; it does not make it reviewed, merge-ready, or
releasable.

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

## Relationship to plans

Evaluators and assurance matrices define what must run. This skill binds those
runs to exact evidence; it does not design the battery, review the change,
integrate the branch, or decide release.
