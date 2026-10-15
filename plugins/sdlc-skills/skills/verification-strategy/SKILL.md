---
name: verification-strategy
description: "Designs or repairs a project's correctness battery: which checks catch which defects and when they run. Use when a project's assurance is absent, stale, or unfalsifiable before high-risk work, when risk changes, after an escaped defect or a hollow gate, or when the user asks how to test this project, says the tests don't catch anything, or asks what CI should run. Skip a bounded feature, and skip writing or running an already-defined gate."
---

# Verification Strategy

Map the project's real risks to gates. A gate, the word the matrix and the
catalogue use for a check, is anything that must come back green before the
promotion it protects may go ahead; a promotion is a step the work takes, such
as a change landing, a phase, a trial, a cutover, or a release. Watch each gate
fail before calling it executable, and wire it to block the promotion it
protects. Accept no gate on reading the code, a coverage number, or the
builder's opinion.

## When to use

- The project floor is absent, stale, or cannot catch a real defect.
- A high-risk initiative introduces preservation, platform, data, security,
  concurrency, resource, or rollout risks the current battery (the set of
  gates a project or initiative runs, and the risks each one covers) does
  not cover.
- **Skip** a bounded feature: its plan's evaluators (the checks the plan
  names as the ones that must accept each task's result) and
  `test-driven-development` own the local proof. A missing project floor is
  separate scope.

## Step 1: Map the risks before writing any gate

1. Inventory what the project promises and what could break it: committed
   behaviour, platforms and build modes, data and operations, commands and CI
   that already run, existing tests, escaped defects.
2. For a transformation (a rewrite, a migration, or another broad change that
   must preserve behavior), add its migration facts, invariants, and approved
   deviations.
3. Start the matrix from `assets/assurance-matrix.md` before writing any
   gate. Fill `Risk inventory` and `Risk-to-gate matrix`.
4. Read `references/battery-catalogue.md` before filling `Catalogue
   disposition` (one recorded decision per category) for every category the
   catalogue lists. Each decision is one of two: covered, or an accountable
   expiring approval plus a compensating gate. An N/A needs evidence and an
   owner.

## Step 2: Make each gate real

1. Fill `Cadence and promotion map`: cheap gates block every change;
   expensive ones protect a phase, trial, cutover, or release.
2. A "manual" gate gets a procedure, evidence, an owner, and a promotion it
   blocks.
3. Calibrate each gate (show that it can fail, through the cycle the next
   step describes) in isolation you are authorized to use: pin down what the
   gate touches and your authority to mutate, recover, and clean up.
4. Watch the whole cycle: green, then red on an introduced divergence, then
   full restoration, then green. Keep raw results outside the state under
   check (the exact frozen state under judgment; the templates call it the
   candidate).
5. If calibrating for real is unsafe, use a known-bad fixture, or mark the
   gate `uncalibrated` and say so.
6. Record each gate as `executable`, `planned`, or `blocked`. Only
   `executable` satisfies an entry condition.
7. To implement one bounded gate, invoke `test-driven-development`. For gate
   work that takes more than one step, invoke `writing-plans`.

## Step 3: Protect the battery from its own erosion

1. Fill `Control-plane independence` and `Test-inventory audit`.
2. Keep the inventory, the validator, and the wiring *outside* the tests they
   protect.
3. If a mutable control plane would guard its own invocation, record its
   promotion as `planned` or `blocked` until external enforcement exists.

## Step 4: Challenge, then hand over the decision

1. Fill `assets/assurance-challenger.md` with `assets/assurance-report.md` before
   the challenge; the report file is the challenger's report template.
   **REQUIRED SUB-SKILL:** invoke `requesting-code-review` with this
   addendum (the filled challenger prompt), before approval. Keep the state
   under check read-only. Read the returned assurance section. If its Matrix
   version is missing or mismatched, or its verdict is anything other than
   `clear`, approval is blocked.
2. On a blocker, correct a successor (a replacement that names the version
   it replaces), reverify, and rechallenge until clear or concretely blocked.
3. Present the matrix:

   ```text
   Assurance matrix {{path}} — {{n}} executable, {{n}} planned, {{n}} absent
   Thresholds: {{list}}. Omissions: {{list}}. Blocking cadence: {{summary}}.

   1. Approve the battery
   2. Request changes
   3. Reject the strategy
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
4. Approve nothing yourself. Authority to draft gates is not authority to
   accept unseen risks, thresholds, omissions, or exceptions.
5. Keep the matrix file's status at `proposed`.

## Gotchas

- Marking a catalogue category `N/A` with no evidence or owner leaves the
  exact silent gap the matrix exists to surface; it only relabels the gap
  instead of closing it.
- A gate that runs correctly and shows green still blocks nothing if it is
  wired to run only on demand. Being correct and sitting on a path no
  promotion can bypass are two different facts.

## Hard stops

**Calling a control executable when it is not**

- It is only planned, or only prose.
- It has never been run.
- It has never been watched fail.

**Writing gate code before the matrix and its catalogue decisions (the
`Catalogue disposition` rows) exist**, including when the gate is small enough
to stay inline.

**A gate that cannot fail for the right reason**

- A presence or change detector: it goes red without any behaviour being
  protected.
- An aggregate green that hides a platform, a build mode, a shard, a test, or
  a cadence that never ran.
- A wildcard match, a file's presence, a set or count comparison, a named
  receipt (a record that a case or action ran), a success marker, or an outer
  timeout, presented as proof that an exact case or action occurred.

**Calling the battery established** before removing, skipping, duplicating, or
hollowing a test turns the project command red under an independent guard, and
restoring it returns green.

**Self-protection that protects nothing**

- A validator living only inside the tree it discovers.
- A mutable command asked to guard its own invocation. Without external
  wiring, that promotion stays `planned` or `blocked`.

**Taking authority you were not given**

- Deferring the independent challenge until after approval.
- Granting yourself an exception.
- Approving work the decision owner has not seen.
- Writing lifecycle state into the matrix under check.

**Lowering a threshold, deleting a test, or accepting a deviation to make the
matrix green.**
