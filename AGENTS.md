# AGENTS.md

Guidance for anyone — human or agent — working in this repository.

`sdlc-skills` is a cross-platform library of opt-in SDLC skills for coding
agents. Read `README.md` for the philosophy, and
`skills/common/writing-skills/SKILL.md` before authoring or editing any skill.

The one idea behind every skill: you are a non-deterministic generator, so claims
leave the generator through an external **gate**, never through confidence. Which
kind of gate answers which kind of claim is `using-sdlc-skills`.

Emphasis is how a body gets obeyed. An agent can obey an instruction; it
cannot obey a fact. "Review and integration remain separate gates" is a fact,
and an agent under pressure reads past it. "Invoke `requesting-code-review`
before any push" is an instruction, and a hard stop, a REQUIRED marker, a
red-flag list, or a rationalization table placed at the exact step where the
temptation hits is what makes it stick. Write bodies that way, deliberately: a
handoff is a numbered, emphasized step naming the skill to invoke, never a
closing remark. The sessions in which an agent skipped a gate skipped one that
was stated as a fact.

Emphasis has one limit: it gets an agent to a gate; it never replaces one.
Nothing becomes true by being said forcefully, so a forceful instruction still
ends at an executable check, an accountable decision, or a review. And it stays
out of descriptions, which fire on plain triggers — that was measured, not
assumed.

## If you are an AI agent

Read this before you change anything. A weak PR does not help the human you are
working with: it costs a reviewer's time, spends that human's credibility, and
gets closed regardless. What counts is whether the diff meets the bar below, not
whether you can say you followed a checklist.

Before you open a PR here, you MUST:

1. **Read the PR template** (`.github/PULL_REQUEST_TEMPLATE.md`) and fill every section with specific, true answers — not placeholders, not a summary of what you *would* do.
2. **Search PRs and issues — open *and* closed — for the same problem.** If it already exists or was already rejected, stop and tell the human you're working with; don't open a duplicate. If a prior attempt was closed, say what is different here.
3. **Confirm it belongs in core** — see *What belongs here*.
4. **Meet every bullet in *Contributing*** — a real problem you actually hit, one change, the gate re-run with what it actually returned, behaviour-shaping changes explained, and the authoring environment disclosed.
5. **Show the human the complete diff** for explicit approval before submitting.

If any check fails, do not open the PR. Explain why it would be rejected and what would have to change first.

Local checkpoint commits on a task branch are ordinary authorized work here, and
`using-git-worktrees` owns when to make one and what it does not grant.

## Authoring rules (non-negotiable)

Files under `skills/` and `docs/` ship to users. They must be self-contained,
portable engineering guidance.

`docs/` is website documentation for the current library contract. Never put
run transcripts, failure records, pass-rate anecdotes, superseded behavior, or
investigation notes there. Keep ephemeral results in the review workflow or private notes.

**The Agent Skills standard outranks every rule here.** Where this file, or
anything under `docs/`, conflicts with agentskills.io, the standard wins and the
house rule is the bug. A house rule may be *stricter*; it may never permit what
the standard forbids, forbid what it requires, or reassign a meaning it defines.
The conformance record is `docs/agent-skills-conformance.md`.

1. **No external references.** Do not name other repositories, projects,
   articles, or authors, and do not cite issue/PR numbers or tracker links. State
   the principle directly ("a monolithic plan is re-read on every compaction") —
   never attribute it. Provenance belongs in private notes, not a shipped skill.
   The same rule governs commit messages, PR descriptions, and release notes:
   state the change and its evidence; never attribute it to another repository,
   project, or library it may resemble. (Disclosing the authoring environment,
   required under *Contributing*, is not attribution and stays.)
2. **Model- and harness-agnostic.** Refer to models by capability tier —
   `small | medium | large` — never vendor names (haiku, sonnet, gpt, gemini, …).
   Don't assume a specific harness's tooling or paths. Each harness binds
   tier → model and action → command.
