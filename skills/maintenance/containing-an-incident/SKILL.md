---
name: containing-an-incident
description: "Contains a failure that is reaching real users before diagnosing it. Use when there is an outage, a broken signup or checkout, a bad deploy, a spiking error rate, data corrupted or exposed, or a customer-visible regression, or when the user says it's down, customers are getting errors, something broke in production, or this started after the deploy. Skip a failing test, a bug caught in review, or a defect nobody has hit, and skip once impact has stopped."
---

# Containing an Incident

Stop the impact first and prove it stopped from the outside; leave the cause
to `debugging`.

## When to use

- A failure is reaching users right now — requests erroring, a feature broken,
  data being corrupted or exposed, a queue backing up, a limit or budget being
  burned.
- **Skip** when nothing is reaching users: a red test, a bug found in review, a
  defect nobody has hit. That is `debugging`.
- **Skip** once impact has stopped: an unknown technical cause goes to
  `debugging`; a known cause and why safeguards missed it go to
  `post-mortem`.
- If you are not sure whether users are affected, answering that *is* step
  1, and it is fast. Do not resolve the doubt by starting to read code.

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
   - rolling back to the last known-good release — wide, needs approval
2. Read the runbook, deploy log, and config for them. Reading is not pulling.
3. A lever is yours only when the user, the incident owner, or a runbook the
   project designates gives you scoped authority for that lever on that target;
   holding credentials or access grants nothing. If a lever is not yours,
   escalate now with the Step 1 lines; that is the containment step. This
   includes every deploy, rollback, production-data change, and customer-facing
   block such as a tenant block, whatever access you hold.
4. Pull the narrowest lever that works. If its effect cannot be stated in one
   sentence, do not pull it. Open `assets/containment-record.md` when you pull
   it, with the impact, the lever, and when it was pulled.

   Checkout fails for every user since a deploy that, the deploy log shows,
   put a new discount-code path behind a flag. Blocking the tenant that first
   reported it is the narrowest scope but does not work, since every user is
   failing; a rollback works but is wide. Turning the flag off is the
   narrowest lever that works, and its effect fits one sentence: checkout
   runs without discount codes. Pull it if Step 2.3 makes it yours.

5. If no safe authorized lever remains, or a lever risks evidence or other
   users, read `references/hard-containments.md` before anything else. Record
   the exhausted options, residual impact, and escalation; do not keep
   selecting the same lever.

## Step 3: Prove it stopped

1. Read the signal from Step 1 again. If it has returned to normal, the
   impact is contained.
2. If the signal is unchanged, the impact is not contained. Record the
   attempted lever and result; return to Step 2 only for a different
   justified intervention. If the options are exhausted, take its
   hard-containment fallback. The action taken proves nothing.
3. If capturing is cheap, and the user, the incident owner, or a designated
   runbook currently authorizes keeping that data, redact credentials and
   personal data, then save a failing example, the logs, or the current
   configuration to `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/` before
   a rollback or restart erases it. Seconds, not minutes. Never delay
   containment for evidence.
   If there is no such authority, keep nothing, and name what was lost in
   the record.

## Step 4: Record and hand off

1. Complete the containment record from Step 2.4: cost while it holds, how to
   reverse, who owns reversal. Open `assets/containment-record.md` here when
   no lever was pulled, because Step 2.3 escalated or Step 2.5 exhausted the
   options, and put the escalation in its lever table.
2. Report three things and call nothing resolved:

   ```text
   Stopped: {{what the signal shows}}
   Still true: {{the feature is still broken}}
   Cost while it holds: {{what the mitigation costs}}
   ```

3. **REQUIRED SUB-SKILL:** invoke `debugging` for the cause. Once cause and
   containment are known, invoke `post-mortem`. Write both into the record's
   `Still open` lines. Diagnose nothing from this skill.
4. Under the hard-containment fallback, pass residual impact, attempted
   levers, and incident/escalation owner to `debugging`. New or worsened
   impact or a newly available lever reopens containment; unchanged residual
   impact does not.

## Gotchas

- Access that can pull a lever is not authority to pull it: an unauthorized
  rollback or tenant block becomes a second incident.

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

Without a recorded hard-containment fallback, stop and go to step 2 for these:

- You are reading source code and users are still failing.
- You know which flag or release would stop it, and it is still not pulled.
- Your first edit is in the product code.
- You are writing a reproduction for a failure that is reproducing itself in
  production.
- You are explaining the cause in your reply while the impact is ongoing.
- The mitigation is in place and nothing records that it is.
