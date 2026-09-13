# Gate details

Expanded checks behind the readiness gate in `../SKILL.md`. Loaded on demand — when a gate item needs a concrete check, a template, or a failure pattern to rule out.

For each item: what *good* looks like, how to check it concretely from the repo, and the most common way it silently fails.

The release-input descriptor supplies the stable expected row inventory and
effect contract. Run controlled actions through `verification-before-completion`; its
attempt ledger owns execution, quiescence, raw evidence, and pre/post effects.
This reference owns which release rows must exist and how their results affect
the promotion verdict. Never run a mutating drill against shared or production
state without exact direct authority.

## 1. Integration CI is green on the artifact's source

- **Good:** every required integration check passed after merge on the exact
  source revision from which the immutable artifact was built.
- **Check:** resolve source provenance from the artifact, then inspect that
  revision's pipeline. Confirm the required integration set ran after the last
  source change. Artifact checks remain separate.
- **Silent failure:** the green badge is from a run *before* the last rebase or merge. The branch moved; the check didn't rerun. Another: a flaky test was retried until green, and the failure was never read.

## 2. Acceptance criteria verified

- **Good:** every criterion in the spec or issue maps to an observed result — a passing check, a reproduced behaviour, a screenshot — not to "the code looks right."
- **Check:** list the criteria verbatim, then name the evidence for each one. Any criterion whose evidence is "should" or "in theory" is unverified — run it now (see `verification-before-completion`).
- **Silent failure:** the criteria were verified on a branch that then changed. A late "small fix" invalidated the earlier verification and nobody re-ran it.

## 3. Migrations have exercised recovery

- **Good:** each schema/data transition has an exercised reversal or restoration
  path that meets accepted data-loss and recovery-time bounds. A destructive
  change uses retained artifacts and a tested restore; a fictional down script
  is worse than an honest recovery plan.
- **Check:** exercise the real sequence on representative data: forward,
  mixed-version operation, rollback/restore, validation, and forward again as
  applicable. Measure RPO/RTO and data written during the new-version interval.
- **Silent failure:** schema shape rolls back while rows written in the new
  format disappear or become unreadable.

## 4. Rollback target is named

- **Good:** an exact immutable, already available artifact version is written
  down, along with source provenance and steps to restore application, data, and
  config state.
- **Check:** fill this in before deploy, and keep it where the on-call can find it:

```text
Rollback target: {{immutable artifact and digest}}
Source provenance: {{revision and build identity}}
Revert by: {{command-or-deploy-step}}
Transition recovery: {{restore/reversal steps and data consequences}}
Config to revert: {{variables-to-restore}}
Known gaps: {{what-rollback-does-not-undo}}
```

- **Silent failure:** "rollback" means reverting application code, but the migration already ran — the old code now runs against the new schema and fails differently than the new code did. If rollback and migrations disagree, the migration plan is the one to fix.

## 5. Risk has controlled rollout

- **Good:** risk is bounded by the mechanism that fits it: flag, canary,
  partition, staged publication, or phased rollout, with telemetry, thresholds,
  abort, and a named owner.
- **Check:** name the owning assurance, migration, or release-policy version and
  bind its mechanism, target state, cohort, baseline, success/failure thresholds,
  minimum observation duration, kill/rollback action, and authority. Missing
  policy blocks readiness; do not create it inside the verdict.
- **Silent failure:** the flag exists in code but defaults to on, or the flag check sits *after* the risky work runs. Another: the flag guards the happy path but not the background job, migration, or event consumer that the same change introduced.

## 6. Config and secrets are present

- **Good:** every new or changed variable, secret, or setting the change reads is already set in the target environment — or the deploy ordering accounts for it — and each has a documented expected value or shape.
- **Check:** diff the change's config reads (environment lookups, config files, injected settings) against what the target environment actually defines. For secrets, verify *presence and shape*, never print the value.
- **Silent failure:** the variable is missing and the code falls back to a default — a local default. It "works," connected to the wrong thing, until it doesn't. Require explicit failure on missing config for anything that selects an environment (hosts, credentials, endpoints).

## 7. Changelog / release notes written

- **Good:** one honest line per user-visible or operator-visible change, written for the reader who wasn't in the room — what changed, what to do about it if anything.
- **Check:** the entry exists and a stranger could answer "do I need to act?" from it. A template that forces the point:

```text
{{version-or-date}} — {{what changed, in one line}}. Action needed: {{none | what, and by whom}}.
```

- **Silent failure:** the notes list commit messages — "fix bug," "update deps" — which describe the author's day, not the system's behaviour. The reader learns nothing and stops reading the notes entirely.

