# Harness Support

How one skill library runs on several coding agents without putting
harness-specific behavior into the skills.

## One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills use capability tiers and
portable actions; each harness adapter binds those concepts to its own manifest,
tools, and lifecycle events.

| Harness | Adapter | Entry-skill injection | Re-applied after compaction |
| --- | --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | `SessionStart` hook | Yes — `compact` is in the matcher |
| Codex | `plugins/sdlc-skills/` and `.agents/plugins/marketplace.json` | bundled `SessionStart` hook | Yes — the hook is unfiltered, so `source=compact` reaches the injector |
| Kimi Code | `.kimi-plugin/plugin.json` | `sessionStart.skill` | Not exposed — the manifest declares no compaction event |
| OpenCode 1.x | `.opencode/plugins/sdlc-skills.js` | `experimental.chat.system.transform` hook | Yes — the `experimental.session.compacting` hook carries it forward |
| OpenCode 2.x | the checkout directory, entered through the root `index.js` | `setup`'s `session.hook("context")`, into the first user message | Inferred, not observed — the context hook runs on every request and the injection is deduped, so a transcript replaced without the block gets it again; no compaction was run against a 2.x build here |
| Grok Build | `.claude-plugin/plugin.json` and `hooks/hooks.json`, read as shipped — no separate manifest | none — see below | not applicable, there is no injection to re-apply |
| Muse Code | `.muse-plugin/plugin.json` on a build with plugin support; otherwise the per-skill install `scripts/sh/install-muse-skills.sh` drives | the manifest's `SessionStart` hook — never on 1.3.0, which loads no plugin | Not exposed — no hook runs, so there is nothing to re-apply |
| pi | `.pi/extensions/sdlc-skills.js`, registered through the `pi` key in `package.json` | `before_agent_start` hook, via `appendSystemPrompt` | Yes — `session_compact` re-appends the block into the saved compaction entry's own summary |

The Codex plugin manifest carries the skill catalogue but has no session-start
field, so the entry skill arrives through hooks the plugin itself bundles
(`"hooks": "./hooks/hooks.json"`). Bundling matters: the plugin is installed
standalone, so a hooks file at the repository root is outside the plugin root and
Codex never loads it — a repo-local config wires contributors and ships nothing.
Everything the hook touches therefore lives inside the plugin, and
`scripts/sh/sync-codex-plugin-skills.sh` mirrors it in.

The injector resolves its files through the installed plugin root, since hooks
run from the session's working directory. It supports both canonical phase
paths and the Codex plugin's flat `skills/<name>/` layout.

The injector reads the router shipped in that installation; it does not embed a
second handwritten body. After canonical skill edits, run
`scripts/sh/sync-codex-plugin-skills.sh` to rebuild the Codex mirror. Then install
or update the package being exercised. Editing this checkout does not update an
existing plugin cache. `scripts/sh/validate-skills.sh` checks mirror equality
and the skill set exposed by all four adapters.

The OpenCode plugin resolves the router from its own location at runtime, so the
same file serves a contributor working inside this checkout and a user
elsewhere. How each reaches it differs by generation. 1.x auto-discovers the
plugin file from `.opencode/plugins/`; 2.x scans that same directory but keeps
only entries that are directories, so it never picks the file up, and a
contributor on 2.x names the checkout directory in `opencode.json` exactly as a
user elsewhere does. Neither generation's passive discovery is exercised by the
tests — the smoke adapter writes an explicit config entry for both. One file
carries both contracts, because the two generations share no entry point:
1.x discovers a plugin by scanning the module's named exports for hook
factories, and 2.x calls `default.setup(ctx)` and nothing else. The factory is
therefore exported by name and as `default.server`, and `setup` sits beside it.

On 1.x the `config` hook registers the canonical `skills/` directory, so no
separate skill-path step is needed, and the router goes into the system
context. 2.x models `skills` as an array with no paths under it, so that hook
returns early there; `setup` registers each skill through `skill.transform` and
puts the router into the first user message instead. That hook runs on every
request and the injection is deduped on the block's own opening, so in steady
state the block lands once per top-level session, and lands again on any later
request whose first user message no longer carries it. Child sessions are
skipped — they inherit the work, not the routing —
and every callback is wrapped, because a throw escaping one takes the plugin,
and for the context hook the session running it, down with it.

