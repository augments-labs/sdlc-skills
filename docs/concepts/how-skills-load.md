# How the agent finds and loads skills

You install the library once and the agent picks the skills that fit the
task. This page explains how that choice is made, what the routing skill
does, and what happens in a long session.

## The catalogue

The agent sees the name and a short description of every skill. A
description says when the skill applies and where it stops, so the agent can
tell it apart from its neighbours. The body of a skill, with the procedure
and the questions it asks you, is loaded only when the skill is used.

A skill gets loaded in one of three ways:

- Its description matches what you asked for.
- You ask for it by name, as `sdlc-skills:<name>`.
- A skill that is already running hands off to it.

The third way is why a skill late in a task does not have to match your
first message. `debugging` hands off to `test-driven-development` for the
fix; `test-driven-development` hands off to `verification-before-completion`
before it calls anything done; that hands off to the review and then to the
branch choice. Each skill names the next one.

## The routing skill

`using-sdlc-skills` is the skill that starts the chain. On most agents the
adapter puts its whole body into the session as it starts, so the agent does
not have to remember to load it. It tells the agent to load every skill that
might apply before it answers or acts, to say which skill it is using and
why, and to check again whenever the state of the work changes: a phase
ends, a decision comes back, feedback arrives.

The routing skill gives starting points, not a fixed sequence. Once a skill
is loaded, that skill decides what happens next, and the agent sets a skill
aside only when the skill's own scope or skip conditions say it does not
fit. The agent is not meant to decide "this task is too simple for process"
on its own; each skill says how small it scales.

The routing body is kept to about 700 words, because every session loads all
of it.

## Long sessions and compaction

When a session runs long, the agent compacts its context: the transcript is
replaced by a summary. Text that was put into the session at its start is
not carried over, so the routing skill would be gone after compaction.

On agents that expose that moment to a plugin, the adapter supplies the
routing skill again at that moment, and routing continues. On agents that
offer no such moment, it is gone until you ask for it again.
[Supported agents](../reference/agents.md) says which is which.

The adapters do nothing else. They register no hook on tool calls, on your
prompts, or at the end of a turn. If the agent reaches for a skill, it is
because the routing skill was in context and the agent followed it.

## What loading does not prove

An instruction in context makes an agent more likely to do something. It
does not prove that the agent read the skill, that it followed the
procedure, or that the result is right. Those are three separate things, and
only the last one is what you care about.

That is why the skills lean on checks outside the agent: your tests, your
reviews, your decisions. [Skills guide, your checks decide](skills-and-gates.md)
explains that side.
