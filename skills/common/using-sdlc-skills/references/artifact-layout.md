# Artifact layout

Where the skills write. Only the user or the project's own instructions set
another path; record it in the artifact's ledger pointer so the next reader
finds it.

## Directories

Every path sits under `.sdlc-skills/` at the project root. Run
`bash scripts/artifact-layout.sh` from the root to create them; a second run changes
nothing.

| Directory | Holds | Committed |
| --- | --- | --- |
| `briefs/` | goals, scope, feasibility, and interview briefs; captured tickets | yes |
| `specs/` | specifications | yes |
| `designs/` | architecture, data models, UI, coding standards, ADRs, migration contracts, rollout records, schema change records, deprecation records, shard manifests | yes |
| `plans/` | plan directories: an index and its task files | yes |
| `audits/` | complexity audit reports, outside the candidate workspace | yes |
| `post-mortems/` | post-mortems | yes |
| `verification/` | assurance matrices | yes |
| `evidence/` | run records bound to one state, prototype results and boundary records included | only its `.gitignore` |
| `handoffs/` | handoff notes and containment records | only when safe to share |
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

Every ledger is one markdown table with this header:

| Identity | Section | Location | State | Bound evidence | Updated |
| --- | --- | --- | --- | --- | --- |

- `Identity` is the artifact's identity (see Identity). `Section` names the
  section when one file holds several, such as a brief's goals, scope, and
  feasibility. `Location` is the artifact's path from the project root.
- `State` uses the vocabulary the artifact's pointer field lists, for example
  pending, changes requested, approved, rejected, cancelled, superseded.
- `Bound evidence` names who decided and holds the receipt or evidence the
  state rests on. A plan's approval row also records its execution mode there:
  `mode: inline` or `mode: delegated`, and `waves: yes` when the wave answer
  was chosen.
- `Updated` is the date the row was appended.

A plan's decision rows leave `Section` empty. An execution row fills the same
columns: `Identity` is the plan version, `Section` is the task ID, `State` is
the task state, `Bound evidence` holds the attempt, the result revision and the
evaluator evidence, and `Updated` holds the owner and the time. The other rows
`executing-plans` appends (`finding`, `gap`, `admitted`, `cancellation requested`) use
the same columns with the kind in `State`; only a row whose `State` is a task
state sets a task's state. A row about no single task, such as
`workspace: not applicable` or a finding outside every task's contract, puts
`plan` in `Section`, so no reader takes it for a decision row.

A ledger kept anywhere else, or returned instead of written, is recorded in the
artifact's pointer field.

## Identity

An issued artifact's identity is the first 7 characters of `git hash-object`
over the exact text the artifact owns:

- **A file of its own:** the whole file.
- **A section in a shared file:** from its heading down to the next heading at
  the same or a higher level, without trailing blank lines, so appending the
  next section does not change it. A `#` or `##` line inside a fenced code
  block is not a heading. The block opens at three or more backticks or
  tildes and closes only at a line holding nothing but a run of the same
  character at least as long. A successor never reuses its predecessor's
  heading: give it its own file, or a heading that sets it apart, such as
  `## Scope (successor)`. Reuse it and the command below reads the
  predecessor and hands the successor its identity.
- **A brief's own text:** from the top of the file down to its first `##`
  heading outside a fenced code block; the goals, scope, and feasibility
  sections are other artifacts.
- **A captured ticket** (a file whose H1 begins `# Ticket:`): the whole
  file; nothing else is written into it.
- **A plan:** its index, with every task checkbox and state label normalized to
  `[ ]` and `todo`, followed by every task file in index order.

```bash
bash scripts/artifact-layout.sh --hash .sdlc-skills/specs/2026-01-15-login.md
bash scripts/artifact-layout.sh --hash .sdlc-skills/designs/2026-01-15-login.md --section '## Architecture'
bash scripts/artifact-layout.sh --hash .sdlc-skills/briefs/2026-01-15-login.md --brief
```

A `# comment` in a fenced shell example stays inside its section, so an edit
below it changes the identity.

When `--section` matches no heading or more than one heading, `artifact-layout.sh`
prints the match count on stderr, writes nothing to stdout, and exits `2`. Fix
the headings before recording (`e69de29` is the hash of empty input, such as an
empty file or a `--brief` file with no preamble before its first `## ` heading).
The agent that issues the artifact runs the command at issue;
whoever later checks an approval or drift recomputes it the same way. Record the
value in the ledger row and show it in the decision block. Never write it into
the artifact: that changes the bytes it names. Any later byte change is a new
identity, and so a successor, except in a deprecation record, shard manifest,
schema change record, or rollout record: those are updated in place, a decision
row binds the record's identity at the time of that decision, and a later
update does not make the row stale.

## Evidence

`evidence/` holds records that bind to one state and go stale with it:
verification ledgers, TDD RED records, debugging hypothesis and attempt
ledgers, review descriptors, dispatch receipts and reports, plan review
reports, security reports, gate-state records, boundary records, and prototype
results. Group them by task: `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/`.
A plan's run records use its directory name: the SDD run ledger lives at
`.sdlc-skills/evidence/{{plan directory name}}/sdd-ledger.md` and keeps its
own header (`When | Kind | Task | Detail`), being a run record, not a decision
ledger.

The candidate digest (`state-identity.sh`, `branch-state.sh`) leaves `evidence/`
out, so a record written there never changes the candidate it describes. Write
run records nowhere else inside the workspace.

The directory holds a `.gitignore` containing `*` and `!.gitignore`. Commit
that file with the trail, so every clone and worktree ignores the rest. A
result worth keeping is summarized into the artifact's ledger with the
identity it ran on.

## Handoffs

`handoffs/` is the durable handoff store:
`.sdlc-skills/handoffs/{{YYYY-MM-DD}}-{{topic}}.md`. A handoff can carry session
detail that nobody chose to publish, so commit a handoff note or a containment
record only when its reader works from another checkout and the content is
safe to share.

## Views

`views/` holds generated output, such as the project view at
`.sdlc-skills/views/index.html`. Regenerate it instead of editing it.
