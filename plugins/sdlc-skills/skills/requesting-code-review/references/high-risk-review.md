# High-risk transformation review

Use this topology when reviewability, preservation, breadth, or independent
failure surfaces defeat ordinary line-by-line review.

## Required role separation

- **Implementer:** produces a candidate under the approved migration, assurance,
  plan, and shard contracts; does not approve it.
- **Equivalence specialist:** uses `../assets/equivalence-reviewer.md` to compare source,
  target, and migration contract independently of implementation claims.
- **Adversarial reviewers (at least two):** independently try to refute
  readiness. Give them distinct risk hypotheses or partitions, then require an
  integrated-result pass over cross-partition behavior.
- **Security auditor:** required when trust boundaries changed; follows
  `security-audits`.
- **Fixer:** separate from implementer and reviewers. Applies only findings
  accepted through `receiving-code-review`, then runs the named gates.

These are independent roles, not necessarily concurrent processes. Do not leak
one reviewer's findings or the desired verdict into another's first pass.
Fresh context is necessary but may not be sufficient: when correlated generator
blind spots are material, diversify reasoning/tool chains or add human/domain
expertise, and record any narrower topology as the exception below.

A smaller topology requires a direct, recorded exception scoped to the exact
candidate. It names omitted roles, reason, consequence, compensating gates,
decision owner, and expiry. Cost or a confident general review alone is not a
reason.

## Review units

Review trial and phase/shard candidates while they remain comprehensible. Each
review binds to its immutable input/output identity and evidence. Before
promotion, also review the exact integrated result for cross-shard behavior,
generated/shared files, queue reconciliation, and platform/build parity.

No reviewer must manually read every mechanically reproducible generated line.
Arbitrary source written by an agent is not “generated output” merely because an
agent typed it. Use source-to-target mapping, differential artifacts, structural
invariants, risk-based sampling, compiler/static/dynamic results, and raw
failure queues for the scale exception. The reviewer—not the implementer—derives
and records the sample rule/seed and identities from the complete inventory,
including rare, boundary, failure, and cross-shard cases. Sampling never
replaces a required exhaustive gate.

## Mandatory axes

1. Preserved facts and intentional deviations match the migration contract.
2. Differential, safety, performance/resource, security, and parity results
   match assurance thresholds and evidence freshness.
3. Every source item maps to one accepted target/shard result or an exact approved
   skip disposition; all attempts, leases, quarantined partials, and late results
   are accounted.
4. Every post-baseline source change appears exactly once in the intake queue,
   reopens affected shards, and stays within the approved lag bound.
5. Every post-baseline source change is applied-and-verified, proved reverted/
   absent, or an approved deviation. Every post-snapshot data/work change is
   captured, ordered, and ends applied once/reconciled, reversed/absent with
   source evidence, or owning-contract-approved rejection/deviation.
6. Added, changed, skipped, quarantined, focused, and deleted tests/corpora are
   derived from the stable inventory. Every skip binds its approved exclusion/
   deviation version, owner, evidence, expiry/revisit, and compensating gate.
7. Repeated failure classes changed shared rules and reopened all affected work.
8. Cutover, abort, retained artifacts, and rollback remain executable.

## Findings and fixes

Every finding names the violated invariant and a reproduction or gate. Reviewer
agreement is not promotion evidence. After the separate fixer changes anything,
create a new candidate, rerun affected and integrated gates, and obtain focused
re-review from the relevant independent roles.
