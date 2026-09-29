# Harness Support

A harness is the program that runs a coding agent: a CLI, an IDE extension, or
an agent runner. This page explains how one skill library runs on several
harnesses without putting harness-specific behavior into the skills.

For installation commands, see the [README](../README.md#installation).

## One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills refer to models by
capability tier and to tools by what they do. Each harness has a small adapter
that binds those ideas to its own manifest, tools, and lifecycle events.

An adapter has two jobs:

1. **Discovery.** Make the harness see every skill.
2. **Routing.** Put the body of `using-sdlc-skills`, the router, into the
   session when it starts, and again after compaction where the harness allows
   it.

| Harness | Adapter | How the router arrives | Supplied again after compaction |
| --- | --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | `SessionStart` hook | Yes. `compact` is in the hook's matcher |
| Codex | `plugins/sdlc-skills/` and `.agents/plugins/marketplace.json` | `SessionStart` hook bundled in the plugin | Yes. The hook is unfiltered, so `source=compact` reaches the injector |
| Kimi Code | `.kimi-plugin/plugin.json` | `sessionStart.skill` | No. The manifest declares no compaction event |
| OpenCode 1.x | `.opencode/plugins/sdlc-skills.js` | `experimental.chat.system.transform` hook | Yes. The `experimental.session.compacting` hook carries it forward |
| OpenCode 2.x | The checkout directory, entered through the root `index.js` | `session.hook("context")` registered in `setup`, into the first user message | Inferred, not observed. See [OpenCode](#opencode) |
| Grok Build | `.claude-plugin/plugin.json` and `hooks/hooks.json`, read as shipped | It does not. A rules file nudges the agent instead | Not applicable |
| Muse Code | `.muse-plugin/plugin.json` on a build with plugin support, otherwise `scripts/sh/install-muse-skills.sh` | The manifest's `SessionStart` hook. Never on 1.3.0, which loads no plugin | No. No hook runs |
| pi | `.pi/extensions/sdlc-skills.js`, registered through the `pi` key in `package.json` | `before_agent_start` hook, through `appendSystemPrompt` | In the running process only. See [pi](#pi) |

This page uses two labels for its claims. **Measured** means the behavior was
observed on the version named. **Inferred, not observed** means it follows
from the code or the documentation and has not been run.

## Claude Code

The plugin manifest is `.claude-plugin/plugin.json`, and `hooks/hooks.json`
registers the `SessionStart` hook. The hook's matcher includes `compact`, so
the router is supplied at session start and again after compaction.

## Codex

The Codex plugin manifest carries the skill catalogue but has no session-start
field. The router therefore arrives through hooks that the plugin bundles
itself (`"hooks": "./hooks/hooks.json"`).

Bundling matters. The plugin is installed standalone, so a hooks file at the
repository root sits outside the plugin root and Codex never loads it. A
repository-level configuration would work for contributors and ship nothing to
users. Everything the hook touches therefore lives inside the plugin, and
`scripts/sh/sync-codex-plugin-skills.sh` mirrors it in.

Hooks run from the session's working directory, so the injector finds its
files through the installed plugin root. It supports both the canonical phase
paths and the flat `skills/<name>/` layout the Codex plugin uses.

The injector reads the router that ships in that installation. It does not
embed a second, handwritten copy.

### Keeping the mirror current

After you edit a canonical skill:

1. Run `scripts/sh/sync-codex-plugin-skills.sh` to rebuild the Codex mirror.
2. Install or update the package you are testing. Editing this checkout does
   not update a plugin cache that already exists.

`scripts/sh/validate-skills.sh` checks that the mirror equals the canonical
tree, checks the skills array of every manifest, and runs each adapter's own
validator.

## Kimi Code

The manifest is `.kimi-plugin/plugin.json`. Its `sessionStart.skill` field
names the router, and its `skillInstructions` hold the tool bindings. The
manifest declares no compaction event, so the router is not supplied again
after compaction.

## OpenCode

The OpenCode plugin finds the router relative to its own location at runtime.
The same file therefore serves a contributor working inside this checkout and
a user somewhere else.

OpenCode 1.x and 2.x differ in almost every other respect.

| | OpenCode 1.x | OpenCode 2.x |
| --- | --- | --- |
| Entry point | Scans the module's named exports for hook factories | Calls `default.setup(ctx)` and nothing else |
| What you install | The plugin file | A directory. It resolves `<dir>/server.js`, then `<dir>/index.js` |
| Skill registration | The `config` hook registers the canonical `skills/` directory | `setup` registers each skill through `skill.transform` |
| Where the router goes | The system context | The first user message |
| What the smoke test reads back | The harness's own skill listing | The harness's own "loading plugin" line, naming the entry point it resolved |

### One file, two contracts

The two generations share no entry point, so one file carries both contracts.
The factory is exported by name and as `default.server`, and `setup` sits
beside it.

On 2.x, `skills` is an array with no paths under it, so the `config` hook
returns early there and `setup` does the registration.

### Router injection on 2.x

The context hook runs on every request, and the injection is deduplicated on
the opening of the router block. In a steady session the block lands once per
top-level session. It lands again on any later request whose first user
message no longer carries it.

That is the basis for the compaction entry in the table above: a transcript
replaced without the block would receive it again. This is inferred, not
observed. No compaction was run against a 2.x build.

Child sessions are skipped. They inherit the work, not the routing.

Every callback is wrapped in error handling. An exception that escapes a
callback takes the plugin down, and for the context hook it takes down the
session as well.

### Installation and discovery

1.x discovers the plugin file in `.opencode/plugins/` automatically. Measured
on 2.0.14: a session started inside the checkout loads the file from
`.opencode/plugins/` with no configuration entry. The same passive load on 1.x
is inferred, not observed.

A user outside the checkout names the plugin in `opencode.json`, on either
generation. The smoke adapter writes that explicit entry for both, since it is
the documented installation.

On 2.x the root `index.js` re-exports the adapter, and an installed package
reaches it through `main`. The root `package.json` has no dependencies and its
version is kept in sync with the manifests. It is what makes the
`sdlc-skills@git+...` package spec installable. Without it the spec resolves
to nothing.

### What the tests prove

`tests/run-opencode-plugin.sh` checks the logic of both contracts offline,
against stub hosts.

`tests/run-plugin-smoke.sh --harness opencode` checks discovery through the
installed CLI. What it can prove depends on the generation.

2.x offers no skill listing without a model call. `debug skill` is gone, and
`opencode serve`, whose API does list skills, loads no plugins. On 2.x the
test therefore reports the inventory as unavailable. It does not count the
files in the tree and call that discovery.

The evidence for 1.x is weaker than for 2.x. The offline checks assert the 1.x
load structurally: the named export exists, and every function the package
entry exposes answers a 1.x-shaped call with a set of hooks. It has not been
observed on a 1.x binary, because the entry shape is what this arrangement
changed and no 1.x build has run it.

## Grok Build

Grok Build 1.0.40 accepts a plugin directory in the Claude format directly, so
there is no separate Grok manifest. It reads `.claude-plugin/plugin.json` and
`hooks/hooks.json` from the checkout as they ship.

### Installation

`grok plugin install <path> --trust` copies the checkout into a per-install
directory under `GROK_HOME` and registers the plugin as enabled at user scope.
For a local path it works offline and without a login.

There is a second route. Listing the checkout under `[plugins] paths` and
`[plugins] enabled` in `config.toml` also discovers it, but that route
requires the folder to be marked as trusted in `trusted_folders.toml`. The
install route needs no separate trust record, so `tests/harnesses/grok.sh`
uses it.

Measured on 1.0.40: the install registers every skill in the manifest, and one
hook.

### The router channel

No hook reaches the system prompt on 1.0.40:

- For `SessionStart`, standard output is discarded.
- `additionalContext` exists only on tool events (`PreToolUse`, `PostToolUse`,
  `PostToolUseFailure`) and on `Stop`.
- `--rules`, also available as `--append-system-prompt`, appends to the system
  prompt for one invoked session only. It does nothing at install time.

The binding uses a rules file instead: one line under `$GROK_HOME/rules/` that
names `using-sdlc-skills` first. Grok scans that directory for every project,
whether or not the folder is trusted.

Measured: a file placed there is read back with `scope: global`. It is listed
in the `projectInstructions` array of `grok inspect --json` and in the
plain-text `Project Instructions` section, with no `--trust` and no
configuration change.

This is a nudge in the rules. It is not an injected router body, and it is
weaker than the session-start injection of the other adapters. It is one more
file the model may or may not act on. Until Grok offers a hook that appends to
the prompt at session start, this is as far as routing can go on this harness.

### What the tests prove

The install copies the checkout, so the path of the copy cannot be known in
advance. The inventory step reports skills by `source.plugin_name` from
`grok inspect --json`, matched against the plugin id (`sdlc-skills`) that the
manifest declares.

`grok inspect` also reads `~/.claude/plugins/marketplaces/` on the operator's
machine, whatever `GROK_HOME` is set to. On a machine that already has this
plugin installed for Claude Code, that installed copy would answer for the
tree under test. The adapter therefore isolates `HOME` as well as `GROK_HOME`.

`tests/run-plugin-smoke.sh --harness grok` proves the install, the skill
inventory, and that `grok inspect` lists the rules file under
`projectInstructions` in the same isolated home. It runs no model turn.
Whether the nudge actually leads the agent to invoke `using-sdlc-skills` is a
question for a live session, and the smoke test does not answer it.

## Muse Code

Muse Code has two routes. Which one a user gets depends on their build.

### The native manifest

`.muse-plugin/plugin.json` is the native manifest. It has `schemaVersion` 1,
one `{id, path}` entry under `capabilities.skills` for each canonical skill,
and a `SessionStart` hook that runs the shared `scripts/sh/session-start.sh`
injector. It provides discovery and the router in one file.

Inferred, not observed: no build with plugin support has been run against this
manifest, so it is unconfirmed whether the binding works with nothing more
asked of the user.

Measured on 1.3.0: that build ships no plugin loader. `muse plugins` answers
"plugins are not available in this build". The manifest can be neither
installed nor validated there, and its hook never runs.

The manifest still ships, and it carries the current release version like
every other manifest, so the version gate covers it. Whether a future build
with plugin support would find the manifest already correct has not been
observed.

### The per-skill install

The route that 1.3.0 does offer is `muse skills install <dir> --scope user`.
It takes exactly one skill directory and copies it under `skills/` in the
configuration directory. Pointed at a whole tree, it fails with "skill package
must contain SKILL.md".

`scripts/sh/install-muse-skills.sh` runs that command for each canonical
directory:

- It passes `--force`, so running it again overwrites the skills and does not
  fail with "skill already installed".
- `--remove` uninstalls the same set. It treats the CLI's
  `skill-not-installed` code as already removed, so a second removal does
  nothing and prints no error for each skill.

This route provides discovery and nothing else. No hook runs, so no router
body reaches the prompt. `using-sdlc-skills` is listed like any other skill
and has to be invoked. That is weaker than every other adapter, and weaker
than the native manifest this repository ships. It is the most a build without
a plugin loader allows. The README says so at the install step, so that nobody
assumes routing from a list of skills.

### What the tests prove

`tests/harnesses/muse.sh` runs the install script against a throwaway home,
with both `HOME` and `XDG_CONFIG_HOME` overridden. Muse takes its
configuration directory from `XDG_CONFIG_HOME` when it is set and from `HOME`
otherwise. Overriding only one would let the operator's real
`~/.config/muse/skills/` answer for the tree under test.
`MUSE_NO_AUTO_UPDATE=1` keeps the launcher off the network in a fresh home.

The inventory step reads `muse skills list --source user --json`. Installed
copies report `provenance: null`, so there is no source path to filter on. The
isolation is what makes the unfiltered list trustworthy: the home was empty
before the install ran.

Measured on 1.3.0: every installed skill is listed at user scope.
`muse skills validate` is the per-skill check this build allows, and it
returns valid for all of them.

The smoke test proves the install and the skill inventory. It runs no model
turn, so it does not show whether the agent invokes `using-sdlc-skills` from
the list.

## pi

pi 0.86.1 reads the `pi` key in `package.json`:

```json
{"extensions": ["./.pi/extensions/sdlc-skills.js"], "skills": ["./skills"]}
```

It does so once a checkout is installed with `pi install <path>`, or with `-l`
for one project. Skills under a listed directory are discovered recursively,
so the tree nested by phase needs no flattening.

### The extension

The entry point of the extension is `export default function (pi)`. It does
three things:

- On `resources_discover`, it registers `skillPaths: [<checkout>/skills]`.
- On `before_agent_start`, it appends the router body once, through
  `event.systemPromptOptions.appendSystemPrompt`. Appending is preferred to
  replacing `systemPrompt`. That field is a plain string, so the check that
  prevents a second append looks for the body itself.
- On `session_compact`, it writes the same block into the `summary` field of
  the compaction entry.

### Compaction

Text supplied at session start does not survive a transcript replaced by a
summary, which is why the `session_compact` handler exists.

It has a limit. pi has already saved the compaction entry before the event
fires. The write reaches the copy in memory, for the rest of the run, and not
the saved one. A session resumed later receives the router again from
`before_agent_start`.

### Installation

Measured on 0.86.1: for a local path, `pi install <path>` registers the
checkout by reference in `<HOME>/.pi/agent/settings.json` and copies nothing.
A throwaway `HOME` holds only that one settings file after the install, and
the checkout is untouched, so no `.gitignore` entry is needed.

`pi list` prints the registered package line. There is no non-interactive
listing of skills, and `pi -p` runs a model turn, so the offline evidence
stops at registration.

### What the tests prove

`tests/run-pi-extension.sh` runs the extension's handlers against stub inputs.
It checks the set of registered events, the path given on
`resources_discover`, and that `before_agent_start` and `session_compact`
append the body verbatim and only once. It does not prove that the append
survives a resume.

`tests/harnesses/pi.sh` installs into a throwaway `HOME`, offline, and reports
the `pi list` package line and the limit of the inventory.

`tests/run-plugin-smoke.sh --harness pi` also counts the `SKILL.md` files
under the checkout, because the install refers to the checkout in place, and
checks that `.pi/extensions/sdlc-skills.js` is present.

### No tool bindings yet

No tool bindings file ships with this adapter. pi's tool names have not been
measured against a running session, so the dispatch and role-binding tables
below have no row for pi.

## Lifecycle policy

Every adapter supplies the full router through a session-start mechanism,
with two exceptions described above: Grok Build gets a rules-file nudge, and
Muse Code 1.3.0 gets discovery only. No adapter registers a hook on tool calls, on prompts, or at the end of a turn.

Compaction is a boundary like start, resume, and clear. It replaces the
transcript with a summary, and text injected at session start is not carried
into the replacement. The router is therefore supplied again wherever the
harness exposes that moment.

The router arrives through the session-start mechanism and not through a
dedicated compaction hook. Where a harness has both, the `SessionStart` output
that follows compaction is added to the compacted context, and the output of a
`PostCompact` hook is not. That event reports the compaction and contributes
nothing to it. The shared injector therefore answers `SessionStart` for every
source and ignores `PostCompact`.

### What the lifecycle tests cover

`tests/run-session-start.sh` checks the registrations and the branches for
synthetic payloads, including the injected body and its envelope. It does not
compact a real session to see which instructions survive.

When you add or update a harness, verify its lifecycle behavior on the
installed version before you rely on retained context or change the
re-injection policy.

`scripts/sh/token-budget.sh` measures the approximate size of the injected
context. It measures text. It does not measure the billing cost of a session
or any benefit to behavior.

See [`activation.md`](activation.md) for the difference between routing and
enforcement.

## Dispatching work to subagents

`dispatching-parallel-agents`, `executing-plans`, and
`subagent-driven-development` hand work to a fresh agent through what the
skills call "the real callable action". The skills never name that action,
which keeps them portable. Each adapter binds it, and each harness decides
whether it exists at all.

| Harness | Dispatch action | Does the subagent load skills? | Nesting depth | Model tier |
| --- | --- | --- | --- | --- |
| Claude Code | `Agent` tool | Yes, unless the subagent's own definition withholds the action | One level for the read-only built-in types. A general subagent can dispatch again, which the packet prohibits unless it allocates a sub-scope | Settable. The tier binds to the model parameter of the dispatch call |
| Codex | `spawn_agent`, `wait_agent`, `list_agents`, `send_message`, `followup_task`, `interrupt_agent` | Only when the plugin is installed for the spawned agent, and not for the session alone | Not declared by the build. Treat a worker's own dispatch as prohibited | Settable. The spawn call carries the model the tier binds to |
| Kimi Code | `Agent` tool | The brief names the file to read, because a subagent may not resolve paths relative to the plugin | One level. A background run adds parallelism, not nesting | Not settable. The tier is stated in the prompt and the harness binds it |
| OpenCode | 1.x: the `Task` tool, to the `general` and `explore` subagents. 2.x: the `subagent` tool, with the same role names as its `agent` argument | Yes, for the whole session, through the plugin's skill registration | Not declared by the build. Treat a worker's own dispatch as prohibited | Settable through the agent's `model`. A subagent without one inherits the invoking agent's. The tier is stated in the prompt and the harness binds it |

Grok Build, Muse Code, and pi have no row. No tool binding ships for them.

### Where the tool names live

A shipped skill never names a harness tool, so the names live inside each
adapter:

- Codex: `plugins/sdlc-skills/references/codex-tools.md`, which holds the tool
  names, their arguments, and the resume path.
- OpenCode: `.opencode/references/opencode-tools.md`.

### What each row rests on

- The Claude Code row was checked against the tool surface of the running
  harness.
- The OpenCode 1.x row was checked against that build's skill listing and its
  published tool and agent references.
- The OpenCode 2.x row was checked against the tool surface a running 2.x
  session reports.
- The Codex and Kimi Code rows are read from the binding their adapter
  declares, not from a live run.

Availability, nesting, and agent names belong to the installed build. They
change between versions, and some builds keep multi-agent tools behind a
configuration entry that is off by default. Check a cell again with the CLI
before you rely on it. Check the harness's own configuration reference for the
current form, and ask the installed CLI which tools it exposes. Do not trust a
snippet copied from somewhere else.

### When the action is not available

The skills do not hardcode a remedy, because the remedy depends on the build.
They require the agent to:

1. Treat an action it cannot call as **not dispatched**.
2. Name the action it attempted, and what this environment would need for the
   action to become callable.
3. Ask the user once, offering a self-review labelled as one, a named reviewer
   or agent, or keeping the work pending.

The answer becomes the written assignment. The agent never stops without
explanation, never describes a fan-out it has no receipts for, and never does
the work itself in silence.

### Role binding for subagent-driven development

`subagent-driven-development` dispatches through the same action and adds one
more binding. Its three role briefs are the specification:
`assets/implementer.md`, `assets/task-reviewer.md`, and
`assets/re-reviewer.md`. A named harness agent is only a runtime that carries
one of them.

Where a harness exposes an agent whose contract covers the role, the adapter
maps the role to that name and the filled brief is dispatched to it. Where it
does not, the same brief goes to a general subagent.

The mapping lives in the adapters and in this table, never in the skill body.
A harness that renames or removes an agent changes no shipped skill.

| Harness | Agents a role can bind to | Fallback |
| --- | --- | --- |
| Claude Code | The built-in general-purpose type, plus any agent defined under `.claude/agents/`, selected with the `subagent_type` of the `Agent` tool | The general-purpose type carrying the role prompt |
| Codex | The agent roles the installed build exposes to `spawn_agent` | A general agent carrying the role prompt |
| Kimi Code | The `subagent_type` values bound in the `skillInstructions` of `.kimi-plugin/plugin.json` | `coder` carrying the role prompt. It cannot enforce read-only, so a review brief sent to it forbids every edit, commit, and push |
| OpenCode | `general` for the implementer and `explore` for the reviewers, selected with the `Task` tool on 1.x and the `agent` argument of the `subagent` tool on 2.x | The general-purpose subagent carrying the role prompt, which forbids every edit, commit, and push |

The tier is a separate choice from the agent. The skill sets `small`,
`medium`, or `large` explicitly for each dispatch, and the adapter binds that
tier to a model. An agent name never implies a tier.

## Repository instruction files

`AGENTS.md` is the canonical contributor guide, and the file coding agents
read when they work in this repository. `GEMINI.md` is a symbolic link to it, and `CLAUDE.md` is a short
pointer to it. A harness that reads its own conventional instructions file
gets the same rules from one source, including a harness that refuses a
symlinked instructions file.

## Using the skills on another harness

The skills are Markdown files invoked by name. To use them on a harness that
has no adapter here:

1. Expose the canonical skill directories through the harness's normal skill
   mechanism.
2. Supply the full router through the harness's session-start mechanism. Use
   `scripts/sh/session-start.sh` where its event and output format apply. Find
   out which of start, resume, clear, and compaction require the context to be
   restored. Do not infer that from the name of a hook.
3. Bind the actions the skills use to the harness's real tools, and verify
   that those tools are available.
4. Run a representative activation through the installed adapter before you
   claim support. State your lifecycle assumptions and the capabilities that
   are not supported.

Do not simulate runtime support with copied transcript fixtures.

## Adding an adapter to this repository

1. Point the manifest at the canonical skills. Do not fork their content.
2. Extend the structural validation so that missing, extra, or divergent
   skills fail.
3. Add offline install bindings under `tests/harnesses/` for
   `tests/run-plugin-smoke.sh`.
4. Add an offline test only for deterministic adapter logic that the
   integration introduces.
5. Show a skill activating through the harness's own CLI on a representative
   opening. Files that are present but never invoked are not a working
   integration.
6. Document the adapter's current lifecycle and the limits of its support on
   this page. Keep run transcripts and evaluation results in the test
   workflow.

## What to test

Different claims need different evidence.

| Claim | Evidence |
| --- | --- |
| Packaging and structure | Deterministic validation of manifests, mirror equality, reference paths, frontmatter, and token budgets. These checks belong in CI |
| Deterministic adapter scripts | Focused offline tests for parsing or hook branches that matter. Keep each script small enough that its test does not become a second implementation |
| Discovery and activation | A skill activating through the harness's own CLI, shown once, when the harness is added |

Each harness is bound in one place. Its offline contract, meaning how the
plugin installs and what the CLI resolves, is documented in
[`tests/harnesses/README.md`](../tests/harnesses/README.md) and exercised by
`tests/run-plugin-smoke.sh`. See [`tests/README.md`](../tests/README.md).
