<!--
Read every word before filling this in, and read CLAUDE.md → "If you are an
AI agent" first. Every section needs a specific, true answer. A PR that leaves
a section blank, keeps placeholder text, bundles unrelated changes, or shows
no evidence of a human reading the diff is closed without review.
-->

> **This PR must target `dev`, not `main`.** `main` holds releases; every
> change lands on `dev` first through a reviewed PR. A PR opened against
> `main` is asked to retarget `dev` before review.

## Who made this change? (required)

<!-- We assume an agent wrote this PR. Say which one and where it ran, or
state plainly that it was written by hand. Contributions are weighed by how
they were made: a behaviour claim reasoned from documentation is held to a
different bar than one grounded in a real session. Hiding the authoring
environment is grounds for closing the PR. -->

| Field | Value |
| --- | --- |
| Written by | hand / agent |
| Model + exact id | <!-- or n/a if by hand --> |
| Harness + version | <!-- the IDE, CLI, or runner, or n/a --> |
| Installed plugins | <!-- name and version of every plugin loaded, or none --> |
| Human who reviewed this diff | <!-- a person, not a role --> |

## What problem did you hit?

<!-- The real problem: the session, the error, or the user experience that
motivated this. If it was a session, say what you were doing, what went
wrong, the exact failure mode, and attach or link the transcript if you can.
"Improving X", "it could theoretically break", or "my review agent flagged it"
is not a problem statement. -->

## What does this PR change?

<!-- One to three sentences. What, not why; the why is the section above. -->

## What alternatives did you consider?

<!-- What else you tried or evaluated, and why it was worse. If you
considered nothing else, say so; know that a reviewer reads that as a flag. -->

## Is this one change?

<!-- If the PR carries more than one unrelated change, stop and split it.
If the edits look separable but depend on each other, name the dependency. -->

## Does it belong in core?

<!-- Core is general-purpose SDLC guidance (CLAUDE.md → "What belongs here").
Would this help someone on a completely different kind of project? Is it
specific to one domain, team, tool, or workflow? Does it integrate or promote
a third-party service? A yes to either of the last two means it belongs in
your own skill library, not here. -->

## Prior PRs and issues

- [ ] I searched open **and** closed PRs and issues for this problem or area.
- Related: <!-- #number, #number, or "none found" -->

<!-- If a related PR was closed, say what is different here and why this
attempt should land where that one did not. -->

## Proof

<!-- Paste what the gate actually returned; it must be green:

    bash scripts/sh/validate-skills.sh

For a behaviour-shaping change, also re-run the smallest behavioural
scenario that exercises it (`tests/run-behavioral.sh`) and paste what it
returned. Say how many runs, on which arms, and include inconclusive and
failing results; an inconclusive result is a finding, a fabricated one is
grounds for closing. `docs/testing.md` says which run answers which question.

For a change confined to `references/` or `assets/`, the always-loaded body
is unchanged; say so instead of running something. -->

## Evaluation

<!-- "It works" is not evaluation. -->

- What opening prompt started the session that led to this change?
- How many sessions did you run **after** the change?
- What changed in the outcome compared with before?

## Rigor

- [ ] For a skill change: I invoked `writing-skills`, and `skills/common/writing-skills/scripts/check-skill.sh` passes on every skill touched.
- [ ] The change was pressure-tested, not only exercised on the happy path.
- [ ] I did not reword tuned discipline content (red-flag lists, rationalization tables, hard stops) without re-proving it still holds (CLAUDE.md → "Editing a skill").
- [ ] Nothing shipped under `skills/` or `docs/` names another repository, project, article, author, issue, or vendor model.

## New harness support (required only if this PR adds a harness)

<!-- Files present but never invoked are not a working integration. A real
one loads the entry skill at session start so that skills fire without the
user asking. A PR adding a harness must:

- add `tests/harnesses/{{name}}.sh` bindings for the shared runners;
- pass `tests/run-session-start.sh` and `tests/run-plugin-smoke.sh --harness {{name}}`;
- show a skill actually activating through the harness's own CLI on a
  representative opening. Open a clean session, send exactly:

      Fix the failing login test

  and paste the complete transcript below. A working integration invokes
  `using-sdlc-skills` and then `debugging` or `test-driven-development`
  before any code is read or written.

Copying skill files in by hand, a runtime shim that injects them, or anything
the user must opt into per session is not an integration. If you are unsure
whether the harness loads the entry skill at session start, it does not. -->

<details>
<summary>Clean-session transcript for "Fix the failing login test"</summary>

```text
paste the complete transcript here
```

</details>

## Human review

- [ ] A human has read the **complete** diff before this PR was opened.

<!--
STOP. If that box is not checked, do not open the PR.

A PR is closed without review when it:
- shows no evidence of a human reading the diff;
- bundles unrelated changes;
- leaves a required section blank or keeps placeholder text;
- names another repository, project, author, issue, or vendor model in
  shipped files;
- submits domain-, tool-, or workflow-specific content as core;
- changes behaviour-shaping content without evidence.
-->
