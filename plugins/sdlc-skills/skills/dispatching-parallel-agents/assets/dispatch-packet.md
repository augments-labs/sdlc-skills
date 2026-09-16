Fill every field and hand the result to one agent. Delete a field only when it is
genuinely empty for this task — and say so, so the agent knows the omission is
deliberate rather than forgotten.

```text
TASK: {{one sentence — the exact problem this agent owns}}
TIER: {{small | medium | large}}
BASE: {{immutable revision this work starts from}}
OWNS: {{files/dirs it may edit}}
DO NOT TOUCH: {{files/dirs owned by other agents, or off-limits}}
START FROM: {{pasted verbatim: the task contract, the exact spec, the failing test name}}
READ: {{paths of bulky context — diffs, logs, large fixtures — read on demand, don't paste}}
DONE WHEN: {{the observable condition — a named test passes, a specific output exists}}
REPORT: {{base/result revisions, diff range, files changed, command and raw verdict, authorized checkpoint commits or none, scope exceptions}}
DISPATCH RECEIPT: {{fill only from the callable action's returned nonempty
agent/job IDs; otherwise "not dispatched" plus unavailable/refused/empty result}}
TERMINAL OUTCOME: {{not dispatched | running | cancellation requested |
succeeded with accepted report | failed and quiescent | timed out and quiescent |
cancelled and quiescent; raw evidence, quarantined output, late-result state,
and linked reassignment/scope disposition}}
```

A controlled run adds ten more fields — workspace, sharing, checkpoints,
routing, stop conditions, isolation, data, capacity, sub-dispatch, and terminal
control. They are in `dispatch-packet-controlled.md`. Until they are filled in,
a worker dispatches nobody, touches only what this packet names, and returns its
report to the coordinator.

Why the fields are shaped this way, and worked weak-versus-strong packets, are in
`../references/brief-examples.md`.
