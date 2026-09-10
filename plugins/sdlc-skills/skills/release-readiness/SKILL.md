---
name: release-readiness
description: "Use when an integrated candidate is about to be promoted to a release, deployment, or publication — the first release of a project, a version bump, a package publish, a production deploy, or a rollout stage expansion. Fires on ship it, cut a release, publish the package, and is this safe to deploy, even if nobody says release. Skip internal work with no release surface."
---

# Release Readiness

Judge the exact artifact set that will ship, then put the promotion decision
to the user. This skill never deploys or publishes.

## When to use

- An integrated candidate is approaching an initial or later release promotion.
- **Skip** internal work with no release surface. A library or package release
  is not a skip merely because it has no running production service.

## Step 1: Fix what is being released

Open `assets/release-candidate.md`. Read `references/gate-details.md` at the
row numbers below for each concrete check.

1. Fill the `Immutable release-input descriptor`: promotion, source, contracts,
   expected artifacts and gate cells, who may approve. No secret values.
2. Write attempts and evidence in the `External attempt and evidence ledger`,
   never in the descriptor.
3. Freeze the artifact set: one terminal successful build per required member,
   from the recorded source. Record its identity (row 10).
4. Test and promote *that* set. Reject a later rebuild, however equivalent.

## Step 2: Judge it

Work every `Readiness rows` entry to **evidenced**, **not applicable with an
approved disposition** (the row's owner accepts the rationale, recorded under
the descriptor's approver rule), or **blocking**.

1. Install, start, or load each member through the paths a real consumer
   uses. A green source tree is not artifact evidence.
2. **REQUIRED SUB-SKILL:** invoke `verifying-completion`. Run every gate
   protecting this promotion over its expected inventory; reconcile against
   what actually ran (row 11).
3. Exercise cutover and recovery by observation, including the claimed
   RPO/RTO (rows 3, 13). Fill `Rollout and recovery`.
4. Check the target: configuration, secrets, capacity, dependencies, step
   ordering (row 6). Verify shape and presence; never print values.
5. Bind rollout control to the owning assurance, migration, or release policy
   (rows 5, 12). Missing policy: blocking. Do not invent or lower one.
6. Expansion or full release: attach observed evidence from the prior stage.
7. Account for consumers (rows 7, 8, 15). Package: install the packed
   artifact into a clean representative consumer before publishing anything.

## Step 3: Decide

1. Disposition every deviation in `Deviations` (row 14). Lowering a gate so
   the candidate passes is a new assurance decision, not a release fix.
2. Write the `Verdict` bound to the release-input, artifact-set,
   terminal-evidence, approval, and freshness identities.
3. Recompute every identity immediately before any decision. On drift, reopen
   the decision.
4. Present the decision and stop:

   ```text
   Release candidate {{artifact-set identity}} → {{target}}
   Verdict: {{ready | not ready}} — {{n}} gates evidenced, {{n}} deviations owned, rollback {{state}}

   1. Promote this exact set
   2. Hold
   3. Cancel

   Recommendation: {{1 only when ready, otherwise 2}} — {{one sentence}}.
   ```

5. Promote nothing until the user names one. The promotion then runs under its
   own authorized action, never on the strength of the verdict.

## Hard stops

- Release tests ran on source or a different/incomplete artifact set.
- Release-input, artifact-set, terminal-evidence, or verdict identity is missing,
  stale, incomplete, or changed.
- Any required cell/evidence/change is missing, duplicated, generically skipped/
  rejected, unresolved, unowned, misordered, or beyond its bound.
- Decommission is partial, failed, awaiting/failed validation, or unresolved.
- Rollback names only source, not a restorable artifact and data/config state.
- The fixer, builder, or deployer self-accepts an unapproved deviation.
- “Ready” is treated as authority to deploy or publish.

## Common mistakes

- Rebuilding after tests and assuming the bytes are equivalent.
- Treating local/pre-merge green as release evidence, or skipping package gates.
- Calling a bare flag a rollout plan, or an unbounded recovery promise rollback.
