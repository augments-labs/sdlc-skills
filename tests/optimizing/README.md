# tests/optimizing/

Measurements, not gates. Nothing here has a correct answer known in advance —
you get a number, compare it to the number the previous iteration got, and
exercise judgement. **A red sheet here is not a regression.** That is what
separates this directory from the gates beside it in `tests/`, where red does
mean something broke, and it is why the two do not share a runner.

What lives here is the Agent Skills standard's description-tuning loop: score a
description against a set of queries, revise it against the failures, score it
again, and keep the iteration that did best. The corpora are its input, not a
test suite that happens to be written in JSON.

## Layout

```
tests/optimizing/descriptions/
  test-triggering-on-queries.sh   scores a DESCRIPTION: queries x runs -> trigger rate
  <phase>/<skill>.json            at least 20 balanced positive/near-miss queries
```

The runner is self-contained: it opens a session per query repetition, points it
at a seeded project from `tests/fixtures.sh`, and reads which skills fired from
the CLI's own stream through `tests/harnesses/<name>.sh`.

```bash
tests/optimizing/descriptions/test-triggering-on-queries.sh --harness codex --all --dry-run
tests/optimizing/descriptions/test-triggering-on-queries.sh --harness claude-code --skill yagni --split validation
```

`--help` covers the flags. This file covers what the flags cannot say.

## Anyone can run this, and it spends your own quota

**A 20-query set at the defaults is 60 CLI invocations** — each repeated 3 times —
billed to whatever account your harness CLI is logged into, and `--all` is
roughly 2,000. Nothing about it is free and nothing about it runs in CI.

Always price a selection with `--dry-run` first; it prints the exact call count
and calls nothing. Runtime varies with the harness, query, and stopping limit.

## A trigger rate is not a pass mark

The standard describes three roles for query data, and this repository
implements two of them:

1. **train** — the failures you are allowed to revise against.
2. **validation** — the split that *selects* which iteration you keep.
3. **a fresh held-out set, written after selection** — the only one the standard
   calls a test.

Role 3 does not exist here. That is the honest limit, and it has a consequence
people get wrong: because validation is what selection is performed on, repeated
selection burns it too. Tune against train and the holdout stays meaningful for
a while; tune against validation and you have overfitted away the only thing
that was telling you the truth. Either way, **neither split is a held-out
result**, so no number produced here is evidence that a description generalises
to openings nobody wrote down.

What the numbers are good for is comparison between two iterations of the same
description, measured the same way. That is genuinely useful and it is all they
are.

Practical consequences:

- Revise on **train** failures only.
- Keep the iteration with the best **validation** rate, which is very often not
  the last one you tried.
- Report the real numbers, including inconclusive and failing ones, and say how
  many runs produced them.

## The query sets

Drop a JSON array at `descriptions/<phase>/<skill>.json`. The filename is the
contract — no registration, no code change. Each entry needs `query`,
`should_trigger`, and `split`; every negative also needs `expect`, naming the
expected neighbouring activity (`"none"` if there is none). This field is
diagnostic; the scorer does not evaluate that activity.

**Nothing enforces the shape of a set — that is on the reader.** A set is only
worth the money it costs to run if it can actually decide something: at least
ten positives and ten near-miss negatives, no duplicates, a validation split
between a quarter and a half of the set, and the same positive-to-negative
proportion on both sides of it. Twenty happy-path positives will pass every eval
they are ever run through and prove nothing. Check the shape when you edit a set;
a live run cannot tell you the set was broken.

**The near-misses are the point.** A description firing on its own happy-path
opening proves nothing, because every description does that. The runner observes the subject anywhere in the bounded skill chain, including
a prerequisite or an on-demand read for model selection. Another skill owning
the opening does not make a valid negative if that workflow legitimately calls
the subject later. Write near-misses where the subject remains outside the
requested boundary; a natural stopping point can make that boundary explicit.
Do not tell the agent which skill to avoid. Keep general explanations alongside
real adjacent work; explanations alone make an easy, unrepresentative set.

Keep each query's `train` or `validation` assignment. Correcting an ambiguous
query changes the measurement: restart comparison on the revised set and
disclose the change; old rates are not comparable. Do not move validation
failures into training or call either split an untouched held-out test.

**Ground the query in the fixture whenever the verb presupposes what it names.**
Asking to *add* `src/utils/money.ts` works whether or not that path exists;
asking to *delete* or *refactor* it does not — the agent answers that there is
no such file and routes nowhere, which is indistinguishable in the report from a
description that failed to fire. A query like that scores the fixture, not the
description. `tests/fixtures.sh` says what actually exists.

## What this costs, before you run it

Each repetition is a paid CLI invocation; one invocation can make several model
requests and tool calls. For a 20-query set, three repetitions means 60
invocations, or 24 for an eight-query validation split. The exact all-library
count changes with the corpus: use `--dry-run`, not a historical total.

A description is revised one skill at a time. Run only the affected selection;
a full sweep is not a routine gate. `--jobs` runs repetitions concurrently. It
changes elapsed time and resource contention, not the planned invocation count.

Negatives dominate that clock. A positive stops the moment the expected skill
fires; a negative has nothing to wait for and runs to `--max-turns` or the
timeout, so the back half of a set costs multiples of the front half.

**Keep `--jobs` equal across runs you intend to compare.** Concurrency does not
change what is measured, but it can change whether a call completes, and a
timeout scores as "did not fire" rather than being dropped from the denominator.
A before/after pair split across concurrency levels is confounded. Retain
timeout and truncation counts separately: bounded non-observation is not proof
that the skill would never fire.

## The sibling loop, and why it is not here

Output behavior is a different question from activation. Use the smallest
relevant `tests/run-behavioral.sh` scenario or a temporary controlled probe.
`--arm none` observes the bare agent; `--arm red --base REV` observes the prior
library; `--arm green` observes the current library. Installed arms normally
expose the whole library, so disclose a probe that instead loads only its
intended skill. A passing bare or prior-library sample does not erase a
reported failure or a source contradiction.

Freeze fixture, evaluator, skill sources, and allowed effects before comparing
arms. Evaluate the actual artifact or side effect mechanically where possible;
use a controlled rubric where the claim needs judgment. Neither an exit code
nor an agent's assurance alone proves that the intended behavior was observed.
`docs/testing.md` owns the behavioral workflow and its limits.

## Honest limits

Live runs cost tokens and are **not deterministic**: the same query fires and
does not fire across runs, and coverage is selective by design. So these are
manual tools, never CI, and no result is committed as a record — re-run for
current truth.

A single green run is weak evidence. Say how many runs you did and what the
spread was; the runner prints `(fired/valid)` beside every rate for exactly that
reason. A run the harness marks **inconclusive** is dropped from the
denominator rather than scored, because a provider that never answered is not
evidence about a description. An observed failure the harness cannot explain is
a finding, not a rerun.
