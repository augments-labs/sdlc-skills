# Task NN: {{name}}

**Task ID:** `{{stable non-positional ID; never renumber or recycle}}`
**Objective:** {{what this task accomplishes — one sentence}}
**Depends on:** {{none, or stable task IDs that must finish first}}
**Files:** `path/to/file` (new) · `path/to/other` (edit)
**Exclusive ownership/effects:** {{files, generated outputs, data, processes,
external state, and evaluator artifacts this task may mutate; overlaps require
an explicit dependency and one transition owner}}
**Context:** {{key files or entrypoints to read first for this task — plus any spec artifact that defines it (a failing test, a mockup page, a reference implementation to port). Point at the path; do not paraphrase it back into prose. Or "none".}}
**Applicable visual references:** {{for a UI-bearing task: the keyed subset of
the plan index's Selected visual references, copied field for field below; or
`not applicable`. This task may not substitute a different direction}}

| Reference ID | Decision ID | Medium | Approved design artifact version | Artifact locator | Artifact version | Content digest | Selection ID | Rendering-input identity | Freshness evaluator | Normative conditions | Distinguishing invariants |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| {{VR-001}} | {{D-001}} | {{medium}} | {{design version}} | {{stable path, route, or artifact ID}} | {{immutable version, revision, or capture ID}} | {{selected content digest}} | {{stable selection ID}} | {{immutable rendering-input identity}} | {{exact freshness check}} | {{normative states/viewports/themes/fixtures/captures}} | {{observable distinguishing traits}} |

**Visual conformance gates:**

| Reference ID | Evaluator ID | Implementation conformance gate |
| --- | --- | --- |
| {{VR-001}} | {{VCONF-001}} | {{executable check or controlled rubric that judges the Distinguishing invariants}} |

Every Applicable visual reference has a gate row, and every gate ID matches the
plan index's Visual reference coverage. A UI task's required gate set is its task
Evaluator, every applicable VCONF row, and, for an integrated UI, the verdict
returned by `visual-ui-verification`. Every required gate must pass on the same
accepted state before the task can be `done`; a `mismatch`, failed VCONF, `unavailable` or
`error` evaluator result, or any pending gate keeps it non-done.

**Suggested tier:** {{small | medium | large}} — {{reason under the Model selection criteria}}
**Implementation disciplines:** {{`test-driven-development` + `yagni` for
behavior-affecting work, or the exact carve-out that makes them inapplicable}}

{{For a high-risk transformation, also fill the shard/phase fields from
`../references/scalable-transformation.md`; do not clone one task file per
homogeneous item.}}

## Change

{{Intent — what this task makes true, in a sentence or two.}}

**Interface** — the contract that lets other tasks build against this one without reading it:

- **Consumes:** {{names, signatures, data shapes this task takes from earlier tasks — or "nothing"}}
- **Produces:** {{the exact names and types later tasks will rely on — another task's executor sees only this line to learn them}}

{{Don't pre-write the implementation — the executor writes it at run time with full context. Include exact code ONLY where precision is fragile (tricky regex, security check, migration SQL).}}

## Evaluator

The precommitted pass/fail gate—preferably executable and deterministic—run on
the built result.

**Evaluator identity/owner:** {{immutable gate/rubric identity, owner, and
whether this task may edit it. If yes, exact permitted scope plus required
pre-change RED or deliberate falsification evidence}}

```bash
{{command}}
```

Expected: {{exit 0 / named tests pass / HTTP 200 body X / query returns Y}}

{{If the spec shipped a failing test for this requirement, that test IS the
Evaluator—run it by name; don't write a second one beside it. If the spec
shipped a rubric, use it verbatim and name the evaluator plus observation
record.}}

{{No deterministic check possible? Replace the command with a rubric pass-list:
explicit criteria, named evaluator, and recorded observations.}}
