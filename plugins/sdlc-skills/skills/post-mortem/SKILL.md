---
name: post-mortem
description: "Use after a production escape, late defect, data loss, outage, security incident, or badly failed work cycle, once the immediate technical cause and containment are known and the open question is why the safeguards missed it or why the impact grew. Fires on how did this reach production, why didn't we catch this, and what do we change so it doesn't happen again, even if nobody says post-mortem. Skip while the technical cause is itself still unknown, and skip ordinary bugs."
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

## Procedure

1. **Fill `Control and evidence handling` in `assets/post-mortem-template.md`
   before writing any finding:** who may read the record, how long it
   survives, redaction, and the expected reviewers and approver rules. Decide
   this before the record concentrates logs, traces, and user data.

2. **Reconstruct `Summary and impact` and `Timeline` from artifacts, not
   memory.** Mark every time as observed or estimated; never let an estimate
   read as a measurement.

3. **Fill `Root cause and contributing conditions`:** paste the code-level
   cause from `debugging`, then write each condition that made introduction or
   impact more likely. Name conditions, never a person, and keep several real
   conditions separate instead of collapsing them into one tidy cause.

4. **Fill `Escape-path audit`.** Freeze the expected gate and surface
   inventory with its source digest, then write for each entry
   `missing / too weak / skipped / stale / failed but ignored / held`, and an
   accountable disposition for every omission.

5. **Fill `Risk-reduction claim` for each action:** which it buys — prevent,
   detect earlier, limit blast radius, or recover faster — with baseline,
   target, horizon, and residual risk. Never claim recurrence is impossible.

6. **Write each corrective action as `proposed`,** mapped to a structural
   cause, with every field the template's action rows require. Then present
   the analysis path, impact, structural cause, escaped gate, and each action
   with owner and date. Ask one conversational question offering: accept the
   actions, request changes, reject the analysis, or cancel. Recommend the
   answer the evidence and action ownership support, with one sentence of
   reasoning, then stop.

   Move an action out of `proposed` only on a complete trusted receipt
   accepting the exact scope and dates. Record rejection, cancellation, or
   supersession with its residual risk and replacement.

7. **Falsify every corrective gate you implement.** Fill `Targeted
   fail-then-pass proof` with raw evidence that the gate fails on the captured
   incident or a representative bad case, passes on the good control, and
   that the pre-fix version did *not* catch it.

8. **Track each control to enforcement on an identity-bound receipt** from
   the surface that will really enforce it — CI, runtime, review, release,
   alerting, or recovery. Never infer success from a summary. **Invoke
   `verification-strategy`** for any change to the battery itself; do not add
   a duplicate gate nobody owns.

9. **At the predeclared date, review effectiveness:** compare baseline
   against target and check the gate actually ran. Write effective,
   ineffective, or inconclusive; reopen the action on either of the last two
   unless the exact approver rule accepts closure with residual risk.

10. **Issue the immutable analysis alongside its `External lifecycle
    ledger`,** writing to the user-set path, or the template's default, only
    under current storage authority. Treat an in-repository record as a new
    candidate. Never edit an issued analysis to record something that happened
    later; append to the ledger.

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
