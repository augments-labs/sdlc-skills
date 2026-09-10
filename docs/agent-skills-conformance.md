# Agent Skills conformance

This library targets the open **Agent Skills** standard published at
<https://agentskills.io>. A skill written here is a standard skill: a directory
containing `SKILL.md` with YAML frontmatter, loaded by any compliant agent
through progressive disclosure. Nothing here needs a bespoke loader, a custom
manifest field, or a house file format.

## Precedence

**The standard outranks every house rule.** Where `CLAUDE.md`, this document, or
anything else in `docs/` conflicts with agentskills.io, the standard wins and the
house rule is the bug. A house rule may be *stricter* than the standard — that is
not a conflict — but it may never permit what the standard forbids, forbid what
the standard requires, or reassign a meaning the standard defines.

This document is the conformance record: what the standard requires, where the
gate enforces it, where we are stricter, and where we knowingly differ.

> This is the one file that names an external source by URL. The authoring rule
> against external references keeps *provenance* out of shipped guidance. A
> conformance target is not provenance — it is the contract the artifacts are
> built to, and a contract you cannot name is one nobody can check. Files under
> `skills/` still carry no URLs; they state the limits as numbers.

## Normative conformance

Every row is checked by `scripts/sh/validate-skills.sh`, which CI runs on every
push and pull request.

| Standard requirement | Status | Gate |
| --- | --- | --- |
| `SKILL.md` with YAML frontmatter | conforms | frontmatter parsed for every skill |
| `name` 1–64 chars, lowercase `a-z0-9-` | conforms | charset + length check |
| `name` no leading/trailing hyphen, no `--` | conforms | pattern check |
| `name` matches parent directory | conforms | compared per skill |
| `description` non-empty, ≤ 1024 chars | conforms | length check; longest is 460 |
| Body ≤ 500 lines | conforms | line check; longest is 162 (32% of ceiling) |
| Body < 5000 tokens recommended | conforms | token check; largest is ~1757 (35%) |
| File references relative to skill root | conforms | every path resolved in the install tree |
| References one level deep, no nested chains | conforms | depth check |
| `scripts/` / `references/` / `assets/` semantics | conforms | see *Directory conventions* |

No skill in the library violates a normative rule of the standard.

## Where we are stricter, and why

Many skills coexist in one session, several can be active at once, and the
router's body is resident from session start. That arithmetic justifies a tighter
*house target* — but only as a target.

| Dimension | Standard | House target | Enforcement |
| --- | --- | --- | --- |
| `SKILL.md` body | ≤ 500 lines | 80–120 typical | warns over 200, **fails** over 500 |
| Body tokens | < 5000 | ≈ 2000 | warns over 2500, **fails** over 5000 |
| Body drift | — | ≈ 2000 | **fails** over 5000 in CI |
| `description` | ≤ 1024 chars | ≈ 460 chars | **fails** over 1024 |

The two token rows count differently and are not comparable: `check-skill.sh`
scores a body against the standard's 5000 as words × 1.3, while
`token-budget.sh` reports the always-loaded surface as characters ÷ 4. The
second is the drift gate CI runs.

A *target* prompts the question of whether a body earned its length. A *limit* is
a wall authors write around. Do not buy line count with telegraphic,
noun-stacked prose: that reads as concision but makes the agent decompress the
instruction before it can act.

**Compression is not concision.** Cut a paragraph that does not change behaviour;
do not cut the articles and verbs out of one that does.

## Practices adopted from the standard

Not machine-checkable. These are the bar a reviewer holds a skill to.

- **Descriptions are triggers, and carry no emphasis.** Imperative and in the
  third person — every one opens `Use when…`, `Use before…`, `Use after…` — and
  states the situation the user is in rather than what the procedure does inside.
  Deliberately pushy where a trigger is easy to miss: the contexts are listed
  explicitly, including the ones that never say the skill's own vocabulary ("even
  if nobody says branch or worktree"). Short, because the trigger words are what
  fires it and nothing may crowd them out — which is also why a shouted
  imperative belongs in a body and never here.
