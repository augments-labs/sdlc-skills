---
name: visual-ui-verification
description: "Verifies a running interface visually across states, viewports, themes, and input paths. Use when a UI-bearing change is about to be called visually correct, done, or ready to ship, when acceptance depends on how a running GUI or TUI looks or responds, or on does this look right, is the UI done, or check the screen. Skip isolated widget snapshots, nonvisual behavior, and open design decisions."
---

# Visual UI Verification

Drive the integrated interface, keep every frame, calibrate the inspection on
a deliberately broken frame, and return a row-by-row verdict bound to the
state under check. Never return "looks good".

## When to use

- A running GUI or TUI must be judged before acceptance or release.
- A claim depends on integrated layout, rendering, or visible interaction state.
- **Skip** isolated component or snapshot checks and purely nonvisual
  behavior.
- If the flow or visual direction is unsettled, route it to `ui-ux-design`
  before verifying it.

## Step 1: Bind the target

1. Open `assets/evidence-record.md`. Fill the `Run` header before any capture.
2. Write the state under check as an immutable source or artifact identity,
   or as the working-tree hash `verification-before-completion` captures,
   which covers staged, unstaged, and untracked non-ignored paths only. List
   the ignored inputs the launch path reads (build output, generated assets,
   local configuration) with
   `git ls-files --others --ignored --exclude-standard -- {{input paths}}`,
   and record each one's path and SHA-256 under `Ignored inputs`. Recompute
   those hashes before the verdict; if one has changed, every pass captured
   before that change is invalid. Keep the record outside that identity.
3. Establish whether an approved design applies. If plan-bound, the task's
   `Context` and `Applicable visual references` say. Otherwise check
   `.sdlc-skills/designs/` and any user-set design path, and record what you
   checked.

   - If uncertain, the verdict is pending.
   - If no approved design exists and the direction is settled, record in
     `Acceptance source` which observation source you took: the acceptance
     criteria of the spec, the task, or the settling request, or a rendering
     of the pre-change revision captured in its own workspace under Step 2's
     matrix.
   - If an approved design exists, read the approved design itself: flows,
     states, conditions, decisions and acceptance checks. Map each applicable
     obligation to a required observation or to the other check that owns
     it; a preview is only part of that contract. Copy its **Selected
     visual references** field for field, filling `Approved design artifact
     version` with the design's identity from its ledger row. If plan-bound,
     match the obligations and references to their tasks and conformance
     evaluators.
4. Run each selected reference's Freshness evaluator:
   - On `pass`, capture.
   - On `mismatch`, restore the binding and rerun, or obtain a design
     successor (plus a plan successor when plan-bound).
   - On `unavailable` or `error`, the verdict is pending until repaired and
     rerun.
5. If source, field, or obligation coverage is missing, the verdict is
   pending. The recorded no-design source counts as the source. A design with
   no compared visual reference still has its approved UI obligations.

## Step 2: Capture

1. Build the smallest matrix that can decide the verdict: journeys and states
   crossed with viewport, theme, input method, platform, and content
   pressure. Include the empty, loading, error, overflow, and no-permission
   states the UI contract contains. Record a decision for each omission.
2. Drive the real interface through its real input boundary. For a GUI,
   capture screenshots or recordings. For a TUI, use a PTY at the declared
   dimensions and a VT-capable renderer, and keep the raw terminal stream and
   the rendered frame.
3. End each row at a stable, named observation, not at a successful launch.
4. Write one `Scenario matrix` row per observation: hash the raw bytes and
   the rendered media, record the capture tool and the row's inputs.
5. Never overwrite an earlier frame. Keep retries, duplicates, late output,
   and superseded frames, and record a decision for each. Each required row
   has one accepted result.

## Step 3: Calibrate, then inspect

1. Fill `Calibration` before any pass: freeze the rubric and observer.
2. Produce one deliberately broken frame with a reversible fault or a
   known-bad fixture outside the state under check. Confirm the same
   inspection marks it red.
3. Restore the probe. Record the receipts for the red and for the
   restoration. If the probe is unsafe or was missed, this check is pending.
4. Inspect every frame with a media-capable observer against the accepted UI
   criteria: hierarchy, legibility, clipping and overflow, focus, contrast,
   content extremes, state feedback, visible recovery controls.
5. Judge the finished state under check against every mapped design
   obligation and selected reference. Matching the preview does not pass an
   untested flow, recovery state or condition. An unapproved layout or
   interaction fails, however polished, unless an approved successor replaces
   the binding.
6. File each defect in `Defects`: severity, requirement violated, matrix row
   and frame, impact, reproduction.
7. For a human-owned criterion or exception, follow
   `verification-before-completion`'s manual-acceptance contract. Only its
   trusted user-origin receipt passes that row.

## Step 4: Fix and verdict

1. Edit nothing from this skill. Route each fix through
   `test-driven-development` and `yagni` under the authority that covers it.
2. Recapture the fixed row and its affected neighbors. Keep the before and
   after evidence. Any change to the state under check, or an environment
   change that could alter the render, invalidates the affected passes.
3. Write the `Verdict`. Pass only when all four hold: the calibrated probe was
   caught and restored; every required row was captured and inspected; there
   is no blocking defect; every human-owned row has its trusted receipt.
   Otherwise the verdict is fail or pending.
4. Return the verdict to the skill that requested it. Authorize no
   acceptance, integration, or promotion here.
5. When the project battery is being established, add this check as a row
   in `verification-strategy`'s matrix with its own cells, action, evidence,
   owner, cadence, promotion, and failure response.
6. For a release, take a fresh verdict against the exact immutable artifact.
   A verdict on source or a working tree is acceptance evidence only.

## Gotchas

- A UI fix with no design artifact reads as a missing source, and the verdict
  stays pending for good unless the acceptance criteria or a pre-change
  rendering is recorded as the source.
- A "pre-change" rendering captured from the edited workspace is the state
  under check itself, and it compares the change with itself.
- A working-tree hash leaves ignored paths out, so a rebuilt bundle or changed
  local configuration renders a different screen under the same hash; only
  the recorded per-path hashes show that the pass is stale.

## Common mistakes

- Calling subjective preference a defect when the design direction is unsettled.
