# Agent Skills conformance

This library follows the
[Agent Skills specification](https://agentskills.io/specification). Every
skill is an ordinary directory holding a `SKILL.md` file with YAML
frontmatter, so any agent that reads the format can load it.

The standard outranks the rules of this repository. A house rule may be
stricter than the standard, and it must be labelled as a house limit and not
as a requirement of the standard. It may never allow what the standard forbids. This
page records what the standard requires, what the checks cover, and where the
library is stricter on purpose.

This page names the standard because it is the conformance record. The skills
themselves state their instructions without naming outside sources.

## What the standard requires

The repository gate runs
`skills/common/writing-skills/scripts/check-skill.sh` on each skill, then adds
packaging and house-policy checks.

| Format requirement | How it is checked |
| --- | --- |
| YAML frontmatter with `name` and `description` | The delimiters and both fields are extracted. This handles the simple format the library uses and is not a complete YAML parser |
| `name` is 1 to 64 lowercase letters, digits, or hyphens | Length and character checks |
| No leading, trailing, or consecutive hyphens | Pattern check |
| `name` matches its directory | Compared for each directory |
| `description` is not empty and at most 1024 characters | Extracted field length; longest is 582 |
| Only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` | `frontmatter-fields` policy check |
| `compatibility`, when present, is at most 500 characters | `compatibility-length` policy check |

### Limits of the checker

The checker does not validate every optional metadata field or every form of
YAML. Policy checks report as warnings, and `--strict` turns them into
failures.

A green result proves the checks that were implemented. It does not prove that
an arbitrary skill is fully valid against the standard. When a skill carries
metadata you do not recognize, compare it with the specification yourself.

## Where the library is stricter

The specification and its guidance for authors recommend short bodies,
progressive disclosure, references kept close to the skill, and conventional
support directories. This library turns several of those recommendations into
limits. A skill rejected by a house rule has not necessarily broken the
standard.

| Dimension | House policy and measurement |
| --- | --- |
| Body lines | At most 500; longest is 311 (62% of ceiling) |
| Estimated body tokens | Under 5000 by the skill checker; largest is ~3478 |
| Typical body size | Aim for about 80 to 120 lines. A longer discipline body needs behavioral evidence that justifies it |
| Presentation | The checker warns on long stretches of undivided prose. Keep sentences readable |
| Supporting paths | They resolve inside the installed skill, and direct references stay shallow |
| Gotchas | `gotchas-present` policy check: the body has a `## Gotchas` section |
| Support-file load conditions | `reference-load-condition` policy check: each named `references/` or `assets/` file says when to load it, using when, if, before, or after |
| Description wording | `description-rules` policy check: no `Fires on` list, and none of four internal terms |
| Support-file depth | `reference-depth` warning: a support file names another support file that `SKILL.md` does not name itself |
| Description YAML | `description-yaml` policy check: the raw value loads under a strict YAML parser |
| Fill-in templates | They go in `assets/`. Explanatory guidance goes in `references/` |
| Template shape | The "every assets/ template has the house shape" check in `validate-skills.sh`. See below |

### Template shape

Each `assets/*.md` file must match the mechanical rules in the `## Shape`
section of `template-format.md`, which belongs to `writing-skills`. Those are
rules 1, 2, 3, and 5:

- an H1 on line 1
- a preamble line before the fence
- exactly one outer markdown or text fence of three or four backticks, holding
  at least one `{{slot}}`
- no bare `<angle>` placeholder outside an inline code span

Rule 4 (the family shape), rule 6, the sentence counts, and the content
checklist are judged by a person.

### Two token estimates

`check-skill.sh` estimates tokens as words × 1.3. The CI drift gate,
`scripts/sh/token-budget.sh`, uses characters ÷ 4 over full `SKILL.md` files
and its own configured maximum. Both are rough text budgets. They are not
interchangeable, and neither is a billing figure. Compare each estimate only
with earlier values from the same tool.

The validator checks the maximum sizes and directory counts on this page
against the current tree, so a stale number fails the gate.

Being concise means removing content nobody needs. Do not shorten an
instruction by removing the verbs and context needed to act on it.

## Authoring practices

The [creator best practices](https://agentskills.io/skill-creation/best-practices)
recommend focused, reusable guidance, with more control where a task is more
fragile. The library applies them through its authoring skill,
`writing-skills`:

- Describe when the skill applies and how it differs from its neighbors. The
  house convention is plain trigger language with no emphasis.
- Include the knowledge the agent needs for the task. Leave out generic
  explanation.
- Say when each supporting file should be loaded.
- Give defaults for routine implementation choices. Leave to the user the
  decisions that belong to the user, and reuse valid authority where its owner
  permits.
- Use a concrete template when the structure of the output matters.
- Keep exact sequences and discipline controls where a wrong action has
  consequences. Allow judgment where several approaches would satisfy the
  contract.

## Supporting directories

| Directory | House use |
| --- | --- |
| `references/` | 25 skills; rubrics, checklists, worked examples, and lookup guidance |
| `assets/` | 32 skills; every fill-in template and other static resources |
| `scripts/` | 10 skills — see below |

The repository classifies a document by how it is used. A file that is filled
in and emitted is a template, whatever its filename says. The gate rejects
templates under `references/`. That is house policy. The standard's layout
conventions are optional and do not forbid other valid arrangements.

## Bundled scripts

| Skill | Scripts | What they do |
| --- | --- | --- |
| `finishing-a-branch` | `branch-state.sh` | Inspects commits, uncommitted changes, ownership, and recoverability |
| `verification-before-completion` | `state-identity.sh` | Captures the identity of the source and its environment, so evidence can be tied to them |
| `writing-skills` | `check-skill.sh` | Inspects skill files and runs bundled scripts with `--help` |
| `writing-plans`, `executing-plans`, `subagent-driven-development` | `plan-version.sh`, one byte-identical copy each | Prints a plan's version from its normalized index and task files. Read-only. The gate fails when the copies differ |
| `subagent-driven-development` | `sdd-workspace.sh`, `task-brief.sh`, `review-package.sh` | Opens and re-checks a plan's run ledger, renders one role brief and refuses a half-filled one, inserts the role's report template, and assembles a task's diff for its reviewer |
| `using-sdlc-skills` | `artifact-layout.sh` | Creates the `.sdlc-skills/` directories and `evidence/.gitignore`. Never overwrites a file |
| `viewing-artifacts` | `serve.py`, `start-server.sh`, `stop-server.sh` | Starts and stops a local preview that the skill owns, writes a log, and may open a browser |
| `ui-ux-design` | The same preview scripts | Provides the comparison preview. The gate checks that the copies are byte-identical to the viewer's |
| `diagnosing-a-session` | The same preview scripts | Serves the session trace page. The gate checks the same byte equality |

The scripts need the runtimes and system tools they declare. They add no
third-party packages.

Scripts that inspect and scripts that start a preview have different effects.
For a preview, follow the resource and cleanup rules of the skill that owns
it.

### The checker runs code

Checking conformance runs each candidate script with `--help`. That executes
code, so it is not a passive inspection of an untrusted directory. Review the
code, or isolate the run, before you check a skill from outside this
repository. In the scripts bundled here, the `--help` branch returns before
any real work starts.

## Evaluation is separate from conformance

The layout of the tests is repository policy. It is not part of the format
the standard requires. `tests/` holds offline checks of scripts and packaging,
and no live agent runs in this repository. A structural pass says nothing
about how a model behaves.

## Running the checks

```bash
bash scripts/sh/validate-skills.sh
bash scripts/sh/validate-skill-graph.sh
bash scripts/sh/token-budget.sh --chain bug-fix
bash scripts/sh/validate-trigger-collisions.sh
bash skills/common/writing-skills/scripts/check-skill.sh path/to/skill
```

| Command | What it does |
| --- | --- |
| `validate-skills.sh` | Checks the library and its adapters. With `--strict` it also fails on the policy checks it otherwise reports as warnings, `reference-load-condition` included |
| `validate-skill-graph.sh` | Reports pairs of skills that hand off to each other. A pair listed in `scripts/sh/data/allowed-cycles.txt` prints as allowed, and `--strict` fails on any other |
| `token-budget.sh --chain` | Adds up the body words of one chain in `scripts/sh/data/chains.toml` and fails when the chain is over budget |
| `validate-trigger-collisions.sh` | Reports each description clause of two or more words that more than one skill shares. `--strict` fails on any |
| `check-skill.sh` | Checks one skill, including one outside this repository, within the parsing and execution limits described above |

`validate-skills.sh` and `check-skill.sh` enforce this checker's own profile.

### The reference validator

The standard's reference validator is not vendored, because this library adds
no third-party dependencies. A separate CI job installs it and runs it over
every skill directory as a cross-check of the parser. The job never blocks a
merge, and its output is a job summary.

When its verdict differs from `check-skill.sh`, investigate. Do not defer to
either tool. Identify the rule and the parser behavior involved, correct any
mistaken claim about the standard, and keep a house restriction only when it
is intentional and labelled as one.
