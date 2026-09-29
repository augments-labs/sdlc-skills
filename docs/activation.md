# Activation: routing and enforcement

Two separate things have to go right. The agent has to reach the skill that
applies, and the work it produces has to pass the project's checks. This page
explains how the first one works, what it cannot guarantee, and why the second
one is what decides the outcome.

## How the agent finds a skill

The agent sees the name and description of every skill in the catalogue. A
description says when the skill applies and where it stops, so the agent can
tell it apart from its neighbors. The body is loaded afterwards and holds the
procedure, the preconditions, the conditions for skipping, and the skill that
comes next.

A skill is invoked in one of three ways:

- Its description matches the current situation.
- The user asks for it by name.
- A skill that is already loaded hands off to it.

The third way means a skill later in a task does not have to match what the
user first asked for. The skill before it names it.

## The router

`using-sdlc-skills` is the routing skill. It is in context from the start of
every session. It tells the agent to load every skill that might apply before
it acts, and to check again whenever the state of the work changes: a phase
ends, a decision comes back, feedback arrives.

The router gives examples of where to start. Once a skill is loaded, that
skill decides what happens next. A body that is already in context and still
current is reused without being read again. A skill is set aside only when its
own scope or skip conditions show that it does not fit.

Some assessments cannot be made from the opening message alone. For a
high-risk transformation, `migration-strategy` classifies the work and sets
the conditions that must hold before it starts. A general classifier reading
the first message cannot stand in for that assessment.

The router body stays within 700 words, because every session loads all of it.

## Instructions do not enforce anything

Each adapter puts the full router body into the session context, so the agent
does not need a separate step to load it. That is all the adapters do. They
register no hook on tool calls, on prompts, or at the end of a turn.

Compaction needs special care. When a long session is compacted, the
transcript is replaced by a summary, and text that was injected at session
start is not carried into the replacement. The adapters therefore supply the
router again after compaction, on every agent that exposes that moment. Some
agents also offer a hook that only reports that compaction happened. Its
output never enters the new context, so it cannot carry the router, and the
adapters leave it unregistered. [`harness-support.md`](harness-support.md) has
the details for each agent.

Instructions in context influence an agent. They do not prove that a skill was
loaded, or that its procedure was followed. These are three separate
observations:

1. The agent read the skill body.
2. The agent followed it.
3. The result was acceptable.

Watching a skill activate once describes one run, on one agent, under one set
of conditions.

## Gates decide the result

Tests, compilers, static analysis, reviews, and release criteria inspect the
work itself. The project that adopts this library decides which checks apply,
ties them to specific versions of the work, and wires them into CI, protected
branches, and release controls.

The commands, thresholds, environments, and responses to failure belong to
that project. This library ships no universal CI template.

Passing a check supports the claims that check covers. A green result from an
incomplete check says nothing about a requirement nobody tested. Keep raw
failures, missing evidence, and open questions visible.

Two kinds of check are easy to confuse. Structural checks confirm that
packaging and scripts are in order. Behavioral tests observe what an agent
does in a sample of runs. Neither replaces the other.
[`testing.md`](testing.md) covers how to read the checks in this repository.
