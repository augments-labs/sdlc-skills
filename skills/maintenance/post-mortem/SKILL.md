---
name: post-mortem
description: "Explains why safeguards missed a production escape, incident, loss, or failed work cycle, or why its impact grew, and what prevents it happening again. Use when a production escape, incident, material loss, or failed work cycle has been contained, or when the user asks how this reached production or what prevents another failed handoff. Establish any technical cause and immediate containment first; a process-only failure needs its event evidence. Skip ordinary bugs and ongoing uncontained impact."
---

# Post-Mortem

Explain why the failure escaped or grew, then measure whether each corrective
control reduces recurrence, detection, or impact risk. Take the code-level
cause from `debugging`; do not re-derive it. Close on deployed and falsified
controls, never on reflection. For a process-only failure, use the observed
event and decision trail; do not invent a code defect to enter this skill.

## When to use

- A failure reached users/production, escaped far downstream, caused material
  loss, or exposed a process failure worth correcting.
- **Skip** an ordinary reproduced bug. For technical incidents, establish the
  technical cause and immediate containment first; unknown technical cause →
  `debugging`. A process-only failure begins from its evidenced events.

## Step 1: Control the record

1. Open `assets/post-mortem-template.md` when starting the analysis. Fill
   `Control and evidence handling` first: readers, lifetime, redaction,
   expected reviewers and approver rules.
2. Fill `Summary and impact` and `Timeline` from artifacts, not memory. Mark
   every time `observed` or `estimated`.

## Step 2: Find the structural cause

1. Fill `Root cause and contributing conditions`: cite the technical cause
   from `debugging` when applicable, or the process-failure evidence, then each
   condition that made introduction or impact
   more likely. Name conditions, never a person. Keep several conditions
   separate.
2. Fill `Escape-path audit`: freeze the gate and surface inventory with its
   source digest, then mark each entry `missing / too weak / skipped / stale /
   failed but ignored / held`, with an accountable disposition per omission.
3. Fill `Risk-reduction claim` per action: prevent, detect earlier, limit
   blast radius, or recover faster, with baseline, target, horizon, residual
   risk. Never claim recurrence is impossible.
4. Challenge the draft. Dispatch the template's independent escape-path
   challenger per `dispatching-parallel-agents` Step 2; a material incident
   without one needs the omission the `Expected reviewers` field requires.
   Disposition every finding.
5. Issue the immutable analysis with its `External lifecycle ledger` to the
   user-set path or the template's path, under current storage authority, and
   record its identity per the template. In-repository record → a new candidate.

## Step 3: Propose and get the actions accepted

1. Write each corrective action as `proposed`, mapped to a structural cause,
   every action-row field filled.
2. Present:

   ```text
   Post-mortem {{identity}} — {{path}}
   Impact: {{one line}}  Structural cause: {{one line}}  Escaped gate: {{one line}}
   Actions: {{each with owner and date}}

   1. Accept the actions
   2. Request changes
   3. Reject the analysis
   4. Cancel

   Recommendation: {{the answer the evidence and ownership support}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `interview-me` owns what closes it.
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
5. Append every action state, proof, rollout result, and effectiveness verdict
   to the ledger; never edit the issued analysis.

## Action states

Record in the external ledger `proposed → {owner-accepted | rejected |
cancelled | superseded}`, and for accepted:
`implemented → falsified → deployed/enforced → effectiveness reviewed → effective → closed`.
Let no prose, merge, or local green skip a state.

## Gotchas

- An escape-path audit taken from today's gate list instead of the frozen
  inventory pinned to its source digest can end up describing the battery
  after the fix already landed — which makes every gate look fine and the
  audit worthless.
- A `Risk-reduction claim` of "prevent" with no baseline, target, or horizon
  can never be marked `effective` or `ineffective` at the review date — only
  `inconclusive`, permanently.

## Common mistakes

- “Human error” or “reviewer missed it” instead of the conditions and absent
  gate that allowed the action to escape.
- Publishing sensitive incident artifacts without access and retention controls.
