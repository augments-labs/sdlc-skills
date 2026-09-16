Add these fields to the packet in `dispatch-packet.md` when the run is high-risk
or uses phase queues. They bind what the slim packet leaves to the coordinator:
which workspace the worker owns, what it shares, whether it may commit, where it
routes, when it stops, how it is isolated, what data and capacity it may consume,
whether it may dispatch anyone, and how its attempt terminates. Fill every field
you add; delete one only when it is genuinely empty for this task, and say so.

```text
WORKSPACE: {{owned branch/workspace path; never a shared writer checkout}}
SHARED/GENERATED: {{shared files, generators, outputs, manifests, lockfiles, and their sole integration owner}}
CHECKPOINTS: {{withheld | the coordinator's recorded local commit authority, quoted from its workspace record, plus required gate}}
ROUTE: invoke using-sdlc-skills once from this packet; do not reopen settled scope.
At DONE WHEN, invoke verification-before-completion and return REPORT;
requesting-code-review, finishing-a-branch, and any push, PR, or merge belong
to the coordinator.
STOP IF: {{new overlap, dependency, shared state, or out-of-scope change is discovered}}
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
SUBDISPATCH: {{prohibited | allocated sub-scope, capacity, data/egress boundary,
and coordinator/reconciliation owner}}
```

`SUBDISPATCH` is `prohibited` unless this packet allocates sub-scope, capacity,
the data and egress boundary, and who reconciles the grandchildren. `DATA/ACCESS`
says what is reachable, who may hold it, what is prohibited, and who cleans up —
configuration grants no disclosure authority. Unknown host capacity under
`RESOURCES` means do not dispatch at all.
