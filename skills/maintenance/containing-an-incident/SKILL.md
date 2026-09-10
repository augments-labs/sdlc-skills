---
name: containing-an-incident
description: "Use this skill the moment a failure is reaching real users — an outage, a broken signup or checkout, a bad deploy, a spiking error rate, data being corrupted or exposed, a customer-visible regression. Fires on it's down, customers are getting errors, something broke in production, and this started after the deploy, even when nobody says incident, outage, or severity. Skip when nothing is reaching users — a failing test, a bug caught in review, a defect nobody has hit. Skip once impact has stopped and the question is why the safeguards missed it; that is post-mortem."
---

# Containing an Incident

Stop the impact first and prove it stopped from the outside; leave the cause
to `debugging`. Every minute spent finding the cause while users are failing is
a minute you chose to spend.

## When to use

- A failure is reaching users right now — requests erroring, a feature broken,
  data being corrupted or exposed, a queue backing up, a limit or budget being
  burned.
- **Skip** when nothing is reaching users: a red test, a bug found in review, a
  defect nobody has hit. That is `debugging`.
- **Skip** once impact has stopped and the open question is why the safeguards
  missed it. That is `post-mortem`.
- Not sure whether users are affected? Answering that *is* step 1, and it is
  fast. Do not resolve the doubt by starting to read code.

## Procedure

1. **Bound the impact before you explain it.** What is failing, for whom, since
   when, and how badly — read from the signal users are actually hitting, not
   from the source. Three lines is enough. You are not diagnosing yet; you are
   sizing the decision that comes next.

2. **Inventory the levers, not the causes.** What could stop this in the next few
   minutes? Fastest and narrowest first:
   - a feature flag, config value, or kill switch — seconds, narrow, reversible
   - shedding or redirecting traffic, draining an instance, opening a breaker
   - raising or lowering a limit, quota, or concurrency
   - blocking the input, tenant, or job that triggers it
   - rolling back to the last known-good release — minutes, wide, usually needs
     approval

   The runbook, the deploy log, and the config are where these live. Reading
   them is not pulling them.

3. **Check what you are allowed to do.** A deploy, a rollback, a production data
   change, or a customer-facing block may not be yours to make. When it is not,
   **escalating is the containment step** — it starts now, carrying the impact
   statement from step 1, not after you have found the cause.

4. **Pull the narrowest lever that stops the impact.** Prefer the smallest blast
   radius that actually works over the one that feels most thorough. Never pull a
   lever whose effect you cannot state in one sentence.

5. **Prove it stopped, from the outside.** Containment is proved by the signal
   that showed the impact returning to normal — the error rate, the failing
   request, the affected user's path. It is never proved by the fact that you
   took the action. If the signal has not moved, you have not contained it: back
   to step 2.

6. **Preserve what the fix will need, if it is cheap.** A rollback or a restart
   can erase the state that explains the failure. Capture a failing example, the
   relevant logs, or the current configuration before it disappears — in seconds,
   not minutes. Never delay containment to collect evidence while users are
   failing.

7. **Write down what you changed and how to undo it.** A flag left off, a limit
   lowered, an instance drained is live debt that outlives your session. Fill
   `assets/containment-record.md`: the impact, the lever, when it was pulled,
   what it costs while it holds, what reversing it takes, and who owns that.
   Unrecorded mitigation becomes a permanent mystery.

8. **Report three things, and call nothing resolved:** what stopped, what is
   still true — the feature is still broken — and what the mitigation costs
   while it stays in place. Containment closes nothing.

9. **REQUIRED — with the impact stopped, invoke `debugging`** for the cause,
   and once cause and containment are known, invoke `post-mortem` for why it
   escaped. Fill the record's `Still open` lines with both handoffs. Do not
   diagnose from this skill; both are cheaper once the pressure is off.

When none of this fits cleanly — no lever exists, the damage is already done,
containment would destroy the only evidence, or the lever helps some users and
hurts others — read `references/hard-containments.md`.

## When you are tempted to skip it

| The thought | The reality |
| --- | --- |
| "Five more minutes and I'll have the real fix" | Five minutes of certainty is five minutes of users failing. The lever costs seconds and reverses. |
| "I found the cause — a proper fix beats a flag" | A correct fix still has to be reviewed, tested, and shipped. The flag is live now. |
| "I read the runbook, so I know the lever is there" | Reading a lever is not pulling it. |
| "Rolling back drops the other changes in that release" | Then use a narrower lever. Blast radius is a reason to choose better, not a reason to do nothing. |
| "The tests are green, so it can't be that bad" | The suite covers what someone thought of. The users are the evidence. |
| "I don't have deploy access" | Then escalating is the containment step, and it starts now. |
| "Flipping the flag just hides the bug" | It hides it from users. It stays visible in the branch, the tests, and the record. |
| "It's been broken for an hour already" | Every minute from now is one you chose. |
| "It only affects some requests" | Then contain for those. Partial impact is impact. |
| "Containment worked, so we're done" | The mitigation is load-bearing and the feature is still broken. |

## Red flags

Each of these means stop and go to step 2:

- You are reading source code and users are still failing.
- You know which flag or release would stop it, and it is still not pulled.
- Your first edit is in the product code.
- You are writing a reproduction for a failure that is reproducing itself in
  production.
- You are explaining the cause in your reply while the impact is ongoing.
- The mitigation is in place and nothing records that it is.

## Common mistakes

- Treating the runbook as background reading rather than a menu of actions.
- Reaching for the widest lever available — a full rollback where a flag would
  have done.
- Verifying containment by the action taken instead of by the signal.
- Waiting to be sure of the cause first. Certainty is not the goal here; the
  impact stopping is.
- Calling the incident resolved because the bleeding stopped.
