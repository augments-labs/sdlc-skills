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
| OpenCode | `.opencode/plugins/sdlc-skills.js` | `experimental.chat.system.transform` hook | Yes — the `experimental.session.compacting` hook carries it forward |

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
same file serves a contributor working inside this checkout (auto-discovered
from `.opencode/plugins/`) and a user elsewhere (named in `opencode.json` under
`plugin`). Its `config` hook registers the canonical `skills/` directory, so no
separate skill-path step is needed. The dependency-free root `package.json`,
version-synced with the manifests, is what makes the `sdlc-skills@git+...`
package spec installable — without it the spec resolves to nothing.
`tests/run-opencode-plugin.sh` checks the
hook logic offline; `tests/run-plugin-smoke.sh --harness opencode` checks
discovery through the installed CLI.

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
| OpenCode | `Task` tool to the `general` / `explore` subagents | Session-wide, through the plugin's skills registration | Not declared by the build — treat a worker's own dispatch as prohibited | Settable through the agent's `model` — a subagent without one inherits the invoking agent's; the tier is stated in the prompt and the harness binds it |

The Codex tool names, their arguments, and the resume path live in
`plugins/sdlc-skills/references/codex-tools.md`, inside that adapter, because a
shipped skill never names a harness tool. The OpenCode names live in
`.opencode/references/opencode-tools.md` for the same reason. What each row
rests on: the Claude Code row was checked against the running harness's own
tool surface; the OpenCode row was checked against the installed build's skill
listing and its published tool and agent references; the other two are read
from their adapter's declared binding, not from a live run.
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
| OpenCode | `general` for the implementer, `explore` for the reviewers, selected with the `Task` tool | the general-purpose subagent carrying the role prompt, which forbids every edit, commit, and push |

The tier is a separate choice from the agent: the skill sets `small`, `medium`,
or `large` explicitly per dispatch, and the adapter binds that tier to a model.
An agent name never implies a tier.

## Repository instruction files

`AGENTS.md` and `GEMINI.md` are symlinks to `CLAUDE.md`. A harness that reads
its conventional repository instructions therefore receives the same contributor
rules from one source.

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
  its own CLI once, when it is added (see `CLAUDE.md`, *New harness support*).

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
