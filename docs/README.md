# SDLC skills documentation

These pages are for people who install the library and work with an agent
that has it. They explain what the agent will do, what you will see, and
what still depends on you.

If you want to change the library itself, read
[`CONTRIBUTING.md`](../CONTRIBUTING.md) instead. That is where the design
reasons, the checks, and the adapter internals live.

## Where to start

1. Install the library for your agent. The commands are in the
   [README](../README.md#installation); the
   [installing guide](guides/installing.md) adds updating, removing, and
   the notes for each agent.
2. Read [Your first session](guides/first-session.md) to see what changes
   once the library is in place.
3. Pick the guide for what you want to do.

## Guides

Each guide starts from something you want to do and shows what the agent
does along the way, with example prompts.

| Page | What it is for |
| --- | --- |
| [Installing, updating, and removing](guides/installing.md) | The steps for each supported agent, and what each one does with the files |
| [Your first session](guides/first-session.md) | How to check the skills loaded, how to call one by name, and the folder the agent creates in your project |
| [Building a feature](guides/building-a-feature.md) | From the request to a reviewed branch: worktree, failing test first, checks, review |
| [Fixing a bug](guides/fixing-a-bug.md) | How the agent finds the cause before it proposes a fix, and what it asks you for |
| [Reviewing and shipping](guides/reviewing-and-shipping.md) | Verification, independent review, and the choice of what happens to the branch |
| [Planning larger work](guides/planning-larger-work.md) | Briefs, specs, designs, and plans for work that is bigger than one change |
| [When a session goes wrong](guides/when-a-session-goes-wrong.md) | Getting a cited account of what a session did, as a report and a trace page |
| [Setting up for a team](guides/setting-up-for-a-team.md) | What a team writes once in its agent instructions file: checkout, base branch, branch names, local commits, review depth, PR rules |
| [Using the skills on another agent](guides/other-agents.md) | What to do when your agent is not in the supported list |

## Concepts

Short explanations of the ideas behind the library.

| Page | What it explains |
| --- | --- |
| [How the agent finds and loads skills](concepts/how-skills-load.md) | The catalogue, the routing skill, and what happens in a long session |
| [Skills guide, your checks decide](concepts/skills-and-gates.md) | Why the library relies on tests, reviews, and your decisions rather than the agent's confidence |
| [The `.sdlc-skills/` folder](concepts/project-artifacts.md) | What the agent writes in your project, and what to commit |

## Reference

Lookup material.

| Page | What it holds |
| --- | --- |
| [Skill catalogue](reference/skills.md) | Every skill, by phase, with one line on what it does |
| [Supported agents](reference/agents.md) | What each agent gets, how the routing skill reaches it, and its known limits |
| [Agent Skills conformance](reference/agent-skills-conformance.md) | How the library follows the open Agent Skills format, and where it is stricter |
