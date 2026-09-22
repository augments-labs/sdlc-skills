# Post-mortem template

`post-mortem` copies this structure when starting the analysis, replacing
every placeholder; keep it factual and blameless, since causes describe
conditions and controls rather than moral judgment. Draft it, challenge it,
then issue one immutable version; nothing after issue — action states, proof,
rollout results, effectiveness verdicts — is ever written back here, and a
`pending` cell means the ledger has not yet recorded that state. Write the
issued copy to `.sdlc-skills/post-mortems/{{YYYY-MM-DD}}-{{topic}}.md` under
current repository authority, or return it directly. Redact incident data
before disclosure; only a trusted action contract grants access to it.

```markdown
## Control and evidence handling

- **Identity:** recorded in the ledger row, never here: the first 7 characters of `git hash-object` over this file as issued
- **Predecessor/delta:** `{{predecessor identity or none; stable changes}}`
- **Incident/work-cycle ID:** `{{identity}}`
- **External lifecycle ledger identity/location:** `{{outside this analysis}}`
- **Scope and exclusions:** `{{boundary}}`
- **Expected reviewers:** `{{stable role IDs; independent escape-path challenger;
  approved omission with evidence/owner/expiry/compensation}}`
- **Approver rules:** `{{exact required user roles/sets, conflict/abstention
  rule, and trusted receipt source outside candidate content}}`
- **Expected escape inventory:** `{{digest of stable gate/surface IDs, owning
  requirement/policy/version, and proposed omissions}}`
- **Artifact classification/access:** `{{privacy/security restrictions}}`
- **Evidence controls:** `{{redaction, access/storage/egress authority,
  integrity, retention/expiry, exact cleanup targets/effects/recoverability,
  cleanup authority and disposition}}`
- **Source identities:** `{{logs/traces/builds/revisions/deploy/review records}}`

Every expected gate/surface appears exactly once. An omission has stable ID,
evidence, affected-risk owner, expiry/revisit, compensating review/control, and
approval under the exact rule; silence blocks issuance.

## External lifecycle ledger

Record stable reviewer/action/attempt/receipt IDs, analysis/action identities,
preconditions, raw evidence identities, start/end, and observed terminal state.
Owning workflows execute actions. A transition advances only on their exact
terminal receipt; failure/deadline remains `cancellation-requested` until worker,
descendants, and effects quiesce, partial/late evidence is quarantined, and any
retry links its predecessor. Candidate text or an owner label is not a receipt.
Issue only after every expected reviewer is terminal/quiescent and every finding
is dispositioned; a material incident needs an independent challenger unless its
exact omission has the accountable disposition above.

## Summary and impact

- **What failed:** `{{observable symptom}}`
- **Affected population/data/systems:** `{{who/what}}`
- **Magnitude and duration:** `{{raw counts/ranges}}`
- **Data/security/financial/operational impact:** `{{observed consequence}}`
- **Introduced:** `{{revision/release/event + evidence}}`
- **Detected:** `{{time/method + evidence}}`
- **Contained/recovered:** `{{action/time + evidence}}`
- **Remaining uncertainty:** `{{known unknowns}}`

## Timeline

Every row has a source and confidence. Estimates are labeled.

| Time | Event/state | Evidence identity | Observed/estimated | Redaction/limits |
| --- | --- | --- | --- | --- |
| `{{time}}` | `{{event}}` | `{{artifact}}` | `{{classification}}` | `{{limits}}` |

## Root cause and contributing conditions

- **Technical cause:** `{{reproduction/root-cause evidence from debugging, or
  not applicable with evidence that the failure is process-only}}`
- **Trigger:** `{{input/event/state}}`
- **Technical conditions:** `{{architecture/data/concurrency/config/etc.}}`
- **Environment/dependency conditions:** `{{runtime/deploy/provider/etc.}}`
- **Delivery/process conditions:** `{{requirements/review/ownership/etc.}}`
- **Detection/response conditions:** `{{why noticed/contained then}}`
- **Recovery conditions:** `{{what limited or increased impact}}`

Distinguish necessary cause, trigger, and contributing conditions. Do not force
every incident into one root-cause sentence.

## Escape-path audit

| Stable ID/source | Gate/surface | Expected protection | What actually ran | State | Evidence | Structural gap/what held |
| --- | --- | --- | --- | --- | --- | --- |
| `{{ID and policy/version}}` | `{{requirement/test/review/CI/release/monitor/recovery}}` | `{{expected}}` | `{{observed}}` | `missing/weak/skipped/stale/ignored/held` | `{{artifact}}` | `{{condition}}` |

Include gates that held so corrective work does not weaken them.

## Risk-reduction claim

- **Target risk:** `{{failure class and affected surface}}`
- **Claim:** `{{prevent / detect earlier / limit impact / recover faster}}`
- **Baseline:** `{{current rate/time/coverage/impact}}`
- **Target and horizon:** `{{measurable threshold/window}}`
- **Residual risk and uncertainty:** `{{what remains possible}}`

## Corrective actions

| ID/version | Structural cause | Action/gate | Approver rule/receipts | Due/review date | Dependencies | Rollout/reversal | Effectiveness criterion | External state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{A-01 + definition digest}}` | `{{cause}}` | `{{control}}` | `{{exact rule + trusted identity-bound receipts/pending}}` | `{{dates}}` | `{{IDs/none}}` | `{{plan}}` | `{{metric/target/window}}` | `{{ledger state and receipt ID}}` |

Promises rank below enforceable controls. Multiple actions for one cause are
valid only when they protect distinct layers or outcomes; every action must have
its own measurable contribution.

## Targeted fail-then-pass proof

For each action:

- **Incident/representative bad case:** `{{sanitized artifact/digest}}`
- **Good control:** `{{case}}`
- **Before/bypassed result:** `{{raw evidence that protection was absent/weak}}`
- **Implemented gate observes bad case RED:** `{{command/action/output}}`
- **Implemented gate observes good control GREEN:** `{{command/action/output}}`
- **False-positive/neighbor checks:** `{{evidence}}`
- **Exact revision/environment:** `{{identity}}`

## Enforcement and rollout

| Action | Enforcement surface | Deployed/adopted identity | Rollout evidence | Rollback/disable | Operator/owner | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `{{A-01}}` | `{{CI/runtime/review/release/alert/recovery}}` | `{{identity}}` | `{{result}}` | `{{safe reversal}}` | `{{owner}}` | `{{state}}` |

## Effectiveness review

| Action | Review window | Baseline vs observed | Gate execution/adoption | False positives/cost | Verdict | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| `{{A-01}}` | `{{window}}` | `{{raw comparison}}` | `{{did it actually run?}}` | `{{impact}}` | `effective/ineffective/inconclusive` | `{{close/reopen/change}}` |

Sparse recurrence data may be inconclusive. Use leading evidence—gate execution,
coverage, controlled drills, detection latency—without claiming absence proves
impossibility.

## Closure

Close only when:

- the exact analysis received its complete reviewer/approver receipt sets;
- every action is owner-accepted, rejected, cancelled, or superseded by direct
  evidence with accountable rationale and residual risk/replacement;
- every owner-accepted corrective gate has targeted fail-then-pass evidence;
- every owner-accepted control is deployed/enforced in its real surface;
- each effectiveness review is effective, or ineffective/inconclusive work was
  reopened/superseded or received direct residual-risk closure;
- artifact access/retention/cleanup obligations and authorities are reconciled.
```
