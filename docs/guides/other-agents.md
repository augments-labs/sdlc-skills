# Using the skills on another agent

Your agent is not in the supported list, but it reads skills. This page
tells you what you can get working on your own, what you lose without an
adapter, and how to ask for proper support.

## What a skill is

Every skill is a directory with a `SKILL.md` file whose YAML frontmatter has
a `name` and a `description`. That is the open Agent Skills format, and any
agent that reads it can load these skills. The
[conformance page](../reference/agent-skills-conformance.md) says how
closely the library follows it.

The skills name no tool, model, or agent. They refer to models by tier
(small, medium, large) and to tools by what they do, such as "the
skill-loading action" or "the user-input action". Your agent supplies the
real ones.

## Step 1: Make the skills visible

Point your agent's skill mechanism at the skill directories. Two layouts
ship in the repository:

- `skills/<phase>/<name>/`, the canonical tree, nested by life-cycle phase.
- `plugins/sdlc-skills/skills/<name>/`, a flat mirror of the same skills.

Some agents only look one level deep for `SKILL.md`. If yours lists nothing
from the canonical tree, point it at the flat mirror.

Check that the agent lists all the skills. The
[catalogue](../reference/skills.md) is the list to compare against.

## Step 2: Hand the agent the routing skill

Visible skills are not enough. Nothing reaches for a skill unless the agent
is told to, and the skill that tells it is `using-sdlc-skills`. On supported
agents the adapter puts that skill's body into the session as it starts, and
again after the agent compacts its context.

What you can do depends on what your agent offers:

- **A session-start hook that can add context.** Run
  `scripts/sh/session-start.sh` from it, if its event and output format
  match what the script already produces; read the script's header to see
  which agents it answers. Otherwise, have the hook print the body of
  `skills/common/using-sdlc-skills/SKILL.md`.
- **An always-on rule or instructions file.** Put one line in it:

  ```text
  Invoke the `using-sdlc-skills` skill before acting.
  ```

  This is how Grok Build and Antigravity work today. It is weaker than
  injecting the body, because it is one more instruction the agent may or
  may not follow, but it works.
- **Neither.** Start each session by asking the agent to invoke
  `using-sdlc-skills`, as Muse Code 1.3.0 users do.

Find out whether your agent re-runs the hook after it compacts its context.
If it does not, expect to ask for the routing skill again late in a long
session.

## What you lose without an adapter

- **Subagent dispatch.** `requesting-code-review`,
  `dispatching-parallel-agents`, and `subagent-driven-development` hand
  work to a fresh agent through a tool the adapter names. Without a
  binding, the skills treat the action as unavailable: the agent tells you
  what it tried to do and asks you once whether to self-review (labelled as
  one), hand the work to someone you name, or leave it pending. It does not
  do the work itself in silence.
- **Model tiers.** A skill that asks for a small, medium, or large model for
  a reviewer has nothing to bind that to. The agent states the tier in the
  prompt and your agent uses whatever it uses.
- **Re-injection after compaction**, as above.

Everything else works: the skills are plain instructions, and the checks
they lean on are your project's own.

## Asking for support

If you want your agent in the supported list, the contributing guide
describes what an adapter is and what has to be shown before an agent is
listed: see [`CONTRIBUTING.md`](../../CONTRIBUTING.md). The short version is
that the skills have to load and a skill has to activate on a representative
request through the agent's own command line, not just be present on disk.
