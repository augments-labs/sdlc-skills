---
name: requesting-code-review
description: "Use when an exact candidate reaches a done or integration boundary, or an independent review of one frozen state is explicitly requested. Fires on review this, is this ready to merge, and take a look before I push, even if nobody says code review. Explicit keep or discard, and PR-only close or reopen, are branch-state actions rather than readiness review. Skip an unfinished reversible checkpoint unless review was explicitly requested."
---

# Requesting Code Review

Get an independent verdict on one frozen candidate, in this order: verify,
freeze, dispatch, poll, receive. Never say a review is running, and never
wait on one, until the dispatch action has returned a non-empty receipt.

## When to use

- Before you call an exact candidate complete, and before anything is pushed,
  published, or merged. A checkpoint you were authorized to commit is not done.
- When the user asks for a review of one exact state. That verdict covers the
  state it was given and does not make an unfinished checkpoint complete.
- **Skip** here, and go through `finishing-a-branch` directly, for keep,
  discard, and PR-only close or reopen: those need its identity and authority
  gates, not a readiness review.
- For a high-risk transformation, read `references/high-risk-review.md` first;
  it owns the role separation, and one review of an aggregate diff nobody can
  read does not satisfy it.

## Procedure

1. **REQUIRED — invoke `verifying-completion`** and run the gates it requires
   for this transition. Record the state identity, the raw output, and every
   failure it returned. Review challenges that evidence; it never replaces it.

2. **Freeze the candidate.** Stop anything still writing to it. Then open
   `assets/review-candidate.md` and fill every field: mode, identities, the
   complete inventory, artifact controls, and the terminal contract. Compare
   the result identity it produces with the one step 1 recorded; if they
   differ, go back to step 1.

3. **Write the depth and the roles into the descriptor.** Give every role a
   stable ID, including each one you omit, and for an omission write the
   evidence, the owner, the expiry, what compensates meanwhile, and who
   approved it.

   - **Shallow:** self-review, for a trivial mechanical change.
   - **Standard:** one independent breadth reviewer, plus the relevant specialists.
   - **Deep:** breadth, the relevant specialists and a security audit, and an
     independent adversarial pass.
   - **High-risk transformation:** read `references/high-risk-review.md` before
     assigning anyone.

   Before assigning a reviewer, apply the **Model selection** section of
   `dispatching-parallel-agents` to that role's scope, uncertainty, and the
   cost of a missed defect. Depth sets coverage and independence; it does not
   demand the largest tier for every role.

4. **Dispatch through a callable action.** Shallow: run the self-review below
   and dispatch nothing. Otherwise read `references/code-reviewer.md`, attach
   the raw evidence from step 1, and send it through the harness's dispatch
   action.

   Treat the review as dispatched only when the action returns a non-empty
   ID. If it returns empty, refuses, or is unavailable, write the review as
   pending and stop: do not review it yourself instead, and do not poll an
   empty target. Poll the exact IDs to the descriptor's deadline; success is
   exactly one current report.

5. **Add the specialist passes the candidate's content requires.** Open each
   file below when its condition holds, and add that role to step 3:

   - `references/silent-failures-reviewer.md` — the candidate catches, retries,
     falls back, or supplies a default that could swallow a failure
   - `references/type-design-reviewer.md` — it introduces or changes a type,
     interface, schema, or other shape callers bind to
   - `references/test-coverage-reviewer.md` — it changes behavior that tests
     are supposed to pin, or moves behavior between covered and uncovered code
   - `references/comment-accuracy-reviewer.md` — it adds or edits comments,
     docstrings, or prose that claims something about the code
   - `references/equivalence-reviewer.md` — high-risk equivalence
   - `references/yagni-reviewer.md` — it adds or expands enduring owned
     surface, or a simplification review was requested

   A change to a trust boundary: invoke `security-audits`. Send an audit of
   existing code to `complexity-audit` and a challenge to the assurance
   strategy to `verification-strategy`; a generic review never substitutes for
   a specialist's verdict.

6. **Check the report covers the whole inventory,** including every
   human-authored change in it. Where the report followed callers, contracts,
   history, tests, or failures outward, confirm the evidence required it;
   reject a report that wandered the repository.

7. **Block on anything unreconciled.** A missing role, an open finding, an
   inconclusive result, a non-success, or a conditional "ready" each block the
   candidate. Write the verdict and the receipt with the full candidate and
   context identities.

8. **REQUIRED — invoke `receiving-code-review`** with every report before you
   respond to it, disposition it, or conclude anything from it, including a
   `not ready` that asks for no edit. After any fix, or any change to a bound
   input, restart at step 1: a re-review is a fresh invocation with its own
   identities and receipt, never an ad hoc dispatch.

9. **REQUIRED — hand a `ready` verdict on, not an action.** At an integration
   boundary invoke `finishing-a-branch`, which decides push, PR, merge, keep,
   or discard; for a task inside a plan return to `executing-plans`. Run none
   of those actions here, and do not treat the verdict as the user's
   integration choice.

## Self-review for trivial diffs

- Write `self-reviewed: ready` or `self-reviewed: not ready` against the exact
  candidate digest, after reading the complete change and confirming it does
  only what was requested.
- Account for untracked and generated files, and every affected caller.
- Run a real structural gate against that exact candidate.
- On `not ready`, do not hand off. Either the change was not trivial — go back
  to step 3 and raise the depth — or there is a defect: fix it, then restart
  at step 1.

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