The install path differs too. 1.x accepts the plugin FILE; 2.x accepts only a
DIRECTORY, and resolves `<dir>/server.js` then `<dir>/index.js` inside it, so
the root `index.js` re-exports the adapter and an installed package reaches it
through `main`. The dependency-free root `package.json`, version-synced with
the manifests, is what makes the `sdlc-skills@git+...` package spec installable
— without it the spec resolves to nothing.

`tests/run-opencode-plugin.sh` checks both contracts' logic offline against
stub hosts. `tests/run-plugin-smoke.sh --harness opencode` checks discovery
through the installed CLI, and what it can prove depends on the generation: on
1.x it reads back the harness's own skill listing, and on 2.x it reads back the
harness's own "loading plugin" line naming the entry point it resolved. 2.x
exposes no skill listing without a model call — `debug skill` is gone, and
`opencode serve`, whose API does list skills, loads no plugins — so on that
generation the test states the inventory as unavailable rather than counting
the tree and calling it discovery.

What holds the 1.x side is weaker than what holds the 2.x side, and the
difference is worth stating: the 1.x load is asserted structurally by the
offline checks — the named export exists, and every function the package entry
exposes answers a 1.x-shaped call with a hook set — and is not observed on a
1.x binary, because the adapter's entry shape is what this arrangement
changed and no 1.x build has run it here.

Grok Build 1.0.40 accepts a Claude-format plugin directory directly, so no
dedicated Grok manifest is added — it reads `.claude-plugin/plugin.json` and
`hooks/hooks.json` from the checkout as they already ship. `grok plugin
install <path> --trust` copies the checkout into a per-install directory under
`GROK_HOME`, offline and without login for a local-path source, and registers
the plugin enabled at user scope. Listing the checkout under `config.toml`'s
`[plugins] paths` plus `[plugins] enabled` also discovers it, but that route
additionally requires the folder to be marked trusted in
`trusted_folders.toml`; the install route needs no separate trust record, so
`tests/harnesses/grok.sh` uses it. Because the install copies rather than
loading the checkout in place, the copy's path is not knowable in advance —
the adapter's inventory step reports skills by `source.plugin_name` from
`grok inspect --json` instead of by path, matching the plugin id
(`sdlc-skills`) the manifest declares. Measured on 1.0.40: the install
registers 37 skills and 1 hook. `grok inspect` also cross-reads a real
operator's `~/.claude/plugins/marketplaces/` regardless of `GROK_HOME` alone
— on a machine that already has this plugin installed for Claude Code, that
installed copy answers for the tree under test — so the adapter isolates
`HOME` alongside `GROK_HOME` to keep the check offline and free of the
operator's own installs.

No hook reaches the system prompt on 1.0.40: for `SessionStart`, stdout is
discarded; `additionalContext` exists only on tool events (`PreToolUse`,
`PostToolUse`, `PostToolUseFailure`) and `Stop`; and `--rules` (alias
`--append-system-prompt`) appends to the system prompt for one invoked
session only, not at install time. The one channel this binding uses instead
is a rules file: a one-line nudge naming `using-sdlc-skills` first, placed
under `$GROK_HOME/rules/`. Grok scans that directory for every project
regardless of folder trust and reports it under `grok inspect`'s Project
Instructions — measured: a file placed there is read back with `scope:
global` and listed by both `grok inspect --json`'s `projectInstructions`
array and the plain-text `Project Instructions` section, with no `--trust`
or config change needed. This is a nudge sitting in the rules, not an
injected router body, and it is weaker than the other adapters' session-start
injection: it is one more file the model may or may not act on, and it is
never re-verified here beyond `grok inspect` listing the file — until Grok
exposes a hook that appends to the prompt at session start, this is the
honest ceiling of what the router channel can do on this harness.
`tests/run-plugin-smoke.sh --harness grok` checks the install and the skill
inventory only; it does not read back Project Instructions or run a model
turn, so whether `using-sdlc-skills` is actually invoked from the nudge is a
live check, not a smoke one.

