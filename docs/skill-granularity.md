# One Skill or Several?

When an SDLC phase has several activities, should it be one cohesive skill or several granular ones? This is a judgment call on a spectrum, not a rule — here is the heuristic the library uses.

## The test

Split a phase into separate skills when its activities are **separable** — each is something you would reach for on its own, triggered at a different moment, producing a distinct decision. Keep it one cohesive skill when the activities are a **single interleaved pass** that only makes sense as a whole.

The sharpest question:

> **Would you ever invoke just one sub-activity, without the others?**
>
> Yes → separate skills.  No → one skill.

## Planning is split — `define-goals` · `scope-it` · `feasibility-check`

These are separable. You would run a `feasibility-check` on an existing idea without redefining its goals; you would `define-goals` before anyone has scoped anything. Distinct decisions, often made at different moments, each independently useful — so each earns its own skill.

They still compose into one **project brief**. Separate skills can share an artifact; sharing an output is not a reason to merge them.

## Analysis is cohesive — `spec-it`

Gathering requirements, analyzing them, identifying challenges, and writing the spec is one interleaved reasoning pass. You don't gather everything, then analyze everything, then write — you write each requirement while reasoning about its acceptance criterion, its edge cases, and its assumptions, all at once. "Identify the requirement risks" is not independently invokable: you can't do it without the requirements, and once you have them you are already inside `spec-it`. One skill.

## Don't split for its own sake

Several tiny skills that always run together can fragment one coherent task.
Default to one skill unless a sub-activity is independently useful. An output
template can preserve required information without making each section a skill.

## Cross-cutting techniques are a third case

A technique used across many phases — grilling (`interview-me`), code comprehension (`zoom-out`) — is neither a phase's skill nor a split of one. It lives in `common/` because it is *reused everywhere*, not because a phase was divided.
