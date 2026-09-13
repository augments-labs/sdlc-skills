# Equivalence reviewer prompt template

Fill Inputs and Report template from `assets/review-report.md`; send the
fenced prompt. The reviewer fills the report.

````markdown
Review the exact high-risk candidate independently of its implementer.

## Inputs

- Candidate descriptor: {{descriptor path with source/target immutable identities}}
- Migration contract: {{approved version and intentional deviations}}
- Assurance evidence: {{matrix and raw differential/test-inventory results}}
- Execution inventory: {{phase/shard inventory, source-change and live-state catch-up queues, mappings, and failure queue}}

## Checks

Keep the candidate read-only; any replay/probe uses the descriptor's authorized
copy, attempt, effect, restoration, cleanup, and pre/post-state contract.

1. Trace every preserved fact to source evidence, target observation, and the
   gate that compares them.
2. Confirm normalization and tolerances come from approved contracts rather than
   target output.
3. Derive and record an independent risk-stratified sample rule/seed/identities
   from the complete inventory, then reproduce differential results including
   errors, data, ordering, side effects, and resource behavior where contractual.
4. Verify the oracle's deliberate divergence was detected and exact restoration
   returned green.
5. Reconcile source inventory to target/shard states; investigate every missing,
   duplicate, failed, reopened, or intentionally skipped item.
6. Reconcile post-baseline source changes and post-snapshot live state without
   missing, duplicate, misordered, unresolved, or over-lag items.
7. Audit added, changed, skipped, quarantined, weakened, and deleted tests or
   corpora against the stable test inventory.
8. Confirm every intentional delta has direct approval and no unapproved delta
   is hidden by normalization, threshold changes, or exclusions.

## Output

Complete the supplied report template with Role `equivalence` and Verdict
`supported`, `not_supported`, `supported_after_fixes`, or `inconclusive`.

Repeat the finding block; use “none” when clear. Bind the report to both exact
identities. Never infer equivalence from compilation or aggregate green alone.

### {{finding title}}

- Severity/disposition: {{severity and blocking status}}
- Contract: {{migration fact or invariant ID}}
- Evidence: {{source and target observations; reproduction or gate}}
- Correction: {{required change}}

Write only at the descriptor's assigned report location outside the candidate,
then return that location; if no safe location exists, return the full report.

## Report template

{{report template}}
````
