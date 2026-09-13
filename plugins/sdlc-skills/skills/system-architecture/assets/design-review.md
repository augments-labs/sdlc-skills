# Design reviewer prompt template

Fill Inputs and send the fenced prompt. The reviewer fills Output and must
not be the design's sole author.

Before review, bind the exact design version, the reviewer role ID, allowed
artifact access, current authority for its worker/provider/storage/egress, and
the report location. No receipt, no reviewer: an unavailable, refused, or empty
dispatch leaves the review pending, and self-review cannot stand in for it. Set
a terminal deadline and a timeout/cancel owner before dispatching, then poll only
that attempt ID. Quarantine output from any run that did not reach quiescence,
and reject a late result from a reassigned predecessor. Completion is one
nonempty report bound to that design version; failed, timed out, and cancelled
all stay pending.

The design owner resolves every blocking finding and records its disposition.
Every normative correction creates a proposed successor and requires a focused
re-review of affected and dependent sections. Direct approval applies only to
the reviewed version.

````markdown
Review the design in Inputs. Flag **only** issues that would lead to building the wrong thing or an unbuildable design — skip wording and detail-level variation.

## Inputs

- Design: {{design path and exact version}}
- Approved requirements and data model: {{paths and exact versions}}
- Codebase evidence: {{relevant paths and revisions}}
- Review boundary: {{reviewer role ID, allowed artifact access, worker/provider/storage/egress authority, and report location}}
- Terminal control: {{deadline and timeout/cancel owner}}

## Review

1. **Traceability** — every requirement and preserved obligation reaches a
   component, interface, and evaluator; no component is unjustified.
2. **Trust and data** — ownership, authorization boundaries, sensitive paths,
   and sources of truth are explicit.
3. **Failure and recovery** — dependencies and asynchronous paths define
   unavailable, retry, idempotency, degraded, and recovery behavior.
4. **Operations** — the risk-selected runtime, deployment, scale/resource,
   observability, rollout, and compatibility views are sufficient.
5. **Decisions and seams** — hard-to-reverse choices have accepted ADRs; each
   proposed seam has a stable owner and measured change friction or one real
   volatile/external boundary with measured impedance, failure policy, or
   test-isolation value; implementation count alone proves nothing.
6. **Cross-section consistency** — flows use real data-model concepts and
   component boundaries match the named interfaces.
7. **Vocabulary and scope** — domain terms are consistent and no unrequested
   feature or future-only abstraction appears.

## Output

- Design version: {{exact reviewed version}}
- Findings: {{severity — requirement/risk — evidence — required correction; repeat, or state no blockers}}
````
