---
name: architecture-decisions
description: "Use when a significant, hard-to-reverse technical choice is being weighed or has just been settled — a datastore, sync vs async, a framework, a public contract, an auth or security model — so it is recorded with its alternatives and consequences before anything is built on it. Fires on should we use X or Y, on a choice made in passing during discussion, and on a request to revisit an old one, even if nobody says ADR or decision record. Skip easily-reversible choices."
---

# Architecture Decisions

Record the decisions you'd regret not being able to explain in six months. An ADR (Architecture Decision Record) captures *why*, not just *what* — so the next person, or you, doesn't relitigate it or quietly undo it.

## When to use

- Record a decision only when **all three** hold: it's **hard to reverse**, it would be **surprising without the rationale**, and there were **genuine trade-offs** between real options — a datastore, a sync/async boundary, a framework, a public contract, a security model.
- **Skip** when any of the three is missing — a reversible, obvious, or inevitable choice (a variable name; the only option that could work) is noise as an ADR.

## Step 1: Draft the ADR

Open `assets/adr-template.md` now. It owns the fields.

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

1. Present and end the turn:

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

2. Praise and momentum accept nothing. Record accepted, rejected, or
   cancelled externally with exact-version evidence.
3. Normative change → a proposed successor with an exact delta. Accepted
   successor → inventory and invalidate predecessor-bound consumers until
   their owners reconcile. Never edit an issued identity.
4. Track decision and conformance separately. Acceptance puts nothing `in
   force`; conformance does. Retirement needs owner action and absence of the
   governed surface. Contradiction → reopen every affected owner.
5. Return the recorded outcome to the skill that invoked this one.

## Common mistakes

- Recording the *what* without the *why* — it reads as arbitrary and gets undone.
- No rejected alternatives — the next person re-explores the same dead ends.
- An ADR for a reversible choice — only the decisions you'd defend belong here.
- An accepted ADR never moved `in force` when work landed, or an obsolete
  in-force ADR was never linked as superseded or retired.
- Treating “the code now does this” as owner approval or conformance proof.

For a copyable ADR template, a filled example, and common failure patterns, see `assets/adr-template.md`.
