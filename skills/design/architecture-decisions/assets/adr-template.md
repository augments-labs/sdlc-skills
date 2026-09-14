# ADR template

Copyable template behind `../SKILL.md`. Loaded on demand.

## How to use this

- Fill every section; an ADR with an empty section is worse than none — a reader can't tell "considered and rejected" from "never thought about it."
- Write for the reader in six months who has none of today's context. They can see *what* the code does; only you can tell them *why*.
- Prefer one screen, but never omit a decision input, risk, authority, or
  recovery fact to hit a size target. Depth may link to the surrounding design.

## The template

```markdown
## ADR: {{decision-title}}

**Status:** {{draft | proposed; decision and lifecycle stay external}}

**Identity:** recorded in the ledger row, never here: the first 7 characters of
`git hash-object --stdin` over this section, from its heading to the next `##`
heading, without trailing blank lines

**Predecessor:** {{prior ADR normative identity or none; proposal only links it}}

**Approval rule:** {{one accountable decision owner, or required approvers plus
conflict resolver and decision rule}}

**Successor delta:** {{initial, or each stable decision/assumption ID as added /
changed / removed / preserved; removed items need owning approval}}

**Bound inputs:** {{exact requirement, design, model, policy, evidence, and
external-fact identities plus freshness/invalidation rules}}

**Downstream impact:** {{predecessor-bound artifacts/consumers, their owners,
external invalidation state, and revalidation/reconciliation gate}}

**Independent challenge contract:** {{reviewer other than sole author, or exact
current design-review identity that covers this ADR; deadline,
timeout/cancel owner/action, required report and verdict; actual dispatch receipts
stay in the External challenge ledger}}

**External challenge ledger:** {{reviewer-owned location; attempt lineage,
cancellation-requested/quiescent state, quarantined partials, report, findings,
and dispositions bound to this identity}}

**Challenge artifact controls:** {{data class, allowed access, worker/provider/
storage/egress authority, location, retention/expiry, exact cleanup targets,
effects, recoverability, cleanup authority, and disposition}}

**External lifecycle ledger:** {{ledger path: this ADR's path with .ledger.md for
.md unless the user sets another, or a returned record; pending / accepted /
rejected / cancelled / in force / superseded by accepted normative identity /
retired, with trusted evidence, time, and exact version}}

**Context:** {{the forces bearing on the decision — the requirement or constraint
that makes a choice necessary, and the facts (scale, team, existing code, hard
deadlines) that rule options in or out}}

**Decision:** {{the choice, in one or two sentences, stated as something the
code will actually do — not "we'll explore X" but "X does Y"}}

**Alternatives considered:**

- {{alternative}} — {{why rejected: what it assumes, where it breaks, what
  ruled it out; repeat for each real alternative}}

**Evidence and uncertainty:** {{sources/versions; confidence; assumptions; what
observation or date reopens the decision}}

**Assumptions and dependencies:**

| ID | Evidence/state | Validation action | Owner | Expiry/reopen | Failure response |
| --- | --- | --- | --- | --- | --- |
| `{{A-001}}` | `{{evidence or unknown}}` | `{{action}}` | `{{owner}}` | `{{condition}}` | `{{block, reverse, or successor decision}}` |

**Consequences and reversal:** {{what this commits us to, data/migration and
operational cost, what it closes off, and a viable reversal/supersession path}}

**Conformance/retirement contract:** {{implementation and gate required for in
force; owner decision and absence gate required for retirement}}
```

## What each field must contain

- **Title** — the decision as a short active statement: "Session state lives in the datastore, not the process." Not "Database discussion."
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
- **Context** — only what a reader needs to judge the decision without re-running the investigation. A requirement, a measured constraint ("p99 must stay under 200 ms"), an existing commitment ("the rest of the system is synchronous"). Opinions and aspirations don't belong here.
- **Decision** — concrete enough that someone could verify it against the code. "Retries happen at the queue consumer with exponential backoff" is a decision; "we'll make messaging robust" is a wish.
- **Alternatives considered** — compare at least two real options in total, including the selected Decision. Give the reason each alternative lost. This is the load-bearing section: it stops a later reader from re-opening a settled question and from silently reversing the decision. "Rejected: can't do X" beats "X is nicer."
- **Status quo/defer** — evaluate it when viable; otherwise state the evidence
  that disqualifies it rather than silently assuming change.
- **Consequences** — honest about both directions: what you gain *and* what you now own (an operational burden, a migration path, a capability you gave up). A decision with only upsides was not examined.
- **Evidence/uncertainty** — identity and limits, not “research says.” Assumptions
  need stable IDs, evidence/state, validation, owners, expiry, and failure paths.
- **Independent challenge** — dispatch exists only after a nonempty attempt ID.
  Failure/deadline enters cancellation-requested until worker, descendants, and
  effects are quiescent; quarantine partials. A retry is a linked successor and
  rejects predecessor late results/mutations. Missing or unresolved review blocks.
- **Conformance/retirement contract** — defines evidence required to prove the
  accepted choice is implemented or no governed surface remains. Actual results
  stay in the external ledger.

## Worked example

This proposed example assumes its independent challenge has completed and is
recorded externally. The owner's decision and adoption evidence are still pending.

```markdown
## ADR: Background jobs run on a database-backed queue, not an external broker

**Status:** proposed

**Identity:** recorded in the ledger row, never here: the first 7 characters of
`git hash-object --stdin` over this section, from its heading to the next `##`
heading, without trailing blank lines

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

- **The diary entry.** Context recounts the meeting instead of the forces. If a sentence wouldn't change whether the decision is right, cut it.
- **The verdict without the trial.** Decision recorded, alternatives missing. Six months later someone re-proposes the rejected option and the cycle repeats.
- **The missing lifecycle record.** Work shipped, but no bound external evidence
  says whether the proposal was accepted or conformed.
- **The amended ADR.** The decision changed in place. Preserve it; a replacement
  links back, and only acceptance makes the old identity externally superseded.
- **The resume line.** Consequences list only benefits. If reversing the decision would be expensive or impossible, that belongs in the record — it's the warning label.
