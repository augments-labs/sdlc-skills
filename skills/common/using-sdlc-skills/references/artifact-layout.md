# Artifact layout

Where the skills write. Only the user sets another path; record it in the
artifact's ledger pointer so the next reader finds it.

## Directories

Every path sits under `.sdlc-skills/` at the project root. Run
`scripts/artifact-layout.sh` from the root to create them; a second run changes
nothing.

| Directory | Holds | Committed |
| --- | --- | --- |
| `briefs/` | goals, scope, feasibility, and interview briefs | yes |
| `specs/` | specifications | yes |
| `designs/` | architecture, data models, UI, coding standards, ADRs, migration contracts | yes |
| `plans/` | plan directories: an index and its task files | yes |
| `audits/` | complexity and security audit reports | yes; a security report with open findings once disclosing it is safe |
| `post-mortems/` | post-mortems | yes |
| `verification/` | assurance matrices | yes |
| `evidence/` | run records bound to one state | only its `.gitignore` |
| `handoffs/` | handoff notes | only when safe to share |
| `views/` | the generated project view | the project's choice |

Name an artifact `{{YYYY-MM-DD}}-{{topic}}.md`; a plan is a directory with that
name. "Committed" describes a project that keeps its delivery trail in the
repository. A project that keeps planning local ignores `.sdlc-skills/` as a
whole, and the layout inside does not change.

## Decision ledger

- **Path:** beside the artifact, with .ledger.md in place of .md.
  `.sdlc-skills/specs/2026-01-15-login.md` records its decisions in
  `.sdlc-skills/specs/2026-01-15-login.ledger.md`. A plan records them in
  `.sdlc-skills/plans/{{plan}}/00-index.ledger.md`, execution states included.
- **Append-only:** one table row per state change. Never edit or delete a row;
  a correction is a new row that names the row it corrects.
- **Columns:** `| Date | Location | Section | Identity | State | Decided by | Evidence |`.
  `Location` is the artifact's path from the project root. `Identity` is the
  exact normative version. `Section` names the section when
  one file holds several, such as a brief's goals, scope, and feasibility.
- **States:** the vocabulary the artifact's pointer field lists, for example
  pending, changes requested, approved, rejected, cancelled, superseded.

A ledger kept anywhere else, or returned instead of written, is recorded in the
artifact's pointer field.

## Evidence

`evidence/` holds records that bind to one state and go stale with it:
verification ledgers, TDD RED records, debugging hypothesis and attempt
ledgers, review descriptors, dispatch receipts and reports, and gate-state
records. Group them by task: `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/`.

The directory holds a `.gitignore` containing `*` and `!.gitignore`. Commit
that file with the trail, so every clone and worktree ignores the rest. A
result worth keeping is summarized into the artifact's ledger with the
identity it ran on.

## Handoffs

`handoffs/` is the durable handoff store:
`.sdlc-skills/handoffs/{{YYYY-MM-DD}}-{{topic}}.md`. A handoff can carry session
detail that nobody chose to publish, so commit one only when its reader works
from another checkout and the content is safe to share.

## Views

`views/` holds generated output, such as the project view at
`.sdlc-skills/views/index.html`. Regenerate it instead of editing it.
