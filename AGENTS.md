# AGENTS.md

`sdlc-skills` is a library of SDLC skills for coding agents. Invoke
`writing-skills` before authoring or editing a skill.

Every skill rests on one idea: a claim leaves the agent through an external
**gate** (an executable check, an accountable decision, or a review), never
through confidence.

Write instructions, not facts. "Invoke `requesting-code-review` before any
push" gets obeyed; "review and integration are separate gates" gets read past.
Put the hard stop, REQUIRED marker, red-flag list, or rationalization table at
the step where the temptation hits. A handoff is a numbered, emphasized step
naming the skill to invoke, never a closing remark. Emphasis gets an agent to a
gate and never replaces one; keep it out of descriptions.

## Before you open a PR

You MUST:

1. Fill every section of `.github/PULL_REQUEST_TEMPLATE.md` with specific,
   true answers.
2. Search open **and** closed PRs and issues for the same problem. If it exists
   or was rejected, stop and say so to whoever orchestrated the change. If a
   prior attempt was closed, say what is different.
3. Confirm it belongs in core (*What belongs here*).
4. Meet every bullet in *Contributing*.
5. Review the complete diff yourself or with another agent, and report that
   review in the template's *Human review* section. Show a human the diff
   and wait for their approval only when one asked to see it first. Tick the
   box only once the person named in the table has said they read the diff
   at the commit it names; an authorization is not a read.

If any check fails, do not open the PR; explain why it would be rejected.

## Merging or closing a PR

Anyone, human or agent, may open a PR. Only a maintainer (a person with
write access to this repository) merges one, or an agent a maintainer has
authorized to merge that PR. Orchestrating a change grants no merge right,
and green checks authorize nothing. Even then, merge into `dev` only when
all of these hold on the PR's current head commit, whoever merges:

1. Every CI check that gates a merge is green. A job marked
   `continue-on-error`, such as the reference validator, gates nothing.
2. Its *Human review* section reports a review of the complete diff at that
   commit, naming the commit, or a maintainer approved that commit in a
   GitHub review. Every finding is fixed or refuted with evidence; one left
   open needs a maintainer's answer, recorded in the PR.
3. Anyone who asked to see the diff before merge has approved it.

A review covers only the commit it names: after a push, review the new diff
and update the section before merging. Merge into `main` only as
`RELEASING.md` says.

Only a maintainer closes a PR without merging, or an agent a maintainer has
authorized to close it; its author may also withdraw their own. Say why in
a comment: a closing condition in the template, a duplicate of an open PR,
or the author's or a maintainer's request. These rules grant no skill more
than it states: `reviewing-a-pr` still never merges or closes.

Local checkpoint commits on a task branch are authorized; `using-git-worktrees`
owns when to make one.

## Authoring rules (non-negotiable)

Files under `skills/` and `docs/` ship to users.

- `docs/` documents the current contract for users, in plain second person.
  Maintainer material (design reasons, gates, test notes, adapter internals)
  goes in `CONTRIBUTING.md`. Never put run transcripts, failure records,
  pass-rate anecdotes, superseded behavior, or investigation notes in either.
- The Agent Skills standard (agentskills.io) outranks every rule here. A house
  rule may be stricter; it may never permit what the standard forbids, forbid
  what it requires, or redefine its terms. When editing
  `docs/reference/agent-skills-conformance.md`, keep its matched phrases
  intact: the gate reads them.

1. **No external references.** Do not name other repositories, projects,
   articles, or authors, or cite issue/PR numbers or tracker links. State the
   principle directly; never attribute it. This also applies to commit
   messages, PR descriptions, and release notes. Disclosing the authoring
   environment is not attribution.
2. **Model- and harness-agnostic.** Name model tiers (`small | medium |
   large`), never vendor models. Assume no harness's tooling or paths.
3. **`writing-skills` owns the format.** This file does not restate it.
4. **Explain behavior-shaping changes.** A change to what a skill makes an agent
   do names the failure or contract gap it answers.
5. **A body you touch meets the current `writing-skills` format in full.** Run
   `check-skill.sh --strict` on each skill you edit: `validate-skills.sh` only
   warns on those checks.

## Checks

Run before you commit; CI runs the first on every push and PR:

```bash
bash scripts/sh/validate-skills.sh
bash skills/common/writing-skills/scripts/check-skill.sh --strict skills/{{phase}}/{{name}}
```

`check-skill.sh` runs bundled scripts with `--help`: read `CONTRIBUTING.md`,
"Conformance checks", before running it on an unfamiliar skill.

Edit skills under `skills/`, then run
`bash scripts/sh/sync-codex-plugin-skills.sh`; never edit
`plugins/sdlc-skills/skills/` by hand. Edit `AGENTS.md`, never `GEMINI.md` or
`CLAUDE.md`.

## Evals

Behavior evals live in
[sdlc-skills-evals](https://github.com/augments-labs/sdlc-skills-evals):
`bin/triggering` scores whether a description triggers, and `bin/behavior`
runs a scenario against a live agent CLI and judges what it built. A behavior
claim backed by an eval record (its `results/` path and pinned plugin commit)
is evidence; one argued from the skill text is not.

## Adding or editing a skill

- **New skill:** name the failure it answers and say whether it is an observed
  session, a contract gap, or an unmeasured candidate. Pick the phase folder
  from `docs/reference/skills.md`, or `common/`.
- **Focus:** write what the agent wouldn't know without the skill:
  project-specific conventions, domain-specific procedures, non-obvious edge
  cases, and the particular tools or APIs to use.
- **Cutting:** ask of each section "would the agent get this wrong without
  this?" When unsure, keep it and say so in the PR. Hard stops and
  destructive-action guards are never cut.
- **Discipline content:** never reword a red-flag list, rationalization table,
  or hard stop without saying in the PR why the new wording holds the same line.
- **Support files only:** for a change under `references/` or `assets/` alone,
  say the body is unchanged.
- **Chain budgets:** when a body edit pushes a chain over its `budget_words`
  in `scripts/sh/data/chains.toml`, cut the body first. Raise the budget only
  with a line in the PR naming the words added to the budget and what they
  buy, so the budget moves by decision, never by habit.

## What belongs here

General-purpose SDLC guidance that would help someone on a completely different
kind of project. A skill for one domain, tool, team, or workflow belongs in
your own library.

## Contributing

- **Solve a real problem you hit.** "My review agent flagged it" or "this could
  theoretically break" is not a problem statement.
- **One change per PR.**
- **Identify yourself.** Say whether a human, an agent, or both orchestrated
  the change, every model that wrote any of it and the part it wrote, and the
  harness and its version. Hiding it closes the PR; an empty human-review box
  does not.
  Plugins loaded during a run go in the PR template's *Environments tested*
  table.
- **Target `dev` from a task branch.** `main` takes release PRs only.
- **Never bump versions or edit CHANGELOG version headings.** See
  `RELEASING.md`.
- **No third-party dependencies,** except to add a harness and the
  non-blocking reference-validator CI job.
- "No skill is needed here" and an inconclusive result are valid outcomes; a
  fabricated one closes the PR.

## New harness support

A harness must load and activate the skills, not only see the files: it needs
a session-start nudge (on Claude Code, `hooks/`). See `CONTRIBUTING.md`,
"Agent adapters". A PR adding a harness MUST add `tests/harnesses/{{name}}.sh`
for `tests/run-plugin-smoke.sh` and show a skill activating through that
harness's CLI on a representative opening.
