# Project or initiative assurance matrix

`verification-strategy` instantiates this before writing any gate, filling
`Risk inventory` and `Risk-to-gate matrix` first. Write the completed artifact
to `.sdlc-skills/verification/{{YYYY-MM-DD}}-{{topic}}.md` unless the user or
project sets another durable location.

```markdown
## Control

- **Scope:** `project | initiative {{name and exclusions}}`
- **Status:** `draft | proposed` (approval and lifecycle state live in the external
  decision ledger; do not mutate this file to mirror it)
- **Identity:** recorded in the ledger row, never here: the first 7 characters of
  `git hash-object` over this artifact's own text as issued
- **Supersedes:** `{{predecessor normative identity, or none; declare this only
  in the replacement and never edit the predecessor}}`
- **Bound inputs:** `{{exact requirement, risk, migration, platform/mode,
  environment, threat, and operational identities plus freshness/invalidation}}`
- **Successor delta:** `{{initial, or every stable risk/gate/disposition/
  promotion ID as added / changed / removed / preserved; removals need approval}}`
- **Downstream impact:** `{{predecessor-bound gates, plans, reviews, evidence,
  CI/promotion, release, and consumers; owner reconciliation state/gate}}`
- **Migration contract:** `{{version, or reason not applicable}}`
- **Assurance author:** `{{person/process}}`
- **Independent assurance challenger:** `{{required independent role/process,
  deadline, timeout/cancel owner/action, required report/verdict; actual attempt
  receipts and outcomes stay in the External challenge ledger; or exact
  accountable exception with consequence, compensating gate, and expiry}}`
- **External challenge ledger:** `{{predeclared reviewer-owned location outside
  the matrix candidate; predecessor/successor attempts, cancellation-requested/
  quiescent state, quarantined partials, reports/findings/dispositions, and late-
  result rejection bind to the identity}}`
- **Challenge artifact controls:** `{{data class, access, worker/provider/
  storage/egress authority, location, retention/expiry, exact cleanup targets/
  effects/recoverability, cleanup authority, and disposition}}`
- **External gate-state/evidence ledger:** `{{gate state, raw run identity,
  integrity, access, retention/expiry, exact cleanup targets/effects/recoverability,
  cleanup authority, and disposition; at
  .sdlc-skills/evidence/YYYY-MM-DD-topic/gate-ledger.md unless the user
  predeclares another path outside this normative candidate}}`
- **Approval rule:** `{{one accountable decision owner, or required approvers
  plus conflict resolver and decision rule}}`
- **Approval gate:** `{{accepted decision shape and owner; actual state/receipt
  stays external; the initiating request does not approve an unseen matrix}}`
- **External decision ledger:** `{{decision-owned location; pending / changes
  requested / approved / rejected / cancelled / superseded by approved normative identity;
  current user-role answer/standing default, owner, time, exact identity}}`
- **Invalidation triggers:** `{{risk, environment, threshold, or contract changes}}`

A proposal names its predecessor but cannot supersede it. Every normative change
creates a successor with an exact stable-ID delta. An approved successor
invalidates predecessor-bound consumers until their owners revalidate or
reconcile; only then may they rely on it.

## Risk inventory

| Risk ID | Failure and consequence | Requirement/invariant | Pre-existing evidence snapshot or gap | Confidence as of identity |
| --- | --- | --- | --- | --- |
| `{{R-001}}` | `{{what can fail and impact}}` | `{{contract reference}}` | `{{immutable reference or gap captured before gate work}}` | `{{current/stale/unknown at version time}}` |

## Risk-to-gate matrix

| Risk | Invariant or threshold | Gate | Command or controlled action | Platform/build mode/environment | Cadence | Required evidence contract | Owner | Protected promotion | Failure response |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{R-001}}` | `{{exact bar}}` | `{{G-001}}` | `{{runnable command/procedure}}` | `{{matrix cell and fixtures/data}}` | `{{change/phase/scheduled/trial/cutover/release}}` | `{{artifact shape, identity binding, threshold, and freshness}}` | `{{owner}}` | `{{what cannot advance}}` | `{{stop/triage/repair/re-run/resume}}` |

## Gate establishment contract

| Gate | State after criteria are evidenced externally | Invocation owner and protected branch/phase | Required green evidence | Required controlled falsification/known-bad red | Required restoration/control evidence | Open work |
| --- | --- | --- | --- | --- | --- | --- |
| `{{G-001}}` | `{{executable / planned / blocked transition criteria}}` | `{{where enforced}}` | `{{command, threshold, state identity, freshness}}` | `{{controlled action and red threshold}}` | `{{restoration threshold}}` | `{{plan task or blocker}}` |

The external ledger records actual state and receipts. Until its criteria are
met, a gate is `planned` or `blocked` and cannot satisfy entry or promotion.
Never copy those mutable results into this normative matrix.

## Control-plane independence

