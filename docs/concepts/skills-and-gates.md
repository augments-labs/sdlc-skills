# Skills guide, your checks decide

A coding agent can produce useful work and still be wrong about how good it
is. It can write a function, report that the tests pass, and be mistaken on
both counts, with the same confidence it has when it is right.

The library is built around that fact. Skills steer the agent toward the
right step at the right moment. Something outside the agent judges the
result. This page explains what that outside thing is and what it means for
you.

## Two kinds of check

A check is anything that accepts or rejects a result without relying on the
agent's opinion of it.

**An executable check** answers a question of correctness. A test, a
compiler, a linter, or a validator runs against one exact version of the
work and returns a verdict. The verdict covers what the check asserts and
nothing more: a green suite says nothing about a requirement no test covers.
So the skills make the agent read the output, not just the exit code, and
say what the check did and did not cover.

**An accountable decision** answers a question of judgment or authority. No
test can say whether a design is the right one or whether a branch should be
merged. A person decides, or a review against a fixed rubric does, and the
decision applies to one exact version and one action. That is why the agent
shows you a plan's version before asking for approval, and why it re-asks
when a reply does not pick one of the options.

Here is how some skills pair a claim with the evidence it needs:

| Skill | The claim | The evidence |
| --- | --- | --- |
| `test-driven-development` | The new behavior works | A test that failed before the code and passes after |
| `verification-before-completion` | The work is done | The real check results, tied to the current version of the code |
| `debugging` | This is the cause, and this fixes it | A reproduction that fails before the fix and passes after, or a measured sample for an intermittent bug |
| `writing-plans` and `executing-plans` | The plan was carried out | A check for each task, and an acceptance check for the whole plan |
| The planning and design skills | This is the right intent and structure | Your approval of one exact version |

## Why the instructions still matter

If checks judge the result, why write instructions at all? Because a check
only helps when the agent reaches it. Under pressure an agent skips the
test, calls the work done, or opens the PR because "it is one command". The
skills put a hard stop, a list of warning signs, or a table of the usual
excuses exactly where that temptation appears.

Strong wording makes the agent more likely to reach the check. It never
replaces the check's result. Nothing becomes true by being said forcefully.

## What this means for your project

The library is guidance, not an enforcement system. Nothing in it forces a
skill to be invoked, and nothing in it can block a merge.

Keep your CI, your branch protection, your reviews, and your release
controls in place. The skills steer the agent into them; those controls are
what decide. The commands, thresholds, and environments belong to your
project, and the library ships no CI template.

## Evidence stays attached to where it came from

An agent's summary that the tests passed is not the test output. A field
that says `Approval:` is not, by itself, a decision anyone made. The skills
keep the raw output and the version it ran against, and record who decided
what and when. When evidence is missing or stale, the claim stays open and
the agent says so.

One passing run does not cancel a failure that was seen. Testing narrows
uncertainty; it does not remove it. Expect the agent to report what was
observed and what is still unproven, rather than rounding up to "done".

## Scale to the work

The skills are a toolbox. Nothing requires a task to walk through every
phase; each skill says when it applies and how it scales down for small
work. A one-line fix does not get a project brief.

A few checks have no skip. Checking a claim that work is done is one of
them. Even there, the rule is the smallest check that could prove the claim
wrong.
