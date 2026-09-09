# Baseline contract

Read this when establishing the baseline for a task branch or workspace, and
again whenever a baseline run comes back red.

A baseline is not "the suite passed once here." It is the record that lets a
later red cell be attributed: to your change, to an accepted reproduction, or to
a pre-existing failure someone already owns. Without that record, the first
failure after your first edit has no interpretation.

## Before the command runs

A baseline command installs, builds, migrates, and writes. Inspect it before it
executes, not after:

- **What it runs** — the command itself, the scripts it chains into, and the
  dependency graph it resolves.
- **What it touches** — the data and network boundary it crosses, and the
  effects it is expected to leave behind.
- **What contains it** — the authority you hold over each of those effects.

Run it in the current checkout only when that state is task-owned, or the
command is proved read-only and contained. Otherwise defer it until isolation
exists. Authority that does not cover the command, the network, the scripts, or
the effects leaves the baseline **pending** — which is a reportable state, not
a blocker to be worked around.

## Runtime isolation

Parallel work needs distinct ports, databases, migrations, fixtures, caches, and
environments. Two workspaces sharing one database do not have separate
baselines; they have one baseline and a race.

Capture the pre-state before the run and the post-state after it, and classify
every side effect as intended or not. An unclassified effect is an uncontained
one.

## Classifying every red cell

Each failing cell binds to exactly one of two things, with its raw output kept:

1. **The task's accepted reproduction** — this red is the work.
2. **An exact approved pre-existing exclusion**, carrying all of:

   | Field | What it must contain |
   | --- | --- |
   | Evidence | the raw output, from this baseline run |
   | Owner | the accountable person or team, named |
   | Expiry | a date or a revisit rule, not "eventually" |
   | Discriminator | the compensating check that still catches a *new* regression in the excluded area |

The discriminator is the field people skip, and skipping it is what makes an
exclusion permanent. An exclusion without one converts a known failure into a
blind spot.

## What blocks work

- A generic "known failure" with no owner, evidence, or expiry.
- An unexplained red — one that matches neither the reproduction nor an
  approved exclusion.
- Uncontained effects: anything the run changed that you cannot account for or
  restore.

Each of these is a stop, not a warning. The baseline exists to make later
evidence interpretable; a baseline you cannot interpret has already failed at
its only job.
