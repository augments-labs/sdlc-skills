# Visual evidence record template

`visual-ui-verification` opens this before any capture and fills the `Run`
header first. Keep it outside the candidate identity; record where the filled
copy and its captures live in `Evidence controls` below, alongside one row per
required observation using stable `{{double-curly}}` values.

```markdown
## Run

- **Run ID / time:** `{{stable attempt identity and UTC interval}}`
- **Candidate:** `{{immutable source/artifact identity, or working-tree digest of staged, unstaged, and untracked non-ignored paths}}`
- **Ignored inputs:** `{{path and SHA-256 of each ignored input the launch path reads (build output, generated assets, local configuration), recomputed before the verdict; or none}}`
- **Launch path:** `{{command or controlled action}}`
- **Acceptance source:** `{{approved full design path/version, requirements and
  rubric identity; include flows, states, conditions and decisions outside any
  preview; or, with no approved design, the design locations checked and the
  acceptance criteria identity or the pre-change capture identity}}`
- **Selected visual references:** `{{keyed collection applicable to this
  candidate, copied field for field from the approved design and, when
  plan-bound, the approved plan; or not applicable}}`

| Reference ID | Decision ID | Medium | Approved design artifact version | Artifact locator | Artifact version | Content digest | Selection ID | Rendering-input identity | Freshness evaluator | Normative conditions | Distinguishing invariants |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{VR-001}}` | `{{D-001}}` | `{{medium}}` | `{{design version}}` | `{{stable path, route, or artifact ID}}` | `{{immutable version, revision, or capture ID}}` | `{{selected content digest}}` | `{{stable selection ID}}` | `{{immutable rendering-input identity}}` | `{{exact freshness check}}` | `{{normative states/viewports/themes/fixtures/captures}}` | `{{observable distinguishing traits}}` |

- **Freshness evidence:** {{one current outcome—`pass`, `mismatch`, `unavailable`,
  or `error`—per applicable Reference ID, with its evaluator receipt or pending
  recovery route}}
- **Plan binding:** `{{not plan-bound, or approved plan/task identity plus each
  Reference ID → conformance evaluator ID mapping}}`
- **Environment:** `{{platform, build mode, runtime, display or terminal}}`
- **Capture tool:** `{{tool, version, configuration, digest}}`
- **Observer / authority:** `{{who inspects; mechanical or human-owned criteria;
  accountable human set and conflict rule when human-owned}}`
- **Data / effects:** `{{authorized environment, data, actions, recovery}}`
- **Evidence controls:** `{{external location, access, integrity, retention,
  exact cleanup targets and authority}}`
- **Invalidation:** `{{candidate, input, environment, rubric, or tool changes}}`

## Scenario matrix

Map every applicable design obligation here by stable ID or version plus section
and condition. Name its observation row or other owning gate and actual result.
Unmapped or unrun obligations remain pending, including when no visual comparison
was needed. Do not infer coverage from a similar screenshot.

| Design obligation | Observation row or other gate | Evidence/result |
| --- | --- | --- |
| `{{ID or version + section/condition}}` | `{{VQA row or gate ID}}` | `{{receipt and pass / fail / pending}}` |

| Row | Journey/state | Size | Theme/input/platform | Raw capture + digest | Rendered frame + digest | Observation | Defects | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{VQA-01}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{path + digest}}` | `{{path + digest}}` | `{{what was inspected}}` | `{{IDs or none}}` | `pass / fail / pending` |

- **Capture attempts:** `{{one accepted receipt per required row; every retry,
  duplicate, late result, or superseded frame with digest and disposition}}`

## Calibration

- **Frozen rubric / observer:** `{{identity}}`
- **Known-bad method:** `{{reversible fault or fixture outside candidate}}`
- **Expected and observed red:** `{{frame identity and detected defect}}`
- **Restoration:** `{{action, receipt, and unaffected candidate identity}}`

## Defects

| ID | Severity | Requirement | Row/frame | Reproduction and impact | Disposition | Re-shot |
| --- | --- | --- | --- | --- | --- | --- |
| `{{VQA-D01}}` | `{{blocking / major / minor}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{open / fixed / accepted by owner}}` | `{{new row/frame identity or pending}}` |

## Verdict

- **Required rows reconciled:** `{{yes / no, counts}}`
- **Probe caught and restored:** `{{receipt}}`
- **Blocking defects:** `{{none or IDs}}`
- **Human-owned receipts:** `{{trusted user-origin receipts, or not applicable;
  each binds candidate, environment, row, observation, and time}}`
- **Verdict:** `{{pass / fail / pending}}`
- **Release handoff:** `{{source/working-tree acceptance evidence only, or exact
  immutable release artifact/set identity and fresh visual verdict}}`
- **Gate wiring:** `{{verification matrix row, cadence, protected promotion}}`
```
