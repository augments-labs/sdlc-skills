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
4. For a PR that changes a skill, the `eval-record` check ran on the current
   `dev`: if `dev` has moved since, bring the branch up to date so the check
   runs again (see *Evals*). If the PR also changes
   `.github/workflows/eval-record.yml` or `scripts/sh/check-eval-record.sh`,
   its own check is not evidence: run `dev`'s copy of the script on it.

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
`bin/triggering` scores whether a description triggers, and `bin/evaluate`
runs a skill's cases on a live agent CLI, with the skill and without it or
against an older plugin tree, and grades what each run built. A behavior
claim backed by an eval record (its `results/` path; the record names the
plugin commit and skill text it measured) is evidence; one argued from the
skill text is not.

A PR that changes a skill's `SKILL.md`, `assets/`, or `references/` MUST
name, in its body, one `Eval record: results/<dir>` line per record, each
already on the evals repository's `main`. The `eval-record` CI job reads
them and fails the PR unless:

- **a changed description line:** a triggering record's
  `description_sha256` is that line at the PR head, with 3 or more runs, a
  validation split, and no inconclusive query in any split;
- **any other change to those files:** an evaluation record's
  `plugin.skill_tree` is the skill's tree at the head, measured against its
  tree where the branch left the base (`old_skill`), with 3 or more runs of
  every eval in each arm and every run scored: none indeterminate, no null
  pass rate, no assertion awaiting review;
- **a new skill:** both records, the evaluation one against no skill
  (`without_skill`).

If the base changed the skill after the branch left it, rebase and measure
the rebased text. A typo fix or a removed skill needs the `no-eval` label,
and only a maintainer applies it (repository permissions enforce that).
Moving a skill to another phase folder changes no text and needs the label
too. Never argue a behavior change from the skill text in place of a record.
A change to a skill's `scripts/` directory, or to files outside `skills/`,
needs no record; its offline test is the proof.

## Adding or editing a skill

- **New skill:** name the failure it answers and say whether it is an observed
  session or a contract gap, and name its eval records (see *Evals*). Pick
  the phase folder from `docs/reference/skills.md`, or `common/`.
- **Focus:** write what a capable agent gets wrong without the skill: the
  rule it would not choose on its own, the non-obvious edge case, who owns a
  decision, and this library's own scripts and records. Leave out what it
  already does unprompted. A project's conventions, domain procedures, and
  tools come from that project's own instructions, not from a skill here.
- **Cutting:** ask of each section "would the agent get this wrong without
  this?" When unsure, keep it and say so in the PR. Hard stops and
  destructive-action guards are never cut.
- **Discipline content:** never reword a red-flag list, rationalization table,
  or hard stop without saying in the PR why the new wording holds the same line.
- **Support files only:** for a change under `references/` or `assets/` alone,
  say the body is unchanged.
- **Chain budgets:** each chain's `budget_words` in
  `scripts/sh/data/chains.toml` is a fixed ceiling. A body edit that takes a
  chain over it cuts as many words elsewhere in that chain, in the same
  change. Raise a ceiling only with an eval record (see *Evals*) showing the
  added words change what an agent does; a line in the PR arguing for them
  does not raise it. A chain that gains or loses a skill moves its ceiling by
  that body's words and no more.

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
