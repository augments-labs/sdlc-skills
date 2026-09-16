# Codex tool binding for dispatched work

Part of the Codex adapter, not of any skill. The shipped skills say "the real
callable action" and require a returned ID; they never name a harness tool. This
file is where that action is named for this harness, so a renamed or removed tool
changes an adapter file and no skill body.

## The calls a dispatch needs

| Contract step | Codex call | What the adapter binds |
| --- | --- | --- |
| Dispatch | `spawn_agent` | The filled packet or role brief is the whole prompt. Set `fork_turns: none` so the worker starts cold. The returned non-empty agent ID is the packet's `DISPATCH RECEIPT`; an empty, refused, or unavailable result is `not dispatched`. |
| Poll | `wait_agent` | Always bounded — one wait may not outlive the deadline frozen before the first dispatch. |
| Resume | `followup_task` | Sends the next brief to an agent that already holds the work: the fix round after a review, or a re-review of the same change. |
| Reconcile | `list_agents` | Compares what is actually running against the expected packet IDs and count. |
| Clarify | `send_message` | For a question the packet should have answered. Record it; the packet, not the chat, stays the contract. |
| Cancel | `interrupt_agent` | The timeout and cancel action the packet names, with its owner. |

## Cold start is the point of `fork_turns: none`

A worker that inherits turn history inherits the coordinator's assumptions, and
its report then agrees with them. `none` gives it exactly the packet: the task,
the base revision, what it owns, what it must not touch, what to read, and the
observable that means done. Pasting session history in place of those fields is
prohibited by the skill and is not fixed by a larger prompt.

## Bounded waits, and what happens at the edge

Freeze the deadline, the expected IDs and count, and the cancel action before the
first `spawn_agent`. Then wait in bounded slices rather than one unbounded call,
so the deadline is enforced by the coordinator and not by the tool. On expiry:
write `cancellation requested`, call `interrupt_agent`, wait until the agent and
anything it started are quiescent, quarantine whatever partial output exists, and
only then write the terminal outcome. A result that arrives after that is a late
result and is rejected.

## Tier binding

The spawn call carries the model. Map the packet's `TIER` to a model there, at
dispatch. Writing a tier in the prompt selects nothing, and no tier is implied by
an agent name. If the build exposes no model choice, say so and use a fallback
the user's preferences permit; never report an override that was not applied.

## Role binding

`subagent-driven-development` ships three role briefs. Where the installed build
exposes an agent whose contract covers a role, spawn that agent with the filled
brief; otherwise spawn a general agent with the same brief. The brief is the
specification, the agent is only the runtime carrying it. A review role that
lands on an agent able to write is recorded as an unenforced binding: the brief
forbids every edit, commit, and push, and the coordinator inspects the workspace
before accepting the report.

## When the build exposes none of this

Availability is a property of the installed build and its configuration, and it
changes between versions — some builds gate these tools behind a configuration
entry that is off by default. An uncallable action is `not dispatched`. Name the
call attempted and what this environment would need to make it callable, ask the
user once, and record the answer as the written assignment. Never describe a
fan-out that returned no IDs, and never quietly do the work instead.
