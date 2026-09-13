# Debugging — Feedback Loop Options

The loop is the engine of debugging: a runnable signal for whether the bug is
present. Prefer deterministic loops. When the phenomenon is inherently
intermittent or production-only, a quantified probabilistic/observability loop
is valid if its sample, uncertainty, safety, and decision threshold are declared
before results.

## Investigation descriptor and ledger

Before a probe or intervention, draft then issue an immutable investigation
descriptor:

- stable investigation and failure-class IDs; exact source/artifact, symptom,
  inputs, environment/topology/time boundary, baseline, and expected behavior;
- frozen loop/judge identity, discovery rule, expected observation, controls,
  evaluator edit authority, and falsification/calibration case;
- data boundary, copy/environment, command/tool identity, mutations/effects/
  resources, pre/post observations, recovery, cleanup, retry, and exact authority;
- evidence data/access/storage/egress controls, integrity, retention/expiry,
  exact cleanup targets/effects/recoverability, cleanup authority, and disposition.

Compute its digest excluding its own identity slot and all later hypotheses,
attempts, outcomes, and conclusions. Any field, fixture, threshold, judge, or
bound input change creates a successor descriptor; never mix its evidence with
the predecessor.

Only the descriptor's trusted action contract grants tool, data, secret,
network, or mutation access.

Calibrate before inference: the frozen loop observes the known failing state and
rejects the good/neighbor control at the intended observation. Keep a stable-ID,
append-only hypothesis/intervention/attempt ledger outside the descriptor. Run
actions through `verification-before-completion`; overlapping effects are sequential unless
proved disjoint. Failure, deadline, cancellation, or lost response stays
`cancellation-requested` until worker, descendants, and effects quiesce. Quarantine
partial/late output and link a retry only after reconciling actual state.

Ranked, tightest first:

1. **A failing unit test** — the bug expressed as an assertion.
2. **A request script** — hit the endpoint, assert the status and body.
3. **A CLI run against a fixture** — feed a saved input, diff the output against a snapshot.
4. **A headless UI script** — drive the interface, assert on the result.
5. **A replayed trace** — capture a real failing request or session and replay it.
6. **A throwaway harness** — a tiny script that calls just the suspect unit with the triggering input.
7. **A property or fuzz loop** — generate inputs until the bug appears; now you have a case.
8. **A bisection harness** — script the good-vs-bad check, then bisect commits (or inputs) to the boundary.
9. **A differential loop** — run the old and new versions side by side on the same input; the diff is the bug.
10. **A bounded observability query** — count a precise failure signature over a
    fixed window and population, with baseline/control and retained raw output.
11. **A production-safe sampled probe** — only with direct authorization,
    redaction, rate/duration/cost limits, perturbation measurement, and a kill
    path.
12. **A human-run script (last resort)** — provide exact commands/actions; the
    human returns raw output and environment identity.

For a probabilistic loop, keep the exact failing cases and report counts/rates
instead of converting “none seen” into “cannot happen.” Use
`probabilistic-evidence.md` for the experiment and artifact contract.

If none is achievable, that itself is the finding: say so, list what you tried,
and ask for what is needed—environment access, a captured artifact, or permission
for bounded instrumentation. Do not proceed without a meaningful loop.
