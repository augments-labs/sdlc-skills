---
name: requesting-code-review
description: "Gets an independent review of one frozen state before it is called done, pushed, or merged. Use when a change reaches a done or integration boundary, when an independent review of a frozen state is explicitly requested, or when the user says review this, is this ready to merge, or take a look before I push. Skip an unfinished reversible checkpoint unless review was explicitly requested, and skip an explicit keep, discard, close, or reopen transition, and skip a plan document, which `reviewing-plans` reviews."
---

# Requesting Code Review

Get an independent verdict on one frozen candidate, in this order: verify,
freeze, dispatch, poll, receive. Never say a review is running, and never
wait on one, until the dispatch action has returned a non-empty receipt (the
tool-issued dispatch ID).

## When to use

- Before you call an exact candidate complete, and before anything is pushed,
  published, or merged. A checkpoint you were authorized to commit is not done.
- When the user asks for a review of one exact state.
- **Skip** here, and go through `finishing-a-branch` directly, for keep,
  discard, and PR-only close or reopen: those need its identity and authority
  checks, not a readiness review.
- **Skip** a plan document; `reviewing-plans` reviews it.
- Read `references/high-risk-review.md` first when the change is a high-risk
  transformation; it owns the role separation, and one review of an aggregate
  diff nobody can read does not satisfy it.

## Step 1: Verify and freeze

1. Stop the writers this task started; report any other writer to its owner
   and keep review pending until it stops.
2. Read the caller's evidence ledger (add to it, never rewrite it; it sits
   outside the candidate) for the frozen state and its raw results. Reuse
   each row whose candidate, bound inputs and environment, check
   requirements, and evidence freshness still match. Never rerun a matching
   row.
3. If there is no ledger, or a row is missing or stale,
   **REQUIRED SUB-SKILL:** invoke `verification-before-completion` to obtain
   evidence for this review, then resume here. Keep failures and pending
   results: they permit review, never readiness.
4. Open `assets/review-candidate.md`, the descriptor, after the evidence is
   bound. Fill every field: mode, identities, complete inventory, artifact
   controls, terminal contract, continuation, review history. Keep that
   history across successor candidates.
   Record a caller only when it has a step awaiting this verdict. A skill
   whose work ended at this handoff is not a pending return step.

   A change regenerates `api/client.ts` from a schema through the project's
   generator and adds `api/retry.ts`, typed by the agent. Both go in the
   complete inventory. Only the first is generated: the schema and generator
   reproduce it, so the inventory binds it by identity. The second is
   human-authored for review, agent-typed or not; leaving it out as
   "generated" ships it unreviewed under a `ready` verdict.

5. Compare its result identity with the state identity the verification
   evidence carries. If they differ, go back to Step 1.

## Step 2: Choose depth and roles

1. Write the depth into the descriptor:
   - **Shallow:** a self-review. Only when the user, project policy, or the
     plan's task row assigns it in writing. Never chosen here: the size of
     the diff grants nothing.
   - **Standard:** one independent breadth reviewer. A specialist joins only
     when the diff matches its trigger in Step 2.3, and at most three roles
     run at once; the rest wait for a second round.
   - **Deep:** breadth, specialists, a security role filled from
     `security-audits`' report template and checklists before Step 3.2, and an
     independent adversarial pass.
   - **High-risk transformation:** read `references/high-risk-review.md` before
     assigning anyone.
2. Give every role a stable ID, including each omitted role. For an omitted
   role, record the evidence, owner, expiry, compensating check, and approver.
3. Add a specialist role only when the diff matches its trigger below, then
   open its prompt template. If no trigger matches, the breadth reviewer runs
   alone:
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
   - If a trust boundary changed, the suggested owner is `security-audits`.
     That finding blocks readiness at every depth until an independent
     `security clear` on this candidate is recorded, unless the Deep security
     role returned it.
   - If existing code needs an audit for accidental complexity, the suggested
     owner is `complexity-audit`.
   - If the assurance strategy is hollow or needs challenging, the suggested
     owner is `verification-strategy`.

   Record each such finding in the external review ledger. If no caller is
   recorded, return the
   finding with the verdict and name its suggested owner as the next skill. If
   the recorded caller owns that activity, add any brief it supplied to the
   Step 3.2 dispatch and return the result to its pending step.
