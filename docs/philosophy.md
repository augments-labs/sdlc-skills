# The Generator and the Gate

A coding agent can generate useful work and still misjudge it. The library uses
instructions to guide the work and external evidence to assess its results.
Neither confidence nor forceful wording establishes correctness.

## What a gate establishes

An executable check decides a declared predicate for a particular candidate and
environment. Its acceptance supports the requirements its assertions actually
cover, under their stated assumptions. A deterministic check can be incomplete;
a sampled test can miss an intermittent failure. Inspect the evidence and keep
those limits visible.

Judgment and authority need a different boundary. Designs, product preferences,
and integration decisions use controlled review or an accountable decision bound
to the exact version and action. Approval authorizes that transition; it is not
proof of every correctness claim.

| Skill | Generated work or claim | Required evidence |
| --- | --- | --- |
| `test-driven-development` | New or preserved behavior | New behavior: relevant RED then GREEN; preservation: independent GREEN, controlled falsification, restored GREEN |
| `verification-before-completion` | A claim that work is done | Actual check results bound to the current candidate and conditions |
| `writing-plans` / `executing-plans` | An executable plan and its implementation | Per-task Evaluators and integrated plan Acceptance |
| `debugging` | A causal explanation and fix | Reproduction or quantified intermittent evidence that distinguishes the hypothesis |
| Planning and design skills | Intent and proposed structure | Revision-bound review, rubric, and accountable decision |

## Why instructions still matter

Instructions direct an agent toward the right check before it skips a step or
makes an unsupported claim. A discipline skill keeps a hard stop, concrete red
flags, or a rationalization table where pressure can make that omission tempting.
Those instructions remain probabilistic; emphasis gets the agent to a gate and
cannot replace its result.

Descriptions serve discovery. They name the situations in which a skill applies
and distinguish nearby skills. Loaded bodies carry procedures and handoffs.
The router requires applicable skills to load before action; see
[`activation.md`](activation.md) for its limits.

Where enforcement is needed, the adopting project wires checks into its actual
integration and release paths. A CI check blocks the transition it controls;
it does not automatically govern unwired paths. This library supplies guidance
for choosing and binding gates, not a universal enforcement system.

## Evidence and authority retain their source

An agent's summary that tests passed is not the raw result. A field labeled
`Approval:` is not, by itself, an authenticated decision. Keep evidence bound to
its source: the check output and candidate, or the current user answer or trusted
receipt identifying the actor, version, and permitted action.

Missing or stale evidence leaves the affected claim unresolved. A passing
behavioral sample does not cancel an observed failure or demonstrate that an
instruction is unnecessary. Testing narrows uncertainty; report what was
observed and what remains unproven.

## Scale guidance to the work

Skills form a toolbox, not a mandatory walk through every phase. Each skill's
scope and scale-down rules govern how much process applies. Some gates, including
verification of completion claims, have no skip; use the smallest check that can
fail the relevant claim.

Keep guidance that changes actions, preserves required information, or resolves
a demonstrated ambiguity. Remove repetitions and speculative procedure. Concision
means fewer unnecessary instructions, not fewer words at the cost of meaning.

A constraint earns its context only where the agent would otherwise violate it.
Ask of every line "would the agent get this wrong without this?" A line the agent
already follows unprompted costs attention on every load and prevents nothing.
