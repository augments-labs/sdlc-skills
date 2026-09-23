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
| Nonempty `description`, at most 1024 characters | Extracted field length; longest is 582 |
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
| Body lines | At most 500; longest is 204 (41% of ceiling) |
| Estimated body tokens | Under 5000 by the skill checker; largest is ~2312 |
| Typical body size | Aim near 80–120 lines; longer discipline bodies need relevant behavioral evidence |
| Presentation | The checker warns on long undifferentiated prose; keep readable sentences |
| Supporting paths | Resolve inside the installed skill and keep direct references shallow |
| Gotchas | `gotchas-present` policy check: the body has a `## Gotchas` section |
| Support-file load conditions | `reference-load-condition` policy check: a named `references/` or `assets/` file carries when, if, before, or after |
| Description wording | `description-rules` policy check: no `Fires on` list and none of four internal terms |
| Support-file depth | `reference-depth` warning: a support file names a support file that `SKILL.md` itself does not also name |
| Description YAML | `description-yaml` policy check: the raw value loads under a strict YAML parser |
| Fill-in templates | Put them in `assets/`; keep explanatory guidance in `references/` |
| Template shape | `validate-skills.sh`'s "every assets/ template has the house shape" check: each `assets/*.md` file matches the mechanical part of `writing-skills`' `template-format.md` `## Shape` rules 1, 2, 3 and 5 (an H1 on line 1, a preamble line before the fence, exactly one outer markdown/text fence of three or four backticks holding at least one `{{slot}}`, no bare `<angle>` placeholder outside an inline code span); rule 4 (the family shape), rule 6, sentence counts, and the content checklist stay human-judged |

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
| `references/` | 25 skills; rubrics, checklists, worked examples, and lookup guidance |
| `assets/` | 32 skills; every fill-in template and other static resources |
| `scripts/` | 9 skills — see below |

The repository classifies a document by its use: a file filled and emitted is a
template even if its filename says otherwise. The gate rejects such templates
under `references/` as house policy; the standard's optional layout conventions
are not a universal prohibition on other valid organizations.

| Skill | Scripts | Effects and purpose |
| --- | --- | --- |
| `finishing-a-branch` | `branch-state.sh` | Inspects commits, dirty state, ownership, and recoverability |
| `verification-before-completion` | `state-identity.sh` | Captures source identity and environment for evidence binding |
| `writing-skills` | `check-skill.sh` | Inspects skill files and executes bundled scripts with `--help` |
| `writing-plans`, `executing-plans`, `subagent-driven-development` | `plan-version.sh`, one byte-identical copy each | Prints a plan's version from its normalized index and task files; read-only; the gate fails when the copies differ |
| `subagent-driven-development` | `sdd-workspace.sh`, `task-brief.sh`, `review-package.sh` | Opens and re-checks a plan's run ledger, renders one role brief and refuses a half-filled one, inserts the role's report template, and assembles a task's diff for its reviewer |
| `using-sdlc-skills` | `artifact-layout.sh` | Creates the `.sdlc-skills/` directories and `evidence/.gitignore`; never overwrites a file |
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
skill format. `tests/` holds offline script and packaging checks, and no live
agent runs in this repository. A structural pass does not certify model
behavior.

## Running the repository checks

```bash
bash scripts/sh/validate-skills.sh
bash scripts/sh/validate-skill-graph.sh
bash scripts/sh/token-budget.sh --chain bug-fix
bash scripts/sh/validate-trigger-collisions.sh
bash skills/common/writing-skills/scripts/check-skill.sh path/to/skill
```

The first checks the library and its adapters; with `--strict` it also fails on
the policy checks it otherwise reports as warnings, `reference-load-condition`
included. The second reports pairs of
skills that hand off to each other: a pair listed in
`scripts/sh/data/allowed-cycles.txt` prints as allowed, and `--strict` fails on
any other. The third sums the body words of one chain in
`scripts/sh/data/chains.toml` and fails over its budget. The fourth
reports each description clause of two or more words that more than one skill
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
