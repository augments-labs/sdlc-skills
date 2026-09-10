---
name: verification-strategy
description: "Use to establish or repair a project's correctness battery, before high-risk work whose assurance is absent, stale, or unfalsifiable, and again on changed risk, an escaped defect, or a hollow gate. Fires on how should we test this project, our tests don't catch anything, and what should CI run, even if nobody says strategy. Skip a bounded feature, and skip writing or running an already-defined gate."
---

# Verification Strategy

Map the project's real risks to gates, watch each gate fail before calling it
executable, and wire it to block the promotion it protects. Accept no gate on
reading the code, a coverage number, or the builder's opinion.

## When to use

- The project floor is absent, stale, or cannot catch a real defect.
- A high-risk initiative introduces preservation, platform, data, security,
  concurrency, resource, or rollout risks the current battery does not cover.
- **Skip** a bounded feature — its plan evaluators and TDD own the local proof.
  A missing project floor is separate scope.

## Step 1: Map the risks before writing any gate

1. Inventory what the project promises and what could break it: committed
   behaviour, platforms and build modes, data and operations, commands and CI
   that already run, existing tests, escaped defects.
2. Transformation: add its migration facts, invariants, and approved
   deviations.
3. Instantiate `assets/assurance-matrix.md` now. Fill `Risk inventory` and
   `Risk-to-gate matrix`. Write no gate code before this exists.
4. Fill `Catalogue disposition` for every category in
   `references/battery-catalogue.md`: covered, or an accountable expiring
   approval plus a compensating gate. N/A needs evidence and an owner.

## Step 2: Make each gate real

1. Fill `Cadence and promotion map`: cheap gates block every change;
   expensive ones protect a phase, trial, cutover, or release.
2. A "manual" gate gets a procedure, evidence, an owner, and a promotion it
   blocks.
3. Calibrate in isolation you are authorized to use: bind what the gate
   touches and your authority to mutate, recover, and clean up.
4. Watch the whole cycle: green → red on an introduced divergence → full
   restoration → green. Keep raw results outside the candidate.
5. Unsafe to calibrate for real: use a known-bad fixture, or mark the gate
   `uncalibrated` and say so.
6. Record each gate as `executable`, `planned`, or `blocked`. Only
   `executable` satisfies an entry condition.
7. One bounded gate to implement: invoke `test-driven-development`.
   Multi-step gate work: invoke `writing-plans`.

## Step 3: Protect the battery from its own erosion

1. Fill `Control-plane independence` and `Test-inventory audit`.
2. Keep the inventory, the validator, and the wiring *outside* the tests they
   protect.
3. A mutable plane that would guard its own invocation: record its promotion
   as `planned` or `blocked` until external enforcement exists.

## Step 4: Challenge, then hand over the decision

1. **REQUIRED SUB-SKILL:** invoke `requesting-code-review` with the prompt in
   `references/assurance-challenger.md`, before approval. Keep the candidate
   read-only.
2. Blocker: correct a successor, reverify, rechallenge until clear or
   concretely blocked.
3. Present the matrix and stop:

   ```text
   Assurance matrix {{path}} — {{n}} executable, {{n}} planned, {{n}} absent
   Thresholds: {{list}}. Omissions: {{list}}. Blocking cadence: {{summary}}.

   1. Approve the battery
   2. Request changes
   3. Reject the strategy
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

4. Approve nothing yourself. Authority to draft gates is not authority to
   accept unseen risks, thresholds, omissions, or exceptions.
5. Keep the normative file at `proposed`; lifecycle state stays external.
   Every normative change is an exact-delta successor.

## Hard stops

**Calling a control executable when it is not**

- It is only planned, or only prose.
- It has never been run.
- It has never been watched fail.

**Writing gate code before the matrix and catalogue dispositions exist** — including when the gate is small enough to stay inline.

**A gate that cannot fail for the right reason**

- A presence or change detector: it goes red without any behaviour being protected.
- An aggregate green that hides a platform, a build mode, a shard, a test, or a cadence that never ran.
- A wildcard match, a file's presence, a set or count comparison, a named receipt, a success marker, or an outer timeout, presented as proof that an exact case or action occurred.

**Calling the battery established** before removing, skipping, duplicating, or hollowing a test turns the project command red under an independent guard — and restoring it returns green.

**Self-protection that protects nothing**

- A validator living only inside the tree it discovers.
- A mutable command asked to guard its own invocation. Without external wiring, that promotion stays `planned` or `blocked`.

**Taking authority you were not given**

- Deferring the independent challenge until after approval.
- Granting yourself an exception.
- Approving work the decision owner has not seen.
- Writing lifecycle state into a normative candidate.

**Lowering a threshold, deleting a test, or accepting a deviation to make the matrix green.**
