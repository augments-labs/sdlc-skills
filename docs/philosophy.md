# The Generator and the Gate

A coding agent can produce useful work and still be wrong about how good it
is. It can write a function, report that the tests pass, and be mistaken on
both counts, with the same confidence it has when it is right.

This library is built around that fact. Skills guide the work. Something
outside the agent judges the result. We call that outside thing a gate.

## What a gate is

A gate is anything that accepts or rejects a result without relying on the
agent's opinion of it. There are two kinds.

**An executable check** answers a question about correctness. A test, a
compiler, a linter, or a validator runs against one exact version of the work
and returns a verdict. The verdict covers what the check actually asserts and
nothing more. A passing test suite says nothing about a requirement no test
covers, and a test that passed once can still miss a failure that only happens
sometimes. So read the output, and keep its limits in view.

**An accountable decision** answers a question of judgment or authority. No
test can say whether a design is the right one, or whether a branch should be
merged. A person decides, or a review against a fixed rubric does, and the
decision applies to one exact version and one action. Approval lets that step
go ahead. It does not prove the work is correct.

Here is how some of the skills pair a claim with the evidence it needs:

| Skill | The claim | The evidence |
| --- | --- | --- |
| `test-driven-development` | New or preserved behavior works | For new behavior, a test that fails and then passes. For preserved behavior, a passing check that is broken on purpose to prove it can fail, then restored |
| `verification-before-completion` | The work is done | Real check results, tied to the current version and conditions |
| `writing-plans` and `executing-plans` | The plan was carried out | An evaluator for each task, and an acceptance check for the whole plan |
| `debugging` | This is the cause, and this fixes it | A reproduction, or measured evidence for an intermittent failure, that separates this cause from the others |
| Planning and design skills | This is the right intent and structure | A review of one exact version, a rubric, and a decision somebody owns |

## Why instructions still matter

If gates judge the result, why write instructions at all? Because a gate only
helps when the agent reaches it. Instructions steer the agent toward the right
check before it skips a step or makes a claim it cannot back up.

Some steps are tempting to skip under pressure. The skills that guard those
steps use hard stops, lists of warning signs, and tables that answer the usual
excuses, placed exactly where the temptation appears.

Instructions remain probabilistic. Strong wording makes an agent more likely
to reach a gate. It never replaces the gate's result, and nothing becomes true
by being said forcefully.

Descriptions and bodies do different jobs. A description helps the agent find
a skill: it names the situations where the skill applies and separates it from
its neighbors. The body holds the procedure and says which skill comes next.
[`activation.md`](activation.md) explains how skills are found and loaded, and
where that stops.

## Enforcement belongs to your project

This library gives guidance for choosing checks and tying them to the work. It
is not an enforcement system.

When something must be enforced, the project wires the check into its real
integration and release paths. A CI check blocks the step it controls, and
only that step. A path that bypasses CI is not covered by it.

## Keep evidence tied to its source

An agent's summary that the tests passed is not the test output. A field
labelled `Approval:` is not, by itself, a decision anyone made.

Evidence stays attached to where it came from. For a check, that is the raw
output and the version it ran against. For a decision, that is the user's
current answer, or a trusted record that names who decided, which version, and
which action they allowed.

When evidence is missing or out of date, the claim stays open. One passing run
does not cancel a failure that was observed, and it does not show that an
instruction is unnecessary. Testing narrows uncertainty. Report what was
observed and what is still unproven.

## Scale the process to the work

The skills are a toolbox. Nothing requires a task to walk through every phase.
Each skill says when it applies and how to scale it down for small work.

A few gates have no skip. Checking a claim that work is done is one of them.
Even there, use the smallest check that could prove the claim wrong.

## Keep what changes behavior

Every line in a skill costs attention each time the skill is loaded, so each
line has to earn its place. The question to ask is: would the agent get this
wrong without it?

Keep guidance that changes what the agent does, preserves information it
needs, or settles a confusion that has actually been seen. Remove repetition,
and remove procedure written for situations that may never happen.

Being concise means fewer unnecessary instructions. It does not mean squeezing
the necessary ones until they are hard to read.
