# Verification Before Completion — Hollow Verification

A check can pass and still prove nothing. The ways that happens, and how to catch them.

## A gate that was never falsified

New-behavior tests should fail for the missing behavior before implementation.
Preservation gates instead begin green, then detect a deliberate divergence in
an isolated authorized copy with exact effect/recovery controls before complete
candidate/data/effect restoration. A bug reproduction fails on
the before state and passes on the fixed state.

Never undo inherited work or inject a defect into production just to manufacture
red. When direct mutation is unsafe, use a retained known-bad case or controlled
calibration fixture. Without falsification evidence, call the gate uncalibrated
and limit the claim it supports.

## Inherited premises

Before stating a conclusion, list the facts it depends on and mark each: confirmed *this session*, or inherited from earlier or elsewhere. If the conclusion would change should an inherited fact be wrong, re-verify that fact first. Stale string matches and untested assumptions are the usual culprits.
