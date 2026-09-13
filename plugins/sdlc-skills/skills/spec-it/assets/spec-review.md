# Spec reviewer prompt template

Fill Inputs and send the fenced prompt. The reviewer fills Output and must
not be the spec's sole author.

Before review, bind the exact spec version, the reviewer role ID, allowed
artifact access, current authority for its worker/provider/storage/egress, and
the report location. No receipt, no reviewer: an unavailable, refused, or empty
dispatch leaves the review pending, and self-review cannot stand in for it. Set
a terminal deadline and a timeout/cancel owner before dispatching, then poll only
that attempt ID. Quarantine output from any run that did not reach quiescence,
and reject a late result from a reassigned predecessor. Completion is one
nonempty report bound to that spec version; failed, timed out, and cancelled all
stay pending.

The spec owner resolves every finding and records its disposition. Every
normative correction creates a proposed successor and requires focused re-review
of affected and dependent requirements. Direct approval applies only to the
reviewed version.

````markdown
Review the requirements spec in Inputs. Flag **only** issues that would lead to building the wrong thing or make a requirement impossible to test — skip prose style and detail-level variation.

## Inputs

- Spec: {{spec path and exact version}}
- Approved goal/brief: {{goal/brief path and exact version}}
- Codebase evidence: {{relevant paths and revisions}}
- Review boundary: {{reviewer role ID, allowed artifact access, worker/provider/storage/egress authority, and report location}}
- Terminal control: {{deadline and timeout/cancel owner}}

## Review

1. **Testable** — every functional requirement is a behaviour that can pass or fail, not a wish ("rejects an expired token with a 401", not "good auth").
2. **Acceptance criteria** — every requirement has at least one, and it is a real check, not a restatement of the requirement.
3. **What, not how** — no design or implementation smuggled into the requirements (a named cache, a specific endpoint). Flag it; don't fix it.
4. **Complete vs the goal** — every part of the stated goal has a requirement, and every requirement traces back to the goal (no gaps, no orphans).
5. **No contradictions** — no two requirements, or a requirement and its criterion, that can't both hold.
6. **The form is honest and it exists** — every referenced test, mockup,
   source-fact contract, or rubric resolves to a real artifact. For approved
   new behavior, an authorized executable criterion can be observed failing
   for the missing behavior. Preserved behavior instead starts green and is
   deliberately falsified through the TDD preservation cycle. Flag fabricated
   paths, target-derived preservation oracles, unauthorized project mutation,
   and prose only when the chosen acceptance form cannot honestly judge the
   requirement.

## Output

- Spec version: {{exact reviewed version}}
- Findings: {{requirement — issue — fix; repeat, or state no blockers}}
````
