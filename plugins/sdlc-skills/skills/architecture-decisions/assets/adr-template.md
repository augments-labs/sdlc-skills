# ADR template

`architecture-decisions` opens this before Step 1's actions; it owns the
fields the steps below fill. Append the drafted, `proposed` ADR to
`.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
preserving what is already there. Fill every section — an ADR with an empty
section reads as "never thought about it," not "considered and rejected" —
and write for a reader in six months who has none of today's context. Prefer
one screen, but never omit a decision input, risk, authority, or recovery
fact to hit a size target.

```markdown
## ADR: {{decision-title}}

**Status:** {{draft | proposed; decision and lifecycle stay external}}

**Identity:** recorded in the ledger row, never here: this section's identity
under the Identity rule of the artifact layout reference (`using-sdlc-skills`)

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
current design-review identity that covers this ADR; deadline and
timeout/cancel owner/action; the report uses the shipped ADR challenger prompt,
and approval waits for its clear verdict; actual dispatch receipts stay in the
External challenge ledger. Reversible choice, or no dispatch action → the
author's own counter-case against that same contract, labelled self-challenge}}

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
