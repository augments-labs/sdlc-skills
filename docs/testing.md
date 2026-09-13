# Testing this library

Tests separate known expected outcomes from exploratory measurements. A known
assertion can score a sampled agent run; it does not make that agent's behavior
deterministic.

| Where | What a result establishes | Runner |
| --- | --- | --- |
| `tests/behavioral/` | Observed behavior on a labeled scenario and candidate | `run-behavioral.sh` |
| `tests/`, offline | The checked packaging or script predicate | `run-session-start.sh`, `run-plugin-smoke.sh`, `run-serve-preview.sh` |
| `tests/optimizing/` | A measurement used to tune a description | `descriptions/test-triggering-on-queries.sh` |
| `tests/harnesses/` | Shared runners' CLI bindings | One adapter per supported CLI |

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
- **Description tuning:** `tests/optimizing/README.md` owns query design, fixed
  selection splits, costs, and interpretation. Optimization is not certification
  and does not run in CI.
- **Repository structure:** run `scripts/sh/validate-skills.sh` before committing;
  CI runs it on pushes and pull requests. It does not prove agent compliance.

Use behavioral tests only for the affected skill or handoff. Do not broaden to
unrelated skills for coverage, emulate whole provider sessions when a smaller
observable answers the question, or build an evaluator comparable in size to the
behavior being evaluated.
