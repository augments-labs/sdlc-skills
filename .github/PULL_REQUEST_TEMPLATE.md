<!--
Read every word before filling this in, and read AGENTS.md → "Before you open
a PR" first. Every section needs a specific, true answer. A PR that leaves
a section blank, keeps placeholder text, bundles unrelated changes, hides who
made it, or claims a human reading of the diff that nobody gave is closed
without review. One that says no human has read the diff is reviewed as it is.
-->

> **This PR must target `dev`, not `main`.** `main` holds releases; every
> change lands on `dev` first through a reviewed PR. A PR opened against
> `main` is asked to retarget `dev` before review.

## Who made this change? (required)

<!-- Say who orchestrated this PR, a human, an agent, or both: whoever
decided why it exists and what it changes, which need not be whoever wrote
it. Then name every model that wrote any of it, the part each wrote, and
where it ran. Contributions are weighed by how they were made: a behaviour
claim reasoned from documentation is held to a different bar than one
grounded in a real session. Hiding the authoring environment is grounds for
closing the PR. -->

| Field | Value |
| --- | --- |
| Orchestrated by | human / agent / both |
| Model + exact id | <!-- every model that wrote any of it, and which part each wrote; or n/a when no agent did --> |
| Harness + version | <!-- the IDE, CLI, or runner, or n/a --> |
| Agent that reviewed this diff | <!-- every agent that reviewed it, each with its exact model id and whether it wrote the change or reviewed separately; or n/a when no agent did --> |
| Human who reviewed this diff | <!-- `-` by default; a person, not a role, only when a human wrote this PR or asked the agent to put their name here; an agent never names a person on its own --> |

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

<!-- Yes or no. If the edits look separable but depend on each other, name
the dependency. -->

## Does it belong in core?

<!-- Core is general-purpose SDLC guidance (AGENTS.md → "What belongs here").
Would this help someone on a completely different kind of project? Is it
specific to one domain, team, tool, or workflow? Does it integrate or promote
a third-party service? A yes to either of the last two means it belongs in
your own skill library, not here. -->

## New skill (required)

<!-- When the PR adds no skill, write `not applicable` on the first line below
and leave the rest of this section blank. A blank section is placeholder text
and the PR is closed without review.

An added skill must be general-purpose SDLC guidance: it belongs to a phase of
the software development lifecycle in the canonical order `docs/reference/skills.md` lists
(or to `common/`), and would help someone on a completely different kind of
project. Name that phase and the failure the skill answers.

A PR that adds a skill outside the SDLC is closed without review, whatever its
quality. -->

- Adds a skill: <!-- yes or not applicable -->
- Phase folder: <!-- a phase from the skill catalogue (`docs/reference/skills.md`), common, or n/a -->
- Why this is SDLC guidance, not domain, tool, or workflow content: <!-- or n/a -->

## Prior PRs and issues

- [ ] I searched open **and** closed PRs and issues for this problem or area.
- Related: <!-- #number, #number, or "none found" -->

<!-- If a related PR was closed, say what is different here and why this
attempt should land where that one did not. -->

## Proof

<!-- Paste what the gates actually returned; they must be green:

    bash scripts/sh/validate-skills.sh
    bash skills/common/writing-skills/scripts/check-skill.sh --strict path/to/each/skill/touched

For a skill change, name the failure or contract gap it answers. This
repository runs no live agent, so behaviour is argued from the text unless
"Environments tested" below records a run. -->

## Evaluation

- What opening prompt started the session that led to this change?

## Environments tested

<!-- One row per environment in which you ran the changed skill, script, or
hook after the change. The table above says who made the change and where;
this says where it was exercised. Behaviour is argued from the text until a
row shows it running. A skill change with no row is accepted as a text-only
claim and is held to that bar; say `not run` in the first row, with `n/a`
in its other cells, rather than leaving the table blank or filling it from
memory.

For each row, "What ran" is the exact opening prompt or the scenario, and
"Observed" is what the agent did, in one line, with a link to the transcript,
diagnosis report, or eval record (its `results/` path and pinned plugin
commit) when you have one. A row without an observation is an installation,
not a test. -->

| Harness | Harness version | Model | Model version/ID | Plugins loaded | What ran | Observed |
| --- | --- | --- | --- | --- | --- | --- |
| <!-- the IDE, CLI, or runner, or not run --> | | | <!-- exact id --> | <!-- every plugin, or none --> | <!-- prompt or scenario --> | <!-- one line + link --> |

## Rigor

- [ ] For a skill change: I invoked `writing-skills`, and `skills/common/writing-skills/scripts/check-skill.sh` passes on every skill touched.
- [ ] I did not reword tuned discipline content (red-flag lists, rationalization tables, hard stops) without explaining why the new wording holds the same line (AGENTS.md → "Adding or editing a skill").
- [ ] Nothing shipped under `skills/` or `docs/` names another repository, project, article, author, issue, or vendor model.

## New harness support (required only if this PR adds a harness)

<!-- Files present but never invoked are not a working integration. A real
one loads the entry skill at session start so that skills fire without the
user asking. A PR adding a harness must:

- add `tests/harnesses/{{name}}.sh` offline bindings;
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

- [ ] A human has read the **complete** diff at head commit: <!-- the commit
  they read; after a push, untick until they read the new diff -->

<!-- Required unless the box is ticked, since a reader weighs this review in
place of a human one; who reviewed is the table's "Agent that reviewed this
diff" row. For each reviewer there: the head commit it reviewed, what it
read (the complete diff, and which skills, callers, or docs it checked
against), what it found, and what became of each finding: fixed, refuted
with the evidence, or left with the reason. "None" is an answer. After each
push, review the new diff and add it here with its commit; a review covers
only the commit it names. -->

<!--
Tick the box only once the person named in the table has said they read the
complete diff at that commit; authorizing the PR, or authorizing an agent to
open or merge it, is not a read. Otherwise leave it empty, with `-` in the
table: a name goes there only when a human wrote this PR or asked the agent
to put their name there, never on an agent's own initiative. An empty box is
a complete answer, not a defect: no human read the diff, which is acceptable
when whoever orchestrated the change relies on the agent's own review. The PR
is not closed for it; a reader weighs the table above, the Proof, and the
review reported here instead. The person whose account opens the PR still
answers for it. A tick nobody gave is a false statement about a person.

A PR is closed without review when it:
- ticks the box for a person who has not read the diff at the named commit;
- hides who orchestrated it, which models wrote it, or where it ran;
- leaves the box empty and reports no agent review above;
- bundles unrelated changes;
- leaves a required section blank or keeps placeholder text;
- names another repository, project, author, issue, or vendor model in
  shipped files;
- submits domain-, tool-, or workflow-specific content as core;
- changes behaviour-shaping content without naming the failure it answers;
- adds a skill that is not SDLC guidance (a phase of the lifecycle, useful on
  any kind of project).
-->
