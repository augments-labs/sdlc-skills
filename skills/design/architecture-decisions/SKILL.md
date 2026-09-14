---
name: architecture-decisions
description: "Records a significant, hard-to-reverse technical decision and the options weighed. Use when a choice such as a datastore, sync versus async, a framework, a public contract, or an auth or security model is being weighed or has just been settled, when the user asks whether to use X or Y, when a choice is made in passing during discussion, or when an old decision is revisited. Skip easily reversible choices."
---

# Architecture Decisions

Record the decisions you'd regret not being able to explain in six months. An ADR (Architecture Decision Record) captures *why*, not just *what* — so the next person, or you, doesn't relitigate it or quietly undo it.

## When to use

- Record a decision only when **all three** hold: it's **hard to reverse**, it would be **surprising without the rationale**, and there were **genuine trade-offs** between real options — a datastore, a sync/async boundary, a framework, a public contract, a security model.
- **Skip** when any of the three is missing — a reversible, obvious, or inevitable choice (a variable name; the only option that could work) is noise as an ADR.

## Step 1: Draft the ADR

Open `assets/adr-template.md` before Step 1's actions; it owns the fields.

1. State the question, the artifact or system scope, the forces, and one
   accountable decision owner or the approvers with a conflict rule.
2. Weigh at least two real options: assumptions, failure limits,
   disqualifiers, reversal cost, evidence. Evaluate status quo or deferring
   wherever viable; record the evidence when not.
3. Give every assumption a stable ID and a way to be proved wrong.
4. Record the proposed choice and each rejected alternative. Preserve
   rejections; never edit them away.
5. Record consequences and reversal: commitments, data and migration
   consequences, how to undo, what it closes off. Only upsides → not
   examined.

## Step 2: Challenge and persist

1. A reviewer other than the sole author challenges options, assumptions,
   consequences, reversal, under the template's challenge contract. Skip only
   when a current independent design review covers this exact ADR identity.
2. Append the immutable `proposed` ADR to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the project's
   decision log, preserving what is there.

## Step 3: Present and track

1. Present:

   ```text
   ADR {{identity}}: {{question}}
   Proposed: {{choice}} — {{rationale, one line}}
   Rejected: {{alternatives}}  Reversal cost: {{one line}}

   1. Accept
   2. Reject in favor of {{other option}}
   3. Request changes
   4. Cancel

   Recommendation: {{option the recorded trade-offs support}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `interview-me` owns what closes it.
2. Track decision and conformance separately. Acceptance puts nothing `in
   force`; conformance does. Retirement needs owner action and absence of the
   governed surface. Contradiction → reopen every affected owner.
3. Return the recorded outcome to the skill that invoked this one.

## Gotchas

- An assumption's “way to be proved wrong” (Step 1) can succeed after the
  ADR is accepted — but the ADR itself is immutable and append-only (Step
  2), so a disproven assumption is never fixed by editing the original. It
  needs a new ADR that supersedes the old one, the same way a rejected
  alternative is preserved rather than removed.
- Step 2's reviewer-skip condition requires a *current* review of *this
  exact* ADR identity. A design review that covered an earlier draft —
  before an option was reweighed or an assumption added — no longer
  satisfies either word, even though it can feel like “we already
  reviewed this.”

## Common mistakes

- Recording the *what* without the *why* — it reads as arbitrary and gets undone.
- No rejected alternatives — the next person re-explores the same dead ends.
- An ADR for a reversible choice — only the decisions you'd defend belong here.
- An accepted ADR never moved `in force` when work landed, or an obsolete
  in-force ADR was never linked as superseded or retired.
- Treating “the code now does this” as owner approval or conformance proof.

See `assets/adr-template.md` when a copyable template, a filled example, or
common failure patterns are needed.
