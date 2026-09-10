# Plan: {{topic}}

- **Status:** `draft | proposed` (decision and execution state stay external)
- **Normative version:** {{immutable identity of this index with every task
  checkbox marker and status normalized to `[ ]` and `todo`, plus every task
  contract}}
- **Predecessor:** {{prior normative identity or none; a proposal only links it}}
- **Approval rule:** {{one accountable decision owner, or required approvers plus
  conflict resolver and decision rule}}
- **Bound inputs:** {{exact brief/spec/design/model/ADR/migration/assurance/code
  identities, evidence freshness, and invalidation rules}}
- **Selected visual references:** {{complete keyed collection from the approved
  design, copied field for field in the table below; or `not applicable`}}

| Reference ID | Decision ID | Medium | Approved design artifact version | Artifact locator | Artifact version | Content digest | Selection ID | Rendering-input identity | Freshness evaluator | Normative conditions | Distinguishing invariants |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| {{VR-001}} | {{D-001}} | {{medium}} | {{design version}} | {{stable path, route, or artifact ID}} | {{immutable version, revision, or capture ID}} | {{selected content digest}} | {{stable selection ID}} | {{immutable rendering-input identity}} | {{exact freshness check}} | {{normative states/viewports/themes/fixtures/captures}} | {{observable distinguishing traits}} |

A missing field invalidates the applicable UI-bearing tasks and evidence. A
`pass` permits use, while a proved `mismatch` is stale. `unavailable` means the
environment is absent and `error` means the evaluator failed; either is pending
until the evaluator or its environment is repaired and rerun.

### Visual reference coverage

| Reference ID | Owning task IDs | Conformance evaluator IDs |
| --- | --- | --- |
| {{VR-001}} | {{TASK-UI-01; one or more}} | {{VCONF-001; one or more}} |

Every selected Reference ID maps to at least one owning task and implementation
conformance evaluator; no row may be inferred from task prose.

- **Successor delta:** {{initial, or every stable task/interface/gate/phase ID as
  added / changed / removed / preserved; removals need owning approval}}
- **Downstream impact:** {{predecessor-bound review, task attempts, evidence,
  candidate, release, and external consumers; owner reconciliation state/gate}}
- **External decision ledger:** {{location; pending / changes requested / approved /
  rejected / cancelled / superseded by approved normative identity; trusted
  evidence and inline/delegated mode bind this exact version}}
- **External execution ledger:** {{controlled location outside normative identity,
  or returned directly; append-only task states/evidence bind this version}}
- **Invalidation triggers:** {{any bound-input drift or normative scope/interface/
  evaluator/phase/ownership/cutover/rollback/decommission change}}
- **Required executor:** `executing-plans` after this exact version has direct
  approval and an explicit `inline | delegated` mode. A mode reply triggers that
  skill; it never starts implementation by itself.
- **Implementation entry:** every behavior-affecting task invokes
  `test-driven-development` and `yagni` before its first project command or code
  edit. Naming either skill here is routing evidence, not invocation evidence.
- **Integration cadence:** `plan end | per task`. `plan end` is the default:
  tasks end at `done`, and the integrated candidate goes through
  `requesting-code-review` and `finishing-a-branch` once. `per task` makes every
  task's `done` an integration boundary; it requires the user's direct
  instruction, quoted here.

Every normative change creates a proposed successor with an exact delta. An
approved successor invalidates predecessor-bound consumers until each owner
revalidates or reconciles. Never write approval, execution mode, or evidence
into normative fields. Task checkbox markers and adjacent status labels are the
only mutable projection.

**Goal:** {{1–2 sentences}}
**Architecture:** {{2–3 sentences — the shape of the solution the tasks must stay coherent with}}
**Constraints:** {{project-wide rules every task inherits — version floors, dependency limits, naming/security/platform requirements — one line each, copied verbatim from the brief/spec. "None" if there genuinely are none.}}
**Acceptance:** {{the single end-to-end check that proves the WHOLE plan is done — an e2e test, a user-visible scenario, or a rubric. Distinct from each task's Evaluator; this is the feature-level definition of done.}}
**Brief:** {{link to the alignment brief from interview-me, if any}}   ·   **Created:** {{date}}
**References:** {{paths to artifacts the spec shipped — failing tests, mockup pages, a reference implementation, rubrics — or "none". Tasks point at these; they are never restated in prose.}}

## Trace

| Requirement or accepted risk gate | Owning task/phase | Evaluator |
| --- | --- | --- |
| {{ID and source}} | {{task/phase}} | {{command, rubric, or assurance gate ID}} |

## Tasks

- [ ] `T-001` — {{task name}}   ·   `01-{{slug}}.md`   ·   `todo`
- [ ] `T-002` — {{task name}}   ·   `02-{{slug}}.md`   ·   `todo`
- [ ] `T-003` — {{task name}}   ·   `03-{{slug}}.md`   ·   `todo`

Task IDs are stable, never renumbered or recycled; filenames may stay ordered.
Mirror the external ledger as a checkbox plus its exact state label:

- `[x] done` counts toward completion.
- `[x] done with concerns` counts only after every concern is classified as
  non-blocking or accepted by its owning deviation/exclusion and compensating
  gate; until then use `[ ] done with concerns`.
- `[ ] todo`, `[ ] in progress`, `[ ] blocked`, `[ ] needs context`,
  `[ ] cancelled`, and `[ ] superseded` do not count toward completion.

This projection is navigation, not evidence. Normalize it to `[ ] todo` when
computing the normative version. On mismatch, the external ledger wins.

The external ledger is the single source of truth for progress. Each row binds
plan version, task ID, attempt/result identity, evaluator evidence, owner/time,
and one state: `todo / in progress / done / done with concerns / blocked / needs
context / cancelled / superseded`. `Done` requires green evidence; concerns stay
durable and cannot count toward a gate until classified as non-blocking evidence
or accepted by an exact owning deviation/exclusion with compensating gate.
Blocked/needs-context retains blocker, owner, and next gate. Cancellation
or supersession requires the approved plan change/decision that removed the task.
