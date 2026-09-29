# Testing this library

This repository runs deterministic checks only, and they answer before a
merge. Each one knows the right answer before it runs, needs no model, and costs nothing, so a red result
means something is broken.

No live agent runs here or in CI. These checks tell you the library is well
formed and packaged correctly. They do not tell you what an agent does with a
skill.

## What runs where

| Where | What a result proves | Commands |
| --- | --- | --- |
| `scripts/sh/`, all run in CI | The structure and policy rules each check covers | `validate-skills.sh`, `validate-skill-graph.sh`, `validate-trigger-collisions.sh`, `token-budget.sh` |
| `tests/`, offline. CI runs `run-session-start.sh`, `run-serve-preview.sh`, `run-trace-viewer.sh`, `run-git-hooks.sh`, and `run-state-identity.sh` | One packaging or script behavior each | `run-session-start.sh`, `run-plugin-smoke.sh`, `run-sdd-scripts.sh`, `run-opencode-plugin.sh`, `run-pi-extension.sh`, `run-serve-preview.sh`, `run-validate-skills.sh`, `run-check-skill.sh`, `run-git-hooks.sh`, `run-state-identity.sh`, `run-trace-viewer.sh` |
| `tests/harnesses/` | Nothing on its own. These files hold how each CLI installs the plugin, and the smoke test drives them | One file per supported CLI |

## The four gates

Run these before you commit. CI runs them on every pull request and on every
push to `main` and `dev`.

```bash
bash scripts/sh/validate-skills.sh
bash scripts/sh/validate-skill-graph.sh
bash scripts/sh/validate-trigger-collisions.sh
bash scripts/sh/token-budget.sh --chain NAME
```

| Gate | What it checks |
| --- | --- |
| `validate-skills.sh` | Frontmatter, body and description size limits, the ban on external references and vendor model names, where templates and references live, that every manifest lists every skill, that the adapters are in sync, that `docs/` and `tests/` Markdown paths and skill reference paths resolve, and that the conformance record matches the tree |
| `validate-skill-graph.sh` | Pairs of skills that hand off to each other. A pair listed in `scripts/sh/data/allowed-cycles.txt` is allowed |
| `validate-trigger-collisions.sh` | Trigger phrases of two or more words that more than one description shares |
| `token-budget.sh` | With `--chain NAME`, the total body words of one chain against its budget. With `--max N`, the approximate token size of each `SKILL.md` against a ceiling. CI runs both, the second with `--max 5000` |

The first three report some findings as warnings. Add `--strict` to turn those
warnings into failures. CI runs all three with `--strict`.

### Run them on every commit

Install the git hook once:

```bash
bash scripts/sh/install-git-hooks.sh
```

After that, `git commit` runs the same gates whenever a relevant file is
staged. `bash scripts/sh/install-git-hooks.sh --remove` undoes it.

## Choose the check for your change

| You changed | Run |
| --- | --- |
| A skill | `bash skills/common/writing-skills/scripts/check-skill.sh --strict path/to/skill` |
| Anything | `bash scripts/sh/validate-skills.sh` |
| An adapter or a hook | `tests/run-session-start.sh` and `tests/run-plugin-smoke.sh --harness {{name}}` |
| The OpenCode plugin file | `tests/run-opencode-plugin.sh` |
| The pi extension file | `tests/run-pi-extension.sh` |
| A `subagent-driven-development` script | `tests/run-sdd-scripts.sh` |
| The preview server or its wrappers | `tests/run-serve-preview.sh` |
| The session trace page or its format | `tests/run-trace-viewer.sh` |
| `scripts/sh/validate-skills.sh` | `tests/run-validate-skills.sh` |
| `check-skill.sh` | `tests/run-check-skill.sh` |
| `state-identity.sh` | `tests/run-state-identity.sh` |
| The git hook installer | `tests/run-git-hooks.sh` |

Every runner answers `--help` with its flags and exit codes.

`run-trace-viewer.sh` has three layers. Its source checks need nothing extra.
Its mask and syntax checks need `node`, and its behaviour checks need a
headless Chrome or Chromium. A missing tool skips its layer and says so. In CI
a skipped layer is a failure.

`run-plugin-smoke.sh` needs the CLI of the agent under test installed, so it
runs on your machine and not in CI. It installs this tree into a throwaway
home the way that agent does, then checks that every skill is discovered,
where the CLI can list them.
[`tests/README.md`](../tests/README.md) describes the runners in more detail.

## Chain budgets

A chain is the ordered set of skills the router loads for one kind of task,
such as a bug fix or a new feature. `scripts/sh/data/chains.toml` lists the
skills in each chain, the recorded word count of each body, and the chain's
budget.

```bash
bash scripts/sh/token-budget.sh --chain NAME
```

This adds up the bodies in the chain, leaving out their reference files, and
fails when the total is over budget. CI runs it for every chain.

## Cutting text from a skill

Cut by judgment, not by word count. For each section, ask: would the agent get
this wrong without it? If the answer is no, cut it. If you are unsure, keep it
and say so in the pull request.

Hard stops and guards on destructive actions are never cut.

## What these checks do not cover

A green run here says the files are well formed, the manifests agree, and the
scripts behave. Whether a skill changes what an agent does is a separate
question, and nothing in this repository answers it. A pull request that
changes a skill's behavior argues from the skill text and these checks.
