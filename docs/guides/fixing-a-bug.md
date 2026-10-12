# Fixing a bug

Something is broken and you want it fixed. The library's answer is to find
the cause first and fix second, because a patch applied to a symptom is the
fix that comes back next week.

Example requests:

```text
Login returns a 500 after the token refresh. Find out why.
```

```text
The nightly export test is flaky. It fails about one run in five.
```

```text
Why is the cache returning stale entries?
```

Each of these loads `debugging`.

## If users are affected right now

Before anything else, the agent checks whether the failure is reaching real
users at this moment. If it is, it switches to `containing-an-incident`
first: stop the damage with the safest available lever (a rollback, a feature
flag, a redirect), record what was done and what impact remains, and only
then come back to diagnosis. Say so in your request if you already know:

```text
Checkout is failing for customers right now. Contain it first.
```

## What the agent does

### It reproduces the bug before it forms a theory

The agent's first job is a runnable signal: a command that shows the bug and
would show it fixed. For a deterministic bug that is a reproduction in three
lines (symptom, command, expected versus observed). For an intermittent or
production-only bug it writes down what it observed, what was reported, and
how it will measure the failure before it runs the first probe.

If no meaningful reproduction is possible, the agent stops and tells you
what it tried and what would unblock it. It does not start guessing.

### It tests hypotheses instead of trying fixes

With a reproduction in hand, the agent lists three to five causes the
evidence supports and records them in a small ledger under
`.sdlc-skills/evidence/`. Each one gets a prediction and a probe. It then
controls the suspected factor and watches for the predicted effect, and it
checks that the competing hypotheses fail their own predictions.

A correlation, a quiet interval in the logs, or "the logs look fine" is not
accepted as a cause.

### It stops after three failed fixes

The agent counts fixes it has applied to one kind of failure. After three
that miss the mark, it stops rather than trying a fourth. It goes back to the
reproduction, the causal model, and the assumptions, and either updates the
model or reports to you with the ledger. This is the circuit breaker that
stops a session from thrashing.

### It fixes the way it builds

Once a cause survives, a code fix goes through `test-driven-development`:
the reproduction becomes the regression test, it fails before the fix and
passes after. `yagni` keeps the fix to what the cause requires. If the fix is
not code (a configuration, a permission, a data correction), the agent
treats it as its own controlled action and asks for the authority it needs.

Before saying "fixed", the agent reruns the reproduction against the
original state, the fixed state, and a control, and reads the raw output
through `verification-before-completion`.

## What the agent will ask you for

- **A reproduction it cannot build alone.** Inputs, timing, an environment
  difference, access to a log.
- **Permission to probe production.** The agent never reads production
  state or adds instrumentation there without your say-so, and it keeps
  sensitive values out of what it records.
- **Which decisions are yours.** A data correction or an infrastructure
  change is proposed, not applied.

## Diagnosis only

If you want the cause and not the fix, say so:

```text
Find the cause of the stale cache entries. Don't fix it yet.
```

The agent reports the cause and its evidence and leaves the correction
pending.

## Intermittent bugs

A bug that fails one run in five cannot be called fixed by one green run.
The agent decides in advance how many runs it needs and what failure rate
it will accept, runs that sample, and reports the numbers. Expect this to
take longer than a deterministic fix, and expect the agent to say what is
still uncertain.

## Related guides

- The bug was introduced by an agent session, and you want to know how:
  [When a session goes wrong](when-a-session-goes-wrong.md).
- The failure got past your safeguards and you want to know why:
  ask for a post-mortem, which loads `post-mortem`.
- The fix is done and you want it shipped:
  [Reviewing and shipping](reviewing-and-shipping.md).
