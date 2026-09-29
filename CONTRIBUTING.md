# Contributing to SDLC skills

Thank you for taking the time to contribute. This guide is written for people.
If a coding agent is doing the work with you, it reads
[`AGENTS.md`](AGENTS.md), which holds the same rules in the form an agent
follows.

## Before you start

- **Solve a problem you actually hit.** Describe the session, the error, or the
  experience that led you here. A speculative or theoretical fix is closed.
- **Search first.** Look through open and closed issues and pull requests for
  the same problem. If an earlier attempt was closed, say what is different
  about yours.
- **Check that it belongs in core.** Core skills are general-purpose guidance
  that would help someone on a completely different kind of project. A skill
  for one domain, tool, or team belongs in your own library.
- **Not sure?** Open an issue first. "No skill is needed here" is a valid and
  useful outcome.

## Making a change

1. Fork the repository and create a task branch from `dev`. `main` holds
   releases only.
2. Keep the pull request to one change. Split unrelated edits.
3. If you add or edit a skill, follow the `writing-skills` skill
   (`skills/common/writing-skills/SKILL.md`). It owns the format and the
   checks for a single skill.
4. Follow the authoring rules for anything under `skills/` or `docs/`:
   - Do not name other repositories, projects, articles, or authors.
   - Refer to models by capability tier (`small`, `medium`, `large`), never by
     vendor name.
   - Do not assume one agent's tools or paths.
5. Do not add third-party dependencies. The library is zero-dependency by
   design.
6. Do not bump versions or edit version headings in `CHANGELOG.md`. The
   maintainer versions each release. See [`RELEASING.md`](RELEASING.md).

## Run the checks

Run these before you commit. CI runs them on every push and pull request.

```bash
bash scripts/sh/validate-skills.sh
bash scripts/sh/validate-skill-graph.sh
bash scripts/sh/validate-trigger-collisions.sh
bash scripts/sh/token-budget.sh --chain NAME
```

Run the last one for each chain listed in `scripts/sh/data/chains.toml`.

For each skill you edited, also run the strict check:

```bash
bash skills/common/writing-skills/scripts/check-skill.sh --strict path/to/skill
```

To run the checks automatically on every commit, install the git hook once:

```bash
bash scripts/sh/install-git-hooks.sh
```

`bash scripts/sh/install-git-hooks.sh --remove` undoes it.

[`docs/testing.md`](docs/testing.md) explains what each check proves.

## Open the pull request

1. Target `dev`. A pull request opened against `main` is asked to retarget
   before review.
2. Fill in every section of the pull request template with specific, true
   answers.
3. If the change alters what a skill makes an agent do, name the failure or
   the gap it answers. No live agent runs in this repository, so the pull
   request argues from the skill text and the checks.
4. Say how the change was written: by hand, or with which model, agent, agent
   version, and plugins. A pull request that hides this is closed.
5. Read the complete diff yourself before you submit it.
