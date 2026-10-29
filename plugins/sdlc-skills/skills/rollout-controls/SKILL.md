---
name: rollout-controls
description: "Adds the feature flag or kill switch and threshold signals a controlled rollout needs. Use when release policy, the plan, or the user calls for a feature flag, kill switch, canary, or staged rollout, or when release readiness blocks on missing rollout policy or rollout signals. Skip changes nobody asked to stage and migrations or high-risk transformations whose own contract owns rollout."
---

# Rollout Controls

Build the switch and the signals under terms the owner has accepted. This
skill never decides the release, flips the switch in a shared environment, or
expands a rollout.

## When to use

- The project's release policy or instructions file requires a staged or
  controlled rollout for this kind of change.
- The plan or the user asks for a feature flag, kill switch, canary, or
  staged rollout.
- `release-readiness` blocked this change on a missing rollout policy or on
  rollout signals that measure nothing the policy reads.
- **Skip** a change nobody asked to stage.
- **Skip** a rewrite, migration, or other high-risk transformation:
  `migration-strategy` owns its cutover, pause, abort, and rollback, and
  `verification-strategy` owns the checks its stages pass. Say which one
  owns it. A bounded feature built inside that work still comes here for its
  own switch.

## Step 1: Find the policy, or draft one for its owner

1. Read the project's release or rollout policy, its instructions file, and
   its conventions: the flag facility, metric names, dashboards, cohort
   definitions. Record the document and version you read.
2. If a policy exists, copy its terms for this change: mechanism, target
   state, cohort stages, baseline source, success and failure thresholds,
   minimum observation, kill or rollback action, authority.
3. If there is no policy, or a term is unsaid, draft the missing terms from
   the change's risk and the project's existing telemetry, and put the draft
   to the release or decision owner:

   ```text
   Rollout terms for {{change}} — a draft; not policy until accepted
   Mechanism: {{flag | canary | partition | staged publication | phased rollout}}
   Target state: {{what full rollout looks like}}
   Cohorts: {{stage 1 → stage n, each with its selection rule}}
   Baseline: {{the signal source and window the cohorts compare against}}
   Success / failure thresholds: {{one line per signal: correctness, safety, latency or resources, outcome}}
   Minimum observation: {{duration or volume per stage}}
   Kill / rollback action: {{the exact action and who may take it}}
   Authority: {{who may expand a stage; who may abort}}

   1. Accept these terms as the rollout policy for this change
   2. Change a term (say which)
   3. Decline — ship without a staged rollout

   Recommendation: 1 — {{one sentence}}.
   ```

   Offer option 3 only when no policy requires staging. Under a policy that
   does, or after a release block, drop it: shipping without the rollout is a
   deviation that only `release-readiness` may accept, when the release
   contract permits that exception, never here. Ask this and end the turn;
   `clarifying-intent` owns what closes it.
4. If the answer is option 2, revise, keep the earlier terms visible, and
   present the draft again. If the answer is option 3, fill
   `assets/rollout-record.md` before stopping, with Status `declined` and
   only its Policy and Next action sections, and add the row to the decision
   ledger beside it (add to it, never rewrite it), naming who declined and
   when; this skill ends here. An
   unaccepted draft is not a policy: build nothing against it.

## Step 2: Build the switch

1. Use the flag or configuration facility the project already has. If it has
   none, use the smallest runtime configuration read the project already
   performs, and name it in the record. Add no library.
2. Default it to off, or to the safe state the accepted terms name. Read the
   switch before the risky work starts, never after a side effect.
3. List every path the change adds: request handler, background job, event
   consumer, scheduled work, migration step, retry, cache fill. Put the
   switch in front of each.
4. **REQUIRED SUB-SKILL:** invoke `test-driven-development` in this order:
   the on-state test, failing, then the new path that passes it; then the
   off-state test, which fails because the path still runs; then the switch,
   which passes it by restoring the prior behaviour.
5. Make turning it off change behaviour without a deploy: read the switch at
   runtime, never as a build-time constant. Record the exact off action.
6. Write the removal follow-up: an owner, and the condition after which the
   switch and the prior path are deleted.

## Step 3: Build the signals

1. For each new path, emit the signals the accepted thresholds read: the
   correctness or error outcome, safety (data integrity, security or privacy
   violations), latency or resource use, and the business or operational
   outcome the change exists to move. Liveness serves no threshold.
2. Emit through the project's existing telemetry facility, under its naming
   convention. Add no vendor, library, or dashboard tool.
3. Carry the switch state or cohort on every signal.
4. No secret, credential, token, or personal data in a signal's value or
   labels.
5. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for each signal:
   a test that fails when the signal is missing or carries the wrong state.
6. Confirm the baseline source exists: the prior behaviour is already
   measured where the thresholds compare, or the off cohort supplies it. If
   there is no baseline, write that in the record; do not invent a number.

## Step 4: Record and hand off

1. Open `assets/rollout-record.md` before filling it, and fill every section:
   policy source, switch, guarded paths, signals, baseline, kill action with
   who may pull it, removal follow-up. If the terms were drafted, add the
   acceptance row to the ledger beside the record: who accepted, when, and
   the terms they saw. Terms copied from a policy need no row.
2. Report three lines and decide nothing:

   ```text
   Switch: {{name}}, default {{state}}, guards {{n}} paths, off-state test {{path}}
   Signals: {{n}} emitted, {{n}} thresholds served, baseline {{source | none}}
   Policy: {{from policy, source | accepted by whom, when | declined}}
   ```

3. Continue the ordinary chain to verification, review, and the branch
   decision unchanged. **REQUIRED SUB-SKILL:** at the release step, invoke
   `release-readiness` with the record; it binds the policy and the signals.
   The first flip in a shared environment, every stage expansion, and every
   abort run under the authority the accepted terms name, never from here.

## Gotchas

- A switch read inside the new path, after the side effect it should guard,
  is a switch in name only — shows when the off-state test passes on the
  response while the job the handler enqueued still ran.
- A switch on the request path leaves the consumer, the scheduled job, and
  the migration step the same change added running in both states — shows
  when the off cohort's signals keep moving after the switch is pulled.
- A signal without the switch state blends both cohorts into one series, so
  the baseline is the new behaviour — shows when the record's comparison
  names a metric the off cohort emits under the same labels.
- A written draft reads like a policy once it sits in the record — shows
  when the release decision binds "the policy in the rollout record" with no
  acceptance row in its ledger.
- A build-time flag turns off by redeploying — shows when the record's off
  action is the rollback the switch was meant to avoid.

## Common mistakes

- Refactoring or deleting the prior path while adding the switch, so off
  no longer means before: keep the prior path reachable, unchanged,
  until the removal follow-up runs.
- Lowering a draft threshold so the first stage can pass: thresholds are the
  owner's; a stage that cannot meet them is a finding for the owner.
- Flipping the switch on in a shared environment to see it work: the test
  suite and a local run are where it is exercised; the first shared flip is
  the owner's action after the release decision.
