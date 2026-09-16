# One Skill or Several?

When an SDLC phase has several activities, should it be one cohesive skill or several granular ones? This is a judgment call on a spectrum, not a rule — here is the heuristic the library uses.

## The test

Split a phase into separate skills when its activities are **separable** — each is something you would reach for on its own, triggered at a different moment, producing a distinct decision. Keep it one cohesive skill when the activities are a **single interleaved pass** that only makes sense as a whole.

The sharpest question:

> **Would you ever invoke just one sub-activity, without the others?**
>
> Yes → separate skills.  No → one skill.

Skills that keep loading together get a written case: compare their trigger
lines, and write down what each catches that the other would not. Merge them
only when the triggers overlap **and** the case cannot tell them apart.
Overlapping triggers alone are a reason to write the case, not to merge.

## Decisions

- merged: none
- kept: `test-driven-development` + `yagni`; `mapping-the-codebase` + `debugging`;
  `define-goals` + `scoping` + `feasibility-check`

## test-driven-development + yagni

**Trigger overlap.** Both fire on work that adds, changes, or fixes behavior,
and both skip throwaway spikes and content or configuration with no behavior;
the router loads them together before the first edit. The triggers of `yagni`
also reach past that work: a removal of code as unused, scope drift, a proposal
that needs a strict challenge, "let's make it configurable".

**What each catches that the other would not.**

- `test-driven-development` catches a change with no observed failure behind
  it: a test that passed on its first run, failed only because it could not
  execute, or checks generated text instead of behavior, and a preserved
  behavior whose gate was never made red on purpose. A lean, complete change
  under a hollow test passes every check `yagni` makes.
- `yagni` catches what a green test cannot see: a speculative flag,
  abstraction, or dependency; a fix in the first path that shows the symptom
  instead of the behavior's owner; a stub on a path no test reaches; code
  deleted because it looked unused. Each extra feature can carry its own honest
  red-green cycle, so an over-built change passes every check
  `test-driven-development` makes.

The case tells them apart, so they stay two skills that load together.

decision: kept

## mapping-the-codebase + debugging

**Trigger overlap.** Both fire on a bug with an unknown cause in code whose
structure and callers have not been established for the task. Outside that
they part: `mapping-the-codebase` also fires before changing or extending
unfamiliar code with nothing broken, and `debugging` also fires where a current
boundary record already covers the region.

**What each catches that the other would not.**

- `mapping-the-codebase` catches a boundary drawn too small: a caller reached
  through configuration, reflection, a generated route, or a scheduler; a
  compatibility-sensitive change stopped at its direct callers; a boundary
  record relied on past its freshness limit. None of these needs a failure, so
  `debugging` never looks for them.
- `debugging` catches a fix with no surviving cause: a patched symptom, an
  intermittent failure called fixed after one green run, fixes repeated past
  the circuit breaker, a production probe without authority. A complete,
  current map of the region does not say which plausible cause produced this
  failure.

The case tells them apart, so they stay two skills.

decision: kept

## define-goals + scoping + feasibility-check

**Trigger overlap.** All three belong to starting a project or initiative,
skip a single feature, and write their own section of one project brief. They
part on timing: `scoping` also fires when scope creeps mid-project, and
`feasibility-check` is skipped when the path is well-trodden and the risk
obviously low.

**What each catches that the others would not.**

- `define-goals` catches features listed as goals, a target with no baseline,
  source, horizon, or owner, a guardrail nobody could check, and approvers with
  no rule for settling a disagreement. The other two consume approved goals and
  never ask why the work exists.
- `scoping` catches a missing out-of-scope list, compatibility, security, or
  rollback cut as "out of scope" to shrink the MVP, a large dependency hidden in
  a one-word assumption, and a deferred item's ID reissued for another item.
- `feasibility-check` catches a go decided on optimism with no named risks, a
  technical proof taken for delivery, operations, or compliance proof, a
  confidence the evidence has not earned, and a skipped Option Zero: an
  existing tool, a configuration change, or not building at all.

Each is a distinct decision with its own approval question, so they stay three
skills. Sharing one brief is no reason to merge them: separate skills can share
an artifact.

decision: kept

## Analysis is cohesive — `writing-specs`

Gathering requirements, analyzing them, identifying challenges, and writing the spec is one interleaved reasoning pass. You don't gather everything, then analyze everything, then write — you write each requirement while reasoning about its acceptance criterion, its edge cases, and its assumptions, all at once. "Identify the requirement risks" is not independently invokable: you can't do it without the requirements, and once you have them you are already inside `writing-specs`. One skill.

## Don't split for its own sake

Several tiny skills that always run together can fragment one coherent task.
Default to one skill unless a sub-activity is independently useful. An output
template can preserve required information without making each section a skill.

## Cross-cutting techniques are a third case

A technique used across many phases — grilling (`clarifying-intent`), code comprehension (`mapping-the-codebase`) — is neither a phase's skill nor a split of one. It lives in `common/` because it is *reused everywhere*, not because a phase was divided.
