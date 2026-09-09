# tests/behavioral/

One file per scenario, run by `tests/run-behavioral.sh`. Each drives a real
coding-agent CLI against a disposable project and then reads **the artifact it
produced** — not what it said about the artifact.

That is the whole reason these exist. A test that asks an agent to describe a
skill passes whenever the agent can paraphrase; only reading the output catches a
skill described correctly and *applied* wrongly — a spec that promises "all
criteria are automated tests" and ships none, or ships them marked `todo` so the
suite can never go red.

## The arms

**RED vs GREEN is the gate.** RED loads the skills from a `git worktree` at
`--base`, GREEN from the working tree, so the before-arm stays reproducible after
the change is committed. The question has a known answer: what built before must
still build. Red means somebody has to act.

**`--arm none` is a measurement, not a gate.** NONE loads no skills at all, and
asks whether the skill is worth its context — one whose assertions pass just as
well without it is spending tokens for nothing. That is the only arm that can
retire a skill, and it has no correct answer in advance, so read a red NONE arm
the way you would read anything under `tests/optimizing/`: a number to compare,
not a regression.

Each arm prints a **cost** line — wall clock, and tokens where the harness
reports them — because the value question has two sides. A skill that lifts the
assertions and triples the tokens is a different trade from one that is better
and cheaper, and a pass/fail verdict hides that. Run two arms and compare their
cost lines; nothing aggregates them for you, deliberately. Counts come from each
CLI's own stream via `adapter_usage`, so a harness that reports none says "tokens
not reported by this harness" instead of printing a misleading `0`. That is
currently kimi, whose `stream-json` carries no usage object at all.

## Writing one

A scenario is one file, `<skill>.sh`, defining three required functions and one
optional continuation function:

```bash
scenario_opening          # the user's first message, verbatim
scenario_followups        # optional: fills followups=(...) for one resumed session
scenario_setup   <dir>    # seed the disposable project
scenario_assert  <dir>    # read what was built; exit code IS the verdict
```

Three optional variables narrow a run, and each is declared in the scenario
rather than inferred: `scenario_branch` names the branch the fixture is seeded
on (default `task/behavioral-probe`; a scenario judging branch discipline needs a
protected name there or the skill's skip clause fires), `scenario_harnesses`
lists the adapters the assertions have been checked against (any other adapter
refuses the run), and `scenario_model_tier` asks for `small | medium | large`,
which the adapter binds to a model (`adapter_model`) — a small model is where a
discipline slips first, and the cheapest place to watch it.

A scenario with follow-up turns requires an adapter implementation of
`adapter_continue_behavioral`. Continuation must use the harness's structured
session identity; starting a fresh session and replaying prose is not equivalent.

**Make the exit code carry the verdict.** A written summary is produced by the
same agent that wants it green; an exit code is not. Assert what is easy to fake
and hard to see in a transcript: that an artifact exists, that it *loads*, and
that it can actually fail. The strongest assertions take something away and
require the gate to notice — gut the implementation and the test must go red;
restore the defect and the reproduction must go red.

**Ground the opening in the fixture.** An opening that presupposes something the
project does not contain scores the fixture, not the library: the agent correctly
answers that there is no such area and builds nothing, which is
indistinguishable from a skill that failed to change anything. `tests/fixtures.sh`
says what exists, and `assert.sh` holds the helpers every scenario shares.

**Scenarios are shared by every harness.** They were byte-identical across three
copies before this. A per-harness override exists only for a real constraint —
`codex exec` is single-turn, so a scenario that invites a clarifying question ends
that run with no deliverable, and `scenario_opening_codex()` pre-empts it. A
per-adapter `scenario_setup_<harness>()` override works the same way for fixtures.
Never use an override to make an arm look better, and say so when you use one.

## Admission is deliberately strict

A scenario is retained only for **a failure actually observed**, with a verdict
that can be checked mechanically. Not an imagined gap, and not a coverage push:
these are the most expensive tests in the repository, and one that was never
grounded in a real defect costs hours to run and proves nothing when it passes.

| Selection | API calls | Per call | Wall clock |
| --- | --- | --- | --- |
| One scenario, one harness, one arm | 1 | ~5–40 min | — |
| Every scenario × 3 harnesses × 2 arms | 15 × 3 × 2 | ~5–40 min | **8–60 h** |

That matrix is **deliberately not filled**, and the limit is stated rather than
papered over. Run one arm before a sweep — if GREEN fails on one harness, the
rest of the matrix will not tell you anything new yet.

Live runs are **not deterministic**. Report the runs you actually did, failures
included, and never commit a result as a record.

A mandatory ordering boundary has no majority threshold. If one valid run
crosses the boundary in the wrong order, that run is a failure requiring action;
two passing runs do not cancel it.
