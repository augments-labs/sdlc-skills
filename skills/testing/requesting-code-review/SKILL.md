---
name: requesting-code-review
description: "Use when an exact candidate reaches a done or integration boundary, or an independent review of one frozen state is explicitly requested. Fires on review this, is this ready to merge, and take a look before I push, even if nobody says code review. Skip an unfinished reversible checkpoint unless review was explicitly requested, and skip an explicit keep, discard, close, or reopen."
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

1. Stop anything still writing to the candidate.
2. Read the available verification evidence and raw results. Reuse required
   rows only when the candidate, bound inputs/environment, gate requirements,
   and evidence freshness still match.
3. Missing or stale rows → **REQUIRED SUB-SKILL:** invoke
   `verification-before-completion` to obtain evidence for this review, then resume here.
   Keep failures and pending results: they permit review, never readiness.
4. Open `assets/review-candidate.md`. Fill every field: mode, identities,
   complete inventory, artifact controls, terminal contract, continuation,
   review history. Retain that history across successor candidates.
   Record a caller only when it has a step awaiting this verdict. A skill
   whose work ended at this handoff is not a pending return step.
5. Compare its result identity with the verification evidence. Different →
   back to step 1. Review challenges the evidence; it never replaces it.

## Step 2: Choose depth and roles

1. Write the depth into the descriptor:
   - **Shallow:** self-review. Only when the user, project policy, or the
     plan's task row assigns it in writing. Never chosen here: the size of
     the diff grants nothing.
   - **Standard:** one independent breadth reviewer plus relevant specialists.
   - **Deep:** breadth, specialists, `security-audits`, and an independent
     adversarial pass.
   - **High-risk transformation:** read `references/high-risk-review.md`
     before assigning anyone.
2. Give every role a stable ID, including each one omitted. An omission
   records evidence, owner, expiry, compensation, and approver.
3. Add each applicable specialist role; open its prompt template:
   - `assets/silent-failures-reviewer.md` — catches, retries, fallbacks,
     or defaults that could swallow a failure
   - `assets/type-design-reviewer.md` — a new or changed type, interface,
     schema, or shape callers bind to
   - `assets/test-coverage-reviewer.md` — behavior tests should pin, or
     behavior moved between covered and uncovered code
   - `assets/comment-accuracy-reviewer.md` — comments, docstrings, or
     prose that claims something about the code
   - `assets/equivalence-reviewer.md` — high-risk equivalence
   - `assets/yagni-reviewer.md` — new or expanded enduring surface, or a
     requested simplification review
4. Trust boundary changed → invoke `security-audits`. Audit of existing code →
   `complexity-audit`. Challenge to the assurance strategy →
   `verification-strategy`. When the recorded caller owns that activity,
   use its supplied brief and keep its return step; never invoke it
   recursively. A generic review never substitutes.
5. Pick each reviewer's tier with the **Model selection** section of
   `dispatching-parallel-agents`. Depth sets coverage and independence, not
   the largest tier for every role.

## Step 3: Dispatch and receive

1. Shallow, with its written assignment recorded in the descriptor → run the
   self-review below; dispatch nothing. No assignment → Standard.
2. Otherwise open `assets/code-reviewer.md` and each selected specialist
   template. Fill Inputs from the descriptor and raw evidence; insert
   `assets/review-report.md` into its Report template slot. Leave the report
   fields for the reviewer. Send each filled fenced prompt through the
   harness's dispatch action.
3. Dispatched = the action returned a non-empty ID. Empty, refused, or
   unavailable → write the review as pending and stop. Do not review it
   yourself. Do not poll an empty target.
4. Poll the exact IDs to the descriptor's deadline. Success = exactly one
   current report.
5. Read each returned report, opening its file if only a location was returned.
   Match Candidate, Review inputs, Role, and the role's allowed Verdict to the
   frozen request. Missing, unreadable, conflicting, or mismatched fields →
   pending. Check the complete inventory and every human-authored change;
   reject unrelated traversal.
6. Block readiness on missing or failed required verification, a missing role,
   an unresolved blocking finding, an inconclusive result, or a conditional
   "ready". Reconcile advisory dispositions without making optional improvements
   new acceptance criteria.
7. Record each report's location and disposition in the external review ledger.
   A report is the reviewer's assessment; keep the tool-issued dispatch ID as
   the evidence that the reviewer was actually dispatched.
8. **REQUIRED SUB-SKILL:** invoke `receiving-code-review` with every report
   before responding to it, including a `not ready` that asks for no edit.
9. Before another round, apply `receiving-code-review`'s convergence check.
   Retry permitted and candidate or bound inputs changed → restart at Step 1
   with fresh identities and receipt. Carry prior coverage and dispositions;
   focus successor review on fixes, affected paths, and regressions.
10. **REQUIRED — continue a `ready` verdict through the recorded owner:**
    - caller awaiting this review → return to its pending step; never invoke
      the caller recursively
    - task or plan owned by `executing-plans` → return there; it owns cadence
      and plan-end finishing
    - review-only request, unfinished checkpoint, or unchanged state with an
      already settled branch choice → return the verdict
    - completed standalone implementation or integration boundary with an
      unsettled branch choice → invoke `finishing-a-branch`, even without a
      user request for a Git action
    Run no push, PR, merge, keep, or discard here. A ready verdict does not
    choose an integration action.

## Self-review, assigned depth only

- Write `self-reviewed: ready` or `self-reviewed: not ready` against the exact
  candidate digest, after reading the complete change and confirming it does
  only what was requested.
- Account for untracked and generated files, and every affected caller.
- Run a real structural gate against that exact candidate.
- On `not ready`, do not hand off. Either the assignment did not fit the
  change — report that to the user, raise the depth to Standard, and restart
  at Step 2 — or there is a defect: fix it, then restart at Step 1.

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
