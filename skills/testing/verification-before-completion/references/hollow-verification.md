# Verification Before Completion — Hollow Verification

A check can pass and still prove nothing. The ways that happens, and how to catch them.

## A gate that was never falsified

New-behavior tests should fail for the missing behavior before implementation.
Preservation gates instead begin green, then detect a deliberate divergence in
an isolated authorized copy with exact effect/recovery controls before complete
candidate/data/effect restoration. A bug reproduction fails on
the before state and passes on the fixed state.

Never undo inherited work or inject a defect into production just to manufacture
red. When direct mutation is unsafe, use a retained known-bad case or controlled
calibration fixture. Without falsification evidence, call the gate uncalibrated
and limit the claim it supports.

## Inherited premises

Before stating a conclusion, list the facts it depends on and mark each: confirmed *this session*, or inherited from earlier or elsewhere. If the conclusion would change should an inherited fact be wrong, re-verify that fact first. Stale string matches and untested assumptions are the usual culprits.

## An instrument that could not see

An empty result, a zero count, or "no errors" says the probe found nothing. It
does not say there was nothing to find.

1. Before citing silence, run the identical probe (same query, filter,
   credentials, host, and configuration) on an input known to hold a hit:
   a planted record, a retained known-bad case, or a real one you can point to.
2. Run that control in the environment the system runs in. A hit on a local
   copy, a test database, or another account says nothing about whether the
   probe can see the population where the system lives.
3. If the control returns nothing, the instrument is blind: the reading is
   inconclusive, not clean. Fix the probe or limit the claim.
4. List the surfaces the claim spans (endpoints, platforms, data partitions,
   log sources). Mark each one the run exercised; every other surface stays
   unverified and is named in the claim.

```text
Wrong: grep for "ERROR" in the service log returned nothing, so no errors.
Right: the same grep on the same host found the planted line "ERROR probe-7f3",
       then returned nothing for the window since deploy; the worker log was
       not searched and stays unverified.
```

## Output you produced yourself

If you ran the command by hand, the log line, file, or row it left shows you
can run the command. It does not show the system ran it. When the claim is that
a scheduler, service, hook, or pipeline acted, cite a trace the system wrote on
its own run: its log entry, its timestamp, its run record. If no such trace
exists, the claim is pending.

## A value the actor reported

A tool's report of its own effect ("3 rows updated", "saved", "applied") is the
actor's account. Read the effect back through a path that does not share the
actor's code: query the rows, open the file, read the live setting. If the
read-back disagrees, record both and treat the claim as failed.