| Gate | Definition/inventory/threshold owner and protected location | Invocation/protected-promotion owner | Target writer may change? | Independent challenge or held-out evidence | Control-change gate and authority |
| --- | --- | --- | --- | --- | --- |
| `{{G-001}}` | `{{immutable/protected source}}` | `{{external CI/branch/promotion control, or planned/blocked}}` | `no / bounded exception` | `{{review, adversarial corpus, mutation evidence}}` | `{{separate action, review, owner}}` |

## Catalogue disposition

| Disposition ID/capability | Gate IDs, or N/A rationale/evidence | Owner | Expiry/revisit | Compensating gate | Approval |
| --- | --- | --- | --- | --- | --- |
| `{{D-001}}` Differential equivalence/characterization | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-002}}` Unit and observable behavior | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-003}}` Static and dynamic safety | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-004}}` Property/fuzz/stress/concurrency | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-005}}` Performance and resources | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-006}}` Security | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-007}}` Platform/build-mode parity | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-008}}` Production-like/QA/canary/soak/recovery | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-009}}` Falsifiability/mutation/metric floors | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |
| `{{D-010}}` Skipped/deleted-test and inventory audit | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{...}}` |

N/A is not prose shorthand: every omission needs current rationale/evidence,
owner, expiry/revisit, compensating gate, and complete approval.

## Differential oracle

- **Source runner and immutable identity:** `{{...}}`
- **Target runner and immutable identity:** `{{...}}`
- **Input/corpus inventory and digest:** `{{...}}`
- **Held-out/adversarial corpus owner and access boundary:** `{{...}}`
- **Normalization and comparison:** `{{...}}`
- **Approved deviations:** `{{migration-contract IDs}}`
- **Deliberate divergence procedure and required red:** `{{...}}`
- **Restoration procedure and required green:** `{{...}}`

Remove this section only with a rationale when equivalence is not a material
risk.

## Test-inventory audit

- **Required inventory source/digest:** `{{suites, cases, corpora, shards, cells}}`
- **Scale and execution-loss decision:** `{{tiny fixed inventory whose risk is
  decided by an existing-command path/count floor | larger or dynamic inventory
  plus the named risk that floor cannot decide and pre-edit YAGNI challenge}}`
- **Protected control location and owner:** `{{outside target-writer ownership}}`
- **Allowed skips/quarantines:** `{{exact approved exclusion/deviation version,
  owner, reason/evidence, expiry/revisit, and compensating gate; generic skip is
  a blocking inventory mismatch and never an execution receipt}}`
- **Comparison action:** `{{tiny fixed: existing-command path/count assertion
  whose sole-test/layer deletion is red | larger/dynamic: recursive declared-root
  discovery plus exact multiset reconciliation of eligible runtime receipts}}`
- **Self-protection:** `{{risk-selected applicable attacks and smallest deciding
  falsification: empty inventory; validator/manifest removal; valid invocation
  rewiring; skip/focus/todo; case/cell deletion, duplication, addition,
  hollowing, narrowing, non-execution, or forged receipts; controller/launcher
  hollowing only when that mechanism exists; explicit rationale for omissions}}`
- **Resource bound and cleanup:** `{{bounds for the selected existing command or
  controller; only when a real controller launches descendants, include a
  representative escaped child/process-group failure}}`
- **Control-change gate:** `{{external owner that detects valid rewiring or
  whole-plane replacement; otherwise protected promotion is planned/blocked}}`
- **Failure response:** `{{who blocks and reopens affected work}}`

Keep every risk-applicable self-protection class as an explicit acceptance cell
whose red/restoration receipts stay external. Choose the smallest falsification
that decides the declared claim. Small size does not exempt a real risk; an
inapplicable class is omitted with mechanism evidence and rationale rather than
built solely so it can be tested. A tiny fixed inventory does not add a
controller, parser, launcher, manifest, receipt protocol, or dependency unless
the named execution-loss risk survives its simple floor and the pre-edit YAGNI
challenge accepts that added surface.

Gate, challenge, and decision receipts stay in their predeclared external
ledgers. Copying them here mutates the candidate they judge. A later repository
status mirror is a new candidate to verify and review-classify.

## Cadence and promotion map

| Promotion | Required gate IDs | Maximum evidence age | Authority after green |
| --- | --- | --- | --- |
| `{{change/phase/trial expansion/cutover/decommission/release}}` | `{{G-...}}` | `{{freshness}}` | `{{owner or automated policy}}` |

## Known gaps and deviations

| Item | Consequence | Compensating gate | Owner | Expiry/revisit | Required acceptance owner and external decision ledger |
| --- | --- | --- | --- | --- | --- |
| `{{gap/deviation}}` | `{{impact}}` | `{{G-...}}` | `{{owner}}` | `{{condition/date}}` | `{{accepted decision shape and version-bound ledger location}}` |
```
