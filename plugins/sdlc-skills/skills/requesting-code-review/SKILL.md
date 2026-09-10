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

## Step 1: Verify and freeze

1. **REQUIRED SUB-SKILL:** invoke `verifying-completion`. Run the gates it
   requires for this transition. Keep the state identity, raw output, and
   every failure. Review challenges that evidence; it never replaces it.
2. Stop anything still writing to the candidate.
3. Open `assets/review-candidate.md`. Fill every field: mode, identities,
   complete inventory, artifact controls, terminal contract.
4. Compare its result identity with the one from step 1. Different → back to
   step 1.

## Step 2: Choose depth and roles

1. Write the depth into the descriptor:
   - **Shallow:** self-review, trivial mechanical change only.
   - **Standard:** one independent breadth reviewer plus relevant specialists.
   - **Deep:** breadth, specialists, `security-audits`, and an independent
     adversarial pass.
   - **High-risk transformation:** read `references/high-risk-review.md`
     before assigning anyone.
2. Give every role a stable ID, including each one omitted. An omission
   records evidence, owner, expiry, compensation, and approver.
3. Add the specialist role whose condition holds; open its brief:
   - `references/silent-failures-reviewer.md` — catches, retries, fallbacks,
     or defaults that could swallow a failure
   - `references/type-design-reviewer.md` — a new or changed type, interface,
     schema, or shape callers bind to
   - `references/test-coverage-reviewer.md` — behavior tests should pin, or
     behavior moved between covered and uncovered code
   - `references/comment-accuracy-reviewer.md` — comments, docstrings, or
     prose that claims something about the code
   - `references/equivalence-reviewer.md` — high-risk equivalence
   - `references/yagni-reviewer.md` — new or expanded enduring surface, or a
     requested simplification review
4. Trust boundary changed → invoke `security-audits`. Audit of existing code →
   `complexity-audit`. Challenge to the assurance strategy →
   `verification-strategy`. A generic review never substitutes.
5. Pick each reviewer's tier with the **Model selection** section of
   `dispatching-parallel-agents`. Depth sets coverage and independence, not
   the largest tier for every role.

## Step 3: Dispatch and receive

1. Shallow → run the self-review below; dispatch nothing.
2. Otherwise read `references/code-reviewer.md`, attach the raw evidence from
   Step 1, and send it through the harness's dispatch action.
3. Dispatched = the action returned a non-empty ID. Empty, refused, or
   unavailable → write the review as pending and stop. Do not review it
   yourself. Do not poll an empty target.
4. Poll the exact IDs to the descriptor's deadline. Success = exactly one
   current report.
5. Check the report covers the whole inventory, including every
   human-authored change. Reject a report that wandered the repository beyond
   what the evidence required.
6. Block on anything unreconciled: a missing role, an open finding, an
   inconclusive result, a non-success, a conditional "ready".
7. Write the verdict and receipt with the full candidate and context
   identities.
8. **REQUIRED SUB-SKILL:** invoke `receiving-code-review` with every report
   before responding to it, including a `not ready` that asks for no edit.
9. After any fix or bound-input change → restart at Step 1. A re-review is a
   fresh invocation with its own identities and receipt.
10. **REQUIRED — hand a `ready` verdict on, not an action.** Integration
    boundary → invoke `finishing-a-branch`. Task inside a plan → return to
    `executing-plans`. Run no push, PR, merge, keep, or discard here. The
    verdict is not the user's integration choice.

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