5. Pick each reviewer's tier with the **Model selection** section of
   `dispatching-parallel-agents`. Depth sets coverage and independence, not
   the largest tier for every role.

## Step 3: Dispatch and receive

1. If the depth is Shallow and its written assignment is recorded in the
   descriptor, run the self-review below and dispatch nothing. If no
   assignment is recorded, the depth is Standard.
2. Otherwise open `assets/code-reviewer.md` before dispatch, with each
   selected specialist template. Fill Inputs from the descriptor and raw
   evidence. Insert `assets/review-report.md` before sending, in its Report
   template slot; leave the report fields for the reviewer.
3. Send each filled fenced prompt once, following `dispatching-parallel-agents`
   Step 2, with the descriptor's deadline as the frozen deadline. If the
   answer there assigns a self-review, quote it as the Shallow assignment in
   a successor descriptor and return to Step 3.1.
4. Success means exactly one current report for each role.
5. Read each returned report, opening its file if only a location was
   returned. Match Candidate, Review inputs, Role, and the role's allowed
   Verdict to the frozen request. If a field is missing, unreadable,
   conflicting, or mismatched, review stays pending. Check the complete
   inventory and every human-authored change; reject unrelated traversal.
6. Decide each Declined to judge entry and record it in the ledger, except
   one that turns on a product, scope, or requirement reading: that goes to
   its decision owner through `clarifying-intent`. An undecided entry keeps
   review pending.
7. Block readiness while required current verification or role coverage is
   missing, failed, inconclusive, or conditional, or while a blocking finding
   or an attempt's effects remain unresolved. Keep every failed attempt on
   record; an accepted successor attempt linked to it can satisfy its current
   role once effects are reconciled. Reconcile each advisory finding's
   recorded decision without adding acceptance criteria.
8. Record each report's location, its recorded decision, and the tool-issued
   dispatch ID in the external review ledger.
9. **REQUIRED SUB-SKILL:** invoke `receiving-code-review` with every report
   before responding to it, including a `not_ready` that asks for no edit.
10. Before another round, apply `receiving-code-review`'s convergence check.
    If a retry is permitted and the candidate or its bound inputs changed,
    restart at Step 1 with fresh identities and a fresh receipt. Carry prior
    coverage and recorded decisions forward; focus the successor review on
    fixes, affected paths, and regressions.
11. **REQUIRED — continue a `ready` verdict through the recorded owner:**
    - If a caller is awaiting this review, return to its pending step; never
      invoke the caller recursively.
    - If the task or plan is owned by `executing-plans` or
      `subagent-driven-development`, return there; it owns cadence and
      plan-end finishing.
    - If this was a review-only request, an unfinished checkpoint, or an
      unchanged state with an already settled branch choice, return the
      verdict.
    - If this is a completed standalone implementation or integration
      boundary with an unsettled branch choice, invoke `finishing-a-branch`,
      even without a user request for a Git action.

    Run no push, PR, merge, keep, or discard here. A ready verdict does not
    choose an integration action.

## Self-review, assigned depth only

- Write `self-reviewed: ready` or `self-reviewed: not ready` against the exact
  candidate hash, after reading the complete change and confirming it does
  only what was requested.
- Account for untracked and generated files, and every affected caller.
- Run a real structural check against that exact candidate.
- If there is a trust-boundary finding without an independent `security clear`
  on this hash, write `self-reviewed: not ready`.
- On `not ready`, do not hand off. Either the assignment did not fit the
  change: report that to the user, void a no-dispatch answer that assigned it,
  raise the depth to Standard, and restart at Step 2. Or there is a defect:
  fix it, then restart at Step 1.

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

- Treating checks, workspace size, urgency, or completion pressure as an
  independent reviewer or as permission to downgrade.
- Inventing delegation authority, or treating an action as disclosure consent.
- Asking a reviewer to mutate the frozen candidate; destructive challenge runs
  only in a reviewer-owned copy or against retained evidence.
- Filling high-risk roles that must stay separate with the same party, without
  a direct recorded exception.
