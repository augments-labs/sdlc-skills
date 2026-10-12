# Supported agents

One set of skills works on every agent below. Each agent has a small adapter
in the repository that makes the skills visible and hands the agent the
routing skill, `using-sdlc-skills`, when a session starts. This page says
what each agent gets and where its support stops.

Three things differ between agents:

1. **How the routing skill arrives.** On most agents the adapter puts its
   whole body into the session at start. On a few, a one-line rule asks the
   agent to load it, which is weaker. On one, nothing does, and you ask.
2. **Whether it arrives again after compaction.** When the agent compacts a
   long session, text supplied at session start is lost. Some agents let the
   adapter supply it again; some do not.
3. **Whether the skills can dispatch subagents.** Reviews and delegated plan
   execution hand work to a fresh agent through a tool the adapter names.
   Where no tool is bound, the agent asks you what to do instead.

The version named for each agent is the one the support was checked on.
Later versions may differ.

## At a glance

| Agent | How the routing skill arrives | Supplied again after compaction | Subagent dispatch |
| --- | --- | --- | --- |
| Claude Code | Injected at session start | Yes | Yes |
| Codex CLI | Injected at session start | Yes | Yes |
| Kimi Code | Injected at session start | No | Yes |
| OpenCode 1.x | Injected into the system context | Yes | Yes |
| OpenCode 2.x | Injected into the first user message | Expected, not yet observed | Yes |
| Grok Build | A rules file you create asks the agent to load it | Not applicable | No binding |
| Muse Code 1.3.0 | It does not; you ask at the start of each session | No | No binding |
| pi | Appended to the system prompt at session start | For the rest of the running process; a resumed session gets it again at start | No binding |
| Devin | Injected at session start | Expected, not yet observed | No binding |
| Antigravity | A rule shipped in the plugin asks the agent to load it | Not applicable | No binding |
| Hermes | Rendered into the system prompt | Yes | No binding |
| Cursor | Injected at session start | Not yet observed | No binding |

"No binding" means the skills have no name for that agent's subagent tool.
When a skill needs to dispatch a reviewer or a worker, the agent tells you
it cannot and asks once whether to do a self-review (labelled as one), hand
the work to someone you name, or leave it pending.

## Claude Code

The routing skill is injected at session start and again after compaction.
Subagents run through the `Agent` tool, they load skills unless their own
definition withholds the tool, and the model tier a skill asks for (small,
medium, large) is set on the dispatch call. Reviewer and worker roles can
bind to the built-in general-purpose agent or to any agent you define under
`.claude/agents/`.

## Codex CLI

Codex installs the plugin directory `plugins/sdlc-skills/`, which carries
its own hook, so the routing skill is injected at session start and after
compaction. Subagents run through Codex's agent tools (`spawn_agent` and
its companions) with the tier set on the spawn call.

Known limit: a spawned agent only sees the skills when the plugin is
installed for it, not just for the session.

## Kimi Code

The manifest names the routing skill for session start, so it is injected
then. The manifest declares no compaction event, so after compaction the
routing skill is gone until you ask for it again.

Subagents run through the `Agent` tool. A subagent may not resolve paths
relative to the plugin, so a brief names the file to read. The model tier is
stated in the prompt rather than set on the call; Kimi binds it.

## OpenCode

OpenCode 1.x and 2.x load the plugin differently and the adapter handles
both. On 1.x the routing skill goes into the system context and is carried
forward through the compaction hook. On 2.x it goes into the first user
message on every request that no longer carries it, which should cover
compaction; this has not been run against a 2.x build.

Subagents run through the `Task` tool on 1.x (`general` and `explore`) and
the `subagent` tool on 2.x with the same role names. A subagent's model is
set through its agent definition and defaults to the invoking agent's. Child
sessions do not get the routing skill; they inherit the work, not the
routing.

Known limit: on 2.x there is no way to list skills without a model call, so
the only confirmation that the plugin loaded is the "loading plugin" line in
`opencode run --standalone --print-logs`.

## Grok Build

Checked on 1.0.40. Grok reads the plugin in the Claude Code format directly,
so the skills are discovered. No hook on this version can add text to the
prompt at session start, so routing rests on the one-line rules file you
create at install time, which Grok reads for every project. This is a nudge
the agent may or may not act on, and it is weaker than the injection other
agents get.

No subagent tool is bound.

## Muse Code

Checked on 1.3.0, which ships no plugin loader. The install script puts each
skill in place one at a time, so the agent can see them, but nothing hands
it the routing skill: ask for `using-sdlc-skills` at the start of each
session. The repository also ships a native manifest for a Muse build with
plugin support, which would supply the routing skill at session start; no
such build has been observed.

No subagent tool is bound.

## pi

Checked on 0.86.1. The extension appends the routing skill to the system
prompt at session start. On compaction it writes the routing skill into the
summary, but pi has already saved the compaction entry by then, so the
update reaches only the running process. A session resumed later gets the
routing skill again at start, which covers it.

pi registers the clone by reference; the files stay where you cloned them.
No subagent tool is bound.

## Devin

Checked on 3000.11.3. Devin installs the Codex plugin directory and runs its
hook, so the routing skill is injected at session start. Whether that
happens again after compaction is expected from Devin's hook model but has
not been observed. Devin's plugin hooks fail open: a hook that cannot run is
skipped and the session continues without the routing skill, with no error.

Plugin commands refuse to run signed out, even for a local directory, and an
install checks your organisation's plugin policy over the network. A local
install links the clone in place rather than copying it.

Devin documents subagent tools, but none is bound.

## Antigravity

Checked on 1.3.3. Antigravity installs the Codex plugin directory and runs
no session-start hook from a plugin, so the plugin ships an always-on rule
that asks the agent to load `using-sdlc-skills` before acting. As on Grok,
this is a nudge rather than an injected body. An install copies the
directory into `~/.gemini/config/plugins/sdlc-skills/` and needs no
sign-in.

No subagent tool is bound.

## Hermes

Checked on 0.21.7. The plugin renders the routing skill into the system
prompt as a set of sections, once per session and again after Hermes
compresses the context, so routing survives compaction.

Known limit: Hermes skips any section longer than 4,000 characters and
gives all plugins 8,000 characters between them. The routing skill is split
into sections to fit. If other enabled plugins use up the shared budget,
Hermes drops a section and logs a warning, and part of the routing skill
does not reach the agent.

Hermes also logs a warning that it could not parse `.muse-plugin/plugin.json`
when it loads the plugin. That file belongs to another agent; the warning is
harmless.

No subagent tool is bound.

## Cursor

Checked on Cursor CLI 2026.10.01. Cursor reads the Claude Code manifest and
hook from the cloned folder, so every skill is listed and the routing skill
is injected at session start. Whether the hook runs again after compaction
has not been measured. Cursor's plugin hooks fail open, like Devin's.

Cursor loads every folder under `~/.cursor/plugins/local/` and rejects a
symlink there that points outside it, so the library has to be cloned into
that folder.

No subagent tool is bound.

## Adding an agent

If your agent is not here, [Using the skills on another agent](../guides/other-agents.md)
shows what you can set up yourself, and [`CONTRIBUTING.md`](../../CONTRIBUTING.md)
describes what an adapter needs before an agent is listed on this page.
