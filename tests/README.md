# tests/

Everything that observes the library actually running. Inside it, one question
splits the work: **is the correct answer known before the run?**

The runners at this level check labeled expectations. Offline predicates are
deterministic; live agent behavior is sampled. Investigate a failing assertion,
and distinguish it from a timeout, unavailable provider, or invalid observation.
`optimizing/` holds exploratory measurements used to tune descriptions.

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

`run-behavioral.sh` runs a real agent and inspects the artifact it produced.
RED/GREEN compares library versions; `--arm none` observes the bare agent. A
passing sample cannot establish absence of a problem or redundancy of a skill.
The arms and scenario format are in `behavioral/README.md`; `docs/testing.md`
owns their interpretation and cost limits.

`optimizing/descriptions/test-triggering-on-queries.sh` asks the separate
question of whether a *description* fires, and has its own price tag —
`optimizing/README.md`.

Both bind to `harnesses/<name>.sh`, which holds only what differs per CLI. Adding
a harness also requires its install/routing adapter and validation; see
`harnesses/README.md` and `docs/harness-support.md`.

## Honest limits

The live runners cost tokens and are **not deterministic**. So they are manual
tools, never CI, and no result is committed as a record — re-run for current
truth and report the numbers you actually got, failures included.
