# tests/harnesses/

One file per coding-agent CLI, holding **only what differs between them**:
how skills are installed, how the CLI is invoked, how an activation is detected
in its stream, and what a run cost. Each is sourced by a runner, never executed
directly, and none of them decides anything — judging an observation belongs to
the caller.

Three runners bind to these adapters, and they ask different questions:

- `tests/run-behavioral.sh` — did the skill change what got **built**? The answer
  is known in advance, so red means broken.
- `tests/run-plugin-smoke.sh` — do the skills land where this harness looks?
  Offline, free, deterministic.
- `tests/optimizing/descriptions/test-triggering-on-queries.sh` — how often does a
  description fire? There is no pass mark; it is compared against the previous
  iteration.

This is also why none of it belongs in `scripts/sh/`. Everything there is
deterministic, free, and safe to run in CI, and two of those scripts *are* CI.
Everything here drives a live provider: non-deterministic, costs money, and it
must never run in CI. Mixing them invites someone to wire a paid prober into a
push hook.

## The contract

```text
tests/harnesses/
  claude-code.sh
  codex.sh
  kimi-code.sh
```

Required: `adapter_check`, `adapter_install`, `adapter_chain`,
`adapter_run_activation`, `adapter_run_behavioral`.

Optional: `adapter_ran`, `adapter_usage`, `adapter_component_inventory`,
`adapter_continue_behavioral`, and `adapter_model`. `adapter_continue_behavioral`
is required only for a scenario that defines follow-up turns; it must resume
from structured session evidence rather than simulate continuity with a new
session. `adapter_model` binds a tier — `small | medium | large` — to the
model name the CLI accepts, and is required only by a scenario that sets
`scenario_model_tier` (or a run passing `--tier`); the runner refuses the run
on an adapter without it rather than running on the default model and calling
it that tier. Detection and usage helpers degrade to silence rather than a
confident wrong answer.

The disposable project a run is pointed at is not per-harness, so it lives one
level up in `tests/fixtures.sh`.

## Detection is structural, never a grep

An activation counts only when the harness's own stream carries a structured
skill-invocation record. A raw text match reports phantom activations: the
SessionStart router injection and the init manifest both contain `sdlc-skills:`
tokens that are not actions, and the first version of this harness fell for
exactly that. Each adapter's `adapter_chain` is written against a stream actually
observed from the installed CLI, never against assumed field names.

## Inconclusive is a third outcome, and it matters

A run that never reached the model says nothing about a description, and scoring
it as "did not fire" is how a dead provider gets reported as a result. This was
not hypothetical: an eval once returned exactly 50% positive and 50% negative —
every positive a miss, every negative passing for free — because all sixty calls
died at authentication and no assistant record was ever emitted. The sheet looked
like a measurement.

Two independent detectors, because neither is sufficient alone:

1. **The provider says so.** Its stderr is the CLI talking, so an auth or quota
   phrase there is trusted. The same phrase inside the stream may be model output
   quoting an error, so that side matches only the narrow error-record patterns.
2. **Structural — did a model turn happen at all?** `adapter_ran` answers per
   harness. It is optional and defaults to "it ran", so a harness whose failure
   shape has not been observed behaves exactly as before rather than silently
   losing runs from a denominator.

**Exit status cannot serve here**, and that is worth stating so it is not "fixed"
later. A CLI typically exits non-zero when it exhausts `--max-turns` — the same
code as an auth failure. Every negative query runs to max-turns by design, so
keying on status would drop half of every query set. That is worse than the bug
it would fix.

`adapter_ran` asks whether the model *spoke*, not whether the run *finished*.
Those differ, and conflating them was a real bug: the claude-code predicate
originally required the CLI's terminal record, which a run killed by our own
`--timeout` never emits. A run that fired correctly came back inconclusive with
the expected skill sitting in its chain. Truncation is normal; silence is not.

## Adding a harness

Add `<name>.sh` implementing the contract above. Nothing outside this directory
should need to change. Bindings alone do not make a harness supported — what one
has to prove before claiming support is in `docs/harness-support.md`.
