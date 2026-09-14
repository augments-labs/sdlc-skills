# Testing this library

Tests separate known expected outcomes from exploratory measurements. A known
assertion can score a sampled agent run; it does not make that agent's behavior
deterministic.

Two repositories hold them. This one keeps the deterministic gates: structural
validation and offline script tests, which answer before a merge. The evals lab,
[sdlc-skills-evals](https://github.com/augments-labs/sdlc-skills-evals), keeps
everything that needs a live agent —
behavioral scenarios, description query sets, their runners, fixtures, and
harness launchers — and the dated campaign records their runs produce. Nothing
in this repository runs the lab.

| Where | What a result establishes | Runner |
| --- | --- | --- |
| `tests/`, offline | The checked packaging or script predicate | `run-session-start.sh`, `run-plugin-smoke.sh`, `run-serve-preview.sh` |
| `tests/harnesses/` | Per-CLI install bindings the smoke test drives | One adapter per supported CLI |
| Lab `behavior/` | Observed behavior on a labeled scenario and candidate | The lab's behavior runner |
| Lab `descriptions/` | A measurement used to tune a description | The lab's triggering runner |

## Citing live evidence

A behavior claim in a PR here cites a lab campaign record rather than a local
command: the record's path, `results/{{date}}-{{label}}/summary.md`, and the
plugin commit the campaign pinned. The record measures that commit, not a later
one.

## Behavioral arms and limits

| Arm | Installed configuration | Question |
| --- | --- | --- |
| `none` | No skill library | What did this agent do unaided in these conditions? |
| `red` | Complete library at `--base` | What did the baseline version do? |
| `green` | Complete library from the working tree | What did the candidate version do? |

These compare library configurations, not an isolated skill removed from an
otherwise identical library. Hold the fixture, evaluator, environment, and
permissions fixed; use the smallest scenario that exercises the intended change.
Total run tokens and time include generated work and tool use. Their difference
is an observed arm-cost difference, not the isolated cost of one skill.

A passing control means the proposed failure was not observed in that sample.
It can narrow a behavioral claim or end an unproductive probe; it cannot erase a
reported failure, resolve contradictory instructions, or prove a skill useless.
Repeated green samples strengthen only the conclusion their scope supports.
Keep observed failures, current contract gaps, and unmeasured candidates distinct.

Read raw results before classifying a nonzero exit. An assertion failure,
timeout, provider refusal, process error, and contaminated control are different
outcomes. Confirm the evaluator inspected the candidate the agent actually
changed, including any task-owned worktree. Retain every attempt and explain
inconclusive results; do not silently relabel or omit them.

## Choose the relevant check

- **Skill behavior and before/after proof:**
  `skills/common/writing-skills/references/testing.md` owns the method. Body
  changes use a targeted scenario where applicable; on-demand support files do
  not automatically require a live rerun.
- **Description tuning:** the lab's descriptions guide owns query design, fixed
  selection splits, costs, and interpretation. Optimization is not certification
  and does not run in CI.
- **Repository structure:** run `scripts/sh/validate-skills.sh` before committing;
  CI runs it on pushes and pull requests. It does not prove agent compliance.

Use behavioral tests only for the affected skill or handoff. Do not broaden to
unrelated skills for coverage, emulate whole provider sessions when a smaller
observable answers the question, or build an evaluator comparable in size to the
behavior being evaluated.

## Cutting and the regression net

Cut guidance by judgement, not word count. Ask of each section:
"would the agent get this wrong without this?" Cut it when the answer is no.
When unsure, run a throwaway probe — three pressure prompts, once with the
section and once without — report the result in the PR, and commit nothing.
Hard stops and destructive-action guards are never cut.

The regression net is the lab's behavioral scenarios and description query
sets, run once before and once after each release. A release is compared with
the baseline campaign record, `results/{{date}}-baseline-{{version}}/summary.md`;
a scenario that passed there and fails on the candidate stops the release.
Permanent scenarios are added only for a chain of skills that has none.

A chain is the ordered set of skills the router loads for one kind of task.
`docs/chains.toml` lists each chain's skills with its recorded body word count
and its budget. `bash scripts/sh/token-budget.sh --chain NAME` sums those
bodies, references excluded, and fails when the chain exceeds its budget; CI
runs it for every chain.
