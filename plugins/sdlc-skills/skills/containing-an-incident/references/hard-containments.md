# Hard containments

Read when selecting or proving a containment lever does not resolve cleanly. Each shape below changes
*what containment means*, not whether it comes first.

## No lever exists

You looked, and nothing stops this in minutes. Before accepting that:

- **Widen the definition.** Containment does not have to be technical. Turning
  off the campaign that drives the traffic, pausing the job that produces the bad
  records, telling support to stop advising the broken path, or putting a banner
  on the page all reduce impact.
- **Reduce rather than stop.** Halving the rollout, throttling to a rate the
  system survives, or degrading to a slower correct path are containment. Partial
  containment beats none and buys the time the fix needs.
- **If it is genuinely nothing**, that is itself the finding, and it is urgent:
  say so explicitly rather than letting silence imply you are on it. Then
  diagnose — but with the impact statement published, and with somebody who can
  authorize a bigger lever aware.

The failure mode here is quiet: an agent that finds no obvious lever slides into
debugging without ever saying that the impact is uncontained.

## The damage is already done

Corrupted records, wrong charges, data sent to the wrong recipient, a leaked
credential. Containment splits into two questions, and only the first is urgent:

1. **Stop it growing.** Stop the writes, revoke the credential, halt the sends,
   pause the job. This is the ordinary procedure and it still comes first.
2. **Do not repair yet.** A repair written before the cause is understood
   usually widens the damage — it runs on the same wrong assumption that caused
   it. Bound the damage instead: which records, which window, which users.

Never delete or overwrite the damaged state to "clean up". It is the evidence,
it is what the repair will be derived from, and its extent is often the only
proof of what happened.

## Containment would destroy the evidence

A restart clears the memory state, a rollback replaces the running code, a
truncation drops the poison message. Resolve it in this order:

1. Contain anyway if the capture would take more than seconds.
2. Capture what is cheap first, under Step 3.3's authority, redaction, and
   location — a copy of the failing input, the current config, a snapshot of
   the queue head, the last N log lines.
3. Say plainly in the record what was lost, so the investigation does not
   quietly assume it exists.

Ongoing user impact outranks a better investigation. An investigation with a gap
is recoverable; the minutes are not.

## The lever helps some users and hurts others

Rolling back fixes checkout and breaks the feature shipped alongside it.
Blocking the tenant that triggers the bug takes that tenant offline entirely.

- State both sides in one sentence each, then choose the smaller total harm —
  and record that you chose it, with the trade named.
- Prefer a lever that can be scoped: one tenant, one region, one plan, one route.
- When the harms are genuinely comparable, this is not your call alone. It is an
  authority question: escalate with both sides
  stated, and keep looking for a narrower lever while you wait.

## You cannot tell whether it is contained

The signal is noisy, delayed, or aggregated, and the graph has not moved yet.

- Find a faster proxy: one real request through the affected path, one affected
  account checked directly, one queue depth read.
- Distinguish "no evidence it worked" from "evidence it did not". Waiting one
  reporting interval is reasonable; assuming success is not.
- If the lever's effect cannot be observed at all, treat it as unpulled, and say
  so — an unverifiable mitigation is a guess wearing a timestamp.

## It keeps coming back

The lever holds, then the impact returns — a flag re-enabled by a deploy, a
rollback overwritten by the next release, a limit reset by autoscaling.

Containment has to survive the systems that fight it: pin the flag in the source
of truth, block the deploy pipeline, or hold the release. Otherwise you are not
contained, you are between recurrences — and the containment record is what
tells the next person why the flag must stay off.
