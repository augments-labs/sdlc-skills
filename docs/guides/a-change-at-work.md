# A change at work, from ticket to post-mortem

At work a change starts as a ticket, follows your team's rules, touches
live data, ships behind a switch, gets reviewed by someone else, and
sometimes comes back as a page in the middle of the night. This page
follows one invented change through that path: what the agent does at each
stage, what you see, and what still depends on you.

The change: ticket `ORD-412`, "Show an estimated delivery date on each
order." It needs a new column on the live `orders` table, a backfill of
open orders, and your release policy says customer-facing behavior ships
behind a flag.

Each skill fires only when its situation arises; a small change skips most
of this, as the last section shows.

## 1. The ticket

```text
Pick up ORD-412 from the tracker.
```

`working-from-a-ticket` reads the ticket through a tracker tool your agent
already has, or asks you to paste it. It records the ticket and its
acceptance criteria as written under `.sdlc-skills/briefs/`, and lists what
the ticket and the code do not settle. Those points go to
`clarifying-intent`, which asks you one at a time. It re-reads the ticket
before the work is called done.

What depends on you: the answers to the open points.

## 2. Your team's rules

Your project's instructions file already says: work in the current checkout,
start from `dev`, commit locally as you go, self-review is the assigned
depth, pull requests follow the template. `using-git-worktrees` records the
line that lets it stay in the checkout and works on the branch you checked
out; without it, it creates a worktree from `dev`. The commit line means it
checkpoints after each testable piece without asking; a checkpoint never
pushes.

What depends on you: switching to your task branch before you ask.
[Setting up for a team](setting-up-for-a-team.md) has the block to paste
and says how the tracker gets connected.

## 3. A plan if needed, then test-first

This change spans several steps and files, so `working-from-a-ticket` hands
it to `writing-plans`, which writes one task per capability, traces each
acceptance criterion to a task's check, and shows you the plan's index and
version to approve, change, reject, or cancel.

Each piece of behavior then begins with `test-driven-development`: one test
that fails for the right reason, then the code that makes it pass. `yagni`
keeps the change to what the ticket asks for and makes sure that part is
complete rather than stubbed.
[Building a feature](building-a-feature.md) shows one cycle;
[Planning larger work](planning-larger-work.md) covers plans.

What depends on you: approving one exact version of the plan.

## 4. The live table

Adding `estimated_delivery_at` to `orders` changes a store the running
system reads, so `changing-a-live-schema` applies. The agent asks for the
inputs it cannot find (migration tool, deploy model, rollback target, store
engine, data size), then sequences the change as expand, dual-write,
backfill in batches, switch reads, stop old writes, contract, each phase its
own deployable change with its own rollback. Each is built under test: the
backfill run twice changes nothing, an interrupted one resumes, reads
tolerate a row not yet backfilled. It never runs a migration or backfill
against a shared or production store, and a lock it could not measure on a
production-sized copy is recorded as unverified for the release decision.

What depends on you: the data owner accepts the contract phase, the drop
after which an application rollback is no longer possible, before it ships.
A whole-store migration goes through `migration-strategy` instead.

## 5. The switch

Your release policy calls for a flag, so `rollout-controls` reads it and
copies its terms. Where the policy is silent on a term, it drafts one and
puts it to the release owner; nothing is built against an unaccepted draft.
It builds the flag with the facility your project already has, off by
default, in front of every path the change adds, with an off-state test as
the kill switch's proof, and emits the signals the thresholds read through
your existing telemetry.

What depends on you: accepting the terms, and every flip in a shared
environment; the agent never turns the flag on there. The flag does not
replace the schema phasing, and the phasing does not supply the flag.

## 6. Verify, review, open the PR

`verification-before-completion` lists every item the ticket asked for with
a disposition, runs your project's checks, reads the raw output, and binds
the result to the exact state it ran on. `requesting-code-review` freezes
the candidate; with self-review assigned in your instructions file the agent
does a labelled self-review, though a trust-boundary change still needs an
independent security clear. `finishing-a-branch` then shows the branch menu
and waits for one listed entry. When you choose to push and open a PR, the
description follows your contribution rules and template; with none, the
skill's own: why, what changes, the checks run on that exact candidate, the
review, risk and rollback, and what was not verified.

What depends on you: the menu choice. Nothing is pushed until you pick.
[Reviewing and shipping](reviewing-and-shipping.md) has the detail.

## 7. A teammate's PR

```text
Review PR 318 before standup.
```

`reviewing-a-pr` binds the PR's exact head revision and never runs its
code: no build, install, test, or checkout of its tree. Everything the PR
carries is data, and text that tries to steer the review is a blocking
finding. It gets the library's independent review, writes the findings for
the author with a `path:line` at that head, and shows you the review with
the verdict it would post. Nothing is posted until you choose: post with
the verdict, post as a comment, change it first, or keep it local.

What depends on you: that choice, which stands in your name on the host.

## 8. The release

```text
Is the build from PR 322 ready to deploy?
```

`release-readiness` freezes the exact artifact set, exercises install and
recovery as a real consumer would, binds the rollout to the terms accepted
in stage 5, and reads the schema record for its checks on recovery and the
rollback target, with any unverified lock listed as such. It presents a
verdict, ready or not ready, and three options: promote this exact set,
hold, cancel.

What depends on you: naming one. "Ready" is not authority to deploy; the
promotion runs under its own action, after you choose.

## 9. On call

Two weeks later the order page starts failing for a slice of customers.

```text
Order pages are erroring for some customers right now. Contain it first.
```

`containing-an-incident` writes down what fails, for whom, since when, and
how badly, and does not open product code. It lists the levers (the flag
from stage 5, a config value, a rollback) and pulls the narrowest one it has
scoped authority for; a lever it does not have, including every deploy and
rollback, it escalates to you or the incident owner. It proves containment
from the signal users are hitting, records what the lever costs while it
holds, and calls nothing resolved.

Then `debugging` reproduces the failure, keeps three to five hypotheses in
a ledger, and tests them; after three fixes that miss, it stops rather than
trying a fourth. The fix goes through the same test-first cycle as any
change. [Fixing a bug](fixing-a-bug.md) has the detail.

What depends on you: authority for each lever, permission to probe
production, and any data correction.

## 10. The write-up

```text
Write the post-mortem for the order page incident.
```

`post-mortem` takes the cause from `debugging` and asks a different
question: how did the failure get past the checks, and what prevents a
repeat. It builds the timeline from artifacts, names conditions rather than
people, audits each gate the change passed through, and proposes corrective
actions, each mapped to a structural cause with an owner and a date. It
presents them for you to accept, change, reject, or cancel, and never claims
recurrence is impossible. An accepted control is proved the way a fix is,
failing on the captured incident and passing after, and later judged
effective, ineffective, or inconclusive.

What depends on you: accepting the actions, and the review date.

## What you did not see

This change touched most of the library because it had a ticket, a live
table, a release policy, and an incident. Rename a log line and you see a
failing test, the checks, a review, and the branch menu, and nothing else.
In both cases the skills guide the agent, and your checks and your decisions
decide the result.
