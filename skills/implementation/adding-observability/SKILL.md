---
name: adding-observability
description: "Instruments a change or a service so its operators can tell whether it works for users and find out why when it does not, through the project's existing logging, metrics, and tracing facility, with an alert on a user-facing symptom. Use when adding logs, metrics, traces, or an alert, or when the user says add observability, add monitoring, instrument this, we have no visibility, or we cannot tell whether it is working. Skip the signals a staged rollout's thresholds read, which rollout-controls owns, and skip reading existing signals to find a cause, which debugging owns."
---

# Adding Observability

Pick the question an operator will ask before picking any signal, emit the
signal through what the project already has, and call nothing instrumented
until someone has seen it arrive. This skill never adds a telemetry library
or vendor on its own, never renames a signal something already reads, and
never decides who gets paged.

## When to use

- A change or a service needs signals so its operators can answer "is it
  working for users?" and "why not?".
- **Skip** the signals a staged rollout's thresholds read:
  `rollout-controls` owns them. A rollout that still cannot answer the two
  questions above comes here for the rest.
- **Skip** finding a cause from signals that already exist: `debugging` owns
  that, and the probes it adds are temporary.

## Step 1: Pick the questions, then the signals

1. Write the user-visible outcome the change exists to produce, and the two
   signals that answer the operator's questions: the success rate and the
   latency where the user feels them. A liveness check, CPU, memory, or
   "function called" answers neither question; add it only when something
   reads it.
2. For "why not?", name what an operator reads next when the success rate
   drops: the error kind by label, the log line with the request's context,
   and the trace across every hop the request takes.
3. Read the project's logging, metrics, and tracing facility, its naming
   convention, its unit convention, and the dashboard or query the operators
   already use. Emit through that, under those names. Add no library and no
   vendor.
4. If the project has no facility, the choice is the user's; ask and end the
   turn, and `clarifying-intent` owns what closes it:

   ```text
   {{project}} has no logging, metrics, or tracing facility. Where should the new signals go?

   1. Structured log lines on the process's standard output, which {{the host or platform}} already collects; counts and durations as fields of those lines
   2. A library or vendor you name: print which

   Recommendation: 1 — {{one sentence}}.
   ```

5. If a staged rollout is asked for, **REQUIRED SUB-SKILL:** invoke
   `rollout-controls` for the switch and the threshold signals, then return
   here for the signals that still lack an operator's question.

## Step 2: Build the signals

1. Give every metric a label set a human can list in advance: outcome, error
   kind, route template, operation. Never a user id, request id, raw URL
   path, email, or error message text: each distinct value is a new series.
2. Initialize every counter the alerts and ratios read to zero for each label
   set that can occur, at startup, so a path that has not failed yet reports
   `0` rather than nothing.
3. Record latency as a histogram whose buckets include every threshold
   someone will alert on. Never an average, and never a summary when
   instances are aggregated.
4. Carry the trace or request id on every log line the request writes, so
   the trace and the log meet. Where the request crosses a queue, a thread
   pool, a scheduled job, or another process, inject the trace context into
   the message or carry it by hand; it does not follow on its own.
5. If the facility samples traces at the start of the request, set it to keep
   errors when it allows that; if it does not, say in the report that error
   traces are sampled away.
6. Log an expected condition (a validation failure, a not-found, a retry
   that will succeed) below error level. Error level is for what an operator
   acts on.
7. No secret, credential, token, request body, header, query string, or
   personal data in a signal's value, label, or log field.

## Step 3: Prove each signal is emitted

1. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for each signal:
   a test that fails when the signal is missing, carries the wrong label, or
   carries a value from the forbidden list above.
2. For each signal the test cannot reach (a dashboard query, a trace across
   a hop, a sampled error), read it in a real environment and record where
   it was seen. A signal nobody has seen is unverified; report it as such.

## Step 4: Alert, then hand off

1. Write each alert on a user-facing symptom (the success rate or latency
   from Step 1), never on a cause, with an owner and the first action the
   owner takes. Whether it pages anyone is the owner's decision; ask, never
   assume.
2. Fire each alert once on purpose (a test environment, a synthetic failure,
   or a lowered threshold restored afterwards) and record that it fired. An
   alert that has never fired is unverified.
3. If an existing metric name, label, or log field must change, every
   dashboard and alert that reads it is a caller. **REQUIRED SUB-SKILL:**
   invoke `deprecating-an-api` for the rename; never rename in place.
4. Report three lines and decide nothing:

   ```text
   Questions: working for users → {{signal}}; why not → {{signals}}
   Signals: {{n}} through {{facility}}, each seen in {{test | environment}}; unverified: {{list | none}}
   Alerts: {{n}}, each with owner and first action; fired on purpose: {{yes | which ones not, and who will}}
   ```

5. Continue the ordinary chain to verification, review, and the branch
   decision unchanged.

## Hard stops

- Adding a telemetry library or vendor the project does not already use
  without the user's answer to the Step 1 question.
- A secret, credential, token, or personal data in any signal's value,
  label, or log field.
- Renaming or removing a metric, label, or log field a dashboard or alert
  reads, outside `deprecating-an-api`.
- Calling a signal or an alert done when nobody has seen it emitted or fired.

## Gotchas

- A counter incremented only on failure has no series until the first
  failure, so a rate or a ratio over it returns no data rather than `0`, and
  an alert on "no data" never fires, or fires on every fresh instance —
  shows when an error-rate alert stays silent through an outage on a path
  that had never failed before.
- A summary's percentiles cannot be aggregated across instances, so a p99
  over a fleet is nonsense; a histogram's buckets are fixed at creation, a
  quantile between two boundaries is an interpolated guess, and changing
  the layout later breaks every query over the old series — shows when a
  300 ms alert on buckets of 250 ms and 500 ms fires on an estimate and
  nobody can say whether 300 ms was crossed.
- A label on a value nobody enumerated (raw path, user id, message text)
  makes one series per value; the store slows or drops the metric, and a
  caller can mint values on purpose. A route must be the template with
  placeholders, never the path — shows when the metric vanishes from the
  dashboard after a crawler visits every id.
- Head sampling decides at the start of the trace, before the error or the
  slow span exists, so it cannot keep every error trace; only a decision
  taken after the trace ends can — shows when the one failing request of the
  day has no trace.
- Trace context travels only where something injects it into a carrier
  (headers, message metadata) and something extracts it on the other side; a
  queue, a thread pool, or a scheduled job starts a new trace unless the
  producer attaches the context to the message and the consumer reads it —
  shows when every consumer trace is a root with no parent.
- Unit conventions differ by facility and both are strict: one wants base
  units in a plural suffix (`_seconds`, `_bytes`, `_total` after the unit);
  another wants the unit in the metric's metadata (`s`, `By`) and not in the
  name. A duration in milliseconds under either breaks the fleet's shared
  queries — shows when `request_latency_ms` sits beside `_seconds` metrics
  and the dashboard's unit axis reads it a thousandfold wrong.

## Common mistakes

- Instrumenting what is easy to reach (the handler's entry, the call count,
  the host's CPU) instead of the user's outcome: start from Step 1's two
  questions and add nothing that answers neither.
- Writing an alert for every metric: an alert without a first action is noise
  the owner silences along with the real ones.
