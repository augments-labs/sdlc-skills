# Migration contract template

`migration-strategy` opens this before its steps below; each step fills the
section it names. Use this template for
`.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-migration.md`, replacing every
placeholder; remove an inapplicable row only with a recorded rationale.

```markdown
## Normative control

- **Status:** `draft | proposed` (review, decision, and execution state stay external)
- **Identity:** recorded in the ledger row, never here: the first 7 characters of
  `git hash-object` over this artifact's own text as issued
- **Predecessor:** `{{prior normative identity or none; a proposal only links it}}`
- **Scope:** `{{included transformation and explicit exclusions}}`
- **Source revision:** `{{immutable revision or snapshot}}`
- **Target contract/design revision:** `{{approved revision}}`
- **Approval rule:** `{{one accountable decision owner, or required approvers
  plus conflict resolver and decision rule}}`
- **Successor delta:** `{{initial, or every stable fact/unknown/mapping/phase/
  policy ID as added / changed / removed / preserved; removals need owning approval}}`
- **Downstream impact:** `{{predecessor-bound assurance, plan, review, execution,
  release, and operational consumers; owners and reconciliation gates}}`
- **Independent challenge coverage:** `{{source/domain and operations/data roles;
  each omitted role has skip ID, rationale/evidence, owner, expiry/revisit,
  compensating challenge, and approval}}`
- **Independent challenge contract:** `{{role IDs, terminal deadlines, and
  timeout/cancel owners/actions; each report uses the shipped migration
  challenger prompt and its clear, revise, or inconclusive verdict; actual
  attempt receipts belong in the External challenge ledger}}`
- **External challenge ledger:** `{{reviewer-owned location; dispatch IDs,
  predecessor/successor lineage, cancellation-requested/quiescent state,
  quarantined partials, succeeded/failed/timed-out/cancelled outcomes, reports,
  findings, and dispositions bind this identity}}`
- **Challenge artifact controls:** `{{data class, allowed access, current
  worker/provider/storage/egress authority, location, retention/expiry, exact
  cleanup targets/effects/recoverability, cleanup authority, and disposition}}`
- **External decision ledger:** `{{decision-owned location; pending / changes
  requested / approved / rejected / cancelled / superseded by approved normative
  identity; owner, time, and trusted evidence bound to this version}}`
- **External execution ledgers:** `{{append-only shard, source-change, live-state,
  convergence/failure, and decommission locations; each binds this version plus
  integrity, access, retention/expiry, exact cleanup targets/effects/
  recoverability, cleanup authority, and disposition}}`
- **Invalidation triggers:** `{{facts or target changes that reopen approval}}`

A proposal links its predecessor but does not supersede it. Every normative
change creates a successor and exact stable-ID delta. An approved successor
invalidates predecessor-bound consumers externally until each owner revalidates
or reconciles; only then may they rely on it.
Never copy mutable review, decision, heartbeat, queue, result, or action state
into this contract.

## Source-fact inventory

Facts describe observable commitments, not the source implementation's shape.

| ID | Observable behavior, data, or obligation | Evidence and revision | Consumers/surfaces | Freshness and confidence |
| --- | --- | --- | --- | --- |
| `{{F-001}}` | `{{fact}}` | `{{artifact, observation, or result}}` | `{{affected consumers}}` | `{{current/stale/unknown}}` |

Inventory public behavior and contracts, durable data, supported platforms and
build modes, operational procedures, security and privacy obligations, resource
floors, known defects, and intentionally unsupported cases as applicable.

## Preservation and deviation contract

| Fact ID | Classification | Required target outcome | Rationale | Owning requirement/decision and approval |
| --- | --- | --- | --- | --- |
| `{{F-001}}` | `preserve / intentional deviation / unresolved` | `{{invariant or delta}}` | `{{why}}` | `{{artifact/version, owner, direct evidence}}` |

Every unresolved item blocks unless current evidence proves it irrelevant or
its owner approves an exact exclusion with a compensating gate. Known source
defects are not silently preserved or fixed: classify them explicitly. The
migration contract cannot originate product/domain/public-contract change;
reopen and approve its owning artifact, then reference that exact version here.

## Unknown contract

| Unknown ID | Evidence/state | Validation action | Owner | Expiry/revisit | Failure response | Relevance disposition |
| --- | --- | --- | --- | --- | --- | --- |
| `{{U-001}}` | `{{evidence or unknown}}` | `{{action}}` | `{{owner}}` | `{{condition}}` | `{{block/revise/abort}}` | `{{relevant and blocking, or proved irrelevant/approved exclusion plus compensating gate}}` |

No unknown advances merely because it was judged unlikely. Its exact relevance
evidence or approved exclusion must remain current.

## Transition and translation

- **Approach:** `incremental | cutover | hybrid`
- **Why this approach:** `{{trade-offs and rejected alternatives}}`
- **Compatibility direction:** `{{old reads new, new reads old, both, or none}}`
- **Mixed-version interval:** `{{legal intermediate states and duration}}`

| Source case | Target mapping | Intermediate state | Unknown/invalid input | Reversal |
| --- | --- | --- | --- | --- |
| `{{case}}` | `{{rule}}` | `{{state}}` | `{{reject/quarantine/preserve}}` | `{{reverse rule or loss}}` |

## Representative trial slice

- **Coverage inventory:** `{{stable fact/risk/platform-mode/data-shape/
  operational-cell IDs, source identity, count, and digest}}`
- **Coverage mapping:** `{{selected cell IDs and why they expose the riskiest
  translations, boundary combinations, and operational paths}}`
- **Uncovered cells:** `{{exact exclusion/deviation identity, owner, evidence,
  expiry/revisit, compensating gate, and approval; otherwise blocking}}`
- **Selection:** `{{slice and why it covers the riskiest paths}}`
- **Scale and environment:** `{{representative boundary}}`
- **Entry evidence:** `{{required approved inputs and gate references}}`
- **Required outcome:** `{{preserved facts, intentional deltas, and transition condition}}`
- **Exit gate references:** `{{assurance gate IDs; commands and thresholds stay in that matrix}}`
- **Failure response:** `{{pause, revise shared rule, abort, or redesign}}`
- **Expansion decision owner:** `{{who may authorize the next phase}}`

## Partitions and ownership

- **Stable inventory:** `{{machine-derived source, identity, count, digest}}`
- **Partition rule:** `{{exclusive deterministic mapping}}`
- **Ownership policy:** `{{attempt/lease, heartbeat, expiry, quiescence,
  quarantine, release/reclaim authority, and late-result rule}}`
- **External shard ledger:** `{{predeclared location and record identity schema}}`

| Shard | Input identity/digest | Dependencies | Required evidence | Skip-eligibility contract |
| --- | --- | --- | --- | --- |
| `{{S-001}}` | `{{inputs}}` | `{{none or IDs}}` | `{{assurance gate ID}}` | `{{approved exclusion/deviation class or never}}` |

The external ledger owns `queued → claimed → transformed → verified`, plus
`failed`, `reopened`, and `intentionally skipped`. Every skip binds an approved
exclusion/deviation version, owner, evidence, expiry/revisit, and compensating
gate; a generic skip blocks promotion. Every ownership transfer retains old and
new attempts, quiescence, quarantined partials, reason, authority, and time.

## Source evolution during migration

- **Policy:** `source freeze | versioned change-intake lane`
- **Bound source baseline:** `{{immutable identity and observed time}}`
- **Queue derivation:** `{{action that discovers every later source revision}}`
- **Maximum permitted lag:** `{{count/time/risk threshold and owning gate}}`
- **Rebaseline trigger/authority:** `{{condition, decision owner, affected contracts}}`
- **External source-change ledger:** `{{predeclared location and record identity schema}}`

External ledger rows use this schema:

| Change ID/source revision | Affected facts/shards | Classification | Owner | State, terminal disposition, and evidence |
| --- | --- | --- | --- | --- |
| `{{C-001 / revision}}` | `{{fact/shard IDs}}` | `{{preserve / approved deviation / unresolved}}` | `{{owner}}` | `queued / in progress / applied and verified / source reverted or absent / approved deviation — {{exact evidence and authority}}` |

Derive this queue from every source change after the bound baseline. Reconcile
identities/counts exactly once. Generic `rejected`, unowned, missing, unresolved,
or over-threshold changes block the affected phase and release promotion.

## Mutable live-state catch-up

- **Applicability:** `{{mutable data/work exists, or N/A with evidence}}`
- **Snapshot/high-water binding rule:** `{{how execution records the exact boundary}}`
- **Post-boundary capture:** `{{change log, stream, dual-write direction, or writer freeze}}`
- **Ordering/idempotency/deduplication:** `{{keys, rules, retry behavior}}`
- **Maximum permitted lag:** `{{count/time threshold and owning gate}}`
- **Writer-freeze/cutover authority:** `{{owner and exact boundary}}`
- **External live-state ledger:** `{{predeclared location and record identity schema}}`

External ledger rows use this schema:

| Stream/partition | Bound baseline | Captured range | Terminal disposition | Reconciliation evidence |
| --- | --- | --- | --- | --- |
| `{{stream}}` | `{{through watermark}}` | `{{range identities}}` | `{{applied once and reconciled / reversed or absent with source evidence / approved rejection or deviation under owning contract}}` | `{{gaps/duplicates/order/lag gate and raw result}}` |

Every accepted write or work item after the snapshot appears exactly once in
one exact terminal disposition. Generic rejection, missing, duplicate, misordered,
unresolved, or over-lag state blocks cutover and promotion.

## Convergence and failure queue

- **External convergence/failure ledger:** `{{predeclared location; raw counts,
  failure instances, corrections, and re-audits bind this identity}}`
- **Reconciliation invariant:** `{{total equals every exclusive state across
  shard, source-change, and live-state ledgers exactly once}}`

| Failure class | Evidence contract | Pause threshold | Shared-rule correction owner | Re-audit derivation | Resume authority |
| --- | --- | --- | --- | --- | --- |
| `{{class}}` | `{{queue/query/result shape}}` | `{{condition}}` | `{{owner/rule version}}` | `{{affected-set action}}` | `{{owner}}` |

A percentage is insufficient. Skipped work counts only with its exact approved
disposition; otherwise reconciliation is blocking.

## Pause, abort, cutover, and rollback

- **Global and phase pause conditions:** `{{conditions and owner}}`
- **Abort conditions:** `{{conditions that end the approach}}`
- **Cutover entry:** `{{required gate references and evidence freshness}}`
- **Cutover authority and procedure:** `{{owner and ordered actions}}`
- **Named rollback target:** `{{known-good immutable state}}`
- **Point of no return:** `{{irreversible action, if any, and direct authority}}`
- **Recovery objective and validation:** `{{time/data bounds and post-restore gate}}`

## Retained artifacts

| Artifact | Immutable identity | Purpose | Location | Data class/access | Retention owner/period | Restoration check |
| --- | --- | --- | --- | --- | --- | --- |
| `{{source snapshot}}` | `{{digest/revision}}` | `{{rollback/audit}}` | `{{location}}` | `{{classification/allowed actors}}` | `{{owner/period}}` | `{{gate reference}}` |

## Decommission and retained-source retirement

- **External decommission ledger:** `{{predeclared append-only location}}`
- **Entry contract:** `{{retention/rollback window, soak, assurance gates, and
  zero/dispositioned consumers, traffic, readers, writers, jobs, queues, source
  changes, and live-state deltas}}`
- **Destructive-target binding:** `{{selection rule and required exact runtime/
  data/config/artifact identities before each decision}}`
- **Policy obligations:** `{{audit, legal, privacy, support, and recovery duties}}`
- **Direct-authority contract:** `{{owner answer bound to exact targets/action;
  a resumed partial action needs fresh authority for remaining targets}}`
- **Remaining recovery / point of no return:** `{{retained minimum or accepted loss}}`
- **Post-action gate:** `{{absence, target health, data integrity, and unexpected-use gates}}`

The external state graph is `not eligible → eligible → approved → executing →
executed awaiting validation → verified`. Before execution, `cancelled` or
`superseded` closes the attempt. `partial`, `failed`, or `validation failed`
records action evidence, remaining targets, recovery, and point of no return;
it advances only to `recovered`, `rolled back`, or fresh exact-target approval.
Those states block release, cleanup, and success claims.

Cutover, elapsed time, or zero traffic never authorizes decommission. Planning
owns the action; verification owns entry and post-action proof. Preserve minimum
evidence and recovery artifacts after old runtime or data is removed.

## Downstream handoffs

- `verification-strategy` consumes this identity plus external-ledger
  schemas, risks, and terminal states and owns executable gates.
- `writing-plans` consumes the approved identity and current external
  ledger identities; it owns tasks, not migration policy or runtime state.
- Review consumes source, target, and equivalence mappings; release readiness
  consumes the identity plus exact current ledger identities.
```
