# Your first session

Once the library is installed, sessions start a little differently. This
page shows what to expect, how to check that the skills are loaded, and what
the agent will create in your project.

## What happens when a session starts

On most agents, the plugin puts a short routing skill called
`using-sdlc-skills` into the session as it starts. That skill tells the
agent to look through the catalogue and load the skills that match what you
asked for, before it answers or touches anything.

Three agents work differently:

- **Grok Build** reads a one-line rules file you created at install time,
  which asks the agent to invoke `using-sdlc-skills` first.
- **Antigravity** ships the same kind of rule inside the plugin, so you do
  not have to create it.
- **Muse Code 1.3.0** gets the skills and nothing else. Start each session by
  asking the agent to invoke `using-sdlc-skills`.

[Supported agents](../reference/agents.md) lists this for every agent.

## Check that it works

Start a new session in a project and ask for something that should trigger a
skill:

```text
Fix the failing login test
```

```text
Let's plan the export feature
```

The agent should say which skill it is using before it starts work. For the
first prompt that is `debugging` or `test-driven-development`; for the
second, one of the planning skills, or `clarifying-intent` if the request
leaves too much open.

If the agent starts working without naming a skill, ask it directly:

```text
Invoke the using-sdlc-skills skill and start again.
```

If that does not help either, check the notes for your agent in
[Supported agents](../reference/agents.md) and make sure the install step
completed.

## Calling a skill by name

You do not have to call skills by name; the routing skill picks them from
your request. You can, though. Every skill is addressed as
`sdlc-skills:<name>`, for example:

```text
Use sdlc-skills:mapping-the-codebase on the payments module before we change it.
```

The [skill catalogue](../reference/skills.md) lists every name.

## The questions the agent asks

Several skills stop and ask you something before they go on: which branch to
start from, whether the agent may commit as it works, what to do with a
finished branch, which of several transcripts to diagnose. The skills ask one
question at a time and wait for a direct answer.

Two things follow from that:

- "Looks good" or a comment on the options does not count as an answer. The
  agent re-asks until it has one.
- Telling the agent "don't ask me questions" does not let it answer those
  questions for you. It still stops at a decision that is yours.

## The folder the agent creates

The first time a skill needs to write a brief, a plan, or a record of a
check, the agent creates a `.sdlc-skills/` folder at the root of your
project. Briefs, specs, designs, plans, and post-mortems go there, and so do
the records of what was run and what was decided.

The folder is laid out so that you can commit the useful parts and ignore the
rest, or ignore the whole folder if your project keeps planning out of the
repository. [The `.sdlc-skills/` folder](../concepts/project-artifacts.md)
describes what goes where.

## Long sessions

When a session runs long, the agent compacts its context: the transcript is
replaced by a summary. On several agents the plugin supplies the routing skill
again at that moment, so the agent keeps routing after compaction. Where the
agent offers no way to do that, the routing skill is gone from the context
once compaction happens.

If the agent seems to have stopped reaching for skills late in a session,
ask it to invoke `using-sdlc-skills` again. [How the agent finds and loads
skills](../concepts/how-skills-load.md) explains the mechanism.
