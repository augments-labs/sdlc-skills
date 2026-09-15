---
name: requesting-code-review
description: "Gets an independent review of one frozen state before it is called done, pushed, or merged. Use when a change reaches a done or integration boundary, when an independent review of a frozen state is explicitly requested, or when the user says review this, is this ready to merge, or take a look before I push. Skip an unfinished reversible checkpoint unless review was explicitly requested, and skip an explicit keep, discard, close, or reopen transition."
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
- Read `references/high-risk-review.md` first when the change is a high-risk
  transformation; it owns the role separation, and one review of an aggregate
  diff nobody can read does not satisfy it.

## Step 1: Verify and freeze

1. Stop writers this task started; report any other writer to its owner and
   keep review pending until it stops.
2. Consume the caller's evidence ledger for the frozen state and its raw
   results. Reuse each row whose candidate, bound inputs/environment, gate
   requirements, and evidence freshness still match. Never rerun a matching
   row.
3. No ledger, or a missing or stale row → **REQUIRED SUB-SKILL:** invoke
   `verification-before-completion` to obtain evidence for this review, then
   resume here. Keep failures and pending results: they permit review, never
   readiness.
4. Open `assets/review-candidate.md` after the evidence is bound. Fill every
   field: mode, identities, complete inventory, artifact controls, terminal
   contract, continuation, review history. Retain that history across
   successor candidates.
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
   - **Deep:** breadth, specialists, a security role filled from
     `security-audits`' report template and checklists before Step 3.2, and an
     independent adversarial pass.
   - **High-risk transformation:** read `references/high-risk-review.md` before
     assigning anyone.
2. Give every role a stable ID, including each one omitted. An omission
   records evidence, owner, expiry, compensation, and approver.
3. Add each applicable specialist role; open its prompt template:
   - `assets/silent-failures-reviewer.md` when catches, retries, fallbacks,
     or defaults could swallow a failure
   - `assets/type-design-reviewer.md` when a type, interface, schema, or
     shape callers bind to is new or changed
   - `assets/test-coverage-reviewer.md` when tests should pin the behavior,
     or behavior moved between covered and uncovered code
   - `assets/comment-accuracy-reviewer.md` when comments, docstrings, or
     prose claim something about the code
   - `assets/equivalence-reviewer.md` when the change claims high-risk
     equivalence
   - `assets/yagni-reviewer.md` when enduring surface is new or expanded, or
     a simplification review is requested
4. Report what another skill owns as a finding with a suggested owner; the
   caller routes it, and review ends at its report:
   - a trust boundary changed → suggested owner `security-audits`. It blocks
     readiness at every depth until an independent `security clear` on this candidate is
     recorded, unless the Deep security role returned it.
   - existing code needs an audit for accidental complexity → suggested owner
     `complexity-audit`
   - the assurance strategy is hollow or needs challenging → suggested owner
     `verification-strategy`
   Record each such finding in the external review ledger; with no recorded
   caller, return it with the verdict and name its suggested owner as the next
   skill. When the recorded caller owns that activity, add any brief it
   supplied to the Step 3.2 dispatch and return the result to its pending step.
   A generic review never substitutes for the owner's verdict.
5. Pick each reviewer's tier with the **Model selection** section of
   `dispatching-parallel-agents`. Depth sets coverage and independence, not
   the largest tier for every role.

## Step 3: Dispatch and receive

1. Shallow, with its written assignment recorded in the descriptor → run the
   self-review below; dispatch nothing. No assignment → Standard.
2. Otherwise open `assets/code-reviewer.md` before dispatch, with each
   selected specialist template. Fill Inputs from the descriptor and raw
   evidence. Insert `assets/review-report.md` before sending, in its Report
   template slot; leave the report fields for the reviewer. Send each filled
   fenced prompt through the harness's dispatch action.
3. Then dispatch per `dispatching-parallel-agents` Step 2, using the
   descriptor's deadline as the frozen deadline. The answer assigns
   self-review → quote it as the Shallow assignment in a successor
   descriptor and return to Step 3.1.
4. Success = exactly one current report for each role.
5. Read each returned report, opening its file if only a location was returned.
   Match Candidate, Review inputs, Role, and the role's allowed Verdict to the
   frozen request. Missing, unreadable, conflicting, or mismatched fields →
   pending. Check the complete inventory and every human-authored change;
   reject unrelated traversal.
6. Block readiness while required current verification or role coverage is
   missing, failed, inconclusive, or conditional, or a blocking finding or
   attempt's effects remain unresolved. Retain every failed attempt; an accepted
   linked successor can satisfy its current role once effects are reconciled.
   Reconcile advisory dispositions without adding acceptance criteria.
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
- A trust-boundary finding without an independent `security clear` on this digest →
  `self-reviewed: not ready`.
- On `not ready`, do not hand off. Either the assignment did not fit the
  change — report that to the user, void a no-dispatch answer that assigned
  it, raise the depth to Standard, and restart at Step 2 — or there is a
  defect: fix it, then restart at Step 1.

## Gotchas

- Rerunning a caller's matching rows looks like rigor, but it verifies one
  frozen state twice, and a second run that disagrees gets argued away instead
  of diagnosed. Reuse the row; review is where it gets challenged.
- A reviewer sees only what the descriptor inventories. An untracked or
  generated file left out of the inventory ships unreviewed under a `ready`
  verdict.
- A trust-boundary finding without `security clear` is not advisory. Filing it
  as advice to reach `ready` ships a boundary nobody audited.

## Common mistakes

- Treating gates, workspace size, urgency, or completion pressure as an
  independent reviewer or downgrade permission.
- Inventing delegation authority, or treating an action as disclosure consent.
- Asking a reviewer to mutate the frozen candidate; destructive challenge runs
  only in a reviewer-owned copy or against retained evidence.
- Filling incompatible high-risk roles without a direct recorded exception.
