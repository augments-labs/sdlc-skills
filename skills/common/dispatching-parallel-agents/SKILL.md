---
name: dispatching-parallel-agents
description: "Use when two or more work items can run concurrently with disjoint file ownership, mutable state, and outputs — unrelated bugs, independent features, parallel research. Fires on do these at the same time and can several agents work on this, even if nobody says parallel or concurrent. Skip shared generators, manifests, or runtime state, dependent outputs, and work quicker to do inline."
---

# Dispatching Parallel Agents

Run independent work concurrently instead of in series. The win is wall-clock;
the risk is collision — so this applies only when the pieces genuinely do not
touch each other.

## When to use

- Two or more pieces of work that are **provably independent**: disjoint files, disjoint state, and no "B needs A's result."
- **Skip** shared files or dependencies, output ordering, and work that is
  quicker done inline. Sequence it in the current task or plan; `executing-plans`
  is for an approved plan only.

## The independence test — confirm before fanning out

Check every pair; if any fails, group them into one agent or sequence them instead:

- **Base** — every writer starts from the same immutable revision, or an
  explicitly ordered dependency revision.
- **Files** — they own exclusive paths, including generated outputs, manifests,
  lockfiles, shared fixtures, and tests. Name one later integration owner for a
  truly shared file; nobody else edits it concurrently.
- **State** — disjoint ports, databases, fixtures. If they run a server or migrations, isolate each (`using-git-worktrees`).
- **Order** — none consumes another's output. A dependency is a sequence, not a fan-out.

## Model selection

This section applies to each subagent, including sequential workers and
reviewers; it does not require a parallel fan-out. Choose autonomously within
the user's permitted models, using the lowest tier sufficient for the remaining
decisions and consequences of error.

| Tier | Work |
| --- | --- |
| `small` | Mechanical transformations, formatting, structured extraction; rules and expected output are explicit. |
| `medium` | Execution of settled decisions that still requires judgment: specified implementation, focused review, substantive summarization. |
| `large` | Resolving uncertainty: architecture, unclear requirements, unexplained failures, uncertain impact, or consequential tradeoffs. |

At dispatch, map the chosen tier to an available model and explicitly set the
harness's supported model parameter or agent configuration. Naming a tier in the
prompt does not select a model. If selection is unavailable, disclose that
limitation and use only a fallback the user's preferences permit; never claim
an override was applied. Preserve the user's main-session model and any models
reserved for orchestration.

Supply missing context before escalating capability. Move up a tier when the
remaining reasoning difficulty warrants it, within the authorized budget and
data boundary; do not retry a stronger model merely because information was
missing.

## The dispatch packet (per agent)

Each agent starts cold, so hand it everything and never your session history.
Fill one `assets/dispatch-packet.md` per agent — it carries every field a packet
owes, from scope and ownership through isolation, data boundary, resource
envelope, and terminal control. `references/brief-examples.md` explains why those
fields exist and shows weak-versus-strong packets for real tasks; read it while
writing your first one.

Three judgements the template cannot make for you:

**Paste what defines the task; point at what merely informs it.** The task
contract, the exact spec, the failing assertion — paste those, so the agent starts
from a known snapshot. A diff, a log, a large fixture — give a path it opens
itself. A paste occupies the most expensive context for the agent's whole run; a
path costs nothing until it is read.

**Keep subdispatch off by default.** A child agent has neither the coordinator's
ownership map nor its capacity view. Allow it only when the packet allocates the
sub-scope, the capacity, the data and egress boundary, and who reconciles the
grandchildren. Otherwise the agent reports back instead of spawning.

**Bound data and effects, not only files.** Say what material is reachable, which
workers, providers, and storage may hold it, what is prohibited outright, and how
evidence is retained and cleaned up under whose authority. Configuration is not
disclosure authority — a new recipient or a new egress path needs its own scoped
decision.

## The dispatch-receipt gate

**Before fan-out,** freeze the expected packet IDs and count, the terminal
deadline, and the timeout and cancel action with its owner.

**Dispatch through the real callable action.** Join each returned nonempty agent
or job ID as an attempt identity under one packet; names and “running” prose are
not receipts. Unavailable, refused, or empty means **not dispatched** — retain
the packet pending and stop, naming the action attempted and what this
environment needs to make it callable (an enabled capability, a granted
permission, a configured runner). Never narrate a fan-out you hold no receipts
for, or silently substitute sequential work for one.

**At failure or deadline,** record `cancellation requested` until the worker, its
descendants, and its effects are confirmed quiescent, and quarantine partial
output. Only then record failed, timed out, or cancelled. Reassignment creates a
linked successor attempt that rejects every late result or mutation from its
predecessor. Non-success never disappears.

If any writer discovers a shared generator, file, state, dependency, or required
scope outside its packet, pause affected work. Preserve the diffs, reclassify the
dependency, assign one owner or sequence it, and issue revised packets. “Small
overlap” is still overlap.

## Reconcile (the coordinator's job, not the agents')

Reconcile the frozen packet set and every terminal outcome. Inspect each returned
diff against its declared base and ownership set, authorized checkpoints (or
none), and raw evaluator evidence. Reject scope leaks, mixed changes, or missing
evidence even if a suite is green. Required scope advances only when every packet
has an accepted success report, or a directly approved scope change or
reassignment. Then integrate through the named owner, and run the combined
checks on the exact result.

## Common mistakes

- Shared file, order, or runtime ownership — one writer or a sequence, never
  “coordinate.”
- Session-history briefs, or undeclared data and egress — neither is bounded
  context.
- No combined exact-result check, or accepting late/quarantined output.
- Treating combined green as permission to ignore scope leaks or mixed commits.
