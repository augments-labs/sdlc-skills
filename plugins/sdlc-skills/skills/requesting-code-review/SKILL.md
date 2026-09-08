---
name: requesting-code-review
description: "Use when an exact candidate reaches a done or integration boundary, or an independent review of one frozen state is explicitly requested. Fires on review this, is this ready to merge, and take a look before I push, even if nobody says code review. Explicit keep or discard, and PR-only close or reopen, are branch-state actions rather than readiness review. Skip an unfinished reversible checkpoint unless review was explicitly requested."
---

# Requesting Code Review

Challenge the exact candidate independently, in one legal order: verify, freeze,
dispatch, poll the receipt, receive the report, hand it to
`receiving-code-review`. Never announce a review, or wait on one, before a
nonempty receipt exists. Any change to the candidate — or to a review input
bound to it — voids the verdict.

## When to use

- Before an exact candidate is called complete, or moves toward integration.
  Being authorized to make a reversible checkpoint does not make it done.
- On an explicit request to review one exact frozen state. That verdict reviews
  the state it was given; it does not call an unfinished checkpoint complete.
- `finishing-a-branch` consumes this skill's depth before it materializes a
  source branch, publishes, or integrates; its keep, discard, and PR-only close
  or reopen paths go through that skill's identity and authority gates instead,
  without a readiness review.
- A high-risk transformation uses `references/high-risk-review.md`, unless that
  exact candidate carries the direct recorded exception the file defines. One
  final review of an aggregate diff nobody can read is not sufficient.

## Procedure

1. **Bring the evidence first.** Invoke `verifying-completion`, run the checks it
   currently requires, and bind the exact state, output, and failures they
   produced. Review challenges completion evidence; it never replaces it.
2. **Freeze the candidate.** Stop anything still writing to it, then read and
   apply `assets/review-candidate.md` — it owns the descriptor: the mode,
   the identities, the complete inventory, the artifact controls, and the
   terminal contract. The one canonical result identity it produces must equal
   completion's state byte-for-byte; if it does not, go back to verification.
3. **Freeze the depth and the roles.** Every role gets a stable ID, whether it is
   required or omitted, and an omission needs evidence, a named owner, an expiry,
   something that compensates for it meanwhile, and an approval.

   - **Shallow:** self-review, for a trivial mechanical change.
   - **Standard:** one independent breadth reviewer, plus the relevant specialists.
   - **Deep:** breadth, the relevant specialists and a security audit, and an
     independent adversarial pass.
   - **High-risk transformation:** read `references/high-risk-review.md` before
     assigning anyone; it owns the required role separation.
4. **Run that depth.** Shallow uses the self-review below and dispatches nothing.
   Otherwise read `references/code-reviewer.md` and send it, with the raw
   evidence, through a callable action.

   Only a returned nonempty ID means the review was dispatched. If the action
   returns empty, refuses, or is unavailable, the review stays pending: do not
   fall back to reviewing it yourself, and do not poll an empty target. Poll the
   exact IDs to the deadline under the descriptor's terminal contract; success
   means exactly one current report.
5. **Traverse by evidence.** Account for the complete inventory, and for every
   human-authored change in it. Follow callers, contracts, history, tests, and
   failures outward only where the evidence requires it.
6. **Block on anything unreconciled.** A missing role, an outstanding finding, an
   inconclusive result, a non-success, or a conditional “ready” each block this
   candidate. The verdict and the final structured receipt both carry the full
   candidate and context identities.
7. **Receive every report through `receiving-code-review`** before responding to
   it, dispositioning it, or concluding anything from it — including a `not
   ready` that asks for no edit. Any fix, or any change to a bound input,
   invalidates the verdict. A focused re-review is a fresh invocation of this
   skill, with its own verification, references, identity, and receipt; never
   dispatch one ad hoc.

## Model selection

Before dispatching a reviewer, apply the **Model selection** section of
`dispatching-parallel-agents` to that role's scope, uncertainty, and consequences
of a missed defect. Review depth determines coverage and independence; it does
not automatically require the largest model for every role.

## Specialist passes

Add the axes the candidate's own content requires — each line says when to open
it, because an axis chosen by vibe is an axis skipped under pressure:

- `references/silent-failures-reviewer.md` — when the candidate catches, retries,
  falls back, or supplies a default that could swallow a failure
- `references/type-design-reviewer.md` — when it introduces or changes a type,
  interface, schema, or other shape callers bind to
- `references/test-coverage-reviewer.md` — when it changes behavior that tests
  are supposed to pin, or moves behavior between covered and uncovered code
- `references/comment-accuracy-reviewer.md` — when it adds or edits comments,
  docstrings, or prose that claims something about the code
- `references/equivalence-reviewer.md` — for high-risk equivalence
- `references/yagni-reviewer.md` — when the candidate adds or expands enduring
  owned surface, or a simplification review is explicitly requested

A change to a trust boundary invokes `security-audits`. Ownership is fixed:
broad review owns unrequested scope, type review owns invariant-specific
ceremony, an audit of existing code belongs to `complexity-audit`, and
challenging the assurance strategy belongs to `verification-strategy`. A generic
review never substitutes for a specialist's verdict.

## Self-review for trivial diffs

- Bind `self-reviewed: ready` or `self-reviewed: not ready` to the exact
  candidate digest, and confirm its complete change does only what was requested.
- Are untracked and generated files, and every affected caller, accounted for?
- Did a real structural gate run against that exact candidate?
- `not ready` never hands off. Either the mechanical premise was false — upgrade
  the depth — or there is a defect: fix it, then restart verification and review.

## Common mistakes

- Treating gates, workspace size, urgency, or completion pressure as an
  independent reviewer or downgrade permission.
- Inventing delegation authority, or treating an action as disclosure consent.
- Asking a reviewer to mutate the frozen candidate; destructive challenge runs
  only in a reviewer-owned copy or against retained evidence.
- Filling incompatible high-risk roles without a direct recorded exception.
- Applying fixes while review continues, so nobody reviewed one stable candidate.
- Writing receipts into the frozen candidate creates a new candidate and voids
  the verdict.