Muse Code takes two routes, and which one a user gets is decided by their
build, not by this repository. `.muse-plugin/plugin.json` is the native
manifest: `schemaVersion` 1, one `{id, path}` under `capabilities.skills` for
each canonical skill, and a `SessionStart` hook running the shared
`scripts/sh/session-start.sh` injector. That is the full binding — discovery
and the router in one file — and on a build that ships plugin support it needs
no further step.

Measured on 1.3.0: that build ships no plugin loader at all. `muse plugins`
answers "plugins are not available in this build", so the manifest can be
neither installed nor validated there, and its hook never runs. The manifest
still ships, carrying the current release version like every other manifest, so
the version gate covers it and a build that gains plugin support finds it
already correct rather than a release behind.

The route that build does offer is `muse skills install <dir> --scope user`,
which takes exactly ONE skill directory — pointed at a tree it fails with
"skill package must contain SKILL.md" — and copies it under the config
directory's `skills/`. `scripts/sh/install-muse-skills.sh` loops the canonical
directories through it with `--force`, so a re-run overwrites rather than
failing on "skill already installed", and `--remove` uninstalls the same set,
treating the CLI's own `skill-not-installed` code as already gone so a second
removal is a no-op rather than 38 errors.

What that route buys is discovery and nothing else. No hook runs, so no router
body reaches the prompt: `using-sdlc-skills` is listed like any other skill and
has to be invoked. That is weaker than every other adapter's session-start
injection and weaker than the native manifest this same repository ships — the
honest ceiling on a build without a plugin loader. The README says so at the
install step rather than letting a user infer routing from a skill list.

`tests/harnesses/muse.sh` drives the install script into a throwaway home with
both `HOME` and `XDG_CONFIG_HOME` overridden: Muse resolves its config
directory from `XDG_CONFIG_HOME` when set and from `HOME` otherwise, so
overriding one alone would let an operator's real `~/.config/muse/skills/`
answer for the tree under test. `MUSE_NO_AUTO_UPDATE=1` keeps the launcher off
the network in a fresh home. The inventory step reads `muse skills list
--source user --json`: the installed copies report `provenance: null`, so there
is no source path to filter on, and the isolation is what makes the unfiltered
list trustworthy — the home was empty before the install ran. Measured on
1.3.0: 38 skills installed, 38 listed at user scope. `muse skills validate` is
the per-skill check this build allows, and it returns valid for all 38.

The smoke test proves the install and the skill inventory. It runs no model
turn, so whether `using-sdlc-skills` is actually invoked from a listed skill is
a live check, not a smoke one.

pi 0.86.1 reads the `pi` key in `package.json` —
`{"extensions": ["./.pi/extensions/sdlc-skills.js"], "skills": ["./skills"]}` —
once a checkout is installed with `pi install <path>` (or `-l` against a
project). Skills under a listed directory are discovered recursively, so the
phase-nested tree needs no flattening. The extension's entry point is
`export default function (pi)`; it registers `skillPaths: [<checkout>/skills]`
on `resources_discover`, and on `before_agent_start` appends the router body
once through `event.systemPromptOptions.appendSystemPrompt`, preferred over
replacing `systemPrompt` — that field is a plain string, not a list, so the
idempotency check is against the body itself rather than a count.
`session_compact` exists for re-injection after compaction; text supplied at
session start does not survive a transcript replaced by a summary, so the
extension writes the same appended block into the saved compaction entry's
own `summary` instead. No tool bindings file ships with this adapter: pi's
tool names are unmeasured against a running session, so the Dispatch
capability and role-binding tables below carry no pi row until they are.

