# tests/

Offline tests for this library's deterministic script and packaging logic. Each
knows its correct answer before it runs, needs no model, and costs nothing, so a
red result means something is broken.

Nothing here samples a live agent: no scenario, query set, or model run belongs
in this repository.

## Layout

```text
tests/
  run-check-skill.sh         offline check for check-skill.sh's reference-depth rule. (offline)
  run-git-hooks.sh           offline unit check for the local git hook installer. (offline)
  run-opencode-plugin.sh     offline unit check for the OpenCode adapter. (offline)
  run-pi-extension.sh        offline unit check for the pi adapter. (offline)
  run-plugin-smoke.sh        do the skills land where this harness looks? No model call.
  run-sdd-scripts.sh         offline unit checks for the SDD scripts. (offline)
  run-serve-preview.sh       offline unit check for the serve.py preview. (offline)
  run-session-start.sh       offline unit check for the session-start injection. (offline)
  run-validate-skills.sh     offline check for the "every assets/ template has the house shape" gate in scripts/sh/validate-skills.sh. (offline)
  harnesses/                 ONLY what differs per CLI: how it installs and discovers skills
```

Every runner answers `--help` with its own flags, defaults, and exit codes; this
file covers only what the flags cannot say.

```bash
tests/run-session-start.sh
tests/run-opencode-plugin.sh
tests/run-pi-extension.sh
tests/run-plugin-smoke.sh --harness codex
tests/run-sdd-scripts.sh
tests/run-serve-preview.sh
tests/run-check-skill.sh
tests/run-git-hooks.sh
```

## What they catch

They catch real defects — a hook that stopped firing, a manifest drift, skills
landing where the harness never looks, a preview server that answers without
its session key. `run-session-start.sh` gates what every adapter injects at
session start: valid JSON in each harness's envelope, the canonical router body
present *verbatim* with its frontmatter stripped, escaping that survives the
quotes and tables inside it, and the event name echoed back.
`run-serve-preview.sh` starts each skill's bundled preview server on loopback
and asserts the auth gate, that a refused request receives no cookie, path
confinement, and clean stop. It then runs the
start and stop commands each skill body documents, as written, against a
fixture project. Both run in CI.
`run-plugin-smoke.sh` needs the harness's CLI installed, so it runs locally: it
installs this tree the way that harness does, into a throwaway home, and checks
that every skill is discovered. Its bindings are in `harnesses/README.md`.

## The regression net

These tests guard scripts and packaging on every change.
