# Architecture Decisions worked example

This file is a filled example and failure catalogue to compare a draft against, not a file to copy.

## What each field must contain

- **Identity** — a rule, not a value: the hash of the decision content the owner
  saw, recorded in the ledger row; every normative edit is a successor and
  reopens the decision.
- **Approval rule** — one accountable owner or the complete required approval
  set and conflict rule. A partial answer cannot accept the ADR.
- **Successor delta/impact** — stable IDs cannot be recycled. An accepted
  successor invalidates predecessor-bound artifacts until owner reconciliation.
- **Status** — only draft/proposed lives here. The external ledger owns accepted,
  rejected, cancelled, in-force, superseded, and retired state without mutating
  the decision subject.
- **Lifecycle evidence** — authenticates the owner's exact answer/version and
  every conformance/terminal transition; an ADR cannot self-authenticate.
- **Alternatives considered** — compare at least two real options in total, including the selected Decision. Give the reason each alternative lost.
- **Status quo/defer** — evaluate it when viable; otherwise state the evidence
  that disqualifies it rather than silently assuming change.
- **Evidence/uncertainty** — identity and limits, not "research says." Assumptions
  need stable IDs, evidence/state, validation, owners, expiry, and failure paths.
- **Independent challenge** — dispatch exists only after a nonempty attempt ID.
  Failure/deadline enters cancellation-requested until worker, descendants, and
  effects are quiescent; quarantine partials. A retry is a linked successor and
  rejects predecessor late results/mutations. Missing or unresolved review blocks.
  A self-challenge never issues `clear`, so approval rests on the decision
  owner accepting the residual risk that label carries.
- **Conformance/retirement contract** — defines evidence required to prove the
  accepted choice is implemented or no governed surface remains. Actual results
  stay in the external ledger.

## Worked example

This proposed example assumes its independent challenge has completed and is
recorded externally. The owner's decision and adoption evidence are still pending.

```markdown
## ADR: Background jobs run on a database-backed queue, not an external broker

**Status:** proposed

**Identity:** recorded in the ledger row, never here: this section's identity
under the Identity rule of the artifact layout reference (`using-sdlc-skills`)

**Predecessor:** none

**Approval rule:** service technical lead is the one accountable decision owner.

**Successor delta:** initial; decision `D-001` and assumption `A-001` added.

**Bound inputs:** approved background-work requirement `REQ-017`; measured
current-load observation `obs-jobs-2026-07-01`, valid for 90 days.

**Downstream impact:** initial decision; no predecessor-bound consumers.

**Independent challenge contract:** platform reviewer role `reviewer-12`, due
2026-07-05; report must challenge operations and reversal. The review owner
cancels on deadline and confirms quiescence before reassignment.

**External challenge ledger:** controlled review record `review-024`; actual
dispatch receipts, terminal outcomes and finding dispositions bind to this
ADR's identity there, outside this proposal.

**Challenge artifact controls:** internal data only; approved repository read,
controlled report store, 90-day retention; review owner may delete that exact
report after expiry and recovery is not required.

**External lifecycle ledger:** controlled decision record `decision-024` will
bind the lead's decision and later conformance evidence to this ADR's identity;
approval and adoption remain pending until those events occur.

**Context:** The service must send emails and run report generation outside the
request path. Load today is tens of jobs per hour, run by a two-person team
with no dedicated operations capacity. The system already runs a relational
datastore with row-level locking.

**Decision:** Jobs are rows in a `jobs` table; a worker inside the app process
claims them with `SELECT ... FOR UPDATE SKIP LOCKED` and retries with capped
exponential backoff.

**Alternatives considered:**

- Dedicated message broker — rejected: a second stateful service to deploy,
  monitor, and back up; its throughput and routing features are unneeded at
  this load and the team can't operate it well.
- In-process task queue with no persistence — rejected: jobs vanish on deploy
  or crash, and email delivery is user-visible loss.

**Evidence and uncertainty:** measured tens of jobs/hour in the current release;
revisit if sustained queue delay exceeds the accepted service threshold or the
operations owner changes.

**Assumptions and dependencies:**

| ID | Evidence/state | Validation action | Owner | Expiry/reopen | Failure response |
| --- | --- | --- | --- | --- | --- |
| `A-001` | current load observation | remeasure queue load | service lead | 90 days or threshold breach | propose a successor ADR |

**Consequences and reversal:** No new infrastructure to operate, and jobs survive restarts.
In exchange, job throughput is bounded by the datastore, heavy job bursts can
contend with request traffic on the same database, and moving to a broker
later means a worker rewrite — acceptable while load stays orders of magnitude
below the datastore's headroom.

**Conformance/retirement contract:** queue integration tests and deployed-schema
inspection must pass on the implementation revision before in-force state.
```

## Common failure patterns

- **The missing lifecycle record.** Work shipped, but no bound external evidence
  says whether the proposal was accepted or conformed.
- **The amended ADR.** The decision changed in place. Preserve it; a replacement
  links back, and only acceptance makes the old identity externally superseded.
