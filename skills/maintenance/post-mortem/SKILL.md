---
name: post-mortem
description: "Use after a production escape, late defect, data loss, outage, security incident, or badly failed work cycle, once the technical cause and containment are known and the open question is why the safeguards missed it or why the impact grew. Fires on how did this reach production, why didn't we catch this, and what do we change so it doesn't happen again, even if nobody says post-mortem. Skip while the technical cause is still unknown, and skip ordinary bugs."
---

# Post-Mortem

Explain why the failure escaped or grew, then measure whether each corrective
control reduces recurrence, detection, or impact risk. Take the code-level
cause from `debugging`; do not re-derive it. Close on deployed and falsified
controls, never on reflection.

## When to use

- A failure reached users/production, escaped far downstream, caused material
  loss, or exposed a process failure worth correcting.
- **Skip** an ordinary reproduced bug. Begin after the code-level cause and
  immediate containment are known; if the cause is still unknown, invoke
  `debugging` first.

## Step 1: Control the record

1. Open `assets/post-mortem-template.md`. Fill `Control and evidence
   handling` first: readers, lifetime, redaction, expected reviewers and
   approver rules.
2. Fill `Summary and impact` and `Timeline` from artifacts, not memory. Mark
   every time `observed` or `estimated`.

## Step 2: Find the structural cause

1. Fill `Root cause and contributing conditions`: paste the code-level cause
   from `debugging`, then each condition that made introduction or impact
   more likely. Name conditions, never a person. Keep several conditions
   separate.
2. Fill `Escape-path audit`: freeze the gate and surface inventory with its
   source digest, then mark each entry `missing / too weak / skipped / stale /
   failed but ignored / held`, with an accountable disposition per omission.
3. Fill `Risk-reduction claim` per action: prevent, detect earlier, limit
   blast radius, or recover faster, with baseline, target, horizon, residual
   risk. Never claim recurrence is impossible.

## Step 3: Propose and get the actions accepted

1. Write each corrective action as `proposed`, mapped to a structural cause,
   every action-row field filled.
2. Present and end the turn:

   ```text
   Post-mortem {{identifier}}
   Impact: {{one line}}  Structural cause: {{one line}}  Escaped gate: {{one line}}
   Actions: {{each with owner and date}}

   1. Accept the actions
   2. Request changes
   3. Reject the analysis
   4. Cancel

   Recommendation: {{the answer the evidence and ownership support}} — {{one sentence}}.
   ```

3. Move an action out of `proposed` only on a complete trusted receipt for
   the exact scope and dates. Record rejection, cancellation, or supersession
   with its residual risk and replacement.

## Step 4: Prove and track the controls

1. Falsify every corrective gate you implement. Fill `Targeted fail-then-pass
   proof` with raw evidence: fails on the captured incident or a
   representative bad case, passes on the good control, pre-fix version did
   not catch it.
2. Track each control to an identity-bound receipt from the surface that
   enforces it: CI, runtime, review, release, alerting, recovery. Never infer
   from a summary.
3. **REQUIRED SUB-SKILL:** invoke `verification-strategy` for any change to
   the battery itself. Add no duplicate gate nobody owns.
4. At the predeclared date, compare baseline against target and check the
   gate ran. Write `effective`, `ineffective`, or `inconclusive`. Reopen on
   either of the last two unless the exact approver rule accepts closure with
   residual risk.
5. Issue the immutable analysis with its `External lifecycle ledger` to the
   user-set path or the template default, under current storage authority.
   In-repository record → a new candidate. Later events → append to the
   ledger; never edit the issued analysis.

## Action states

Record in the external ledger `proposed → {owner-accepted | rejected |
cancelled | superseded}`, and for accepted:
`implemented → falsified → deployed/enforced → effectiveness reviewed → effective → closed`.
Let no prose, merge, or local green skip a state.

## Common mistakes

- A tidy memory-based story with missing raw evidence.
- “Human error” or “reviewer missed it” instead of the conditions and absent
  gate that allowed the action to escape.
- A training/promise action with no observable enforcement or effectiveness
  measure.
- A regression test that was never shown to fail on the incident case.
- Closing when code merges rather than when the control is enforced and reviewed.
- Publishing sensitive incident artifacts without access and retention controls.
