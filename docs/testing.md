# Testing this library

This repository runs deterministic checks only: structural validation and
offline script tests, which answer before a merge. No live agent runs here or in
CI, so nothing here measures what an agent does with a skill.

| Where | What a result establishes | Runner |
| --- | --- | --- |
| `scripts/sh/`, CI | The structural and policy predicates each gate checks | `validate-skills.sh`, `validate-skill-graph.sh`, `validate-trigger-collisions.sh`, `token-budget.sh` |
| `tests/`, offline | The checked packaging or script predicate | `run-session-start.sh`, `run-plugin-smoke.sh`, `run-sdd-scripts.sh`, `run-opencode-plugin.sh`, `run-pi-extension.sh`, `run-serve-preview.sh`, `run-validate-skills.sh`, `run-check-skill.sh`, `run-git-hooks.sh` |
| `tests/harnesses/` | Per-CLI install bindings the smoke test drives | One adapter per supported CLI |

## Choose the relevant check

- **Skill format and house policy:** run
  `bash skills/common/writing-skills/scripts/check-skill.sh --strict path/to/skill`
  on each skill you touch.
- **Repository structure:** run `scripts/sh/validate-skills.sh` before committing;
  CI runs it on pushes and pull requests. It does not prove agent compliance.
- **Adapters and hooks:** run `tests/run-session-start.sh` and
  `tests/run-plugin-smoke.sh --harness {{name}}` when an adapter or hook changes;
  `tests/run-opencode-plugin.sh` and `tests/run-pi-extension.sh` when their
  plugin file changes; `tests/run-sdd-scripts.sh` when a
  `subagent-driven-development` script changes; `tests/run-validate-skills.sh`
  when `scripts/sh/validate-skills.sh` changes; and `tests/run-check-skill.sh`
  when `check-skill.sh` changes.

## Cutting

Cut guidance by judgement, not word count. Ask of each section:
"would the agent get this wrong without this?" Cut it when the answer is no.
When unsure, keep it and say so in the PR. Hard stops and destructive-action
guards are never cut.

## Chain budgets

A chain is the ordered set of skills the router loads for one kind of task.
`scripts/sh/data/chains.toml` lists each chain's skills with its recorded body
word count and its budget. `bash scripts/sh/token-budget.sh --chain NAME` sums
those bodies, references excluded, and fails when the chain exceeds its budget;
CI runs it for every chain.
