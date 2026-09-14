# tests/

Offline tests for this library's deterministic script and packaging logic. Each
knows its correct answer before it runs, needs no model, and costs nothing, so a
red result means something is broken.

Live evidence — whether a description fires, whether a skill changes what an
agent builds — is sampled from a real agent, costs tokens, and is not
deterministic. It lives in the evals lab, `augments-labs/sdlc-skills-evals`,
with the scenarios, query sets, fixtures, and harness launchers it needs, and
never runs here or in CI. A PR that makes a behavior claim cites a lab campaign
record; `docs/testing.md` says how.

## Layout

```text
tests/
  run-session-start.sh    the injected router, per envelope       (offline)
  run-plugin-smoke.sh     install / marketplace mechanics         (offline)
  run-serve-preview.sh    the localhost preview's safety contract (offline)
  harnesses/              ONLY what differs per CLI: how it installs and discovers skills
```

Every runner answers `--help` with its own flags, defaults, and exit codes; this
file covers only what the flags cannot say.

```bash
tests/run-session-start.sh
tests/run-plugin-smoke.sh --harness codex
tests/run-serve-preview.sh
```

## What they catch

They catch real defects — a hook that stopped firing, a manifest drift, skills
landing where the harness never looks, a preview server that answers without
its session key. `run-session-start.sh` gates what every adapter injects at
session start: valid JSON in each harness's envelope, the canonical router body
present *verbatim* with its frontmatter stripped, escaping that survives the
quotes and tables inside it, and the event name echoed back.
`run-serve-preview.sh` starts each skill's bundled preview server on loopback
and asserts the auth gate, path confinement, and clean stop. Both run in CI.
`run-plugin-smoke.sh` needs the harness's CLI installed, so it runs locally: it
installs this tree the way that harness does, into a throwaway home, and checks
that every skill is discovered. Its bindings are in `harnesses/README.md`.