Measured on 0.86.1: `pi install <path>` for a local-path source registers by
reference in `<HOME>/.pi/agent/settings.json` and copies nothing — a
throwaway `HOME` after install holds only that one settings file, and the
checkout itself is untouched, so no `.gitignore` entry is needed. `pi list`
prints the registered package line back; there is no non-interactive skill
dump, and `pi -p` runs a model turn, so the offline evidence stops at
registration. `tests/run-pi-extension.sh` drives the extension's own handlers
against stub inputs: the registered event set, `resources_discover`'s path,
and `before_agent_start`/`session_compact`'s verbatim, idempotent append.
`tests/harnesses/pi.sh` installs into a throwaway `HOME`, offline, and reports
the `pi list` package line and the inventory limit; `tests/run-plugin-smoke.sh
--harness pi` additionally counts `SKILL.md` files under the checkout — the
install references it in place rather than copying it — and checks that
`.pi/extensions/sdlc-skills.js` is present there.

## Lifecycle policy and evidence

All adapters supply the full router through session-start mechanisms and
register no tool, prompt, or turn-end hooks. Compaction is an epoch boundary
like start, resume, and clear: it replaces the transcript with a summary, and
text injected at session start is not carried into the replacement, so the
router is supplied again wherever the harness exposes the event.

It arrives through the session-start mechanism, not a dedicated compaction
hook. Where a harness has both, the post-compaction `SessionStart` output is
added to the compacted context and a `PostCompact` hook's output is not — that
event reports compaction rather than contributing to it. The shared injector
therefore answers `SessionStart` for every source and ignores `PostCompact`.

`tests/run-session-start.sh` checks those registrations and synthetic payload
branches, including the injected body and envelope. It does not compact a real
session and establish which instructions survive. When adding or updating a
harness, verify its lifecycle behavior for the installed version before relying
on retained context or changing re-injection policy.

`scripts/sh/token-budget.sh` measures approximate injected context size. It
measures text, not a guaranteed per-session billing cost or behavioral benefit.
See [`activation.md`](activation.md) for routing versus enforcement.

## Dispatch capability

`dispatching-parallel-agents`, `executing-plans`, and
`subagent-driven-development` hand work to a cold agent
through "the real callable action". The skills stay portable by never naming it;
each adapter binds it, and each harness decides whether it exists at all.

| Harness | Dispatch action | Subagent loads skills | Nesting depth | Tier |
| --- | --- | --- | --- | --- |
| Claude Code | `Agent` tool | Yes — a subagent reaches skills unless its own definition withholds the action | One level for the read-only built-in types; a general subagent can dispatch again, which the packet prohibits unless it allocates sub-scope | Settable — the tier binds to the model parameter on the dispatch call |
| Codex | `spawn_agent` / `wait_agent` / `list_agents` / `send_message` / `followup_task` / `interrupt_agent` | Only when the plugin is installed for the spawned agent, not for the session alone | Not declared by the build — treat a worker's own dispatch as prohibited | Settable — the spawn call carries the model the tier binds to |
| Kimi Code | `Agent` tool | The brief names the file to read, because a subagent may not resolve plugin-relative paths | One level; a background run parallelises, it does not nest | Not settable — the tier is stated in the prompt and the harness binds it |
| OpenCode | 1.x: `Task` tool to the `general` / `explore` subagents. 2.x: `subagent` tool, with the same role names as its `agent` argument | Session-wide, through the plugin's skills registration | Not declared by the build — treat a worker's own dispatch as prohibited | Settable through the agent's `model` — a subagent without one inherits the invoking agent's; the tier is stated in the prompt and the harness binds it |

The Codex tool names, their arguments, and the resume path live in
`plugins/sdlc-skills/references/codex-tools.md`, inside that adapter, because a
shipped skill never names a harness tool. The OpenCode names live in
`.opencode/references/opencode-tools.md` for the same reason. What each row
rests on: the Claude Code row was checked against the running harness's own
tool surface; the OpenCode 1.x row was checked against that build's skill
listing and its published tool and agent references, and the 2.x row against
the tool surface a running 2.x session reports; the other two are read from
their adapter's declared binding, not from a live run.
Availability, nesting, and agent names are properties of the installed build, so
re-check a cell with the CLI before relying on it.

