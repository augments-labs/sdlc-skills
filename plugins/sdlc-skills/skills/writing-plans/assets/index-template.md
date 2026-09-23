# Plan index template

`writing-plans` opens this when starting the index and fills the header first:
exact identity of every approved input, the rule that makes each stale, the
`Approval rule`, and the `Integration cadence`. Write the filled copy to
00-index.md in `.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`, alongside one
file per task. No approval, execution state, or evidence goes in this file;
every later change to what it specifies is a successor file.

```markdown
# Plan: {{topic}}

- **Status:** `draft | proposed` (decision and execution state stay external)
- **Normative version:** this plan's identity, computed by the rule on the next
  line; approval, mode, and evidence bind to it, never to a label
- **Identity:** recorded in the ledger row, never here: the version
  `scripts/plan-version.sh` prints, which runs `git hash-object` over this index
  with every task checkbox and state label normalized to `[ ]` and `todo`,
  followed by every task file in index order
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
- **External decision ledger:** {{ledger path: 00-index.ledger.md in this plan
  directory unless the user sets another; pending / changes requested / approved
  / rejected / cancelled / superseded by approved normative identity; trusted
  evidence and inline/delegated mode bind this exact version}}
- **External execution ledger:** {{ledger path: the same 00-index.ledger.md
  unless the user sets another, or returned directly; outside normative identity;
  append-only task states/evidence bind this version}}
- **Invalidation triggers:** {{any bound-input drift or normative scope/interface/
  evaluator/phase/ownership/cutover/rollback/decommission change}}
- **Required executor:** `executing-plans` for `inline`,
  `subagent-driven-development` for `delegated`, after this exact version has
  direct approval and an explicit mode. A mode reply triggers that skill; it
  never starts implementation by itself.
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
**Brief:** {{link to the alignment brief from clarifying-intent, if any}}   ·   **Created:** {{date}}
**References:** {{paths to artifacts the spec shipped — failing tests, mockup pages, a reference implementation, rubrics — or "none". Tasks point at these; they are never restated in prose.}}

## High-risk classification

Classify before implementing, on risk evidence rather than line count. The
ordinary route is ordinary feature planning and line-by-line review; an
answer is off it when the ordinary route cannot make those surfaces
reviewable and recoverable.

- Can independent humans or gates inspect the result (**reviewability**)?
  {{answer and evidence}}
- Must behavior, compatibility, data, or operations match (**preservation**)?
  {{answer and evidence}}
- How many owners, consumers, platforms, or modes change (**breadth**)?
  {{answer and evidence}}
- Can data, security, concurrency, resources, cutover, or recovery fail
  independently (**failure surfaces**)? {{answer and evidence}}
- **Route:** {{ordinary | high-risk | pending classification}}. Any answer off
  the ordinary route, or the user marking the work high-risk, makes it
  high-risk. Reclassify when inputs change.

## Trace

Include every applicable approved UI flow, state, decision, condition and
acceptance check, even when absent from a preview or no variants were compared.
Use its stable ID or design version plus section/condition. Assign an owning
task and gate; the finished interface must satisfy these alongside reference
conformance. Link the approved source instead of paraphrasing away its details.

| Requirement or accepted risk gate | Owning task/phase | Evaluator |
| --- | --- | --- |
| {{ID and source}} | {{task/phase}} | {{command, rubric, or assurance gate ID}} |

## Review focus

Up to five spec-implied inputs or failure modes no task Evaluator exercises.
Each names the task that owns it and the check that pins it; a row with no
check is a gap the reviewer starts from.

| Implied input or failure mode | Owning task | Pinning check |
| --- | --- | --- |
| {{what the spec implies}} | {{T-00N}} | {{command, test name, or `none yet`}} |

## Tasks

- [ ] `T-001` — {{task name}}   ·   `01-{{slug}}.md`   ·   `todo`
- [ ] `T-002` — {{task name}}   ·   `02-{{slug}}.md`   ·   `todo`
- [ ] `T-003` — {{task name}}   ·   `03-{{slug}}.md`   ·   `todo`

Task IDs are stable, never renumbered or recycled; filenames may stay ordered.
Mirror the external ledger as a checkbox plus its exact state label:

- `[x] done` counts toward completion.
- `[ ] done with concerns` remains incomplete. Once every concern is
  classified as non-blocking or accepted by its owning deviation/exclusion and
  compensating gate, record `done` and mirror `[x] done`. Retain concern history
  in the external ledger; do not use `[x] done with concerns`.
- `[ ] todo`, `[ ] in progress`, `[ ] blocked`, `[ ] needs context`,
  `[ ] cancelled`, and `[ ] superseded` do not count toward completion.
- Nothing follows the state label; blocker, owner, and next-gate text go in the
  ledger.

This projection is navigation, not evidence. Normalize it to `[ ] todo` when
computing the identity. On mismatch, the external ledger wins.

The external ledger is the single source of truth for progress. Each row binds
plan version, task ID, attempt/result identity, evaluator evidence, owner/time,
and one state: `todo / in progress / done / done with concerns / blocked / needs
context / cancelled / superseded`. `Done` requires green evidence; concerns stay
durable and cannot count toward a gate until classified as non-blocking evidence
or accepted by an exact owning deviation/exclusion with compensating gate.
Blocked/needs-context retains blocker, owner, and next gate. Cancellation
or supersession requires the approved plan change/decision that removed the task.
```
