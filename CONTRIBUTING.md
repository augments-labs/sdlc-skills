# Contributing to SDLC skills

Thank you for taking the time to contribute. This guide is written for people.
If a coding agent is doing the work with you, it reads
[`AGENTS.md`](AGENTS.md), which holds the same rules in the form an agent
follows.

The first four sections are what you need to make a change and open a pull
request. The reference sections after them cover the checks, the agent
adapters, the design decisions behind the library, and the conformance
record, for when your change touches one of those.

## Before you start

- **Solve a problem you actually hit.** Describe the session, the error, or the
  experience that led you here. A speculative or theoretical fix is closed.
- **Search first.** Look through open and closed issues and pull requests for
  the same problem. If an earlier attempt was closed, say what is different
  about yours.
- **Check that it belongs in core.** Core skills are general-purpose guidance
  that would help someone on a completely different kind of project. A skill
  for one domain, tool, or team belongs in your own library.
- **Not sure?** Open an issue first. "No skill is needed here" is a valid and
  useful outcome.

## Making a change

1. Fork the repository and create a task branch from `dev`. `main` holds
   releases only.
2. Keep the pull request to one change. Split unrelated edits.
3. If you add or edit a skill, follow the `writing-skills` skill
   (`skills/common/writing-skills/SKILL.md`). It owns the format and the
   checks for a single skill. Two things it does not cover are this
   repository's: name the failure the skill answers, and pick its phase
   folder from the canonical order in the
   [skill catalogue](docs/reference/skills.md), or `common/`.
4. Follow the authoring rules for anything under `skills/` or `docs/`:
   - Do not name other repositories, projects, articles, or authors.
   - Refer to models by capability tier (`small`, `medium`, `large`), never by
     vendor name.
   - Do not assume one agent's tools or paths.