Availability is a property of the installed build and its configuration, not of
this library, and it changes between versions — some builds gate multi-agent
tools behind a config entry that is off by default. So the skill does not
hardcode a remedy. It requires the agent to treat an uncallable action as **not
dispatched**, to name both the action it attempted and what this environment
would need to make it callable, and to ask the user once: a labelled
self-review, a named reviewer or agent, or keeping the work pending. The answer becomes
the written assignment. The agent never stops mysteriously, narrates a fan-out
it holds no receipts for, or silently does the work itself.

Check the harness's own configuration reference for the current form, and verify
by asking the installed CLI what tools it exposes rather than trusting a
second-hand snippet.

### Role binding for subagent-driven development

`subagent-driven-development` dispatches through the same action and adds one
more binding. Its three role briefs — `assets/implementer.md`,
`assets/task-reviewer.md`, and `assets/re-reviewer.md` — are the specification; a
named harness agent is only a runtime that carries one. Where a harness exposes
an agent whose contract covers the role, the adapter maps the role to that name
and the filled brief is dispatched to it. Where it does not, the same brief goes
to a general subagent. The mapping lives in the adapters and in this table, never
in the skill body, so a harness that renames or removes an agent changes no
shipped skill.

| Harness | Agents a role can bind to | Fallback |
| --- | --- | --- |
| Claude Code | the built-in general-purpose type, plus any agent defined under `.claude/agents/`, selected with the `Agent` tool's `subagent_type` | the general-purpose type carrying the role prompt |
| Codex | the agent roles the installed build exposes to `spawn_agent` | a general agent carrying the role prompt |
| Kimi Code | the `subagent_type` values bound in `.kimi-plugin/plugin.json` `skillInstructions` | the general-purpose type carrying the role prompt |
| OpenCode | `general` for the implementer, `explore` for the reviewers, selected with the `Task` tool on 1.x and the `subagent` tool's `agent` argument on 2.x | the general-purpose subagent carrying the role prompt, which forbids every edit, commit, and push |

The tier is a separate choice from the agent: the skill sets `small`, `medium`,
or `large` explicitly per dispatch, and the adapter binds that tier to a model.
An agent name never implies a tier.

## Repository instruction files

`AGENTS.md` is the canonical contributor guide. `GEMINI.md` is a symlink to it
and `CLAUDE.md` is a short pointer to it. A harness that reads its conventional
repository instructions therefore receives the same contributor rules from one
source, even one that refuses a symlinked instructions file.

## Using SDLC skills elsewhere

The skills are Markdown invoked by name. On another harness:

1. Expose the canonical skill directories through the harness's normal skill
   mechanism.
2. Supply the full router through the harness's session-start mechanism, using
   `scripts/sh/session-start.sh` where its event and output format apply.
   Establish which start, resume, clear, or compaction events require restoring
   context; do not infer that from a hook name alone.
3. Bind skill actions to the harness's real tools and verify their availability.
4. Exercise a representative activation through the installed adapter before
   claiming support. State lifecycle assumptions and unsupported capabilities.

Do not simulate runtime support with copied transcript fixtures.

## What to test

Different claims need different evidence:

- **Packaging and structure:** deterministic validation of manifests, mirror
  equality, reference paths, frontmatter, and token budgets. These checks belong
  in CI.
- **Deterministic adapter scripts:** focused offline tests for meaningful parsing
  or hook branches. Keep the script small enough that its test does not become a
  second implementation.
- **Discovery and activation:** a new harness shows a skill activating through
  its own CLI once, when it is added (see `AGENTS.md`, *New harness support*).

Each harness is bound in one place: the offline contract — how the plugin
installs and what the CLI resolves — documented in
[`tests/harnesses/README.md`](../tests/harnesses/README.md) and exercised by
`tests/run-plugin-smoke.sh` (see [`tests/README.md`](../tests/README.md)).

## Adding an adapter

1. Point the manifest at the canonical skills; do not fork their content.
2. Extend structural validation so missing, extra, or divergent skills fail.
3. Add offline install bindings under `tests/harnesses/` for
   `tests/run-plugin-smoke.sh`.
4. Add an offline test only for deterministic adapter logic introduced by the
   integration.
5. Document the adapter's current lifecycle and support boundaries. Keep run
   transcripts and evaluation results in the test workflow, not this website
   documentation.
