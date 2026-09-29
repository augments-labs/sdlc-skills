# One Skill or Several?

A phase of the life cycle often contains several activities. Should they be
one skill or several smaller ones? There is no fixed rule. This page describes
the test the library uses and the decisions made with it so far.

## The test

Split a phase into separate skills when its activities are **separable**: you
would reach for each one on its own, at a different moment, to make a
different decision.

Keep one skill when the activities form a **single interleaved pass** that
only makes sense as a whole.

The sharpest form of the question:

> **Would you ever invoke just one of the activities, without the others?**
>
> Yes: separate skills. No: one skill.

## Skills that keep loading together

When two skills keep loading together, write the case down. Compare their
trigger lines, and record what each one catches that the other would not.

Merge them only when the triggers overlap **and** the written case cannot tell
them apart. Overlapping triggers alone are a reason to write the case. They
are not a reason to merge.

## Decisions so far

| Skills | Decision |
| --- | --- |
| `test-driven-development` and `yagni` | Kept separate |
| `mapping-the-codebase` and `debugging` | Kept separate |
| `define-goals`, `scoping`, and `feasibility-check` | Kept separate |

Nothing has been merged. The three cases follow.

## test-driven-development and yagni

**Where the triggers overlap.** Both fire on work that adds, changes, or fixes
behavior. Both skip throwaway spikes, and content or configuration with no
behavior. The router loads them together before the first edit.

`yagni` also reaches beyond that work. It fires when code is removed as
unused, when scope drifts, when a proposal needs a strict challenge, and when
someone says "let's make it configurable".

**What each catches that the other would not.**

- `test-driven-development` catches a change with no observed failure behind
  it. Examples: a test that passed on its first run, a test that failed only
  because it could not execute, a test that checks generated text and not
  behavior, and a preserved behavior whose check was never made to fail on
  purpose. A lean, complete change under a hollow test passes every check
  `yagni` makes.
- `yagni` catches what a green test cannot see. Examples: a speculative flag,
  abstraction, or dependency, a fix placed where the symptom first showed and
  not where the behavior belongs, a stub on a path no test reaches, and code
  deleted because it looked unused. Each extra feature can carry its own
  honest red-green cycle, so an over-built change passes every check
  `test-driven-development` makes.

The written case tells them apart, so they stay two skills that load together.

## mapping-the-codebase and debugging

**Where the triggers overlap.** Both fire on a bug with an unknown cause, in
code whose structure and callers have not been established for the task.

Outside that, they part. `mapping-the-codebase` also fires before unfamiliar
code is changed or extended when nothing is broken. `debugging` also fires
when a current boundary record already covers the region.

**What each catches that the other would not.**

- `mapping-the-codebase` catches a boundary drawn too small. Examples: a
  caller reached through configuration, reflection, a generated route, or a
  scheduler, a compatibility-sensitive change that stopped at its direct
  callers, and a boundary record relied on after it went stale. None of these
  needs a failure, so `debugging` never looks for them.
- `debugging` catches a fix with no established cause behind it. Examples: a
  patched symptom, an intermittent failure called fixed after one green run,
  fixes repeated past the circuit breaker, and a production probe run without
  authority. A complete, current map of the region does not say which
  plausible cause produced this failure.

The written case tells them apart, so they stay two skills.

## define-goals, scoping, and feasibility-check

**Where the triggers overlap.** All three belong to the start of a project or
initiative. All three skip a single feature, and each writes its own section
of one project brief.

They part on timing. `scoping` also fires when scope grows in the middle of a
project. `feasibility-check` is skipped when the path is well trodden and the
risk is obviously low.

**What each catches that the others would not.**

- `define-goals` catches features listed as goals, a target with no baseline,
  source, horizon, or owner, a guardrail nobody could check, and approvers
  with no rule for settling a disagreement. The other two start from approved
  goals and never ask why the work exists.
- `scoping` catches a missing out-of-scope list, compatibility, security, or
  rollback cut as "out of scope" to shrink the first release, a large
  dependency hidden in a one-word assumption, and the ID of a deferred item
  reused for a different item.
- `feasibility-check` catches a go decided on optimism with no named risks, a
  technical proof mistaken for proof about delivery, operations, or
  compliance, a level of confidence the evidence has not earned, and a skipped
  Option Zero: an existing tool, a configuration change, or not building at
  all.

Each one is a distinct decision with its own approval question, so they stay
three skills. Sharing one brief is no reason to merge them. Separate skills
can share an artifact.

## Analysis is one skill: writing-specs

Gathering requirements, analyzing them, finding the difficult parts, and
writing the spec is one interleaved pass. Nobody gathers everything, then
analyzes everything, then writes. You write each requirement while thinking
about its acceptance criterion, its edge cases, and its assumptions.

"Identify the risks in the requirements" cannot be invoked on its own. It
needs the requirements, and once you have those you are already inside
`writing-specs`. So analysis is one skill.

## Do not split for its own sake

Several tiny skills that always run together break one coherent task into
pieces. Default to one skill unless an activity is useful by itself.

When the concern is that required information might be lost, an output
template solves it. Each section does not need to be its own skill.

## Techniques used in many phases

Some techniques are used across many phases. `clarifying-intent` asks
questions wherever intent is unclear. `mapping-the-codebase` builds an
understanding of code wherever code is about to change.

These are a third case. They are not the skill of one phase, and they are not
a piece split off from one. They live in `common/` because they are reused
everywhere.
