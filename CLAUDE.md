# CLAUDE.md

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
4. **Meet every bullet in *Contributing*** — a real problem you actually hit, one change, the gate re-run with what it actually returned, behaviour-shaping changes proved, and the authoring environment disclosed.
5. **Show the human the complete diff** for explicit approval before submitting.

If any check fails, do not open the PR. Explain why it would be rejected and what would have to change first.

Local checkpoint commits on a task branch are ordinary authorized work here, and
`using-git-worktrees` owns when to make one and what it does not grant.

## Authoring rules (non-negotiable)

Files under `skills/` and `docs/` ship to users. They must be self-contained,
portable engineering guidance.

`docs/` is website documentation for the current library contract. Never put
run transcripts, failure records, pass-rate anecdotes, superseded behavior, or
investigation notes there. Keep reproducible scenarios under `tests/`; keep
ephemeral results in the review workflow or private notes.

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
4. **Prove behavior-shaping changes.** If you never watched an agent fail without
   the skill, you do not know it prevents the right failure. Where there is no
   failure to reproduce, say which class the skill is in instead of running
   something — `skills/common/writing-skills/references/testing.md` draws that
   line and owns the rest.

## Verify against the gate

Rules 1–3 are not honor-system. `scripts/sh/validate-skills.sh` enforces them
deterministically — frontmatter shape, body and description ceilings, no external
references, no vendor model names, the `assets/` vs `references/` split, and that
every skill is registered in the plugin manifests. CI (`.github/workflows/`) runs
it on every push and PR. Run it before you commit:

```bash
bash scripts/sh/validate-skills.sh
```

For a single skill, and for the standard's own rules rather than this
repository's, `skills/common/writing-skills/scripts/check-skill.sh` checks any
skill directory — including one outside this repo — and reports findings with an
exit code.

Rule 4 (behavior) has no deterministic gate — that is the honest limit. Which
live run answers which question, and what a red result means on each side of
`tests/`, is `docs/testing.md`. Report the real numbers in the PR, failures and
inconclusive results included. Which harness produced a run is plumbing: leave
it out of PR, commit, and release narratives unless it is material to the
result — a harness-specific failure or adapter bug is exactly the case where
naming it is the finding.

## Adding a skill

Invoke `writing-skills` and follow its procedure — it owns the template, the
format, and the checks to run before calling one done. Three things are this
repository's and are not in there: prove the failure first, pick the phase
folder from the canonical order in `README.md` (or `common/`), and run
`scripts/sh/validate-skills.sh`, which adds the house rules on top of the
standard's.

**Prove the failure before you author, not after.** A gap in what the library
documents is not a gap in what an agent does. Reading the catalogue for holes
finds absences reliably and predicts behaviour badly — an absence tells you what
nobody wrote, never what an agent gets wrong without it. So where the failure can
be reproduced at all, reproduce it first: run the scenario against a bare agent,
`--arm none`, and watch it fail. A pass means there is nothing to prevent and the
skill would be ceremony; "no skill is needed here" is the finding, so report it
and stop. Where there is no failure to reproduce, authoring rule 4 already
governs.

A red on `--arm none` is necessary and not sufficient. It shows that a *bare*
agent fails, never that the current skills do — only `--arm red` answers that,
and a skill duplicating one already in the catalogue is what that second run
catches. `docs/testing.md` owns which run answers which question.

## Editing a skill

Changing a skill is changing behaviour, and a skill modification is measured
before it lands. The measurement that decides is the **behavioural** one — what
the skill actually does. Match the run to what changed:

- **The always-loaded `SKILL.md` body:** where the change has a failure that can
  be reproduced, run the smallest existing scenario or a temporary before/after
  probe that exercises it, and report the result. Where it has none, name the
  class and say so — that is a finding, not a skipped step. Do not add a
  permanent fixture for coverage.
- **Description (the trigger):**
  `tests/optimizing/descriptions/test-triggering-on-queries.sh` *optimizes* a
  description; it does not certify one, and no edit is held open waiting for it.
  Reach for it when you are tuning that description — `tests/optimizing/README.md`
  owns the loop, what a set must contain, and what a run costs.
