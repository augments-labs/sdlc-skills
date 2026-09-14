Copy this section into the design document, replacing every `{{placeholder}}`.
Preserve the sections already approved around it; this one is immutable once its
identity is issued.

```markdown
## Architecture

**Status:** {{draft | proposed; decision and adoption state stay external}}
**Identity:** recorded in the ledger row, never here: the first 7 characters of
`git hash-object --stdin` over this section, from its heading to the next `##`
heading, without trailing blank lines
**Predecessor:** {{prior normative identity, or none; a proposal only links it}}
**Approval rule:** {{one accountable decision owner, or the required approvers
plus the conflict resolver and the rule that decides}}
**Bound inputs:** {{exact requirement, brief, model, and ADR identities this
design was drawn against, and what makes them stale}}
**External decision ledger:** {{location; pending / changes requested / approved /
rejected / cancelled / superseded by approved normative identity, with trusted
evidence bound to this exact version}}
**Stable ID delta:** {{every component, interface, flow, risk, and evaluator ID
as added / changed / removed / preserved; a removal needs owning approval}}

Never write decision state, review state, or build progress into this section.

### Trace

Every requirement, preserved obligation, and material risk maps to something that
carries it. An unmapped row blocks approval. Reference the existing requirement
or project gates, including the assurance matrix where applicable. Do not
redefine a gate or require a new matrix just to fill this section.

| Requirement / obligation / risk | Owning component | Interface | Evaluator reference |
| --- | --- | --- | --- |
| {{ID and source}} | {{C-001}} | {{I-001}} | {{gate ID owned elsewhere}} |

### Components and boundaries

Name each module by what it does *and* by what it deliberately does not.

| ID | Component | Responsibility | Explicitly not its job | Interface |
| --- | --- | --- | --- | --- |
| {{C-001}} | {{name in the domain's language}} | {{the behavior it hides}} | {{what callers must not push into it}} | {{I-001, and how wide it is}} |

### Data and trust

Follow each path from entry to effect, not just the happy one.

| ID | Path | Owner | Authorization boundary crossed | Source of truth transition | Sensitive data |
| --- | --- | --- | --- | --- | --- |
| {{F-001}} | {{request, response, event, or batch}} | {{component}} | {{where trust changes}} | {{who becomes authoritative, and when}} | {{class, or none}} |

### Failure and recovery

One row per dependency and per asynchronous path.

| Path | Timeout | Retry and idempotency | Degraded operation | Recovery | How it is exercised |
| --- | --- | --- | --- | --- | --- |
| {{dependency or async path}} | {{bound}} | {{policy, and the idempotency key}} | {{what still works}} | {{how it returns to normal}} | {{the test, fault injection, or drill}} |

### Operational views

Cover a view where it affects correctness: deployment and runtime topology, scale
and resource budgets, observability, and the target capabilities that make
rollout and compatibility possible. The migration contract owns the transition
procedure — do not restate it here.

| View | Covered | Content or skip record |
| --- | --- | --- |
| {{view}} | {{yes / skipped}} | {{the view itself, or: skip ID, rationale and evidence, owner, expiry or revisit date, compensating evaluator, and who approved the skip}} |

A view omitted by ritual is not a skip record.

### Seams

A seam is justified by measured pressure, never by an imagined future.

| ID | Seam | What justifies it | Measured evidence |
| --- | --- | --- | --- |
| {{S-001}} | {{the boundary}} | {{repeated behavior with a stable owner and measured change friction, or one real volatile or external boundary containing measured impedance, failure policy, or test isolation}} | {{what was actually observed}} |

Implementation count alone neither requires nor forbids a seam.

### Load-bearing decisions

| ID | Decision | Hard to reverse because | Where it is recorded |
| --- | --- | --- | --- |
| {{D-001}} | {{the choice}} | {{what it locks in}} | {{accepted ADR where its owning skill requires one; otherwise this decision row, or the unresolved decision owner}} |

### Open risks

| ID | Risk | Surface it can fail on | What would settle it |
| --- | --- | --- | --- |
| {{R-001}} | {{the risk}} | {{data, security, concurrency, resources, cutover, recovery}} | {{the evidence or decision that closes it}} |
```
