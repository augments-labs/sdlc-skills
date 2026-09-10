---
name: containing-an-incident
description: "Use the moment a failure is reaching real users — an outage, a broken signup or checkout, a bad deploy, a spiking error rate, data corrupted or exposed, a customer-visible regression. Fires on it's down, customers are getting errors, something broke in production, and this started after the deploy, even if nobody says incident or outage. Skip a failing test, a bug caught in review, or a defect nobody has hit, and skip once impact has stopped."
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

## Step 1: Bound the impact

1. Write three lines from the signal users are hitting, not from source:
   what fails, for whom, since when, how badly.
2. Do not diagnose. Do not open product code.

## Step 2: Pick the lever

1. List what could stop it in minutes, fastest and narrowest first:
   - a feature flag, config value, or kill switch
   - shedding or redirecting traffic, draining an instance, opening a breaker
   - raising or lowering a limit, quota, or concurrency
   - blocking the triggering input, tenant, or job
   - rolling back to the last known-good release — wide, usually needs approval
2. Read the runbook, deploy log, and config for them. Reading is not pulling.
3. Lever not yours to pull (deploy, rollback, production data, customer-facing
   block) → escalate now with the Step 1 lines. That is the containment step.
4. Pull the narrowest lever that works. Cannot state its effect in one
   sentence → do not pull it.

## Step 3: Prove it stopped

1. Read the signal from Step 1 again. Returned to normal → contained.
2. Signal unchanged → not contained. Back to Step 2. The action taken proves
   nothing.
3. Cheap to capture → save a failing example, the logs, or the current
   configuration before a rollback or restart erases it. Seconds, not
   minutes. Never delay containment for evidence.

## Step 4: Record and hand off

1. Fill `assets/containment-record.md`: impact, lever, when pulled, cost
   while it holds, how to reverse, who owns reversal.
2. Report three things and call nothing resolved:

   ```text
   Stopped: {{what the signal shows}}
   Still true: {{the feature is still broken}}
   Cost while it holds: {{what the mitigation costs}}
   ```

3. **REQUIRED SUB-SKILL:** invoke `debugging` for the cause. Once cause and
   containment are known, invoke `post-mortem`. Write both into the record's
   `Still open` lines. Diagnose nothing from this skill.
4. No lever, damage already done, containment destroys the only evidence, or
   the lever helps some users and hurts others → read
   `references/hard-containments.md`.

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
