# Plan reviewer prompt template

Fill Inputs and send the fenced prompt. The reviewer fills Output and must
not be the plan's sole author. Review is mandatory for high-risk plans,
optional for bounded plans.

Before review, bind the exact plan version, the reviewer role ID, allowed
artifact access, current authority for its worker/provider/storage/egress, and
the report location. No receipt, no reviewer: an unavailable, refused, or empty
dispatch leaves the review pending, and self-review cannot stand in for it. Set
a terminal deadline and a timeout/cancel owner before dispatching, then poll only
that attempt ID. Quarantine output from any run that did not reach quiescence,
and reject a late result from a reassigned predecessor. Completion is one
nonempty report bound to that plan version with every finding dispositioned;
failed, timed out, and cancelled all stay pending.

Resolve every blocking finding and record its disposition. Every normative
correction creates a successor and requires focused re-review of affected and
dependent sections before direct approval.

````markdown
Flag only issues that can cause incorrect, incomplete, unsafe, or non-executable work.

## Inputs

- Plan: {{index/task paths and exact version}}
- Approved contracts: {{requirements/design paths and exact versions; migration contract and assurance matrix where applicable}}
- Codebase evidence: {{relevant paths and revisions}}
- Review boundary: {{reviewer role ID, allowed artifact access, worker/provider/storage/egress authority, and report location}}
- Terminal control: {{deadline and timeout/cancel owner}}

## Review

1. **Traceability:** every requirement and accepted risk gate has one owning
   task or phase; every task traces to a requirement, risk, or necessary gate.
2. **Correctness:** paths, interfaces, types, and commands match current
   evidence and exact artifact revisions.
3. **Decomposition:** bounded tasks are independently evaluable; large
   homogeneous work uses a stable inventory and exclusive shards.
4. **Consistency:** every Consumes resolves to a Produces under the same name
   and type; dependencies and phase entries are acyclic and complete; files,
   data, effects, evaluators, and external state are exclusive or ordered.
5. **Assurance:** Evaluators reference the accepted thresholds, environments,
   cadence, and failure response without weakening them.
6. **Control:** trial, phase entry/exit, pause/abort, repeated-failure re-audit,
   cutover, rollback, and ownership transfer are executable where required.
7. **Authorization:** the reviewed plan version and execution mode are pending
   until directly approved.

## Output

- Plan version: {{exact reviewed version}}
- Findings: {{severity — task/phase — source contract — evidence — required correction; repeat, or state no blockers}}
````