- **A file under `references/` or `assets/`** (loaded on demand, not under
  pressure): the always-loaded body is unchanged — no behavioural re-run is
  owed; say so.
- Never reword carefully-tuned discipline content — rationalization tables,
  red-flag lists, hard-stops — without re-proving it still holds. An inconclusive
  result *is* the finding; report it.

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
- **Run the gate, and prove behaviour-shaping changes,** before opening a PR (see *Verify against the gate*).
- **Identify yourself.** Disclose in the PR the model, harness, harness version, and any installed plugins that produced the change — or state plainly it was written by hand. Contributions are weighed by how they were made: a behaviour claim reasoned from documentation is held to a different bar than one grounded in a real session. Hiding the authoring environment is grounds for closing the PR.
- **Target `dev` from a task branch.** `dev` is where reviewed changes collect; `main` holds releases only and receives nothing but release PRs from `dev`. A PR opened against `main` is asked to retarget `dev` before review.
- **Never bump versions or edit CHANGELOG version headings in a PR.** Releases are versioned once, by the maintainer — see `RELEASING.md`, which also owns what a changelog entry says.
- **No third-party dependencies.** SDLC skills is zero-dependency by design; a change that needs an external tool or service belongs in a separate plugin. Adding a harness is the exception.
- The bar is the gate and the evidence, not volume or confidence. "No skill is needed here" is a valid, useful outcome; an inconclusive result is a valid finding; a fabricated one closes the PR.

## New harness support

Adding a harness (an IDE, CLI, or agent runner) means more than dropping skill
files where the tool can see them — they must actually *load and activate*. These
skills are inert unless the harness both discovers them and is nudged to reach
for one at the right moment (on Claude Code, the `hooks/` SessionStart nudge;
elsewhere, an equivalent). See `docs/harness-support.md`.

A PR adding a harness MUST add `tests/harnesses/{{name}}.sh` bindings for the
shared runners and show a skill *actually activating* through that harness's
CLI on a representative opening, not describe how it should work. Files present
but never invoked are not a working integration.

## Layout

- `skills/<phase>/<name>/` — the skills, by SDLC phase (canonical order is in `README.md`; folders are unnumbered).
- `.claude-plugin/` — the install manifest; its skills array must list every skill on disk (the gate checks it). `.kimi-plugin/` — the Kimi Code manifest; its skills paths must resolve to the same canonical set. `plugins/sdlc-skills/` — the Codex plugin, whose skill mirror the sync script regenerates. Adding a harness: `docs/harness-support.md`.
- `AGENTS.md`, `GEMINI.md` — symlinks to this file, so a harness that reads its own instructions file gets the same guidance from one source.
- `.github/` — CI (`workflows/validate.yml`, `workflows/release-readiness.yml`) and the PR template (`PULL_REQUEST_TEMPLATE.md`).
- `scripts/sh/` — portable validators, token budget, adapter checks, and hook scripts; CI runs `validate-skills.sh` and `token-budget.sh`. Everything here is deterministic, free, and safe to run anywhere.
- `tests/` — everything that observes the library running, split by what a red result means. The **gates** live here directly, where the answer is known in advance: `run-behavioral.sh` with `behavioral/{{name}}.sh`, plus the offline `run-session-start.sh`, `run-plugin-smoke.sh`, and `run-serve-preview.sh`. `fixtures.sh` is the disposable project a live run is pointed at.
- `tests/optimizing/` — **measurements**, where it is not: `descriptions/test-triggering-on-queries.sh` scoring descriptions against `descriptions/{{phase}}/{{skill}}.json`. A red sheet here is not a regression, and no part of it runs in CI.
- `tests/harnesses/{{name}}.sh` — one file per CLI, holding only what differs between them: install, invoke, detect, cost. They decide nothing; every runner binds to them.
- `assets/` — the project's brand marks. Not to be confused with a skill's own `assets/`, which holds templates that skill emits.
- `docs/` — repository-only rationale: philosophy, activation, harness support, skill granularity, testing, and the conformance record. Never referenced from a shipped skill; the gate enforces that.
- `CHANGELOG.md`, `RELEASING.md` — the release record, and how releases are versioned and cut (semver over the skill surface; the gate checks the four manifest versions agree).
- `.claude/` — local config and notes; gitignored, never shipped.
