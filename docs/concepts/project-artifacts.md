# The `.sdlc-skills/` folder

The first time a skill writes a brief, a plan, or a record of a check, the
agent creates `.sdlc-skills/` at the root of your project. This page says
what goes in it and what to commit.

## What goes where

| Directory | Holds | Commit it? |
| --- | --- | --- |
| `briefs/` | Goals, scope, feasibility, and interview briefs; captured tickets | Yes |
| `specs/` | Specifications | Yes |
| `designs/` | Architecture, data models, UI designs, coding standards, decision records, migration contracts, schema change records | Yes |
| `plans/` | Plan directories: an index and one file per task | Yes |
| `audits/` | Complexity audit reports, and security reports once their verdict is in | Yes; a security report with open findings only once disclosing it is safe |
| `post-mortems/` | Post-mortems | Yes |
| `verification/` | Assurance matrices: which checks the project runs and what each catches | Yes |
| `evidence/` | Run records tied to one version of the work: test output, debugging ledgers, review reports, session diagnoses | No. The directory carries its own `.gitignore`; commit that file only |
| `handoffs/` | Handoff notes and containment records | Only when the reader works from another checkout and the content is safe to share |
| `views/` | The generated project view | Your choice |

Artifacts are named `<date>-<topic>.md`, for example
`specs/2026-01-15-login.md`. A plan is a directory with that name.

The "commit it" column describes a project that keeps its delivery trail in
the repository. If your project keeps planning out of the repository, ignore
`.sdlc-skills/` as a whole; the layout inside does not change.

## Ledgers

Beside each artifact sits a ledger, `<name>.ledger.md`, with one table row
per change of state: pending, changes requested, approved, rejected,
cancelled, superseded. Each row records who decided, what evidence the state
rests on, and the date. The ledger is append-only. A correction is a new row
that names the row it corrects, so the history stays readable.

This is how an approval survives the session that collected it. When a
later session asks whether a plan is approved, the answer is in the ledger,
not in the agent's memory.

## Identity

An approved artifact is identified by the first seven characters of a hash
over its exact text. The agent shows this identity when it asks you to
approve something and records it in the ledger. Any later change to the text
is a new identity, which means a new version that needs its own approval.
This is what stops a plan from being edited after you approved it and still
counting as approved.

## Evidence

`evidence/` holds everything that is only true for one version of the work:
the output of a test run, a debugging ledger, a review report, a session
diagnosis. Records are grouped by task in `evidence/<date>-<topic>/`. The
directory ignores its own contents, so a record written there never changes
what git sees, and a result worth keeping is summarised into the artifact's
ledger instead.

## Views

`views/` holds generated output, such as the project page that
`viewing-artifacts` builds. Regenerate it rather than editing it.