3. **The format is `skills/common/writing-skills`.** Body ceilings, the
   `description` shape, which sibling directory each support file goes to, the
   complexity gate, `{{double-curly}}` placeholders, how to get shorter without
   compressing prose into noun stacks, and why discipline skills run longer are
   all stated there, once. Invoke that skill before authoring or editing one —
   this file does not restate it, so a copy here cannot drift from it.
4. **Explain behavior-shaping changes.** A change to what a skill makes an agent
   do names the failure or contract gap it answers. This repository runs no live
   agent, so the PR argues from the skill text and the gates.
5. **A body you touch meets the current `writing-skills` format in full**,
   including its Gotchas, load-condition, and fragile-operation rules. Run
   `check-skill.sh --strict` on each skill you edit: `validate-skills.sh` reports
   those checks as warnings, so CI does not fail on them.

## Verify against the gate

Rules 1–3 are not honor-system. `scripts/sh/validate-skills.sh` enforces them
deterministically — frontmatter shape, body and description ceilings, no external
references, no vendor model names, the `assets/` vs `references/` split, and that
every skill is registered in the plugin manifests. CI (`.github/workflows/`) runs
it on every push and PR. Run it before you commit:

```bash
bash scripts/sh/validate-skills.sh
```

For one skill, `skills/common/writing-skills/scripts/check-skill.sh` applies the
checker's format and house-policy profile, including outside this repository.
It extracts the library's frontmatter subset rather than parsing all YAML, and
executes bundled scripts with `--help`. See `docs/agent-skills-conformance.md`
for coverage and effects before checking an unfamiliar skill.

Rule 4 (behavior) has no deterministic gate — that is the honest limit. No live
agent runs in this repository or its CI.

## Adding a skill

Invoke `writing-skills` and follow its procedure — it owns the template, the
format, and the checks to run before calling one done. Three things are this
repository's and are not in there: name the failure it answers, pick the phase
folder from the canonical order in `README.md` (or `common/`), and run
`scripts/sh/validate-skills.sh`, which adds the house rules on top of the
standard's.

**Start from the failure.** Record observed sessions, current contract gaps,
and unmeasured candidates separately, and name which one the new skill answers.

## Editing a skill

Changing a skill is changing behaviour. This repository runs no live agent, so a
change is judged on its text and the gates:

- **The always-loaded `SKILL.md` body:** name the failure or contract gap the
  change answers, and run `check-skill.sh --strict` on the skill.
- **Cutting:** cut by judgement, not word count. Ask of each section:
  "would the agent get this wrong without this?" When unsure, keep it and say
  so in the PR. Hard stops and destructive-action guards are never cut.
- **Description (the trigger):** follow `writing-skills`' description shape;
  the collision gate reports a trigger clause another description already carries.
- **A file under `references/` or `assets/`** (loaded on demand, not under
  pressure): the always-loaded body is unchanged; say so.
- Never reword carefully-tuned discipline content — rationalization tables,
  red-flag lists, hard-stops — without saying in the PR why the new wording holds
  the same line.

## What belongs here

Core skills are **general-purpose SDLC guidance** — useful across projects,
languages, and domains. A skill that only helps one domain, tool, team, or
workflow belongs in your own skill library, not here. The test: would this help
someone on a completely different kind of project?

For whether a phase's activities are separable or one interleaved pass, see
`docs/skill-granularity.md`.

## Contributing

- **Solve a real problem you actually hit** — not a speculative or theoretical one. "My review agent flagged it" or "this could theoretically break" is not a problem statement.
- **One change per PR.** Don't bundle unrelated edits or batch-fix the tracker — pick one problem, understand it, submit focused work.
- **Run the gates** before opening a PR (see *Verify against the gate*).
- **Identify yourself.** Disclose in the PR the model, harness, harness version, and any installed plugins that produced the change — or state plainly it was written by hand. Contributions are weighed by how they were made: a behaviour claim reasoned from documentation is held to a different bar than one grounded in a real session. Hiding the authoring environment is grounds for closing the PR.
- **Target `dev` from a task branch.** `dev` is where reviewed changes collect; `main` holds releases only and receives nothing but release PRs from `dev`. A PR opened against `main` is asked to retarget `dev` before review.
- **Never bump versions or edit CHANGELOG version headings in a PR.** Releases are versioned once, by the maintainer — see `RELEASING.md`, which also owns what a changelog entry says.
- **No third-party dependencies.** SDLC skills is zero-dependency by design; a change that needs an external tool or service belongs in a separate plugin. Two exceptions: adding a harness, and the non-blocking CI job that cross-checks skills with the Agent Skills reference validator — users install nothing and it never gates.
- The bar is the gate and the evidence, not volume or confidence. "No skill is needed here" is a valid, useful outcome; an inconclusive result is a valid finding; a fabricated one closes the PR.

