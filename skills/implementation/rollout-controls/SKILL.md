---
name: rollout-controls
description: "Builds the switch and the signals a controlled rollout needs into a change before it ships: a flag or kill switch that defaults off and guards every path the change adds, and the telemetry the rollout's thresholds read. Use when the project's release policy, the plan, or the user calls for a feature flag, kill switch, canary, or staged rollout, or when release readiness blocked a change on a missing rollout policy or missing rollout signals. Skip a change nobody asked to stage, and skip a migration or high-risk transformation whose own contract already owns its rollout."
---

# Rollout Controls

Put the switch and the signals into the change while it is still being built,
under terms its owner has accepted, so the release decision can bind a policy
instead of inventing one. This skill never decides the release, flips the
switch in a shared environment, or expands a rollout.

## When to use

- The project's release policy or instructions file requires a staged or
  controlled rollout for this kind of change.
- The plan or the user asks for a feature flag, kill switch, canary, or
  staged rollout.
- `release-readiness` blocked this change on a missing rollout policy or on
  rollout signals that measure nothing the policy reads.
- **Skip** a change nobody asked to stage. `yagni` forbids a flag nobody asked
  for, and a change that reaches users in one ordinary deploy needs none.
- **Skip** a rewrite, migration, or other high-risk transformation:
  `migration-strategy` owns its cutover, pause, abort, and rollback, and
  `verification-strategy` owns the gates its stages pass. Say which one owns
  it. A bounded feature built inside that work still comes here for its own
  switch.

## Step 1: Find the policy, or draft one for its owner

1. Read the project's release or rollout policy, its instructions file, and
   its conventions: the flag facility, metric names, dashboards, cohort
   definitions. Record the document and version you read.
2. A policy exists → copy its terms for this change: mechanism, target state,
   cohort stages, baseline source, success and abort thresholds, minimum
   observation, kill or rollback action, authority. A term it leaves unsaid
   is a question for its owner, not a value to fill in.
3. No policy, or a term unsaid → draft the missing terms from the change's
   risk and the project's existing telemetry, and put the draft to the
   release or decision owner:

   ```text
   Rollout terms for {{change}} — a draft; not policy until accepted
   Mechanism: {{flag | canary | partition | staged publication | phased rollout}}
   Target state: {{what full rollout looks like}}
   Cohorts: {{stage 1 → stage n, each with its selection rule}}
   Baseline: {{the signal source and window the cohorts compare against}}
   Success / abort thresholds: {{one line per signal}}
   Minimum observation: {{duration or volume per stage}}
   Kill / rollback action: {{the exact action and who may take it}}
   Authority: {{who may expand a stage; who may abort}}

   1. Accept these terms as the rollout policy for this change
   2. Change a term (say which)
   3. Decline — ship without a staged rollout

   Recommendation: 1 — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print
   this block; end the turn; `clarifying-intent` owns what closes it.
4. Option 2 → revise, keep the earlier terms visible, and re-present. Option
   3 → record the decline and stop; this skill ends here. An unaccepted draft
   is not a policy: build nothing against it.

## Step 2: Build the switch

1. Use the flag or configuration facility the project already has. None →
   the smallest runtime configuration read the project already performs, and
   name it in the record. Add no library.
2. Default off, or the safe state the accepted terms name. Read the switch
   before the risky work starts, never after a side effect.
3. List every path the change adds: request handler, background job, event
   consumer, scheduled work, migration step, retry, cache fill. Put the
   switch in front of each. A path the switch does not guard is a rollout the
   policy cannot stop.
4. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for both states:
   one test that the on state does the new work, one that the off state
   restores the prior behaviour, each failing first. The off-state test is
   the kill switch's proof.
5. Turning it off changes behaviour without a deploy: a runtime read, not a
   build-time constant. Record the exact off action.
6. Write the removal follow-up: an owner, and the condition after which the
   switch and the prior path are deleted.

## Step 3: Build the signals

1. For each new path, emit the signals the accepted thresholds read: the
   correctness or error outcome, latency or resource use, and the business or
   operational outcome the change exists to move. Liveness serves no
   threshold.
2. Emit through the project's existing telemetry facility, under its naming
   convention. Add no vendor, library, or dashboard tool.
3. Carry the switch state or cohort on every signal, so the on and off
   cohorts can be compared against the baseline.
4. No secret, credential, token, or personal data in a signal's value or
   labels.
5. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for each signal:
   a test that fails when the signal is missing or carries the wrong state.
6. Confirm the baseline source exists: the prior behaviour is already
   measured where the thresholds compare, or the off cohort supplies it. No
   baseline → write that in the record; do not invent a number.

## Step 4: Record and hand off

1. Open `assets/rollout-record.md` before filling it, and fill every section:
   policy source and acceptance, switch, guarded paths, signals, baseline,
   abort and kill action with who may pull it, removal follow-up.
2. Report three lines and decide nothing:

   ```text
   Switch: {{name}}, default {{state}}, guards {{n}} paths, off-state test {{path}}
   Signals: {{n}} emitted, {{n}} thresholds served, baseline {{source | none}}
   Policy: {{accepted by whom, when | draft declined}}
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

- Refactoring or deleting the prior path while adding the switch, so off no
  longer means before → keep the prior path reachable, unchanged, until the
  removal follow-up runs.
- Lowering a draft threshold so the first stage can pass → thresholds are the
  owner's; a stage that cannot meet them is a finding for the owner.
- Flipping the switch on in a shared environment to see it work → the test
  suite and a local run are where it is exercised; the first shared flip is
  the owner's action after the release decision.
