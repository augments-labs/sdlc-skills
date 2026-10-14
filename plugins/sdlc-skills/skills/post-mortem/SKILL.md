---
name: post-mortem
description: "Explains why safeguards missed a production escape, incident, loss, or failed work cycle, or why its impact grew, and what prevents it happening again. Use when a production escape, incident, material loss, or failed work cycle has been contained, or when the user asks how this reached production or what prevents another failed handoff. Establish any technical cause and immediate containment first; a process-only failure needs its event evidence. Skip ordinary bugs and ongoing uncontained impact."
---

# Post-Mortem

Explain why the failure escaped or grew, then measure whether each corrective
control reduces recurrence, detection, or impact risk. Take the code-level
cause from `debugging`; do not work it out again. Close on controls that are
deployed and falsified, never on reflection. For a process-only failure, use
the observed trail of events and decisions; do not invent a code defect to
enter this skill.

## When to use

- A failure reached users or production, escaped far downstream, caused real
  loss, or exposed a process failure worth correcting.
- **Skip** an ordinary reproduced bug. For a technical incident, establish the
  technical cause and immediate containment first; if the technical cause is
  unknown, invoke `debugging`. A process-only failure starts from the events
  its evidence shows.

## Step 1: Control the record

1. Open `assets/post-mortem-template.md` when starting the analysis. Fill
   `Control and evidence handling` first: readers, lifetime, redaction,
   expected reviewers, and approver rules.
2. Fill `Summary and impact` and `Timeline` from artifacts, not from memory.
   Mark every time `observed` or `estimated`.

## Step 2: Find the structural cause

1. Fill `Root cause and contributing conditions`: cite the technical cause
   from `debugging` when applicable, or the evidence of the process failure,
   then each condition that made the introduction or the impact more likely.
   Name conditions, never a person. When there are several conditions, keep
   them separate.
2. Fill `Escape-path audit`: freeze the inventory of gates and surfaces (a
   gate is a check that must accept a result before it may advance) with the
   hash of its source, then fill every column for each entry, and for each
   omission record a decision that someone is accountable for.
3. Fill every bullet of `Risk-reduction claim` for each action. Never claim
   that recurrence is impossible.
4. Challenge the draft. Fill `assets/escape-path-challenger.md` before
   dispatching it read-only as `dispatching-parallel-agents` Step 2 says. A
   serious incident without a challenger needs the omission the
   `Expected reviewers` field requires. Record a decision on every finding; a
   `findings` verdict blocks issuing the analysis until the corrected draft
   is challenged again.
5. Issue the analysis, which is never edited after issue, with its
   `External lifecycle ledger` (the ledger: add to it, never rewrite it; it
   sits outside the issued analysis), to the user-set path or the template's
   path, under the storage authority held now, and record its identity as the
   template says. If the record is in the repository, it is a new state under
   check (the exact state being judged).

## Step 3: Propose and get the actions accepted

1. Write each corrective action as `proposed`, mapped to a structural cause,
   with every field of its action row filled.
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

   Ask this and end the turn; `clarifying-intent` owns what closes it.
3. Move an action out of `proposed` only on a complete trusted receipt (proof,
   from a trusted source outside the state under check, that the action or
   decision really happened) for the exact scope and dates. Record a
   rejection, cancellation, or supersession with its residual risk and
   replacement.

## Step 4: Prove and track the controls

1. Falsify every corrective gate you implement. Fill `Targeted fail-then-pass
   proof` with raw evidence: it fails on the captured incident or a
   representative bad case, it passes on the good control, and the version
   before the fix did not catch it.
2. Track each control to a receipt bound to an identity, from the surface
   that enforces it: CI, runtime, review, release, alerting, recovery. Never
   infer from a summary.
3. **REQUIRED SUB-SKILL:** invoke `verification-strategy` for any change to
   the battery itself (the set of checks the project runs). Add no duplicate
   check nobody owns.
4. At the date declared in advance, compare the baseline against the target
   and confirm that the gate ran. Write `effective`, `ineffective`, or
   `inconclusive`. If it is `ineffective` or `inconclusive`, reopen, unless
   the exact approver rule accepts closure with the residual risk.
5. Append every action state, proof, rollout result, and effectiveness
   verdict to the ledger; never edit the issued analysis.

## Action states

Record in the external ledger, outside the issued analysis, each action's
move from `proposed` to one of `{owner-accepted | rejected | cancelled |
superseded}`, and, for an accepted action, from there through `implemented`,
`falsified`, `deployed/enforced`, `effectiveness reviewed`, `effective`, and
`closed`, in that order. Let no prose, merge, or local green skip a state.

## Gotchas

- An escape-path audit taken from today's list of gates instead of the frozen
  inventory pinned to its source hash can end up describing the battery after
  the fix already landed, which makes every gate look fine and the audit
  worthless.
- A `Risk-reduction claim` of "prevent" with no baseline, target, or horizon
  can never be marked `effective` or `ineffective` at the review date, only
  `inconclusive`, permanently.

## Common mistakes

- “Human error” or “reviewer missed it” instead of the conditions and the
  absent gate that let the action escape.
- Publishing sensitive incident artifacts without access and retention
  controls.