- **Add what the agent lacks; omit what it knows.** No skill explains what a pull
  request is, what a migration does, or why tests are good.
- **Say *when* to load each reference,** never "see `references/` for details."
- **Match specificity to fragility.** Prescriptive where an exact sequence or an
  authority boundary is at stake; open where several approaches are valid.
- **Explain the why.** Where this library says "never", the failure is silent and
  expensive, and the rebuttal is stated alongside.
- **Defaults, not menus — for the agent's own choices.** Where several approaches
  work, name one and mention the alternative briefly. This does **not** apply to
  a decision that belongs to the user: presenting a bounded set of options and
  stopping is the correct shape for an authority handoff.
- **Templates beat prose descriptions of format.** Where output shape matters,
  the skill ships the shape.
- **Present the body as sections and paragraphs,** not a wall of prose.
  `check-skill.sh` warns on any undifferentiated run over 12 lines.

## Directory conventions

| Directory | Standard's purpose | Our use |
| --- | --- | --- |
| `references/` | documentation read on demand | 23 skills; rubrics, checklists, reviewer briefs, worked examples |
| `assets/` | static resources, incl. document templates | 26 skills; every fill-in template — see below |
| `scripts/` | bundled executable code | 5 skills — see below |

**The split.** A file the agent *fills in and emits as an artifact* is a
template: `assets/`. A file it *reads to decide or check* is documentation:
`references/`. The honest classifier is the file's own opening sentence — "Fill
one row per…", "Copy this structure…", "Write the completed artifact to…" is a
template regardless of what the filename says. The gate fails a `references/`
file that opens that way, so the split cannot drift back.

These templates lived in `references/` until conformance was reconciled, on the
reasoning that moving them would churn every path for no reader benefit. That is
house convenience outranking the conformance target, which the precedence rule
above forbids.

**On `scripts/`.** The standard's criterion is observational: bundle a script
when the agent is reinventing the same logic every run. Process-discipline skills
look exempt — they teach judgement, not mechanics. That is half right, and the
wrong half matters, because in each case below the reinvention *is* the failure
the skill exists to prevent:

| Skill | Script | What was being re-derived |
| --- | --- | --- |
| `finishing-a-branch` | `branch-state.sh` | commit counts, dirty inventory, worktree ownership, recoverability — the values its menu and discard block interpolate |
| `verifying-completion` | `state-identity.sh` | the source digest evidence is bound to, and whether it drifted while the gate ran |
| `writing-skills` | `check-skill.sh` | conformance itself: frontmatter, name, description, body ceilings, presentation, reference resolution |
| `viewing-artifacts` | `serve.py`, `start-server.sh` / `stop-server.sh` | the governed localhost preview — session key, owner watchdog, idle timeout, PID-safe stop; an ad-hoc server reinvents each, badly |
| `ui-ux-design` | `serve.py`, `start-server.sh` / `stop-server.sh` | the same preview for comparison surfaces; copies are byte-identical, pinned by the gate |

The discriminator is not "discipline versus mechanics" but whether a step has a
*single correct answer a machine can compute*. Where it does, an agent
recomputing it by hand will eventually get it wrong. Where a step needs judgement
— which resources this task owns, whether a base is the intended one — no script
is offered and none should be. Every bundled script is read-only,
dependency-free, non-interactive, answers `--help`, prints structured stdout with
diagnostics on stderr, and returns meaningful exit codes.

The rest of the library has no `scripts/`, deliberately. Bundling one where
nothing is being reinvented is speculative machinery.

`check-skill.sh` is also where the standard's own rules are enforced for this
repository: the house validator runs it per skill rather than keeping a second
implementation of frontmatter shape, the description limit, the body ceilings,
and link resolution. Two copies of one rule can disagree, and delegation puts a
shipped script on the CI path instead of taking its correctness on trust.

