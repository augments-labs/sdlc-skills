Fill every field and hand the result to one agent. Delete a field only when it is
genuinely empty for this task — and say so, so the agent knows the omission is
deliberate rather than forgotten.

```text
TASK: {{one sentence — the exact problem this agent owns}}
TIER: {{small | medium | large}}
BASE: {{immutable revision this work starts from}}
WORKSPACE: {{owned branch/workspace path; never a shared writer checkout}}
OWNS: {{files/dirs it may edit}}
DO NOT TOUCH: {{files/dirs owned by other agents, or off-limits}}
SHARED/GENERATED: {{shared files, generators, outputs, manifests, lockfiles, and their sole integration owner}}
CHECKPOINTS: {{withheld | the coordinator's recorded local commit authority, quoted from its workspace record, plus required gate}}
ROUTE: invoke using-sdlc-skills once from this packet; do not reopen settled scope.
At DONE WHEN, invoke verification-before-completion and return REPORT;
requesting-code-review, finishing-a-branch, and any push, PR, or merge belong
to the coordinator.
SUBDISPATCH: {{prohibited | allocated sub-scope, capacity, data/egress boundary,
and coordinator/reconciliation owner}}
START FROM: {{pasted verbatim: the task contract, the exact spec, the failing test name}}
READ: {{paths of bulky context — diffs, logs, large fixtures — read on demand, don't paste}}
DONE WHEN: {{the observable condition — a named test passes, a specific output exists}}
STOP IF: {{new overlap, dependency, shared state, or out-of-scope change is discovered}}
REPORT: {{base/result revisions, diff range, files changed, command and raw verdict, authorized checkpoint commits or none, scope exceptions}}
ISOLATION: {{own workspace/port/db if it builds or runs anything; else "none needed"}}
DATA/ACCESS: {{classification and exact material exposed; allowed worker,
provider, storage, and readers; prohibited secrets/data/effects/egress;
evidence retention/expiry, exact cleanup targets/effects/recoverability,
cleanup authority, and disposition}}
RESOURCES: {{per-worker peaks/ceilings; aggregate host capacity and reserve;
CPU, memory, temporary disk, processes/descriptors, sockets/network, time and
cost; enforced limits; monitoring, stop/kill, and cleanup. Unknown capacity
means "do not dispatch".}}
TERMINAL CONTROL: {{expected packet ID; attempt identity; predecessor/successor;
deadline; poll action; timeout/cancel action and owner; quiescence proof,
partial-output quarantine, late-result rejection, and required report shape}}
DISPATCH RECEIPT: {{fill only from the callable action's returned nonempty
agent/job IDs; otherwise "not dispatched" plus unavailable/refused/empty result}}
TERMINAL OUTCOME: {{not dispatched | running | cancellation requested |
succeeded with accepted report | failed and quiescent | timed out and quiescent |
cancelled and quiescent; raw evidence, quarantined output, late-result state,
and linked reassignment/scope disposition}}
```

Why the fields are shaped this way, and worked weak-versus-strong packets, are in
`../references/brief-examples.md`.
