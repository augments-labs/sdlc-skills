---
name: reviewing-plans
description: "Gets an independent review of one exact plan version before the plan is presented for approval. Use when a written plan's route is high-risk and it is about to be shown for approval, or when the user says review this plan, is the plan sound, or check the plan before I approve it. Skip a plan whose files are not written yet, and skip editing the plan."
---

# Reviewing Plans

A plan's flaws are cheapest before approval and most expensive mid-execution.
Put one exact plan version in front of a reviewer who did not write it, give
every finding a disposition, and hand the blockers back to the plan's author.
This skill never edits the plan, approves it, or starts an executor.

## When to use

- A plan directory is written and about to be presented for approval, and its
  classification route is high-risk: `writing-plans` requires this review.
- The user asks for an independent look at a plan, or accepts the review that
  `writing-plans` offers for a plan that is not high-risk.
- **Skip** a plan with no printed version yet: its index or task files are not
  written.
- **Skip** editing the plan. Corrections belong to the plan's author, as a
  successor version.
- **Skip** a frozen code change → `requesting-code-review`.

## Step 0: The offer, for a plan that is not high-risk

1. The caller is `writing-plans` presenting a plan whose route is not
   high-risk → ask the offer question below. The user asked for the review
   directly, or the route is high-risk → skip Step 0 and go to Step 1.
2. Ask it with the version `plan-version.sh` prints:

   ```text
   Plan {{version}} is not high-risk.

   1. Review it independently before presenting it
   2. Present it without a review

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print
   this block; end the turn; `clarifying-intent` owns what closes it.
3. Option 1 → Step 1. Option 2 → return to the caller, which presents the
   plan without a review.

## Step 1: Bind the version, the inputs, and the reviewer

1. Print the plan's version with the `plan-version.sh` script that
   `writing-plans` ships, run on the plan directory. The script fails → name
   its error and stop; a version read from the index is not a version.
2. Bind every approved input the index's `Bound inputs` line names, at the
   exact identity it names. An input missing at that identity is a finding
   for the author; never review against a newer one instead.
3. Bind one reviewer role ID that did not write this plan. Pick its tier with
   the **Model selection** section of `dispatching-parallel-agents`.
4. Bind the review boundary: read-only access to the plan directory and its
   inputs, the worker, provider, storage, and egress authority the user or
   project already gave, a deadline, and who cancels. No such authority →
   the review is not dispatched (Step 2.3).
5. Bind the report location beside the plan's decision ledger:
   `{{plan-dir}}/00-index.review-{{version}}-{{attempt}}.md`, attempt `1`
   first. It is the only path that attempt's reviewer may write.
6. A predecessor version already has a review → bind that report too; the
   new review focuses on the corrected sections and every section that
   depends on them, and carries the prior dispositions forward.

## Step 2: Dispatch through a receipt

1. Open `assets/plan-reviewer.md` after Step 1 is bound. Fill every Inputs
   slot with the paths and identities from Step 1, never a paraphrase.
2. Send the filled prompt once through the harness's real dispatch action,
   per `dispatching-parallel-agents` Step 2. Record the tool-issued ID as the
   dispatch receipt, with the plan version it binds. A name or a prompt is
   not a dispatch.
3. Action unavailable, refused, or empty → write `not dispatched` and ask the
   not-dispatched question from `dispatching-parallel-agents` Step 2.2. A
   high-risk route requires an independent reviewer: omit its self-review
   option and say why. No answer keeps the review pending.
4. Poll that receipt to the deadline. Never say a review is running without
   one.
5. Failure, timeout, or cancel → the review stays pending. This skill may
   retry once, through a new receipt linked to the failed one and a report
   location with the next attempt number, after correcting the cause that
   attempt named; a late result from the failed attempt, or a file at its
   path, is rejected. A second failure → return the pending review and both
   receipts to the caller.

## Step 3: Receive, disposition, return

1. Read the report at the current attempt's location, opening the file when
   only its location came back. Its `Plan version` differs from the bound
   version, or it is missing or unreadable → the review stays pending.
2. Print the plan's version again. It changed during the review → the review
   is void; report the edit to the caller and keep the review pending.
3. Give every finding one disposition:
   - `accepted` → the author corrects it in a successor version
   - `rejected` → record the evidence that refutes it
   - `decision` → the index's `Approval rule` owner decides it, at
     presentation
   - no task ID, section, or `path:line` cited → record it as
     `not a finding: uncited`
4. The report is the review record. Write into its header the dispatch
   receipt, the report path, every disposition, who decided each, and the
   date. Write no row in the plan's decision ledger: the plan's presentation
   and its later approval row cite the report path in `Bound evidence`.
5. Return to the caller's pending step with the report path and its
   dispositions:
   - an `accepted` blocker → return to the pending `writing-plans` step; the
     correction is a proposed successor, and a high-risk successor comes back
     here before it is presented
   - no open blocker → return to the caller, or to the user who asked
   - high-risk route → the caller presents nothing until this review has
     returned and every blocker is dispositioned; a pending or void review
     holds the presentation
6. Never re-enter `writing-plans` or start an executor from here.

## Gotchas

- Self-review is not this review. The author's own checks in `writing-plans`
  Step 3 read the plan with the assumptions that wrote it; counting them as
  the independent review presents a high-risk plan no second reader saw.
- A reviewer that edits the plan voids the review: the version it read no
  longer exists, and its findings describe text nobody approved. Step 3.2
  catches it by printing the version again.
- A finding without a section citation is not a finding. It cannot be
  dispositioned, traced into a successor, or checked by the next review.