The validator keeps only the house rules layered on top, and treats a missing or
unrunnable checker as a hard failure — delegation otherwise fails open, passing
every skill in silence. It also re-measures the numbers this document states —
the longest description, the longest body, the largest body in tokens, and the
three directory counts — and fails when they no longer match the tree, so the
record cannot rot into a claim that merely reads as checked.

## Evaluation

`tests/optimizing/` is not part of the specification; it appears only in the standard's
evaluation guide, as a suggested layout. We adopt that guide's **method** and
keep our own layout — no conformance question arises.

### Trigger evals

Implemented, not merely adopted. Every skill has a query set at
`tests/optimizing/descriptions/{{phase}}/{{skill}}.json` — 10 should-trigger
queries
and 10 **near-miss** should-not-trigger ones, each fixed to a `train` or
`validation` split in the file so the holdout is never reshuffled between
iterations. Negatives also record `expect`, the route they should have taken.

`tests/optimizing/descriptions/test-triggering-on-queries.sh` repeats each query,
drops provider refusals from the denominator rather than averaging an outage into
the score, and reports a **trigger rate**: pass above 0.5 for a positive, below
0.5 for a negative. Whether a description fires is live and cannot be gated in
CI. Whether its query set is *capable of deciding* — enough queries, real
near-misses, a proportional holdout, no duplicates — is structural but is not
gated either: that corpus exists to tune descriptions, so its state is a number
to compare, never a claim about the library. It stays a review question, and
`tests/optimizing/README.md` says what a set has to contain.

One skill is exempt: the router fires at every task opening by design, so it has
no should-not-trigger class. Where it routes *next* is measured by every other
query set in the directory.

Revise against train failures only; adding a query's own keywords to a
description is overfitting. Select the iteration with the best **validation**
rate, which is often not the last.

### Behavioural evals

- **Assertions graded against observable evidence,** never a narrated verdict.
- **The without-skill baseline** — the arm that decides whether a skill earns its
  context:

  | Arm | Skills loaded | Question it answers |
  | --- | --- | --- |
  | `none` | none | Does the model already do this unaided? |
  | `red` | the version at `--base` | What did the previous version do? |
  | `green` | the working tree | What does my edit do? |

  `none` versus `green` is the value test, and the one that can retire a skill.
  `red` versus `green` is the regression test. A skill that passes `none` as well
  as it passes `green` is spending context for nothing.

- **What the arm cost,** not only whether it passed. Value is a ratio: a skill
  that lifts the assertions while tripling the tokens is a different trade from
  one that is better and cheaper, and a pass rate alone cannot separate them.
  Each run prints wall clock, plus tokens where the harness's own stream reports
  them; the difference between two arms' cost lines is the price of the skill.

  Token counts come from a per-adapter primitive written against the CLI's
  structured stream, never from assumed field names. A harness that reports
  nothing says so rather than printing a zero. We stop at the per-run cost line
  and do not build the guide's aggregated benchmark workspace, because an
  evaluator larger than the thing evaluated is the failure the proportionality
  rule exists to prevent.

Layout difference: inputs live once and are split by what they decide rather
than by the skill they belong to. Everything that observes the library running
sits under `tests/`, and inside it the split is by what a red result means:
description-tuning corpora are measurements and live under
`tests/optimizing/descriptions/`; gates whose answer is known in advance live in
`tests/` itself; the per-CLI bindings both sides need are neither, and live under
`tests/harnesses/`. Per-skill `evals.json` files colocated
with each skill would duplicate every input per harness, since the same input
runs through several agent CLIs. Proof stays proportional to the claim — a
behavioural scenario is retained for a failure actually observed, not to
enumerate imagined gaps.

## Checking conformance

```bash
bash scripts/sh/validate-skills.sh          # whole library, CI gate
bash skills/common/writing-skills/scripts/check-skill.sh path/to/skill
```

The second is portable: it checks any standard skill directory, including one
outside this repository, and prints machine-readable results.

The standard also publishes a reference validator, `skills-ref validate`. It is
not vendored here — this library is zero-dependency by design — but running it
against a skill directory should agree with our gate. If it does not, our gate is
wrong.
