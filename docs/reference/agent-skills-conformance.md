# Agent Skills conformance

This library follows the
[Agent Skills specification](https://agentskills.io/specification). Every
skill is an ordinary directory holding a `SKILL.md` file with YAML
frontmatter, so any agent that reads the format can load it. If your agent
supports Agent Skills, it can use this library.

The standard outranks the rules of this repository. A house rule may be
stricter than the standard, and it is labelled as a house limit rather than
as a requirement of the standard. It never allows what the standard forbids.
This page records what the standard requires, how the library checks it, and
where the library is stricter on purpose. The numbers on it are measured
against the current skills by the repository's own checks, so they are kept
current.

This page names the standard because it is the conformance record. The
skills themselves give their instructions without naming outside sources.

## What the standard requires

Every skill is checked against the format on every change.

| Format requirement | How it is checked |
| --- | --- |
| YAML frontmatter with `name` and `description` | The delimiters and both fields are extracted. This handles the simple format the library uses and is not a complete YAML parser |
| `name` is 1 to 64 lowercase letters, digits, or hyphens | Length and character checks |
| No leading, trailing, or consecutive hyphens | Pattern check |
| `name` matches its directory | Compared for each directory |
| `description` is not empty and at most 1024 characters | Extracted field length; longest is 582 |
| Only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` | `frontmatter-fields` policy check |
| `compatibility`, when present, is at most 500 characters | `compatibility-length` policy check |

A separate, non-blocking job also runs the standard's own reference
validator over every skill directory as a cross-check.

## Where the library is stricter

The specification and its guidance for authors recommend short bodies,
progressive disclosure, references kept close to the skill, and
conventional support directories. This library turns several of those
recommendations into limits. A skill that another library ships can be
valid against the standard and still fail a house rule here.

| Dimension | House policy and measurement |
| --- | --- |
| Body lines | At most 500; longest is 300 (60% of ceiling) |
| Estimated body tokens | Under 5000 by the skill checker, estimated per word, number, and symbol; largest is ~4138 |
| Typical body size | Aim for about 80 to 120 lines. A longer discipline body needs behavioral evidence that justifies it |
| Presentation | The checker warns on long stretches of undivided prose |
| Supporting paths | They resolve inside the installed skill, and direct references stay shallow |
| Gotchas | `gotchas-present` policy check: the body has a `## Gotchas` section |
| Support-file load conditions | `reference-load-condition` policy check: each named `references/` or `assets/` file says when to load it |
| Description wording | `description-rules` policy check: no `Fires on` list, and none of four internal terms |
| Support-file depth | `reference-depth` warning: a support file names another support file that `SKILL.md` does not name itself |
| Description YAML | `description-yaml` policy check: the raw value loads under a strict YAML parser |
| Outcomes as sentences | `prose-arrows` policy check: no `→` in body prose outside a fenced block or an inline code span |
| Fill-in templates | They go in `assets/`. Explanatory guidance goes in `references/` |
| Template shape | Every `assets/*.md` template has the same house shape, checked by the repository gate |

What this means for you: a skill from this library loads anywhere the
standard is honoured, and its supporting files are where the standard
suggests they should be. The limits above are about how the library is
written, not about what your agent needs to support.

## Supporting directories

| Directory | House use |
| --- | --- |
| `references/` | 25 skills; rubrics, checklists, worked examples, and lookup guidance |
| `assets/` | 39 skills; every fill-in template and other static resources |
| `scripts/` | 10 skills (see below) |

The repository classifies a document by how it is used. A file that is
filled in and emitted is a template, whatever its filename says, and lives
in `assets/`. That is house policy; the standard's layout conventions are
optional and do not forbid other valid arrangements.

## Bundled scripts

Some skills ship scripts. They need only the runtimes and system tools they
declare, and they add no third-party packages.

| Skill | Scripts | What they do |
| --- | --- | --- |
| `finishing-a-branch` | `branch-state.sh` | Inspects commits, uncommitted changes, ownership, and recoverability. Read-only |
| `verification-before-completion` | `state-identity.sh` | Captures the identity of the source and its environment, so evidence can be tied to them |
| `writing-skills` | `check-skill.sh` | Checks one skill against the format and the house rules, and runs its bundled scripts with `--help` |
| `writing-plans`, `executing-plans`, `subagent-driven-development` | `plan-version.sh`, one identical copy each | Prints a plan's version from its index and task files. Read-only |
| `subagent-driven-development` | `sdd-workspace.sh`, `task-brief.sh`, `review-package.sh` | Open and re-check a plan's run ledger, render a role brief, and assemble a task's diff for its reviewer |
| `using-sdlc-skills` | `artifact-layout.sh` | Creates the `.sdlc-skills/` directories and `evidence/.gitignore`. Never overwrites a file |
| `viewing-artifacts` | `serve.py`, `start-server.sh`, `stop-server.sh` | Starts and stops a local preview that the skill owns, writes a log, and may open a browser |
| `ui-ux-design` | The same preview scripts | Provides the comparison preview |
| `diagnosing-a-session` | The same preview scripts | Serves the session trace page |

Scripts that inspect and scripts that start a preview have different
effects. A preview binds a local port and runs until it is stopped or times
out; the skill that owns it says how it is cleaned up.

One thing to know before you run `check-skill.sh` on a skill from somewhere
else: it executes each script it finds with `--help`. That is not a passive
inspection of an untrusted directory. Review the code, or isolate the run,
before you check a skill you did not write.

## What conformance does not cover

A skill that is valid against the standard loads correctly. Whether it
changes what an agent does is a separate question, and no format check
answers it. The checks in this repository are structural; no live agent
runs in them. How the library approaches that limit is in
[Skills guide, your checks decide](../concepts/skills-and-gates.md).

The details of the checker, its limits, and how to run the checks are in
[`CONTRIBUTING.md`](../../CONTRIBUTING.md).
