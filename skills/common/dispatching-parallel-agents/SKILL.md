---
name: dispatching-parallel-agents
description: "Splits independent work across parallel agents, each with its own exclusive writes and resources. Use when tasks can run concurrently with no dependence on another worker's output, such as separate files, services, or investigations; shared reads of frozen inputs are fine. Skip coupled writes, shared runtime state, dependent outputs, or work quicker to do inline."
---

# Dispatching Parallel Agents

Prove the pieces are independent, hand each agent a complete packet, dispatch
through a callable action that returns a tool-issued ID as proof, and
reconcile every diff yourself before anything integrates.

## When to use

- Two or more independent tasks: exclusive writes and mutable resources, with
  no task needing another's output. Overlapping reads of frozen inputs are safe.
- **Skip** overlapping writes, shared mutable state, dependent outputs, and
  work that is quicker done inline. Sequence it in the current task or plan;
  the plan executors are for an approved plan only.

## Step 1: Before fan-out

1. Run the independence test on every pair. Group or sequence any pair that
   fails a line:
   - **Base** — same immutable revision, or an explicitly ordered dependency
     revision.
   - **Writes** — exclusive paths, including generated outputs, manifests,
     lockfiles, shared fixtures, tests. A truly shared file gets one later
     integration owner and no concurrent editor.
   - **State** — disjoint ports, databases, fixtures. If either task runs a
     server or migrations, invoke `using-git-worktrees` for each task in the
     pair; a caller that already gave each task its own worktree has done
     this.
   - **Order** — neither consumes the other's output. A dependency is a
     sequence.

   Then cap the wave at what the machine can run at once. For a heavy build,
   measure one run's memory and cores, dispatch what fits, and sequence the
   rest.
2. Pick each agent's tier from the Model selection table below and write it
   in the packet's `Tier` field: the lowest tier sufficient for the decisions
   that remain and the cost of an error. Supply missing context before moving
   up a tier.
3. Fill one `assets/dispatch-packet.md` per agent, every field, before its
   dispatch. Read `references/brief-examples.md` before writing the first one.
   Never paste session history.
   - Read `assets/dispatch-packet-controlled.md` when the plan is high-risk or
     uses phase queues; it adds the ten controlled fields.
   - Until those fields say otherwise, a worker may not dispatch anyone, and
     the data it may reach stays bounded.
4. Before the first dispatch, freeze the expected packet IDs and their count,
   the final deadline, and the timeout and cancel action with its owner. The
   deadline is the user's; without one, the harness's agent timeout. With
   neither, ask the user once, and dispatch nothing until answered.

## Model selection

This section applies to each subagent, including sequential workers and
reviewers; it does not require a parallel fan-out. Choose within the user's
permitted models.

| Tier | Work |
| --- | --- |
| `small` | Mechanical transformations, formatting, structured extraction; rules and expected output are explicit. |
| `medium` | Execution of settled decisions that still requires judgment: specified implementation, focused review, substantive summarization. |
| `large` | Resolving uncertainty: architecture, unclear requirements, unexplained failures, uncertain impact, or consequential tradeoffs. |

Work that writes a test or code under `test-driven-development` is never
`small`: choosing the assertion is a judgment.

At dispatch, map the chosen tier to an available model and set the harness's
model parameter or agent configuration explicitly; naming a tier in the prompt
selects nothing. If selection is unavailable, say so and use only a fallback
the user's preferences permit; never claim an override was applied. Leave the
user's main-session model and any model reserved for orchestration untouched.

After dispatch, read back the model the harness reports for the spawned agent.
If it differs from the one you set, or the harness reports none, record that
in the packet's `Model read back` field beside its `Dispatch receipt`, and
never report the chosen tier as the one that ran.

## Step 2: Dispatch

1. Dispatch through the real callable action. Work is dispatched only when the
   action has returned a non-empty tool-issued ID; record each ID in the
   packet's `Dispatch receipt` field. Naming an agent or writing a prompt is
   not dispatch.
2. If the action is unavailable, refused, or returns no tool-issued ID, write
   `not dispatched`, and name the action tried and what would make it
   callable. Never describe a fan-out that has no tool-issued IDs behind it,
   and never quietly do the work yourself instead.
   Ask the user once per work item; the answer covers only that work:

   ```text
   {{work}} needs an independent agent, and {{action}} is not callable here.

   1. I do it myself, labelled as a self-review, not an independent one
   2. Name the reviewer or agent who will do it
   3. Keep it pending

   Recommendation: {{option}} — {{one sentence}}.
   ```

   When independence is required (`security clear`, a role the calling
   skill's contract requires to be independent, or an audit the user asked to
   be independent), omit option 1 and say why.
   Ask this and end the turn; `clarifying-intent` owns what closes it.
   Record the answer as the written assignment and continue under it. A named
   reviewer's report counts only when it arrives from outside this session,
   bound to the exact identities; the recorded answer stands in for the
   tool-issued ID. With no answer, the work stays pending.
3. Poll exactly those IDs until the frozen deadline. Never poll a target that
   was not dispatched. Success means exactly one current result for each
   packet.
4. On a failure or at the deadline, write `cancellation requested`. Wait
   until the worker, everything it spawned, and every effect it started have
   all stopped (quiescent). Set partial output aside, unused (quarantine).
   Only then write failed, timed out, or cancelled.
5. Reassign the work as a new attempt linked to the one it replaces only
   with a changed intervention and inside the caller's bound; otherwise
   return the item to the caller as failed or blocked. Reject every late
   result or change that arrives from the replaced attempt.
6. If a writer reports a shared generator, file, state, dependency, or scope
   outside its packet, pause the affected work, preserve the diffs,
   reclassify the pieces, assign one owner or a sequence, and issue revised
   packets. A "small overlap" is overlap.

## Step 3: Reconcile

1. Inspect every returned diff yourself against its declared base, ownership
   set, authorized checkpoints, and the raw output of its checks. Reject a
   scope leak, a mixed change, or missing evidence, even when the suite is
   green. If the packet's scope is a list of items, reject a report that lacks
   a line for any item.
2. Advance the required scope only when every packet has an accepted success
   report, or a directly approved scope change or reassignment.
3. Integrate through the named owner. Run the combined checks on the exact
   result.
4. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` for that
   combined state before anything downstream treats it as done.

## Gotchas

- Doing the work yourself when dispatch fails reads as a fallback, but the
  result then claims an independence it never had. Only the user's recorded
  answer makes a self-review legitimate, and it stays labelled as one.
