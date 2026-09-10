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

## Before fan-out

1. **Run the independence test on every pair.** Group or sequence any pair
   that fails a line:

   - **Base** — both start from the same immutable revision, or an explicitly
     ordered dependency revision.
   - **Files** — exclusive paths, including generated outputs, manifests,
     lockfiles, shared fixtures, and tests. For a truly shared file name one
     later integration owner and let nobody else edit it concurrently.
   - **State** — disjoint ports, databases, fixtures. If either runs a server
     or migrations, invoke `using-git-worktrees` for each.
   - **Order** — neither consumes the other's output. A dependency is a
     sequence, not a fan-out.

2. **Pick each agent's tier from the table below** and write it in the
   packet's `TIER` field. Choose the lowest tier sufficient for the decisions
   that remain and the cost of an error. Supply missing context before moving
   up a tier; never retry a stronger model because information was missing.

3. **Fill one `assets/dispatch-packet.md` per agent** — every field, from
   scope and ownership through isolation, data boundary, resource envelope,
   and terminal control. Read `references/brief-examples.md` while writing
   your first one. Never paste session history.

   - **Paste into `START FROM` what defines the task** — the task contract,
     the exact spec, the failing assertion. **Put into `READ` a path** for
     what merely informs it — a diff, a log, a large fixture.
   - **Write `SUBDISPATCH: prohibited`** unless the packet allocates the
     sub-scope, the capacity, the data and egress boundary, and who
     reconciles the grandchildren.
   - **Fill `DATA/ACCESS` with what is reachable, who may hold it, what is
     prohibited, and who cleans up.** Treat configuration as no disclosure
     authority: a new recipient or egress path needs its own scoped decision.

4. **Freeze the expected packet IDs and count, the terminal deadline, and the
   timeout and cancel action with its owner** before the first dispatch.

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

## Dispatch

5. **Dispatch through the real callable action and record each returned
   non-empty agent or job ID** as the attempt identity in `DISPATCH RECEIPT`.
   If the action is unavailable, refused, or returns empty, write `not
   dispatched`, keep the packet pending, and stop: name the action you tried
   and what this environment needs to make it callable. Never describe a
   fan-out you hold no receipts for, and never quietly do the work
   sequentially instead.

6. **At failure or deadline, write `cancellation requested`** and wait until
   the worker, its descendants, and its effects are confirmed quiescent;
   quarantine partial output. Only then write failed, timed out, or
   cancelled. Reassign through a linked successor attempt that rejects every
   late result or mutation from its predecessor. Never let a non-success
   disappear.

7. **When any writer reports a shared generator, file, state, dependency, or
   scope outside its packet, pause the affected work.** Preserve the diffs,
   reclassify the dependency, assign one owner or a sequence, and issue
   revised packets. Treat "small overlap" as overlap.

## Reconcile

8. **Inspect every returned diff yourself** against its declared base and
   ownership set, its authorized checkpoints or none, and its raw evaluator
   evidence. Reject a scope leak, a mixed change, or missing evidence even
   under a green suite.

9. **Advance required scope only when every packet has an accepted success
   report,** or a directly approved scope change or reassignment.

10. **Integrate through the named owner and run the combined checks on the
    exact result.** Invoke `verifying-completion` for that combined state
    before anything downstream treats it as done.

## Common mistakes

- Shared file, order, or runtime ownership — one writer or a sequence, never
  “coordinate.”
- Session-history briefs, or undeclared data and egress — neither is bounded
  context.
- No combined exact-result check, or accepting late/quarantined output.
- Treating combined green as permission to ignore scope leaks or mixed commits.
