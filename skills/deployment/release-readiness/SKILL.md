---
name: release-readiness
description: "Decides whether an integrated candidate is safe to promote to a release, deployment, or publication. Use when the user says ship it, asks to cut a release or publish the package, or asks whether this is safe to deploy, and before a first release, a version bump, a package publish, a production deploy, or a rollout stage expansion. Skip internal work with no release surface."
---

# Release Readiness

Judge the exact artifact set that will ship, then put the promotion decision
to the user. This skill never deploys or publishes.

## When to use

- Integrated work is approaching an initial or later release promotion.
- **Skip** internal work with no release surface. A library or package release
  is not skipped merely because it has no running production service.

## Step 1: Pin down what is being released

Open `assets/release-candidate.md` before this step's first action; each step
fills its sections. Read `references/gate-details.md` when a step below cites
a row number and you need that row's concrete check.

1. Fill the `Immutable release-input descriptor`: the promotion, the source,
   the contracts, the expected artifacts and check cells (each combination of
   platform, packaging, build mode, and so on that a check must cover), and
   who may approve. Write no secret values.
2. Write every attempt and its evidence in the `External attempt and evidence
   ledger` (the ledger: add to it, never rewrite it), never in the descriptor.
3. Freeze the artifact set: one finished, successful build per required
   member, from the recorded source. Record the set's identity (row 10).
4. Test and promote *that* set. A later rebuild is a different set, however
   equivalent it looks; reject it.

## Step 2: Judge it

Work every `Readiness rows` entry until it is **evidenced** (the ledger holds a
passing result for it), **not applicable with an approved disposition** (the
row's owner accepts the reason it does not apply, and that acceptance is
recorded under the descriptor's approver rule), or **blocking**.

1. Install, start, or load each member through the paths a real consumer
   uses. Passing checks on the source tree are not evidence about the
   artifact.
2. **REQUIRED SUB-SKILL:** invoke `verification-before-completion`. Run every
   check that protects this promotion over its expected inventory, then
   compare that inventory with what actually ran and account for every
   difference (row 11).
3. Exercise the cutover and the recovery, including the claimed RPO (how much
   data may be lost) and RTO (how long recovery may take), and observe what
   happens; do not infer it (rows 3, 13). Fill `Rollout and recovery`.
4. Check the target: configuration, secrets, capacity, dependencies, and the
   order of the steps (row 6). Verify that each is present and has the
   expected shape; never print a value.
5. Tie the rollout control to the assurance, migration, or release policy
   that owns it (rows 5, 12). If there is no such policy, the row is blocking;
   for a bounded feature, `rollout-controls` drafts one for its owner to
   accept. Never invent a policy or lower one.
6. If the promotion is an expansion or a full release, attach the evidence
   observed in the prior stage.
7. Account for the consumers (rows 7, 8, 15: release notes, breaking changes,
   and package obligations). If the release is a package, install the packed
   artifact into a clean, representative consumer before publishing anything.

## Step 3: Decide

1. Record a decision (its disposition) for every deviation in `Deviations`
   (row 14). Lowering a check so the frozen set passes is a new assurance
   decision, not a release fix.
2. Write the `Verdict`, naming the identities it is bound to: release input,
   artifact set, terminal evidence (the complete ledger), approval, and
   evidence freshness.
3. Recompute every identity immediately before any decision. If any has
   changed, reopen the decision.
4. Present the verdict and the choice, then end the turn:

   ```text
   Release candidate {{artifact-set identity}} → {{target}}
   Verdict: {{ready | not ready}} — {{n}} gates evidenced, {{n}} deviations owned, rollback {{state}}

   1. Promote this exact set
   2. Hold
   3. Cancel

   Recommendation: {{1 only when ready, otherwise 2}} — {{one sentence}}.
   ```

5. Promote nothing until the user names one of the three. The promotion then
   runs as its own authorized action, never on the strength of the verdict.

## Gotchas

- Step 2.6's prior-stage evidence has to be captured while that stage is
  live. A rollout that expands on its own schedule — a percentage ramp, a
  timed cohort — has already moved by the time anyone looks, and the
  expansion is then approved against evidence nobody observed.
- A row recorded as **not applicable** counts the same as an evidenced one in
  a bare tally of checks, which is why Step 3.4 presents "gates evidenced" and
  "deviations owned" as separate numbers. Collapsing them into one hides how
  much of the release nobody checked.

## Hard stops

- The release tests ran on the source tree, or on a different or incomplete
  artifact set.
- The release-input, artifact-set, terminal-evidence, or verdict identity is
  missing, stale, incomplete, or changed.
- Any required cell, evidence, or change is missing, duplicated, skipped or
  rejected with only a generic reason, unresolved, unowned, out of order, or
  beyond its bound.
- A decommission is partial, failed, awaiting validation, failed validation,
  or unresolved.
- The rollback names only the source, not a restorable artifact
  together with the data and config state to restore.
- The fixer, builder, or deployer accepts an unapproved deviation on their
  own.
- “Ready” is treated as authority to deploy or publish.

## Common mistakes

- Calling a bare feature flag a rollout plan, or calling a recovery promise
  with no stated bound a rollback.
