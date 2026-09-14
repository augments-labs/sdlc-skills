# Agent Skills conformance

This library targets the [Agent Skills specification](https://agentskills.io/specification).
The standard outranks repository rules. House policy may impose stricter limits,
but must distinguish those limits from standard requirements and recommendations.
This page names the conformance target; shipped skills state their instructions
without external provenance.

## Required format and check coverage

Skills use ordinary `SKILL.md` files with YAML frontmatter. The repository gate
runs `skills/common/writing-skills/scripts/check-skill.sh` for each skill, then
adds packaging and house-policy checks.

| Format requirement | Current coverage |
| --- | --- |
| YAML frontmatter with `name` and `description` | Delimiter and field extraction for this library's simple format; not a complete YAML parser |
| `name`: 1–64 lowercase letters, digits, or hyphens | Length and character checks |
| No leading/trailing hyphen or consecutive hyphens | Pattern check |
| `name` matches its directory | Per-directory comparison |
| Nonempty `description`, at most 1024 characters | Extracted field length; longest is 452 |
| Only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` | `frontmatter-fields` policy check |
| `compatibility`, when present, at most 500 characters | `compatibility-length` policy check |

The checker does not validate every optional metadata field or every YAML form.
Policy checks report as warnings; `--strict` makes them failures. A green result
establishes its implemented checks, not full validation of any arbitrary
standard skill. Inspect unfamiliar metadata against the specification.

## Recommendations and enforced house policy

The specification and creator guidance recommend concise bodies, progressive
disclosure, nearby references, and conventional supporting directories. This
library enforces several of those recommendations as house limits. A rejection
under a stricter house rule is not automatically a standard violation.

| Dimension | House policy and measurement |
| --- | --- |
| Body lines | At most 500; longest is 172 (34% of ceiling) |
| Estimated body tokens | Under 5000 by the skill checker; largest is ~2018 |
| Typical body size | Aim near 80–120 lines; longer discipline bodies need relevant behavioral evidence |
| Presentation | The checker warns on long undifferentiated prose; keep readable sentences |
| Supporting paths | Resolve inside the installed skill and keep direct references shallow |
| Gotchas | `gotchas-present` policy check: the body has a `## Gotchas` section |
| Support-file load conditions | `reference-load-condition` policy check: a named `references/` or `assets/` file carries when, if, before, or after |
| Support-file depth | `reference-depth` warning: a support file names another support file |
| Description YAML | `description-yaml` policy check: the raw value loads under a strict YAML parser |
| Fill-in templates | Put them in `assets/`; keep explanatory guidance in `references/` |

`check-skill.sh` estimates tokens as words × 1.3. The CI drift gate,
`scripts/sh/token-budget.sh`, uses characters ÷ 4 over full `SKILL.md` files and its configured maximum. These are approximate text budgets, not interchangeable token counts
or billing measurements. The validator checks this page's maximum sizes and
directory counts against the current tree.

Concision means removing unnecessary content. Do not shorten instructions by
removing the verbs and context needed to act on them.

## Authoring practices

[Creator best practices](https://agentskills.io/skill-creation/best-practices)
recommend focused, reusable guidance and control proportional to task fragility.
Apply those principles through the library's authoring skill:

- Describe when the skill applies and distinguish adjacent skills. The house
  description convention uses plain trigger language without emphasis.
- Include knowledge the agent needs for the task; omit generic explanations.
- State when to load each supporting file.
- Give defaults for routine implementation choices. Preserve decisions that
  belong to the user and reuse valid, scoped authority where the owner permits.
- Use a concrete template when output structure matters.
- Keep exact sequences and discipline controls where an incorrect action has
  consequences; allow judgment where several approaches satisfy the contract.

## Supporting directories and scripts

| Directory | House use |
| --- | --- |
| `references/` | 21 skills; rubrics, checklists, worked examples, and lookup guidance |
| `assets/` | 28 skills; every fill-in template and other static resources |
| `scripts/` | 5 skills — see below |

The repository classifies a document by its use: a file filled and emitted is a
template even if its filename says otherwise. The gate rejects such templates
under `references/` as house policy; the standard's optional layout conventions
are not a universal prohibition on other valid organizations.

| Skill | Scripts | Effects and purpose |
| --- | --- | --- |
| `finishing-a-branch` | `branch-state.sh` | Inspects commits, dirty state, ownership, and recoverability |
| `verification-before-completion` | `state-identity.sh` | Captures source identity and environment for evidence binding |
| `writing-skills` | `check-skill.sh` | Inspects skill files and executes bundled scripts with `--help` |
| `viewing-artifacts` | `serve.py`, `start-server.sh`, `stop-server.sh` | Starts and stops an owned local preview, writes a log, and may open a browser |
| `ui-ux-design` | The same preview scripts | Provides the governed comparison preview; the gate checks byte equality with the viewer copies |

Scripts require their declared runtimes and system tools, but add no third-party
package dependencies. Inspectors and preview lifecycle commands have different
effects. Use the owning skill's resource and cleanup rules for a preview.

Conformance checking executes candidate script code to check `--help`; it is not
passive inspection of an arbitrary untrusted directory. Review that code or use
appropriate isolation before running the checker on an external skill. The
current bundled help branches return without starting their operational work.

## Evaluation is separate from conformance

The testing layout is repository policy, not part of the standard's required
skill format. `tests/` holds offline script and packaging checks; labeled
behavior scenarios and description tuning measurements live in the evals lab,
[sdlc-skills-evals](https://github.com/augments-labs/sdlc-skills-evals) (see
[`testing.md`](testing.md)). Neither a structural pass nor a description score
certifies model behavior.

### Description tuning

Query sets live in the lab at `descriptions/{{phase}}/{{skill}}.json`.
The current corpus contains 34 sets for 36 skills. The always-applicable router
has no negative class; `containing-an-incident` also has no set. Existing sets
usually contain 10 positive and 10 near-miss negative queries; `executing-plans`
currently has 13 positives and 13 negatives. These are tuning inputs, not a
mandatory coverage matrix.

The runner repeats queries through a fixture and the installed library. It
observes whether the subject loads anywhere in the chain during the observation
window, not just which description matched first. Adapter detection also does
not by itself prove that the full body was read and obeyed. A required downstream
handoff must not be mislabeled as an incorrect initial selection.

Train and validation splits are fixed. Revise against train cases and use
validation to select an iteration; validation is then selection evidence, not an
untouched final test. Report valid/attempted counts and excluded or inconclusive
runs. Refusals and malformed records are excluded; a responding run that later
times out can still count as a miss. Scores depend on this fixture, library,
harness, and observation window.

The 0.5 trigger-rate threshold is an optimization rule, not a certification
barrier. The lab's descriptions guide owns the loop;
[description optimization guidance](https://agentskills.io/skill-creation/optimizing-descriptions)
gives the broader method.

### Behavioral evidence

The `none` arm installs no library; `red` installs the complete baseline library;
`green` installs the complete candidate library. A controlled before/after pair
can measure the intended edit when other inputs stay fixed. It does not isolate
one skill's value or overhead from the rest of the library and generated work.

Keep every observed failure, pass, timeout, refusal, and inconclusive result. A
pass says the failure was not observed in that sample; it cannot erase reported
failures or settle a current contract contradiction. Cost lines report total run
time and available harness telemetry, not an isolated per-skill price. See
[`testing.md`](testing.md) for interpretation and proportionality.

## Running the repository checks

```bash
bash scripts/sh/validate-skills.sh
bash scripts/sh/validate-skill-graph.sh
bash scripts/sh/token-budget.sh --chain bug-fix
bash scripts/sh/validate-trigger-collisions.sh
bash skills/common/writing-skills/scripts/check-skill.sh path/to/skill
```

The first checks the library and its adapters. The second reports pairs of
skills that hand off to each other: a pair listed in `docs/allowed-cycles.txt`
prints as allowed, and `--strict` fails on any other. The third sums the body
words of one chain in `docs/chains.toml` and fails over its budget. The fourth
reports each description clause of three or more words that more than one skill
shares, and `--strict` fails on any. The fifth accepts a skill path, including
one outside this repository, subject to the parsing and execution limits above.
The first and fifth enforce this checker's profile.

The standard's reference validator is not vendored because this library adds no
third-party dependencies. A separate, non-blocking CI job installs it and runs it
over every skill directory as a parser cross-check; its output is a job summary,
never a gate. When its verdict differs from `check-skill.sh`, investigate rather
than defer to either tool: identify the rule and parser behavior involved,
correct a mistaken standard claim, and retain an intentional, accurately labeled
house restriction.
