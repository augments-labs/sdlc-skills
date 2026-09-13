# Executing Plans — Subagent Dispatch

Use a fresh worker for each task when the selected execution mode is delegated.
Wait for its result, run the task's acceptance gate, then dispatch the next
task. Small size does not silently change that selected mode to inline.

A self-contained packet carries all the context its worker needs; the task may
still depend on earlier tasks. Concurrency is a separate decision: only an
approved parallel mode uses `dispatching-parallel-agents` to establish exclusive
writes and reconcile results. Preserve final review classification in every mode.

## The dispatch packet

Build it from `dispatching-parallel-agents`' dispatch packet — scope, explicit capability tier, isolation, and the exact report shape — that skill owns the contract for handing work to a cold agent. A plan task pastes four more things in, because a subagent inherits none of your context:

- **Task contract** — paste the full task text. It is the small, authoritative thing the agent starts from, so per that packet's paste-vs-path rule you paste it rather than point at the task file.
- **Accumulated discoveries** — paste only verified identity-bound learnings from
  the external execution ledger (or “none”). Never mutate or read runtime
  learning state from the immutable plan index.
- **Quality rules** — paste verbatim: *escalate rather than guess; bad work is
  worse than no work; this packet is already routed—follow its named applicable
  disciplines, TDD entry cycle, YAGNI, tier, and owning contracts; if the packet
  is invalid, report needs-context rather than re-route or guess.* A packet
  cannot waive discipline or reopen approved scope.
- **Expected outcome** — one of the four execution states (done / done-with-concerns / blocked / needs-context — see `../SKILL.md`), with file and line references for anything flagged.
- **Authority boundary** — the worker may change only its owned task state. It
  reports raw diff, authorized checkpoint commits (or none), result revision,
  and evaluator output; subdispatch is prohibited unless the packet explicitly
  suballocates scope, capacity, data/egress, and reconciliation. The coordinator
  alone accepts the result and appends the external execution ledger/queue;
  neither party mutates the normative plan.
- **Attempt lifecycle** — bind attempt ID, terminal deadline, timeout/cancel
  owner/action, process/effect boundary, and report location. Failure/deadline
  enters cancellation-requested until worker, descendants, and effects are
  quiescent; quarantine partials. Retry links its predecessor and rejects late
  predecessor results/mutations.

## Git safety (silent-data-loss guards)

- **Write with an absolute workspace path** — every Git mutation or authorized
  checkpoint uses `git -C {{absolute-path-to-task-workspace}}`. A wrong cwd can
  make status look empty or target the wrong branch.
- **Inspect read-only** — use `git show <ref>` or `git diff <a>..<b>`. Never bare `git checkout` / `switch` / `reset` in a subagent; they detach HEAD and orphan commits with no error.

## Reviewing a dispatched task (only when it earns it)

For a large or risky task, give the reviewer the exact range, task contract, and
risk/equivalence references. Start from changed files, but permit
evidence-driven traversal to relevant callers, contracts, generated sources,
history, and tests; arbitrary whole-repository review is still out of scope.
Use `requesting-code-review` for its required topology. Skip independent review
for a trivial task checkpoint unless plan/risk requires it; the final exact
candidate still enters that skill at its done or integration boundary.
