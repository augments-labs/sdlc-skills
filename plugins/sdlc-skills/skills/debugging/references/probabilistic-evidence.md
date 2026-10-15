# Probabilistic and production debugging evidence

Use when a deterministic local reproduction is not yet possible.

## Pre-register the loop

- **Failure signal:** `{{exact event/error/invariant violation}}`
- **Population/environment:** `{{requests/jobs/nodes/version/topology}}`
- **Baseline window/trials:** `{{duration or N}}`
- **Baseline failures/rate/distribution:** `{{raw count and denominator}}`
- **Control/comparison:** `{{unchanged cohort/artifact/environment}}`
- **Success/failure/inconclusive threshold:** `{{decided before observation}}`
- **Uncertainty:** `{{interval, margin, or explicit sample limitation}}`
- **Stop/abort conditions:** `{{safety, cost, privacy, perturbation}}`

Use enough trials to distinguish the proposed effect from normal variation.
Report the raw numerator and denominator; a rounded percentage hides sparse
evidence.

## Production authorization and safety

Before any production probe, obtain direct authorization for:

- exact environment, query/probe, actor, time window, and affected population;
- read/write behavior and least-privilege access;
- data fields collected and redaction performed before retention;
- sampling rate, latency/resource/cost budget, and maximum duration;
- expected perturbation, control measurement, and kill switch;
- artifact location, access/storage/egress authority, retention expiry, exact
  cleanup targets/effects/recoverability, cleanup authority, and disposition.

Prefer existing telemetry and read-only queries. Timing-sensitive bugs can vanish
under instrumentation; compare instrumented and control cohorts and measure
overhead. Never log secrets, raw credentials, unnecessary personal data, or full
payloads merely because the issue is urgent.

## Replay artifacts

Retain the smallest sanitized artifact that reproduces the failure: input,
ordering/timing trace, seed, topology/config identity, relevant logs, and source
revision. Give it an immutable digest and access/retention authority. Preserve
the original raw artifact only when authorized; derive a redacted replay, prove
the redaction still reproduces, and leave cleanup pending without exact authority.

## Causal and fix comparison

Keep hypothesis and fix ledgers separate:

| ID | Kind | Prediction/criterion | Probe/change | Trials/window | Raw result | Confidence/status |
| --- | --- | --- | --- | --- | --- | --- |
| `H1` | hypothesis | `{{prediction}}` | `{{probe}}` | `{{N/time}}` | `{{counts/artifact}}` | `supported/killed/inconclusive` |
| `F1` | fix attempt | `{{registered improvement}}` | `{{exact candidate}}` | `{{N/time}}` | `{{counts/artifact}}` | `meets/fails/inconclusive` |

Compare baseline, control, and fixed candidate under comparable conditions. Zero
observed failures supports only the registered sample and uncertainty. It is not
proof of impossibility.
