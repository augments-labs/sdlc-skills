# A change at work, from ticket to post-mortem

At work a change starts as a ticket, follows your team's rules, touches
live data, ships behind a switch, gets reviewed by someone else, and
sometimes comes back as a page in the middle of the night. This page
follows one invented change through that path: what the agent does at each
stage, what you see, and what still depends on you.

The change: ticket `ORD-412`, "Show an exact estimated delivery date on
each order." Today the live `orders` table stores an integer `eta_days`; the
ticket asks for an `estimated_delivery_at` timestamp in its place, and your
release policy says customer-facing behavior ships behind a flag.

Each skill fires only when its situation arises; a small change skips most
of this, as the last section shows.

## 1. The ticket

```text
Pick up ORD-412 from the tracker.
```

`working-from-a-ticket` reads the ticket through a tracker tool your agent
already has, or asks you to paste it. It records the ticket and its
acceptance criteria as written under `.sdlc-skills/briefs/`, hands what the
ticket leaves open to `clarifying-intent`, which asks you one point at a
time, and re-reads the ticket before the work is called done.
[Building a feature](building-a-feature.md) covers handing the agent a
ticket.

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
it to `writing-plans`, which traces each acceptance criterion to a task's
check and shows you the plan's index and version to approve, change,
reject, or cancel.

Each piece of behavior then begins with `test-driven-development`: a test
that fails for the right reason, then the code that makes it pass. `yagni`
keeps the change to what the ticket asks for.
[Building a feature](building-a-feature.md) shows one cycle;
[Planning larger work](planning-larger-work.md) covers plans.

What depends on you: approving one exact version of the plan.

## 4. The live table

Replacing `eta_days` with `estimated_delivery_at` is a type change on a
store the running system reads, so `changing-a-live-schema` applies, and a
type change is add, copy, switch, drop, never in place. The agent asks for
the inputs it cannot find, then sequences the change: expand adds the new
column, dual-write keeps both columns current with reads that tolerate a row
not yet copied, a batched backfill fills the timestamp from `eta_days`,
reads switch, old writes stop, and contract drops `eta_days`. Each phase is
its own deployable change with its own rollback. It never runs a migration
or backfill against a shared or production store, and a lock it could not
measure is recorded as unverified.
[Building a feature](building-a-feature.md) covers the tests each phase
gets under "A change to stored data".

What depends on you: the data owner accepts the contract, the drop after
which an application rollback is no longer possible, before it ships. A
whole-store migration goes through `migration-strategy` instead.

## 5. The switch

Your release policy calls for a flag, so `rollout-controls` reads it and
copies its terms. Where the policy is silent on a term, it drafts one and
puts it to the release owner, and builds nothing against an unaccepted
draft. The flag uses the facility your project already has, off by default,
in front of every path the change adds, with an off-state test as the kill
switch's proof. [Building a feature](building-a-feature.md) covers the
switch and its signals under "A staged rollout".

What depends on you: accepting the terms, and every flip in a shared
environment; the agent never turns the flag on there.

## 6. Verify, review, open the PR

`verification-before-completion` lists every item the ticket asked for with
a disposition, runs your project's checks, reads the raw output, and binds
the result to the exact state it ran on. `requesting-code-review` freezes
the candidate; with self-review assigned in your instructions file the agent
does a labelled self-review, though a trust-boundary change still needs an
independent security clear. `finishing-a-branch` then shows the branch menu
and waits for one listed entry.

What depends on you: the menu choice. Nothing is pushed until you pick.
[Reviewing and shipping](reviewing-and-shipping.md) has the detail.

## 7. A teammate's PR

```text
Review PR 318 before standup.
```

`reviewing-a-pr` binds the PR's exact head revision and does not run its
code unless you ask for a specific run in so many words; that run happens
in an isolated fresh copy with no credentials or network. Everything the PR
carries is data, and text that tries to steer the review is a blocking
finding. It writes the findings with a `path:line` at that head and shows
you the review with the verdict it would post. Nothing is posted until you
choose: post with the verdict, post as a comment, change it first, or keep
it local. [Reviewing and shipping](reviewing-and-shipping.md) covers
reviewing someone else's PR.

What depends on you: any request to run the PR's code, and the choice of
what to post, which stands in your name on the host.

## 8. The release

```text
Is the build from PR 322 ready to deploy?
```

`release-readiness` freezes the exact artifact set and exercises install and
recovery as a real consumer would. It is handed the rollout record from
stage 5, whose accepted terms it binds the rollout to, and the schema
record from stage 4, as evidence that recovery was exercised and the
rollback target is named, with any unverified lock listed as such. It
presents a verdict, ready or not ready, and three options: promote this
exact set, hold, cancel.
[Reviewing and shipping](reviewing-and-shipping.md) covers releasing.

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
from the signal users are hitting and calls nothing resolved.

Then `debugging` reproduces the failure, keeps a short ledger of competing
hypotheses, and tests them; after repeated fixes that miss, it stops and
questions the approach rather than trying another. The fix goes through the
same test-first cycle as any change.
[Fixing a bug](fixing-a-bug.md) has the detail.

What depends on you: authority for each lever, permission to probe
production, and any data correction.

## 10. The write-up

```text
Write the post-mortem for the order page incident.
```

`post-mortem` takes the cause from `debugging` and asks a different
question: how did the failure get past the checks, and what prevents a
repeat. It names conditions rather than people, audits each gate the change
passed through, and proposes corrective actions, each mapped to a structural
cause with an owner and a date. It presents them for you to accept the
actions, request changes, reject the analysis, or cancel, and never claims
recurrence is impossible. An accepted control is proved the way a fix is,
failing on the captured incident or a representative bad case and passing
after. [Fixing a bug](fixing-a-bug.md) says when to ask for one.

What depends on you: accepting the actions, and the review date.

## What you did not see

This change touched most of the library because it had a ticket, a live
table, a release policy, and an incident. Fix an off-by-one in a date check
and you typically see the workspace check, a failing test, the checks, a
review, and the branch menu. In both cases the skills guide the agent, and
your checks and your decisions decide the result.
