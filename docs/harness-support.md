# Harness Support

How one skill library runs on several coding agents without putting
harness-specific behavior into the skills.

## One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills use capability tiers and
portable actions; each harness adapter binds those concepts to its own manifest,
tools, and lifecycle events.

| Harness | Adapter | Entry-skill injection | Re-applied after compaction |
| --- | --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | `SessionStart` hook | No — `compact` is excluded from the matcher |
| Codex | `plugins/sdlc-skills/` and `.agents/plugins/marketplace.json` | bundled `SessionStart` hook | No — the injector drops `source=compact` payloads |
| Kimi Code | `.kimi-plugin/plugin.json` | `sessionStart.skill` | No — no `PostCompact` hook is registered |

The Codex plugin manifest carries the skill catalogue but has no session-start
field, so the entry skill arrives through hooks the plugin itself bundles
(`"hooks": "./hooks/hooks.json"`). Bundling matters: the plugin is installed
standalone, so a hooks file at the repository root is outside the plugin root and
Codex never loads it — a repo-local config wires contributors and ships nothing.
Everything the hook touches therefore lives inside the plugin, and
`scripts/sh/sync-codex-plugin-skills.sh` mirrors it in.

**Compaction is not context loss on these harnesses**: loaded skills and session
context are carried across it, so re-injecting the same body after compaction is
redundant cost, and no adapter does it. Claude Code excludes `compact` from its
matcher; Kimi registers no `PostCompact` hook; Codex reports compaction as a
`SessionStart` whose payload source is `compact`, and because its hook cannot
filter by source, the injector itself reads the payload and exits without
output. Do not add compact re-injection back to any adapter.

Two consequences worth knowing before editing either side. The command resolves
the injector through `$PLUGIN_ROOT`, because hooks run with the *session* working
directory, not the plugin's. And the mirror is flat (`skills/<name>/`) where the
canonical tree is by phase (`skills/<phase>/<name>/`), so the injector resolves
the entry skill from both layouts; hard-coding one path ships something that works in
this repository and nowhere anyone installs.

Every adapter injects the **full `using-sdlc-skills` body**, not a pointer to it.
A pointer asks the agent to spend a discretionary tool call loading the entry
skill; the body makes the entry mandate resident instead. `scripts/sh/token-budget.sh`
reports the current context cost by running the injector.

The text is **read from the canonical skill at runtime**, never copied into an
adapter, so editing the skill cannot silently stop shipping.
`tests/run-session-start.sh` asserts the injected context contains the canonical
body verbatim, in each harness's envelope.

Session start is the sole activation mechanism across adapters. No tool,
prompt, or turn-end hooks are registered. The resident entry skill directs the
agent to load applicable skills before any response or action, including
preliminary questions and file checks. This is routing guidance; adopting
projects enforce correctness through their own artifact and promotion gates.

The Claude manifest, Codex mirror, and Kimi skill paths must expose the same
canonical skill set. `scripts/sh/validate-skills.sh` checks that deterministic
packaging contract.

No adapter re-injects after compaction, and if invoked with a `PostCompact`
event name the shared injector exits silently rather than emitting context.

## Dispatch capability

`dispatching-parallel-agents` and `executing-plans` hand work to a cold agent
through "the real callable action". The skills stay portable by never naming it;
each adapter binds it, and each harness decides whether it exists at all.

| Harness | Dispatch action | Notes |
| --- | --- | --- |
| Claude Code | `Agent` tool | Native; no configuration needed |
| Codex | `spawn_agent` / `wait_agent` / `list_agents` / `send_message` / `followup_task` / `interrupt_agent` | Availability depends on the installed build and configuration |
| Kimi Code | `Agent` tool | Bound in `.kimi-plugin/plugin.json` `skillInstructions`, including `subagent_type` and the tier-in-prompt rule |

Availability is a property of the installed build and its configuration, not of
this library, and it changes between versions — some builds gate multi-agent
tools behind a config entry that is off by default. So the skill does not
hardcode a remedy. It requires the agent to treat an uncallable action as **not
dispatched**, and to name both the action it attempted and what this environment
would need to make it callable, rather than stopping mysteriously, narrating a
fan-out it holds no receipts for, or silently collapsing it to sequential work.

Check the harness's own configuration reference for the current form, and verify
by asking the installed CLI what tools it exposes rather than trusting a
second-hand snippet.

## Repository instruction files

`AGENTS.md` and `GEMINI.md` are symlinks to `CLAUDE.md`. A harness that reads
its conventional repository instructions therefore receives the same contributor
rules from one source.

## Using SDLC skills elsewhere

The skills are Markdown invoked by name. On another harness:

1. Expose the canonical skill directories through the harness's normal skill
   mechanism.
2. Run `scripts/sh/session-start.sh` from the harness's session-start event and
   feed its `additionalContext` into the session, so the entry skill arrives as
   resident context rather than as an errand the agent can skip. Re-run it on
   whatever event the harness fires when context is genuinely lost (start,
   resume, clear) — not after compaction, which carries context forward.
3. Bind skill actions to the harness's real tools.
4. Exercise one representative activation through the real installed adapter
   before claiming support.

If the harness discards resident context at compaction — unlike the supported
harnesses, which carry it forward — state that behavior explicitly before wiring
any re-injection. Do not simulate support with copied transcript fixtures.

## What to test

Different claims need different evidence:

- **Packaging and structure:** deterministic validation of manifests, mirror
  equality, reference paths, frontmatter, and token budgets. These checks belong
  in CI.
- **Deterministic adapter scripts:** focused offline tests for meaningful parsing
  or hook branches. Keep the script small enough that its test does not become a
  second implementation.
- **Discovery and activation:** a thin live smoke through the real harness.
  Run the relevant opening when a trigger or adapter changes and before a
  release; report authentication, provider, or network failures as inconclusive
  rather than routing failures.
- **Skill behavior:** retain a behavioral regression only for a failure actually
  observed and a verdict that can be checked mechanically. Run it manually and
  report repeated results honestly.

A full skill-by-harness behavioral matrix is neither deterministic nor a useful
default. It consumes provider time, produces noisy results, and shifts maintenance
toward the evaluator instead of the skills.

The adapter contract is documented in
[`tests/harnesses/README.md`](../tests/harnesses/README.md). What consumes it
splits by whether the correct answer is known in advance: gates in
[`tests/README.md`](../tests/README.md), measurements in
[`tests/optimizing/README.md`](../tests/optimizing/README.md).

## Adding an adapter

1. Point the manifest at the canonical skills; do not fork their content.
2. Extend structural validation so missing, extra, or divergent skills fail.
3. Add the smallest install/activation smoke that drives the real CLI.
4. Add an offline test only for deterministic adapter logic introduced by the
   integration.
5. Document the adapter's current lifecycle and support boundaries. Keep run
   transcripts and evaluation results in the test workflow, not this website
   documentation.
