---
name: architecture-decisions
description: "Records a significant, hard-to-reverse technical decision and the options weighed. Use when a choice such as a datastore, sync versus async, a framework, a public contract, or an auth or security model is being weighed or has just been settled, when the user asks whether to use X or Y, when a choice is made in passing during discussion, or when an old decision is revisited. Skip easily reversible choices."
---

# Architecture Decisions

## When to use

- Record a decision only when **all three** hold: it is **hard to reverse**,
  it would be **surprising without the reasons** behind it, and there were
  **genuine trade-offs** between real options. A datastore, a sync/async
  boundary, a framework, a public contract, or a security model is such a
  decision.
- **Skip** when any of the three is missing. A reversible, obvious, or
  inevitable choice is noise as an ADR.

## Step 1: Draft the ADR

Open `assets/adr-template.md` before Step 1's actions; it owns the fields.
Read `references/adr-example.md` when the first draft is written and needs
comparing against a filled example.

1. State the question, the artifact or system the decision covers, the forces
   bearing on it, and who decides: one accountable decision owner, or the
   approvers with a rule for settling a conflict.
2. Weigh at least two real options. For each, record what it assumes, where
   it breaks, what would rule it out, what reversing it would cost, and the
   evidence. Wherever keeping things as they are, or deferring the decision,
   is viable, weigh that too; where it is not, record the evidence that says
   so.
3. Give every assumption a stable ID and a way to be proved wrong.
4. Record the proposed choice and each rejected alternative. Keep the
   rejections; never edit them away.
5. Record the consequences and the reversal path: what the choice commits you
   to, what it means for data and migrations, how to undo it, and what it
   closes off.

## Step 2: Persist, then challenge

1. Append the ADR, with status `proposed`, to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   keeping what is already in the file. The ADR is immutable: never edit it
   after this. Compute its identity now, by the rule the template names (the
   artifact layout's section rule in `using-sdlc-skills`: the first 7
   characters of `git hash-object` over the ADR's own section); the challenge
   binds to this path and this identity.
2. If the choice is irreversible (Step 1.5's reversal row says undo is
   impossible or unaffordable, not merely costly) and a dispatch action
   exists, fill `assets/adr-challenger.md` with that path and identity before
   dispatching it. Dispatch it as `dispatching-parallel-agents` Step 2 says,
   to a reviewer other than the sole author. That reviewer challenges the
   options, the assumptions, the consequences, and the reversal under the
   template's challenge contract.

   Otherwise, write the strongest counter-case yourself, against that same
   contract, and label it **self-challenge**. A self-challenge never
   issues the verdict `clear`, so the risk it leaves open goes to the decision
   owner in Step 3.

   Approval waits for `clear` on this ADR identity, or for the decision
   owner accepting a labelled self-challenge. Skip both the dispatched
   challenge and the self-challenge only when a current independent design
   review covers this exact ADR identity.

## Step 3: Present and track

1. Present:

   ```text
   ADR {{identity (per template)}}: {{question}}
   Proposed: {{choice}} — {{rationale, one line}}
   Rejected: {{alternatives}}  Reversal cost: {{one line}}

   1. Accept
   2. Reject in favor of {{other option}}
   3. Request changes
   4. Cancel

   Recommendation: {{option the recorded trade-offs support}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
2. Track the decision and its conformance (evidence that the accepted choice
   is implemented, as the ADR's conformance contract requires) as two separate
   things. Acceptance puts nothing `in force`; conformance does. Retirement
   needs an action by the owner and the absence of the surface the ADR
   governs. If there is a contradiction, reopen every affected owner.
3. Return the recorded outcome to the skill that invoked this one.

## Gotchas

- An assumption's "way to be proved wrong" (Step 1) can succeed after the ADR
  is accepted. The ADR itself is immutable and append-only (Step 2), so a
  disproven assumption is never fixed by editing the original. It needs a new
  ADR that supersedes the old one, the same way a rejected alternative is kept
  rather than removed.
- Step 2's reviewer-skip condition requires a *current* review of *this
  exact* ADR identity. A design review that covered an earlier draft, before
  an option was reweighed or an assumption added, no longer satisfies either
  word, even though it can feel like "we already reviewed this."

## Common mistakes

- Treating "the code now does this" as owner approval or conformance proof.