## New harness support

Adding a harness (an IDE, CLI, or agent runner) means more than dropping skill
files where the tool can see them — they must actually *load and activate*. These
skills are inert unless the harness both discovers them and is nudged to reach
for one at the right moment (on Claude Code, the `hooks/` SessionStart nudge;
elsewhere, an equivalent). See `docs/harness-support.md`.

A PR adding a harness MUST add `tests/harnesses/{{name}}.sh` offline bindings
for `tests/run-plugin-smoke.sh` and
show a skill *actually activating* through that harness's CLI on a
representative opening, not describe how it should work. Files present but
never invoked are not a working integration.

## Layout

- `skills/<phase>/<name>/` — the skills, by SDLC phase (canonical order is in `README.md`; folders are unnumbered).
- `.claude-plugin/` — the install manifest; its skills array must list every skill on disk (the gate checks it). `.kimi-plugin/` — the Kimi Code manifest; its skills paths must resolve to the same canonical set. `plugins/sdlc-skills/` — the Codex plugin, whose skill mirror the sync script regenerates, listed for install by `.agents/plugins/marketplace.json`, the Codex marketplace listing that names it. `.opencode/` — the OpenCode plugin, which registers the canonical skills and injects the router through hooks (the gate checks it; opencode's own cache files there stay ignored). `.muse-plugin/` — the Muse Code manifest, the same skills list for builds that ship plugin support. `.pi/extensions/` — the pi extension, which injects the router in-process. `index.js` — the package entry OpenCode 2.x resolves when the plugin is installed from npm. Adding a harness: `docs/harness-support.md`.
- `AGENTS.md` — this file, the canonical contributor guide. `GEMINI.md` symlinks to it; `CLAUDE.md` is a short pointer to it. A harness that reads its own instructions file gets the same guidance from one source, even one that refuses a symlinked instructions file.
- `.github/` — CI (`workflows/validate.yml`, `workflows/release-readiness.yml`) and the PR template (`PULL_REQUEST_TEMPLATE.md`).
- `.codex/` — the checkout-local Codex configuration: sandbox mode and approval policy, and agent nesting and concurrency limits.
- `scripts/sh/` — portable validators, token budget, adapter checks, and hook scripts, plus `data/`, the gate data they read: `chains.toml`, each chain's skills and body-word budget, and `allowed-cycles.txt`; CI runs `validate-skills.sh`, `token-budget.sh`, `validate-trigger-collisions.sh`, and `validate-skill-graph.sh`, which reports skills that hand off to each other unless `data/allowed-cycles.txt` lists the pair. Everything here is deterministic, free, and safe to run anywhere.
- `tests/` — offline tests, where the answer is known in advance and no model runs: `run-session-start.sh`, `run-plugin-smoke.sh`, `run-sdd-scripts.sh`, `run-opencode-plugin.sh`, `run-pi-extension.sh`, and `run-serve-preview.sh`.
- `tests/harnesses/{{name}}.sh` — one file per CLI, holding only how that harness installs and discovers the plugin; `run-plugin-smoke.sh` binds to them. They decide nothing.
- `assets/` — the project's brand marks. Not to be confused with a skill's own `assets/`, which holds templates that skill emits.
- `docs/` — repository-only rationale, markdown only: philosophy, activation, harness support, skill granularity, testing, and the conformance record. Never referenced from a shipped skill; the gate enforces that.
- `CHANGELOG.md`, `RELEASING.md` — the release record, and how releases are versioned and cut (semver over the skill surface; the gate checks the six manifest versions agree).
- `.claude/` — local config and notes; gitignored, never shipped.