5. Keep `docs/` for users. It holds guides, concepts, and reference pages for
   people who install and use the library. Design reasons, test notes,
   adapter internals, and anything else a contributor needs go in this file.
   See [Writing documentation](#writing-documentation).
6. Do not add third-party dependencies. The library is zero-dependency by
   design.
7. Do not bump versions or edit version headings in `CHANGELOG.md`. The
   maintainer versions each release. See [`RELEASING.md`](RELEASING.md).

## Run the checks

Run these before you commit. CI runs them on every pull request and on every
push to `main` and `dev`.

```bash
bash scripts/sh/validate-skills.sh
bash scripts/sh/validate-skill-graph.sh
bash scripts/sh/validate-trigger-collisions.sh
bash scripts/sh/token-budget.sh --chain NAME
```

Run the last one for each chain listed in `scripts/sh/data/chains.toml`.

The first three report some findings as warnings. Add `--strict` to turn those
warnings into failures, `reference-load-condition` included. CI runs them with
`--strict`, so a change that passes without it can still fail in CI.

For each skill you edited, also run the strict check:

```bash
bash skills/common/writing-skills/scripts/check-skill.sh --strict path/to/skill
```

To run the checks automatically when you commit, install the git hook once:

```bash
bash scripts/sh/install-git-hooks.sh
```

The hook runs whenever a relevant file is staged.
`bash scripts/sh/install-git-hooks.sh --remove` undoes it.

[Testing and the gates](#testing-and-the-gates) explains what each check
proves and which test to run for which change.

## Open the pull request

1. Target `dev`. A pull request opened against `main` is asked to retarget
   before review.
2. Fill in every section of the pull request template with specific, true
   answers.
3. If the change alters what a skill makes an agent do, name the failure or
   the gap it answers. No live agent runs in this repository, so the pull
   request argues from the skill text and the checks.
4. Say how the change was written: by hand, or with which model, harness,
   harness version, and plugins. A pull request that hides this is closed.
5. Read the complete diff yourself before you submit it.

## Testing and the gates

This repository runs deterministic checks only. Each one knows the right
answer before it runs, needs no model, and costs nothing, so a red result
means something is broken. No live agent runs here or in CI: the checks tell
you the library is well formed and packaged correctly, not what an agent
does with a skill.

### What runs where

| Where | What a result proves | Commands |
| --- | --- | --- |
| `scripts/sh/`, all run in CI | The structure and policy rules each check covers | `validate-skills.sh`, `validate-skill-graph.sh`, `validate-trigger-collisions.sh`, `token-budget.sh` |
| `tests/`, offline. CI runs `run-session-start.sh`, `run-serve-preview.sh`, `run-trace-viewer.sh`, `run-git-hooks.sh`, and `run-state-identity.sh` | One packaging or script behavior each | `run-session-start.sh`, `run-plugin-smoke.sh`, `run-sdd-scripts.sh`, `run-opencode-plugin.sh`, `run-pi-extension.sh`, `run-hermes-plugin.sh`, `run-serve-preview.sh`, `run-validate-skills.sh`, `run-check-skill.sh`, `run-git-hooks.sh`, `run-state-identity.sh`, `run-trace-viewer.sh` |
| `tests/harnesses/` | Nothing on its own. These files hold how each CLI installs the plugin, and the smoke test drives them | One file per supported CLI |

### The four gates

| Gate | What it checks |
| --- | --- |
| `validate-skills.sh` | Frontmatter, body and description size limits, the ban on external references and vendor model names, where templates and references live, that every manifest lists every skill, that the adapters are in sync, that `docs/` and `tests/` Markdown paths and skill reference paths resolve, and that the conformance record matches the tree |
| `validate-skill-graph.sh` | Pairs of skills that hand off to each other. A pair listed in `scripts/sh/data/allowed-cycles.txt` is allowed |
| `validate-trigger-collisions.sh` | Trigger phrases of two or more words that more than one description shares |
| `token-budget.sh` | With `--chain NAME`, the total body words of one chain against its budget. With `--max N`, the approximate token size of each `SKILL.md` against a ceiling. CI runs both, the second with `--max 5000` |

### Choose the check for your change

| You changed | Run |
| --- | --- |
| A skill | `bash skills/common/writing-skills/scripts/check-skill.sh --strict path/to/skill` |
| Anything | `bash scripts/sh/validate-skills.sh` |
| An adapter or a hook | `tests/run-session-start.sh` and `tests/run-plugin-smoke.sh --harness {{name}}` |
| The OpenCode plugin file | `tests/run-opencode-plugin.sh` |
| The pi extension file | `tests/run-pi-extension.sh` |
| The Hermes plugin file | `tests/run-hermes-plugin.sh` |
| A `subagent-driven-development` script | `tests/run-sdd-scripts.sh` |
| The preview server or its wrappers | `tests/run-serve-preview.sh` |
| The session trace page or its format | `tests/run-trace-viewer.sh` |
| `scripts/sh/validate-skills.sh` | `tests/run-validate-skills.sh` |
| `check-skill.sh` | `tests/run-check-skill.sh` |
| `state-identity.sh` | `tests/run-state-identity.sh` |
| The git hook installer | `tests/run-git-hooks.sh` |
| A page under `docs/` | `bash scripts/sh/validate-skills.sh`, which checks that `docs/` paths named in skills, docs, tests, README, and AGENTS still exist. It does not check relative links between pages, so follow those by hand |

Every runner answers `--help` with its flags and exit codes, and its header
comment says what it covers. [`tests/README.md`](tests/README.md) describes
the runners in more detail.

`run-trace-viewer.sh` has three layers. Its source checks need nothing extra.
Its mask and syntax checks need `node`, and its behaviour checks need a
headless Chrome or Chromium. A missing tool skips its layer and says so. In CI
a skipped layer is a failure.

`run-plugin-smoke.sh` needs the CLI of the agent under test installed, so it
runs on your machine and not in CI. It installs this tree into a throwaway
home the way that agent does, then checks that every skill is discovered,
where the CLI can list them.

### Chain budgets

A chain is the ordered set of skills the router loads for one kind of task,
such as a bug fix or a new feature. `scripts/sh/data/chains.toml` lists the
skills in each chain, the recorded word count of each body, and the chain's
budget. `token-budget.sh --chain NAME` adds up the bodies in the chain,
leaving out their reference files, and fails when the total is over budget.
CI runs it for every chain.

### Cutting text from a skill

Cut by judgment, not by word count. For each section, ask: would the agent get
this wrong without it? If the answer is no, cut it. If you are unsure, keep it
and say so in the pull request. Get shorter by removing content, never by
compressing prose into noun stacks; a body that needs 140 clear lines should
take them.

Hard stops and guards on destructive actions are never cut.

### What these checks do not cover

A green run here says the files are well formed, the manifests agree, and the
scripts behave. Whether a skill changes what an agent does is a separate
question, and nothing in this repository answers it. A pull request that
changes a skill's behavior argues from the skill text and these checks.

## Writing documentation

`docs/` is user documentation: guides that start from something the reader
wants to do, short concept pages, and reference pages for lookup. Write it
in plain second person for someone who installs and uses the library. Keep
mechanism, measurements, and test evidence out of it; they go in this file.

A few things the gate enforces:

- Every `docs/….md` or `tests/….md` path named in `skills/`, `docs/`,
  `tests/`, `README.md`, or `AGENTS.md` must exist. When you move or rename a
  page, update every reference, including comments in `tests/harnesses/*.sh`,
  `scripts/sh/*.sh`, and `.github/workflows/`. The check does not read
  `CONTRIBUTING.md`, and it does not follow relative links such as
  `../reference/agents.md`; check those by hand when you move a page.
- Copies that several skills bundle must stay byte-identical: `plan-version.sh`
  and `assets/mode-question.md` in `writing-plans`, `executing-plans`, and
  `subagent-driven-development`, and the preview scripts (`serve.py` and its
  wrappers) in `viewing-artifacts`, `ui-ux-design`, and `diagnosing-a-session`. Edit the
  `writing-plans` copy (for the first two) or the `viewing-artifacts` copy
  (for the preview), then copy it to the others; the gate compares against
  those.
- No shipped skill may reference a `docs/` path, because `docs/` does not
  ship with the skills.
- The conformance record, `docs/reference/agent-skills-conformance.md`, is
  read by the gate. See [Keeping the conformance record current](#keeping-the-conformance-record-current)
  before editing it.

Never put run transcripts, failure records, pass-rate anecdotes, superseded
behavior, or investigation notes in `docs/`. Keep ephemeral results in the
review workflow or private notes.

## Agent adapters

A harness is the program that runs a coding agent: a CLI, an IDE extension,
or an agent runner. This section is how one skill library runs on several
harnesses without putting harness-specific behavior into the skills, and
what a new adapter has to do.

### One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills refer to models by
capability tier and to tools by what they do. Each harness has a small
adapter that binds those ideas to its own manifest, tools, and lifecycle
events.

An adapter has two jobs:

1. **Discovery.** Make the harness see every skill.
2. **Routing.** Put the body of `using-sdlc-skills`, the router, into the
   session when it starts, and again after compaction where the harness
   allows it.

| Harness | Adapter | How the router arrives | Supplied again after compaction |
| --- | --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | `SessionStart` hook | Yes. `compact` is in the hook's matcher |
| Codex | `plugins/sdlc-skills/` and `.agents/plugins/marketplace.json` | `SessionStart` hook bundled in the plugin | Yes. The hook is unfiltered, so `source=compact` reaches the injector |
| Kimi Code | `.kimi-plugin/plugin.json` | `sessionStart.skill` | No. The manifest declares no compaction event |
| OpenCode 1.x | `.opencode/plugins/sdlc-skills.js` | `experimental.chat.system.transform` hook | Yes. The `experimental.session.compacting` hook carries it forward |
| OpenCode 2.x | The checkout directory, entered through the root `index.js` | `session.hook("context")` registered in `setup`, into the first user message | Inferred, not observed |
| Grok Build | `.claude-plugin/plugin.json` and `hooks/hooks.json`, read as shipped | It does not. A rules file nudges the agent instead | Not applicable |
| Muse Code | `.muse-plugin/plugin.json` on a build with plugin support, otherwise `scripts/sh/install-muse-skills.sh` | The manifest's `SessionStart` hook. Never on 1.3.0, which loads no plugin | No. No hook runs |
| pi | `.pi/extensions/sdlc-skills.js`, registered through the `pi` key in `package.json` | `before_agent_start` hook, through `appendSystemPrompt` | In the running process only |
| Devin | `plugins/sdlc-skills/` with `.devin-plugin/plugin.json`, the Codex plugin directory | The `SessionStart` hook the Codex plugin bundles | Inferred, not observed |
| Antigravity | `plugins/sdlc-skills/` with `.antigravity-plugin/plugin.json`, the Codex plugin directory | It does not. The plugin's always-on `rules/AGENTS.md` nudges the agent instead | Not applicable |
| Hermes | `.hermes-plugin/plugin.yaml` and `.hermes-plugin/__init__.py` | Plugin system-prompt sections, rendered once per session | Yes. Compression rebuilds the system prompt |
| Cursor | `.claude-plugin/plugin.json` and `hooks/hooks.json`, read as shipped from the cloned root | `SessionStart` hook, which Cursor runs as its `sessionStart` | Not observed |

Two labels are used for claims about a harness. **Measured** means the
behavior was observed on the version named. **Inferred, not observed** means
it follows from the code or the documentation and has not been run. The
version each adapter was measured on is in
[`docs/reference/agents.md`](docs/reference/agents.md).

### Lifecycle policy

Every adapter supplies the full router through a session-start mechanism,
with three exceptions: Grok Build and Antigravity get a rules-file nudge, and
Muse Code 1.3.0 gets discovery only. No adapter registers a hook on tool
calls, on prompts, or at the end of a turn. A hook that runs before every
model call (such as Antigravity's `PreInvocation` or Hermes' `pre_llm_call`)
is rejected for the same reason.

Compaction is a boundary like start, resume, and clear. It replaces the
transcript with a summary, and text injected at session start is not carried
into the replacement. The router is therefore supplied again wherever the
harness exposes that moment, through the session-start mechanism and not
through a dedicated compaction hook. Where a harness has both, the
`SessionStart` output that follows compaction is added to the compacted
context, and the output of a `PostCompact` hook is not. The shared injector,
`scripts/sh/session-start.sh`, answers `SessionStart` for every source and
ignores `PostCompact`.

`tests/run-session-start.sh` checks the registrations and the branches for
synthetic payloads. It does not compact a real session. When you add or
update a harness, verify its lifecycle behavior on the installed version
before you rely on retained context or change the re-injection policy.

### How each adapter is built

**Claude Code.** `.claude-plugin/plugin.json` is the manifest and
`hooks/hooks.json` registers the `SessionStart` hook with `compact` in its
matcher.

**Codex.** The plugin manifest carries the skill catalogue but has no
session-start field, so the router arrives through hooks the plugin bundles
itself (`"hooks": "./hooks/hooks.json"`). The plugin is installed standalone,
so everything the hook touches lives inside `plugins/sdlc-skills/`, and
`scripts/sh/sync-codex-plugin-skills.sh` mirrors the canonical skills in as
a flat `skills/<name>/` tree. After you edit a canonical skill, run the sync
script, then install or update the package you are testing; editing the
checkout does not update an existing plugin cache. The gate checks that the
mirror equals the canonical tree. The injector supports both the nested and
the flat layout and reads the router that ships in the installation rather
than a second copy.

**Kimi Code.** `.kimi-plugin/plugin.json` names the router in
`sessionStart.skill`, and its `skillInstructions` hold the tool bindings.

**OpenCode.** One file, `.opencode/plugins/sdlc-skills.js`, carries both
generations' contracts: 1.x scans the module's named exports for hook
factories and registers the canonical `skills/` directory through the
`config` hook; 2.x calls `default.setup(ctx)` only, which registers each
skill through `skill.transform` and injects the router through a context
hook on every request, deduplicated on the opening of the router block, so
a transcript replaced without the block receives it again. Child sessions
are skipped. Every callback is wrapped in error handling, because an
exception that escapes a callback takes the plugin down. The root `index.js`
re-exports the adapter for 2.x and the root `package.json` (no dependencies,
version kept in sync with the manifests) is what makes the
`sdlc-skills@git+...` package spec installable. `tests/run-opencode-plugin.sh`
checks both contracts against stub hosts; the smoke test on 2.x cannot list
skills without a model call and reports the inventory as unavailable.

**Grok Build.** Grok reads the Claude plugin format directly. On 1.0.40 no
hook reaches the system prompt (`SessionStart` output is discarded,
`additionalContext` exists only on tool events and `Stop`, and `--rules`
applies to one invoked session only), so the binding is a one-line rules
file under `$GROK_HOME/rules/` that Grok scans for every project.
`tests/harnesses/grok.sh` writes that file into the isolated home and reads
it back through `grok inspect --json`. The adapter isolates `HOME` as well
as `GROK_HOME`, because `grok inspect` also reads
`~/.claude/plugins/marketplaces/`.

**Muse Code.** `.muse-plugin/plugin.json` is the native manifest (`schemaVersion`
1, one `{id, path}` entry per skill, a `SessionStart` hook running the shared
injector); no build with plugin support has run it, and 1.3.0 answers
"plugins are not available in this build". `scripts/sh/install-muse-skills.sh`
runs `muse skills install <dir> --scope user --force` for each canonical
directory, and `--remove` uninstalls the same set, treating
`skill-not-installed` as already removed. `tests/harnesses/muse.sh` overrides
both `HOME` and `XDG_CONFIG_HOME` and sets `MUSE_NO_AUTO_UPDATE=1`.

**pi.** `package.json`'s `pi` key lists the extension and the `skills/`
directory, which pi discovers recursively. The extension registers the skill
path on `resources_discover`, appends the router once on `before_agent_start`
(checking for the body itself, since the prompt is a plain string), and
writes it into the compaction summary on `session_compact`, which reaches
only the in-memory copy. `pi install <path>` registers the checkout by
reference. `tests/run-pi-extension.sh` runs the handlers against stub inputs.

**Devin.** Devin installs the Codex plugin directory, with
`.devin-plugin/plugin.json` beside the Codex manifest, because Devin loads
skills one level deep and injects any `AGENTS.md`, `AGENT.md`, or
`.windsurfrules` at the plugin root into every session. The gate fails if
the Devin manifest declares a `skills` field or a rule file appears at the
plugin root. Devin exports `CLAUDE_PLUGIN_ROOT` and `DEVIN_PLUGIN_ROOT`, not
`PLUGIN_ROOT`, so the hook command resolves `${PLUGIN_ROOT:-$CLAUDE_PLUGIN_ROOT}`;
hooks fail open. `tests/harnesses/devin.sh` isolates `HOME` with a copy of the
credentials file and reads `devin plugins info sdlc-skills`. The Antigravity
rule file in the same directory is listed by Devin as a `manual` rule and
does not fire there.

**Antigravity.** Also the Codex plugin directory, for the same two reasons,
with `.antigravity-plugin/plugin.json`. Its documented hook events are
`PreToolUse`, `PostToolUse`, `PreInvocation`, `PostInvocation`, and `Stop`;
the binary carries an undocumented `SessionStart` that has not been observed
to fire. The router is therefore a nudge in `plugins/sdlc-skills/rules/AGENTS.md`,
always on while the plugin is enabled; the gate checks that the file exists,
names the skill, and carries no frontmatter. `agy plugin install` copies the
directory into `~/.gemini/config/plugins/sdlc-skills/`.
`tests/harnesses/antigravity.sh` accepts the inventory only when
`agy plugin validate` processed the same number of skills.

**Hermes.** The clone's root has no Hermes manifest, so Hermes looks one
level down and loads `.hermes-plugin/__init__.py` as `sdlc-skills/.hermes-plugin`;
a `plugin.yaml`, `plugin.yml`, or `plugin.json` at the root would stop that
search, so the gate rejects one. `register()` registers each canonical
`SKILL.md` by directory name and parses the `description:` field itself. The
router goes in as system-prompt sections, split at its `## ` headings with
zero-padded ids, because Hermes skips any section over 4,000 characters and
gives all plugins 8,000. `on_session_start` cannot add context (its return
value is ignored). `hermes plugins install` takes a catalog name, a git URL,
or `owner/repo`, never a local path. `tests/run-hermes-plugin.sh` loads the
entry point with a stub context; `tests/harnesses/hermes.sh` snapshots the
working tree into a throwaway git repository (Hermes clones a commit) and
needs the network once for the Python environment.

**Cursor.** Cursor loads every directory under `~/.cursor/plugins/local/`,
reads `.cursor-plugin/plugin.json` and falls back to `.claude-plugin/plugin.json`,
so it takes the Claude manifest's skill list and `hooks/hooks.json`. It also
loads any `rules/`, `agents/`, or `commands/` directory at a plugin root,
and a `.cursor-plugin/plugin.json` would replace the Claude manifest, so the
gate fails if any of them appears at the repository root. Cursor converts
`SessionStart` to its `sessionStart`, exports `CURSOR_PLUGIN_ROOT` and
`CLAUDE_PLUGIN_ROOT`, and reads snake_case `additional_context`; the
injector's Cursor branch keys on `CURSOR_PLUGIN_ROOT`. Its `preCompact` hook
can only return a message for the user. Cursor has no command that installs
a single plugin and rejects a symlink in the local folder that points outside
it. `tests/harnesses/cursor.sh` copies the tree into a throwaway `HOME` and
counts `SKILL.md` files, because Cursor lists skills only inside a model
session.

### Dispatching work to subagents

`dispatching-parallel-agents`, `executing-plans`, and
`subagent-driven-development` hand work to a fresh agent through what the
skills call "the real callable action". The skills never name that action.
Each adapter binds it, and each harness decides whether it exists at all.

| Harness | Dispatch action | Does the subagent load skills? | Nesting depth | Model tier |
| --- | --- | --- | --- | --- |
| Claude Code | `Agent` tool | Yes, unless the subagent's own definition withholds the action | One level for the read-only built-in types. A general subagent can dispatch again, which the packet prohibits unless it allocates a sub-scope | Settable. The tier binds to the model parameter of the dispatch call |
| Codex | `spawn_agent`, `wait_agent`, `list_agents`, `send_message`, `followup_task`, `interrupt_agent` | Only when the plugin is installed for the spawned agent, and not for the session alone | Not declared by the build. Treat a worker's own dispatch as prohibited | Settable. The spawn call carries the model the tier binds to |
| Kimi Code | `Agent` tool | The brief names the file to read, because a subagent may not resolve paths relative to the plugin | One level. A background run adds parallelism, not nesting | Not settable. The tier is stated in the prompt and the harness binds it |
| OpenCode | 1.x: the `Task` tool, to the `general` and `explore` subagents. 2.x: the `subagent` tool, with the same role names as its `agent` argument | Yes, for the whole session, through the plugin's skill registration | Not declared by the build. Treat a worker's own dispatch as prohibited | Settable through the agent's `model`. A subagent without one inherits the invoking agent's |

Grok Build, Muse Code, pi, Devin, Antigravity, Hermes, and Cursor have no
row: no tool binding ships for them. Devin documents `run_subagent` and
`read_subagent`, and Hermes has `delegate_task` with a global model setting,
but neither has been measured against a running session.

The tool names live inside each adapter, never in a skill: Codex in
`plugins/sdlc-skills/references/codex-tools.md`, OpenCode in
`.opencode/references/opencode-tools.md`. The Claude Code and OpenCode rows
were checked against a running harness; the Codex and Kimi Code rows are
read from the binding their adapter declares. Availability, nesting, and
agent names belong to the installed build and change between versions, so
check a cell with the CLI before you rely on it.

When the action is not available, the skills require the agent to treat the
work as not dispatched, name the action it attempted and what the
environment would need, and ask the user once, offering a self-review
labelled as one, a named reviewer or agent, or keeping the work pending.

`subagent-driven-development` adds a role binding. Its three role briefs
(`assets/implementer.md`, `assets/task-reviewer.md`, `assets/re-reviewer.md`)
are the specification; a named harness agent is only a runtime that carries
one of them, and the mapping lives in the adapters, never in the skill body:

| Harness | Agents a role can bind to | Fallback |
| --- | --- | --- |
| Claude Code | The built-in general-purpose type, plus any agent defined under `.claude/agents/`, selected with the `subagent_type` of the `Agent` tool | The general-purpose type carrying the role prompt |
| Codex | The agent roles the installed build exposes to `spawn_agent` | A general agent carrying the role prompt |
| Kimi Code | The `subagent_type` values bound in the `skillInstructions` of `.kimi-plugin/plugin.json` | `coder` carrying the role prompt. It cannot enforce read-only, so a review brief sent to it forbids every edit, commit, and push |
| OpenCode | `general` for the implementer and `explore` for the reviewers, selected with the `Task` tool on 1.x and the `agent` argument of the `subagent` tool on 2.x | The general-purpose subagent carrying the role prompt, which forbids every edit, commit, and push |

The tier is a separate choice from the agent. The skill sets `small`,
`medium`, or `large` for each dispatch, and the adapter binds that tier to a
model. An agent name never implies a tier.

### Adding an adapter

Adding a harness means more than dropping skill files where the tool can
see them. The skills are inert unless the harness both discovers them and is
nudged to reach for one at the right moment. A PR that adds a harness:

1. Points the manifest at the canonical skills. Do not fork their content.
2. Extends the structural validation so that missing, extra, or divergent
   skills fail.
3. Adds `tests/harnesses/{{name}}.sh`, holding only how that harness installs
   and discovers the plugin, for `tests/run-plugin-smoke.sh`. The contract is
   in [`tests/harnesses/README.md`](tests/harnesses/README.md).
4. Adds an offline test only for deterministic adapter logic the integration
   introduces.
5. Shows a skill activating through the harness's own CLI on a representative
   opening, as the pull request template asks. Files that are present but
   never invoked are not a working integration. Do not simulate runtime
   support with copied transcript fixtures.
6. Documents what the user gets and the limits of the support in
   [`docs/reference/agents.md`](docs/reference/agents.md), the install steps
   in the README and [`docs/guides/installing.md`](docs/guides/installing.md),
   and the build notes in this section.

| Claim | Evidence |
| --- | --- |
| Packaging and structure | Deterministic validation of manifests, mirror equality, reference paths, frontmatter, and token budgets. These checks belong in CI |
| Deterministic adapter scripts | Focused offline tests for parsing or hook branches that matter. Keep each script small enough that its test does not become a second implementation |
| Discovery and activation | A skill activating through the harness's own CLI, shown once, when the harness is added |

### Repository instruction files

`AGENTS.md` is the canonical contributor guide and the file coding agents
read when they work in this repository. `GEMINI.md` is a symbolic link to
it, and `CLAUDE.md` is a short pointer to it, so a harness that reads its
own conventional instructions file gets the same rules from one source,
including a harness that refuses a symlinked instructions file.

## One skill or several

A phase of the life cycle often contains several activities. Whether they
are one skill or several is decided by one test, applied case by case.

Split a phase into separate skills when its activities are **separable**:
you would reach for each one on its own, at a different moment, to make a
different decision. Keep one skill when the activities form a **single
interleaved pass** that only makes sense as a whole. The sharpest form of
the question: would you ever invoke just one of the activities without the
others? Yes: separate skills. No: one skill.

When two skills keep loading together, write the case down: compare their
trigger lines and record what each one catches that the other would not.
Merge them only when the triggers overlap **and** the written case cannot
tell them apart. Overlapping triggers alone are a reason to write the case,
not to merge.

| Skills | Decision | What each catches that the other would not |
| --- | --- | --- |
| `test-driven-development` and `yagni` | Kept separate | TDD catches a change with no observed failure behind it (a test that passed first run, a test that checks generated text, a preserved behavior never made to fail on purpose). `yagni` catches what a green test cannot see: a speculative flag or abstraction, a fix placed at the symptom, a stub on a path no test reaches, code deleted because it looked unused |
| `mapping-the-codebase` and `debugging` | Kept separate | Mapping catches a boundary drawn too small (a caller reached through configuration, reflection, a generated route, or a scheduler; a stale boundary record), none of which needs a failure. `debugging` catches a fix with no established cause: a patched symptom, an intermittent failure called fixed after one green run, fixes repeated past the circuit breaker |
| `define-goals`, `scoping`, and `feasibility-check` | Kept separate | Each is a distinct decision with its own approval question. Goals catches features listed as goals and a target with no baseline; scoping catches a missing out-of-scope list and compatibility or rollback cut to shrink a release; feasibility catches a go decided on optimism and a skipped "do not build" option. Sharing one brief is no reason to merge |
| Analysis | `writing-specs`, with `working-from-a-ticket` beside it | Gathering requirements, finding the difficult parts, and writing the spec is one interleaved pass. "Identify the risks in the requirements" cannot be invoked on its own. Capturing a ticket is invoked on its own, the moment a ticket arrives and again before the work is called done, and writes no requirement: it records what the ticket says, so a plan has something in the repository to bind |

Nothing has been merged. Do not split for its own sake: several tiny skills
that always run together break one coherent task into pieces, and when the
concern is that required information might be lost, an output template
solves it. Techniques used across many phases (`clarifying-intent`,
`mapping-the-codebase`) are a third case: not the skill of one phase and not
a piece split off from one. They live in `common/`.

## Conformance checks

[`docs/reference/agent-skills-conformance.md`](docs/reference/agent-skills-conformance.md)
is the conformance record: what the Agent Skills standard requires, where
the library is stricter, and the measurements that back it. This section is
how those checks work and how to keep the record current.

### The checker

The gate runs `skills/common/writing-skills/scripts/check-skill.sh` on each
skill, then adds packaging and house-policy checks. The checker extracts the
frontmatter delimiters and the `name` and `description` fields rather than
parsing all YAML, which handles the simple format the library uses. It does
not validate every optional metadata field or every form of YAML. Policy
checks report as warnings, and `--strict` turns them into failures.

A green result proves the checks that were implemented. It does not prove
that an arbitrary skill is fully valid against the standard. When a skill
carries metadata you do not recognize, compare it with the specification
yourself.

The checker runs each candidate script with `--help`. That executes code, so
it is not a passive inspection of an untrusted directory. Review the code,
or isolate the run, before you check a skill from outside this repository.
In the scripts bundled here, the `--help` branch returns before any real
work starts.

### Template shape

Each `assets/*.md` file must match the mechanical rules in the `## Shape`
section of `template-format.md`, which belongs to `writing-skills`. Those
are rules 1, 2, 3, and 5: an H1 on line 1, a preamble line before the fence,
exactly one outer markdown or text fence of three or four backticks holding
at least one `{{slot}}`, and no bare `<angle>` placeholder outside an inline
code span. Rule 4 (the family shape), rule 6, the sentence counts, and the
content checklist are judged by a person.

### Two token estimates

`check-skill.sh` estimates tokens as words × 1.3. `scripts/sh/token-budget.sh`
uses characters ÷ 4 over full `SKILL.md` files and its own configured
maximum. Both are rough text budgets. They are not interchangeable, and
neither is a billing figure. Compare each estimate only with earlier values
from the same tool.

### Running the checks

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

The standard's reference validator is not vendored, because this library
adds no third-party dependencies. A separate CI job installs it and runs it
over every skill directory as a cross-check of the parser. The job never
blocks a merge, and its output is a job summary.

When its verdict differs from `check-skill.sh`, investigate. Do not defer to
either tool. Identify the rule and the parser behavior involved, correct any
mistaken claim about the standard, and keep a house restriction only when it
is intentional and labelled as one.

### Keeping the conformance record current

`validate-skills.sh` re-measures the numbers in the record against the tree
on every run: the longest description, the longest body and its share of the
ceiling, the largest estimated body, and how many skills have `references/`,
`assets/`, and `scripts/` directories. It finds each number by matching a
phrase unique to its row, so a stale number fails the gate, and so does a
rewording that breaks the match. When a skill change moves one of those
numbers, update the record in the same pull request. When you reword the
record, keep the matched phrases intact; the regexes are in the
"conformance record matches the tree" block of `scripts/sh/validate-skills.sh`.

The ceilings themselves (1024, 500, 5000) live in `check-skill.sh` alone and
are deliberately not restated in the gate.

## Releases

Versioning and cutting a release are the maintainer's job and are described
in [`RELEASING.md`](RELEASING.md). Contributors never touch versions.
