# Contributing to SDLC skills

The full contributor guide lives in [`AGENTS.md`](AGENTS.md) — it is written for humans and agents alike (`GEMINI.md` symlinks to it and `CLAUDE.md` points to it, so every harness reads the same rules). This file exists so GitHub surfaces the guide where contributors look for it.

The short version:

- **Solve a real problem you actually hit** — speculative or theoretical fixes are closed.
- **One change per PR**, targeting `dev` from a task branch. `main` holds releases only.
- **Run the gates before you commit:** `bash scripts/sh/validate-skills.sh`, `bash scripts/sh/validate-skill-graph.sh`, `bash scripts/sh/validate-trigger-collisions.sh`, and `bash scripts/sh/token-budget.sh --chain NAME` for each chain in `scripts/sh/data/chains.toml`. CI runs them on every push and PR. `bash scripts/sh/validate-skills.sh --strict` also fails on the policy checks it otherwise reports, `reference-load-condition` included.
- **Or run them automatically:** `bash scripts/sh/install-git-hooks.sh` once makes `git commit` run those same gates on a relevant staged change (`--remove` undoes it).
- **Explain behaviour-shaping changes:** name the failure or contract gap each skill change answers. No live agent runs in this repository.
- **Respect the authoring rules** for anything under `skills/` or `docs/`: no external references, no vendor model names, lean format ([`AGENTS.md`](AGENTS.md), "Authoring rules").
- **AI agents:** read the "If you are an AI agent" section of [`AGENTS.md`](AGENTS.md) first, and fill every section of the PR template truthfully — including the authoring-environment disclosure.

If you are unsure whether a change belongs in core, open an issue first — "no skill is needed here" is a valid, useful outcome.
