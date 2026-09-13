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

## A subagent's word

A subagent reporting "done" or "tests pass" is giving you a claim, not evidence. Verify it independently: read the actual diff (did the files really change?) and the actual check output. Treat the report as a hypothesis to confirm, never as the proof itself.

## Inherited premises

A conclusion is only as verified as what it rests on. Before stating one, list the facts it depends on and mark each: confirmed *this session*, or inherited from earlier or elsewhere. If the conclusion would change should an inherited fact be wrong, re-verify that fact first. Stale string matches and untested assumptions are the usual culprits.

## Evidence is not all equal

Strongest to weakest: a log of the check actually running > a rubric or checklist you ticked > a bare assertion. When the right check can't be run deterministically (visual or subjective behavior), a written rubric is the fallback — and flag it as the weaker evidence it is.
