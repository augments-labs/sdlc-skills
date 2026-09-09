# Testing this library

Everything that observes the library *running* lives under `tests/`, split by one
question: **is the correct answer known before the run?** The two answers are
held to different standards, so they keep different directories.

| Where | What red means | Runner |
| --- | --- | --- |
| `tests/` | something broke; act | `run-behavioral.sh --arm red\|green`, one file per scenario under `tests/behavioral/` |
| `tests/`, offline | something broke; act | `run-session-start.sh`, `run-plugin-smoke.sh`, `run-serve-preview.sh` — no model, free, prefer these |
| `tests/optimizing/` | a number, not a regression | `descriptions/test-triggering-on-queries.sh` |
| `tests/harnesses/` | — | one file per CLI, holding only what differs between them; they decide nothing |

`run-behavioral.sh --arm none` sits with the gates but answers a measurement's
question: whether a skill is worth its context, not whether anything broke. A
skill whose assertions pass just as well with no skills loaded earns nothing.

Nothing under `tests/optimizing/` runs in CI, by design.

## Everything else has an owner

- **Which skills have a behaviour worth proving, and how to prove one** —
  `skills/common/writing-skills/references/testing.md`. It ships with the skill,
  so it is available wherever `writing-skills` is installed.
- **What a query set must contain, what a run costs, and why a trigger rate is
  not a pass mark** — `tests/optimizing/README.md`.
- **The mechanical gate** — `scripts/sh/validate-skills.sh`, run before every
  commit; CI runs it on every push and pull request.

## Proportionality

The doctrine holds the general rule. Two consequences are this repository's own:

- Do not emulate whole provider transcripts, sessions, or process trees when a
  smaller observable answers the question.
- If an evaluator grows comparable in size to the behaviour under test, simplify
  the evaluator before adding to it.
