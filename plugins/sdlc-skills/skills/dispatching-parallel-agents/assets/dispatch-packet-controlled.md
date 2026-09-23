# Controlled dispatch packet prompt template

The coordinator fills this template alongside the base packet when the run
is high-risk or uses phase queues, adding ten fields the slim packet leaves
to the coordinator: which workspace the worker owns, what it shares,
whether it may commit, where it routes, when it stops, how it is isolated,
what data and capacity it may consume, whether it may dispatch anyone, and
how its attempt terminates. Fill every field; delete one only when it is
genuinely empty for this task, and say so. Until every field here is
filled, the worker dispatches nobody, touches only what the base packet
names, and returns its report to the coordinator alone.

```markdown
## Boundary

- **Workspace:** {{owned branch/workspace path; never a shared writer checkout}}
- **Shared/generated:** {{shared files, generators, outputs, manifests,
  lockfiles, and their sole integration owner}}
- **Checkpoints:** {{withheld | the coordinator's recorded local commit
  authority, quoted from its workspace record, plus required gate}}
- **Stop if:** {{new overlap, dependency, shared state, or out-of-scope
  change is discovered}}
- **Isolation:** {{own workspace/port/db if it builds or runs anything;
  else "none needed"}}
- **Data/access:** {{classification and exact material exposed; allowed
  worker, provider, storage, and readers; prohibited secrets/data/effects/egress;
  evidence retention/expiry, exact cleanup targets/effects/recoverability,
  cleanup authority, and disposition}} — states what is reachable, who may
  hold it, and who cleans up; configuration alone grants no disclosure
  authority.
- **Resources:** {{per-worker peaks/ceilings; aggregate host capacity and
  reserve; CPU, memory, temporary disk, processes/descriptors,
  sockets/network, time and cost; enforced limits; monitoring, stop/kill,
  and cleanup}} — unknown capacity means do not dispatch at all.
- **Subdispatch:** {{prohibited | allocated sub-scope, capacity, data/egress
  boundary, and coordinator/reconciliation owner}} — prohibited unless this
  packet allocates every one of those boundaries and names who reconciles
  the grandchildren.

## Done when

- **Route:** invoke `using-sdlc-skills` once from this packet; do not
  reopen settled scope. At done when, invoke `verification-before-completion`
  and return the report; `requesting-code-review`, `finishing-a-branch`, and
  any push, PR, or merge belong to the coordinator.

## Dispatch record

- **Terminal control:** {{expected packet ID; attempt identity;
  predecessor/successor; deadline; poll action; timeout/cancel action and
  owner; quiescence proof, partial-output quarantine, late-result
  rejection, and required report shape}}
```
