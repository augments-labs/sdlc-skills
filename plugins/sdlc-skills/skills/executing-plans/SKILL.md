---
name: executing-plans
description: "Use when asked to execute, run, continue, or resume a multi-task plan directory, and immediately after the user selects an execution mode for an approved plan—even through a terse reply such as inline, delegated, option 1, or option 2. Verify claimed approval, version, mode, and entry state first. Fires on pick up where we left off when a plan directory holds the work. Skip a single task."
---

# Executing Plans

Advance only through real state transitions; nothing is done until its evaluator is green on the exact result.

## Before you start

1. **Verify authority and lineage.** Match the exact plan version, mode, and
   complete approver rule to a current user-role answer or a scoped standing
   receipt, and confirm every predecessor consumer is reconciled. A plan cannot
   authenticate itself.

   An approved plan carrying no bound mode is not a licence to pick one. Ask one
   conversational question offering inline execution in this session or
   delegated execution by one fresh subagent per task in sequence. Explain the
   context trade-off briefly, recommend the mode supported by the harness and
   task boundaries, then stop.

   Offer delegated only where the harness provides a subagent action; otherwise
   say so and execute inline. Task independence is not a mode decision.

2. **Refresh the workspace** through `using-task-branches`. Establish who owns
   it, what HEAD and the intended base actually are, whether the tree is clean,
   what the baseline gate returns, and which runtime identities are live. Read
   all of that from the workspace itself; never infer it from what the plan says
   should be true.

3. **Audit executability before you change any code.** Read each task against
   every contract field the `writing-plans` index and task templates define. A
   missing field, or one that contradicts another, stops execution here rather
   than halfway through the loop: a **Consumes** with no matching **Produces**,
   a dependency on a cancelled task, an evaluator the task is also asked to
   rewrite.

   For a UI-bearing task, its **Applicable visual references** must match the
   plan index's **Selected visual references** field for field, every Reference
   ID must resolve through **Visual reference coverage** to this task and a
   conformance evaluator, and each Freshness evaluator runs before the first UI
   edit. The index template states what each freshness result permits; a proved
   `mismatch` waits for an approved design successor and then an approved plan
   successor. Never infer a preferred direction or let owner reconciliation
   alter the bound input.

4. **Select the execution form.** Bounded tasks use the loop below; a plan with
   phases or machine-derived shards also loads `references/phase-queues.md`, and
   a queue is never flattened into copied tasks.

   High-risk target tasks stay blocked until approved current migration and
   assurance contracts exist and their entry gates have passed. A directly
   authorized gate prerequisite may consume its exact proposal before phase
   entry, but it cannot modify target shards, approve the contract, or satisfy
   entry on that contract's behalf.

## Bounded task loop

Honor `Depends on` and the directly approved execution mode. Switching between
inline and delegated execution needs a direct mode decision; task independence
alone does not override one.

1. **Load** the task, its exact referenced inputs, interfaces, and evaluator,
   plus the identity-bound learnings already in the external execution ledger.

2. **Record what this attempt is bound to** before touching anything: the stable
   task and attempt ID, the prior state you were allowed to start from, the exact
   pre-task revision and effects, the current external task state, the
   evaluator's identity, and the observable you expect to change. An attempt with
   no recorded starting point cannot be reconciled afterwards.

3. **Load the implementation disciplines before action.** For every
   behavior-affecting task, invoke `test-driven-development` and `yagni` before
   the first project command or code edit. Their loading actions must appear in
   the current execution evidence; naming them in the plan is not invocation.
   Apply their RED or preservation cycle and pre-edit scope challenge to the
   task. Only their explicit carve-outs may skip the pair.

   Delegated work carries the same requirement in its packet and goes through
   `references/subagent-dispatch.md`; approved parallel work hands isolation and
   reconciliation to `dispatching-parallel-agents`.

4. **Inspect the result** against the task's file and scope contract. For an
   offload that means its raw diff, its authorized checkpoints (or none), its
   result revision, and its evaluator output — never its summary.

5. **Invoke `verifying-completion`** to run the complete required gate set the
   task template defines — for a UI-bearing task, the Evaluator plus every
   applicable VCONF, and `visual-ui-verification` for an integrated UI — in the
   authoritative workspace, binding every output to the same exact state.
   Similar styling or functional equivalence does not authorize a different
   layout, hierarchy, or interaction. That skill owns the evidence ledger; this
   one owns the task-state transition.

6. **Append `done` only after all required gates pass on the accepted state.**
   A failed or pending gate keeps the task non-done. A concern counts toward no
   gate until it is proved non-blocking, or accepted under its exact owning
   deviation or exclusion and a compensating gate.

7. **Re-run a combined gate** after integrating parallel results.

8. **Return to step 1 with the next task** whose `Depends on` is satisfied.
   `done` is a ledger entry, not a decision point: the approved plan and its
   approved mode are the authority for every task in it, and that authority is
   not re-granted task by task. A green evaluator is not a hand-back, and
   reporting one is not a gate.

   The loop ends — and the turn with it — on exactly one of: the plan's tasks
   are exhausted; the ledger records any outcome other than `done`; a normative
   plan change needs direct reapproval; or a high-risk target task's entry gate
   has not passed. Anything else is the next task.

## Outcomes and circuit breaker

The append-only ledger records **done**, **done with concerns**, **blocked**,
**needs context**, **cancelled**, or **superseded**. Cancellation and
supersession each need their owning approved plan decision, and neither means
done.

Task `done` means evaluator-accepted inside the plan — not integrated, not
merge-ready. Required task review and final-candidate review remain separate
gates.

Every attempt carries an identity and terminal evidence. A failure or deadline
enters **cancellation requested** and stays there until the worker, its
descendants, and its effects are quiescent. Quarantine the partials, and let a
linked retry reject any late result or mutation.

Classify repeated failures under a stable class ID with raw evidence. Three
non-converging terminal attempts in one class stop the task. High-risk contracts
own their own thresholds and pause scope — never patch shard symptoms one at a
time.

## Resume and plan changes

When the remaining work will not fit the current session — context pressure,
an approaching limit, an ending shift — stop at the current task boundary and
invoke `handoff` so the next session resumes without re-deriving state, rather
than degrading through a truncated context.

On resume, re-read the state rather than trusting it. Refresh the plan and its
decision state, the workspace with its base, HEAD, and dirty state, the external
ledgers and queues, the contract versions, and whether the evidence is still
fresh. Never infer progress from task order — a later task file existing says
nothing about an earlier task having passed.

When reality differs from the plan, update the owner of what changed. Every
normative change — scope, interface, evaluator, phase, ownership, cutover,
rollback, decommission, or mode — requires a successor and direct reapproval.
Runtime attempts, leases, and outcomes update only their external ledgers.

Run plan Acceptance on the exact integrated revision, then re-route. Review,
branch integration, and release each retain their own gates and decisions.
