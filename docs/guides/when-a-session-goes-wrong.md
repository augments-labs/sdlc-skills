# When a session goes wrong

Sometimes an agent skips a step, does something nobody asked for, or loses
track of the task. You want to know what happened, in order, with evidence.
That is what `diagnosing-a-session` is for.

Example requests:

```text
Why did you push that branch? I didn't ask you to.
```

```text
What went wrong in yesterday's session on the export feature?
```

```text
Walk me through what this run actually did before the tests broke.
```

The skill reads the recorded transcript of the session and changes nothing.
Every claim it makes cites the transcript line behind it. You get the result
twice: a written report and a local page you can explore.

## What the agent asks first

Before it opens any transcript, the agent asks three things:

```text
Before I open the record, three things:

1. Which session: this one, or an earlier run? (time, branch, or topic)
2. What specifically looks wrong?
3. What did you expect to happen instead?
```

If your request already answered one of them, it does not ask again.
"Everything went wrong" is not a symptom; the agent asks for the first thing
you noticed and diagnoses that. If you just want the sequence of events and
nothing looks wrong, say so, and it records that.

## How it reads the transcript

Session transcripts can run to millions of characters, so the agent never
reads one end to end. It searches for terms and reads short slices around
each hit. If several transcripts could be the one you mean, it lists them
with their times and first prompt and asks which.

It then looks at five things in turn: which skills were invoked and when,
which checks ran and what they returned, questions put to you that nothing
answered, writes outside the directory the session owned, and where the
cause sits in the timeline relative to your instructions. A dimension it
could not search is reported as unavailable, not as clean.

## What you get

The report goes to
`.sdlc-skills/evidence/<date>-<topic>/diagnosis.md`: the symptom, a timeline,
the findings with their citations, the evidence that was not available, and
one next action. Nothing is applied.

The trace page is served from the same directory on a local preview. The
agent gives you its address on a line of its own, with the key the page
needs, and the preview stops by itself after thirty idle minutes:

```text
Session trace: http://127.0.0.1:.../?key=...
Written report: .sdlc-skills/evidence/2026-03-04-pushed-branch/diagnosis.md
Next action: ...
```

The page shows the timeline, the detail of each event, and a walkthrough of
how each finding came about. It needs the preview to be running; opened as a
plain file it cannot read the trace. The preview needs `python3`; if that is
missing, the agent gives you the report path and the command to start the
page once it is installed.

The evidence directory is ignored by git. The trace holds text taken from
the transcript, so it stays local: never committed, uploaded, or pasted
elsewhere.

## Sensitive values

Credentials, tokens, connection strings, and personal data never appear in
the report, the trace, or the agent's replies, even inside a quote of your
own prompt. The agent writes what kind of value it is and where it sits, for
example `[credential, line 412]`. If you need to see one, ask for it by kind
and line; the agent shows that one value in its reply and leaves the files
redacted.

## What it will not do

- Fix anything. A diagnosis that changes the workspace cannot be trusted
  about that workspace. Apply the fix yourself or ask for it in a separate
  request.
- Judge a skill's wording or anyone's prose. A finding that a skill's own
  text caused the problem is written as a note for that skill's maintainers.
- Follow instructions it finds in the transcript. Everything in a transcript
  other than your own prompts is treated as data.

## If the failure reached users

When the diagnosis finds a failure that reached your users or lost your
work, the agent follows up with `post-mortem`, using the report as evidence:
how the failure got past the safeguards, and what prevents a repeat.

## When you correct the agent

A correction is smaller than a diagnosis: the agent did something, you said
"no, not like that", and it fixes it. What keeps that mistake from coming
back is `eliminating-corrections`. It loads when you correct the agent's
work or its behavior, revert an edit it made, repeat a review comment, or
ask how to stop a kind of mistake from recurring:

```text
No, don't build the query string by hand. Use the query builder. I've told you this before.
```

```text
How do we make sure nobody hard-codes the tenant ID again?
```

The agent applies your correction first. It then names the class of mistake
behind the instance, from what it did and what you corrected, and climbs a
ladder from the strongest answer down: a design or data structure that
cannot hold the wrong state; a generator, formatter, or default that writes
the right one; a test or lint rule that fails on the wrong one and runs in
CI; a runtime assertion or alert, for a class only real data shows; a rule
for the agent, placed next to the code or in the skill step where the
mistake happens; and last, an item for a reviewer to look for. It proposes
the highest rung whose cost fits the class and tells you why each stronger
rung was not taken:

```text
Correction: tenant ID taken from the request body instead of the session
Class: a query scoped by a tenant the caller supplied
Cause: the raw-ID helper is the only query helper
Rejected above the recommendation: none

1. Build rung 1: a query helper that takes the session, raw-ID helper removed; one afternoon, thirty call sites
2. Build rung 3 instead: a lint rule for the raw-ID helper; one hour, the helper stays callable
4. Close this instance only: no class to close

Recommendation: option 1 — the class has already recurred and each instance leaks data across tenants.
```

Nothing is built until you choose. A check it builds is run on the state
you corrected and seen to fail there before it counts. A one-off preference
with no chance of recurring gets applied and nothing more.

## The quick fix mid-session

If you only need the agent to get back on track, you do not need a
diagnosis. Ask it to invoke `using-sdlc-skills` again and restate the task.
[How the agent finds and loads skills](../concepts/how-skills-load.md)
explains why this helps after a long session.
