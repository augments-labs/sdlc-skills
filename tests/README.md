# tests/

Everything that observes the library actually running. Inside it, one question
splits the work: **is the correct answer known before the run?**

The runners at this level are **gates** — the answer is known, so red means
something broke and somebody has to act. Nothing at this level is tuned,
compared against a previous number, or judged. That is `optimizing/`, one
directory down, and keeping the two apart is the point of the arrangement.

## Layout

```
tests/
  run-behavioral.sh       does the skill still change what gets BUILT? (live)
  run-session-start.sh    the injected router, per envelope      (offline)
  run-plugin-smoke.sh     install / marketplace mechanics        (offline)
  run-serve-preview.sh    the localhost preview's safety contract (offline)
  assert.sh               assertion helpers every scenario uses
  fixtures.sh             the disposable project a live run is pointed at
  behavioral/             the scenarios, and how to write one
  harnesses/              ONLY what differs per CLI: install, invoke, detect, cost
  optimizing/             MEASUREMENTS: a red sheet is not a regression
```

Every runner answers `--help` with its own flags, defaults, and exit codes; this
file covers only what the flags cannot say.

```bash
tests/run-session-start.sh                    # offline
tests/run-plugin-smoke.sh --harness codex     # offline
tests/run-serve-preview.sh                    # offline
tests/run-behavioral.sh   --harness kimi-code --scenario spec-it --arm green
```

## Prefer the offline tests

`run-session-start.sh`, `run-plugin-smoke.sh`, and `run-serve-preview.sh` need
no model. They are free, deterministic, and they catch real defects — a hook
that stopped firing, a manifest drift, skills landing where the harness never
looks, a preview server that answers without its session key.
`run-session-start.sh` gates what every adapter injects at session start: valid
JSON in each harness's envelope, the canonical router body present *verbatim*
with its frontmatter stripped, escaping that survives the quotes and tables
inside it, and the event name echoed back. `run-serve-preview.sh` starts each
skill's bundled preview server on loopback and asserts the auth gate, path
confinement, and clean stop. Both run in CI. The live runners never do.

## The live runners, and what each one is for

`run-behavioral.sh` runs a skill for real and reads the artifact it produced.
Its RED/GREEN pair is the gate in this directory; its `--arm none` is the one
measurement that shares a runner with a gate, because it asks whether a skill
earns its context rather than whether anything broke. The arms, the cost model,
and how to write a scenario are in `behavioral/README.md`.

`optimizing/descriptions/test-triggering-on-queries.sh` asks the separate
question of whether a *description* fires, and has its own price tag —
`optimizing/README.md`.

Both bind to `harnesses/<name>.sh`, which holds only what differs per CLI. Adding
a harness should touch nothing outside that directory; see `harnesses/README.md`.

## Honest limits

The live runners cost tokens and are **not deterministic**. So they are manual
tools, never CI, and no result is committed as a record — re-run for current
truth and report the numbers you actually got, failures included.
