---
name: dispatching-parallel-agents
description: "Use when two or more work items can run concurrently with disjoint file ownership, mutable state, and outputs — unrelated bugs, independent features, parallel research. Fires on do these at the same time and can several agents work on this, even if nobody says parallel or concurrent. Skip shared generators, manifests, or runtime state, dependent outputs, and work quicker to do inline."
---

# Dispatching Parallel Agents

Prove the pieces are independent, hand each agent a complete packet, dispatch
through a callable action that returns a receipt, and reconcile every diff
yourself before anything integrates.

## When to use

- Two or more pieces of work that are **provably independent**: disjoint files, disjoint state, and no "B needs A's result."
- **Skip** shared files or dependencies, output ordering, and work that is
  quicker done inline. Sequence it in the current task or plan; `executing-plans`
  is for an approved plan only.

## Step 1: Before fan-out

1. Run the independence test on every pair. Group or sequence any pair that
   fails a line:
   - **Base** — same immutable revision, or an explicitly ordered dependency
     revision.
   - **Files** — exclusive paths, including generated outputs, manifests,
     lockfiles, shared fixtures, tests. A truly shared file gets one later
     integration owner and no concurrent editor.
   - **State** — disjoint ports, databases, fixtures. A server or migrations
     → invoke `using-git-worktrees` for each.
   - **Order** — neither consumes the other's output. A dependency is a
     sequence.
2. Pick each agent's tier from the table below. Write it in the packet's
   `TIER` field. Lowest tier sufficient for the remaining decisions and the
   cost of an error. Supply missing context before moving up a tier.
3. Fill one `assets/dispatch-packet.md` per agent, every field. Read
   `references/brief-examples.md` while writing the first one. Never paste
   session history.
   - `START FROM` → what defines the task: the contract, the exact spec, the
     failing assertion.
   - `READ` → a path to what informs it: a diff, a log, a large fixture.
   - `SUBDISPATCH: prohibited` unless the packet allocates sub-scope,
     capacity, data and egress boundary, and who reconciles grandchildren.
   - `DATA/ACCESS` → what is reachable, who may hold it, what is prohibited,
     who cleans up. Configuration grants no disclosure authority.
4. Freeze the expected packet IDs and count, the terminal deadline, and the
   timeout and cancel action with its owner, before the first dispatch.

## Model selection

This section applies to each subagent, including sequential workers and
reviewers; it does not require a parallel fan-out. Choose within the user's
permitted models.

| Tier | Work |
| --- | --- |
| `small` | Mechanical transformations, formatting, structured extraction; rules and expected output are explicit. |
| `medium` | Execution of settled decisions that still requires judgment: specified implementation, focused review, substantive summarization. |
| `large` | Resolving uncertainty: architecture, unclear requirements, unexplained failures, uncertain impact, or consequential tradeoffs. |

At dispatch, map the chosen tier to an available model and set the harness's
model parameter or agent configuration explicitly; naming a tier in the prompt
selects nothing. If selection is unavailable, say so and use only a fallback
the user's preferences permit; never claim an override was applied. Leave the
user's main-session model and any model reserved for orchestration untouched.

## Step 2: Dispatch

1. Dispatch through the real callable action. Record each returned non-empty
   agent or job ID in `DISPATCH RECEIPT`.
2. Action unavailable, refused, or empty → write `not dispatched`, keep the
   packet pending, stop. Name the action tried and what would make it
   callable. Never describe a fan-out without receipts. Never quietly do the
   work sequentially instead.
3. Failure or deadline → write `cancellation requested`. Wait until the
   worker, its descendants, and its effects are quiescent. Quarantine partial
   output. Only then write failed, timed out, or cancelled.
4. Reassign through a linked successor attempt that rejects every late result
   or mutation from its predecessor.
5. A writer reports a shared generator, file, state, dependency, or scope
   outside its packet → pause the affected work, preserve the diffs,
   reclassify, assign one owner or a sequence, issue revised packets. "Small
   overlap" is overlap.

## Step 3: Reconcile

1. Inspect every returned diff yourself against its declared base, ownership
   set, authorized checkpoints, and raw evaluator evidence. Reject a scope
   leak, a mixed change, or missing evidence even under a green suite.
2. Advance required scope only when every packet has an accepted success
   report, or a directly approved scope change or reassignment.
3. Integrate through the named owner. Run the combined checks on the exact
   result.
4. **REQUIRED SUB-SKILL:** invoke `verifying-completion` for that combined
   state before anything downstream treats it as done.

## Common mistakes

- Shared file, order, or runtime ownership — one writer or a sequence, never
  “coordinate.”
- Session-history briefs, or undeclared data and egress — neither is bounded
  context.
- No combined exact-result check, or accepting late/quarantined output.
- Treating combined green as permission to ignore scope leaks or mixed commits.
