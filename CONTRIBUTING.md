# Contributing to SDLC skills

The full contributor guide lives in [`CLAUDE.md`](CLAUDE.md) — it is written for humans and agents alike (`AGENTS.md` and `GEMINI.md` symlink to it, so every harness reads the same rules). This file exists so GitHub surfaces the guide where contributors look for it.

The short version:

- **Solve a real problem you actually hit** — speculative or theoretical fixes are closed.
- **One change per PR**, targeting `dev` from a task branch. `main` holds releases only.
- **Run the gates before you commit:** `bash scripts/sh/validate-skills.sh`, `bash scripts/sh/validate-skill-graph.sh`, `bash scripts/sh/validate-trigger-collisions.sh`, and `bash scripts/sh/token-budget.sh --chain NAME` for each chain in `docs/chains.toml`. CI runs them on every push and PR.
- **Prove behaviour-shaping changes** by re-running the tests and reporting what they returned — see [`skills/common/writing-skills/references/testing.md`](skills/common/writing-skills/references/testing.md). An inconclusive result is a valid finding; a green-washed one is not.
- **Respect the authoring rules** for anything under `skills/` or `docs/`: no external references, no vendor model names, lean format ([`CLAUDE.md`](CLAUDE.md), "Authoring rules").
- **AI agents:** read the "If you are an AI agent" section of [`CLAUDE.md`](CLAUDE.md) first, and fill every section of the PR template truthfully — including the authoring-environment disclosure.

If you are unsure whether a change belongs in core, open an issue first — "no skill is needed here" is a valid, useful outcome.
