---
name: visual-ui-verification
description: "Checks a running interface visually across states, viewports, themes, and input paths before it is called correct. Use when a page, screen, view, or other UI-bearing change is about to be declared visually correct, done, or ready to ship, when acceptance or release depends on how a running GUI or TUI looks or responds, or on questions such as does this look right, is the UI done, or check the screen, even if nobody asks for a visual check. Skip isolated widget or snapshot assertions, nonvisual behavior, and open design decisions."
---

# Visual UI Verification

Drive the integrated interface, retain every frame, calibrate the inspection
on a deliberately broken frame, and return a row-by-row verdict bound to the
candidate. Never return "looks good".

## When to use

- A running GUI or TUI must be judged before acceptance or release.
- A claim depends on integrated layout, rendering, or visible interaction state.
- **Skip** isolated component/snapshot checks and purely nonvisual behavior.
- Route unsettled flow or visual direction to `ui-ux-design` before verifying it.

## Step 1: Bind the target

1. Open `assets/evidence-record.md`. Fill the `Run` header before any capture.
2. Write the candidate as an immutable source or artifact identity, or a
   working-tree digest covering staged, unstaged, untracked, and relevant
   ignored inputs. Keep the record outside that identity.
3. No approved design exists and the direction is settled → take the
   observation source from the spec's or task's acceptance criteria, or from a
   pre-change rendering captured under the same matrix before the edit, and
   record which one in `Acceptance source`. An approved design exists → read
   the approved design itself: flows, states, conditions, decisions and
   acceptance checks. Map each applicable obligation to a required observation
   or its other owning gate; a preview is only part of that contract. Copy its
   **Selected visual references** field for field. Plan-bound: match the
   obligations and references to their tasks and conformance evaluators.
4. Run each Freshness evaluator:
   - `pass` → capture
   - `mismatch` → restore the binding and rerun, or obtain a design successor
     (plus a plan successor when plan-bound)
   - `unavailable` or `error` → verdict pending until repaired and rerun
5. Missing source, field, or obligation coverage → verdict pending. The
   recorded no-design source counts as the source. A design with no compared
   visual reference still has its approved UI obligations.

## Step 2: Capture

1. Build the smallest deciding matrix: journeys and states × viewport, theme,
   input method, platform, content pressure. Include empty, loading, error,
   overflow, and no-permission states the UI contract contains. Disposition
   omissions.
2. Drive the real interface through its real input boundary. GUI: screenshots
   or recordings. TUI: a PTY at the declared dimensions and a VT-capable
   renderer; retain the raw terminal stream and the rendered frame.
3. End each row at a stable, named observation, not at a successful launch.
4. Write one `Scenario matrix` row per observation: hash the raw bytes and
   the rendered media, record the capture tool and the row's inputs.
5. Never overwrite an earlier frame. Retain and disposition retries,
   duplicates, late output, and superseded frames. One accepted result per
   required row.

## Step 3: Calibrate, then inspect

1. Fill `Calibration` before any pass: freeze the rubric and observer.
2. Produce one deliberately broken frame with a reversible fault or known-bad
   fixture outside the candidate. Confirm the same inspection marks it red.
3. Restore the probe. Record the red and restoration receipts. Unsafe or
   missed probe → gate pending.
4. Inspect every frame with a media-capable observer against the accepted UI
   criteria: hierarchy, legibility, clipping and overflow, focus, contrast,
   content extremes, state feedback, visible recovery controls.
5. Judge the finished candidate against every mapped design obligation and
   selected reference. Matching the preview does not pass an untested flow,
   recovery state or condition. An unapproved layout or interaction fails,
   however polished, unless an approved successor replaces the binding.
6. File each defect in `Defects`: severity, requirement violated, matrix row
   and frame, impact, reproduction.
7. Human-owned criterion or exception: follow `verification-before-completion`'s
   manual-acceptance contract. Only its trusted user-origin receipt passes
   that row.

## Step 4: Fix and verdict

1. Edit nothing from this skill. Route each fix through
   `test-driven-development` and `yagni` under the authority that covers it.
2. Recapture the fixed row and its affected neighbors. Keep before and after
   evidence. Any candidate or material environment change invalidates
   affected passes.
3. Write the `Verdict`. Pass only when all four hold: calibrated probe caught
   and restored; every required row captured and inspected; no blocking
   defect; every human-owned row has its trusted receipt. Otherwise fail or
   pending.
4. Return the verdict to the skill that requested it. Authorize no
   acceptance, integration, or promotion here.
5. Establishing the project battery: add this gate as a row in
   `verification-strategy`'s matrix with its own cells, action, evidence,
   owner, cadence, promotion, and failure response.
6. Release: take a fresh verdict against the exact immutable artifact. A
   verdict on source or a working tree is acceptance evidence only.

## Gotchas

- A UI fix with no design artifact reads as a missing source, and the verdict
  stays pending for good unless the acceptance criteria or a pre-change
  rendering is recorded as the source.
- A "pre-change" rendering captured after the edit is the candidate itself,
  and it compares the change with itself.

## Common mistakes

- Treating widget snapshots as integrated-app evidence.
- Capturing frames without driving interactions or retaining raw identity.
- Overwriting failed frames with re-shots or storing evidence in the candidate.
- Calling subjective preference a defect when the design direction is unsettled.
- Returning “looks good” without a calibrated rubric and row-by-row verdict.