## 8. Breaking changes flagged to dependents

- **Good:** every change to a surface something downstream relies on — an API contract, an event schema, a data format, a CLI flag — is enumerated, and each dependent has been notified or the change is backwards-compatible by construction.
- **Check:** enumerate public surfaces changed by the candidate and its
  contracts, including generated or indirectly reachable changes. For each,
  classify additive, changed, or removed; name dependents and
  compatibility/coordination.
- **Silent failure:** the change *looks* additive but isn't — a field renamed in the same payload, a value's type narrowed, an event's ordering changed. Dependents parse it fine and compute the wrong answer. Type and ordering changes are breaking even when the schema still validates.

## 9. Downtime is none, or scheduled

- **Good:** either the deploy is provably zero-downtime (compatible old/new running side by side), or a window is scheduled, communicated to the people affected, and sized with margin.
- **Check:** walk the deploy sequence in order and ask, at each step, what a request in flight sees. If any step answers "an error" or "the old code against the new schema," that's downtime or a compatibility bug — pick the window deliberately instead of discovering it.
- **Silent failure:** "rolling deploy, so no downtime" — but the deploy includes a migration the old version can't run against. Requests hitting the old instances during the roll fail one at a time, so the monitor stays green until the roll finishes.

## 10. Immutable artifact and provenance

- **Good:** one release candidate is built from the recorded integrated source
  with known inputs, contents, dependency inventory, digest, provenance, and
  storage. Every later check and promotion names that same identity.
- **Check:** compare source revision, clean-tree state, build definition,
  dependencies, generated inputs, artifact manifest, digest, and promotion
  records. Inspect the artifact for unexpected/missing files and secrets.
- **Silent failure:** tests cover a local build, then publication rebuilds from
  a different environment or moving dependency and produces different bytes.

## 11. Full assurance and parity

- **Good:** every assurance gate whose protected promotion includes release has
  current evidence for all supported platform, architecture, runtime, feature,
  packaging, and build-mode cells.
- **Check:** reconcile the required matrix to observed results, including
  differential, behavior, static/dynamic safety, security,
  performance/resources, and changed/skipped/deleted-test inventory.
- **Silent failure:** a summary is green while one release build, platform,
  expensive cadence, or test shard never ran.

## 12. Production-like differential and rollout telemetry

- **Good:** the candidate matches the current trusted release over representative
  production-like inputs except approved deviations; rollout signals measure
  correctness, safety, latency/resources, and business/operational health.
- **Check:** for initial stage, bind corpus/data boundaries, artifacts,
  normalization, thresholds, telemetry, baselines, cohorts, soak, abort, and
  authority to their owning contract IDs. For expansion/full release, attach
  observed prior-stage results.
- **Silent failure:** telemetry observes only process liveness while outputs,
  errors, data integrity, or resource tails regress.

## 13. Recovery and retained artifacts

- **Good:** rollback artifact, data/config snapshots, restoration procedure, and
  post-restore gates have been exercised within accepted RPO/RTO.
- **Check:** perform a safe drill using the actual artifacts and ordering,
  including in-flight work and data written after cutover. Verify the restored
  system, not only command exit codes.
- **Silent failure:** code rolls back but queues, schemas, secrets, or new-format
  data remain incompatible.

## 14. Known deviations

- **Good:** each deviation has consequence, owner, compensating gate, evidence,
  expiry/revisit, rollback trigger, and complete trusted approval receipts under
  the exact approver rule.
- **Check:** compare requirements, migration deviations, gate exceptions,
  security findings, and release notes; no item disappears between artifacts.
- **Silent failure:** “known issue” has no owner or expiry and silently becomes
  the permanent floor.

## 15. Library and package candidates

- **Good:** the exact archive/package installs in a clean representative
  consumer and meets public API/ABI/schema, supported runtime/platform,
  dependency, metadata, content, and upgrade/downgrade obligations.
- **Check:** inspect the packed contents, install only the artifact into a clean
  consumer, compile/load/run public usage and compatibility gates, and verify
  the prior immutable version remains the recovery target.
- **Silent failure:** repository tests import the source tree, while the
  published package omits generated files, exports the wrong surface, or relies
  on undeclared local dependencies.

## When the gate can't fully pass

A failed item can become an accepted deviation only when the assurance/release
contract permits that class of exception and an accountable owner directly
accepts the consequence, compensating gate, expiry, and rollback trigger.
Hard blockers remain blockers. Missing or inconclusive evidence is not a risk
acceptance.
