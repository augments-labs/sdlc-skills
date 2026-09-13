# Activation: routing and enforcement

The agent must reach the applicable skill, then produce a result that meets the
project's gates. Those are different claims with different evidence.

## How routing works

Catalogue names and descriptions nominate skills for the current situation.
Explicit user requests and handoffs from loaded skills also cause invocation;
a downstream skill need not match the original opening. Descriptions therefore
focus on when a skill applies, including boundaries with neighboring skills.
The body supplies its procedure, preconditions, skips, and next owner.

The resident `using-sdlc-skills` router requires loading applicable bodies before
action and checking routing again when state changes. Its entry examples help
start the work; the current owning skill governs the actual transition. A body
already loaded and current can be applied without another read. A candidate
skill is set aside according to its own scope or skip conditions.

For a high-risk transformation, for example, `migration-strategy` classifies the
work and establishes the required assurance entry conditions. A generic opening
classifier cannot substitute for that assessment.

## Instructions do not enforce invocation

Adapters supply the full router body as session context, removing a separate
step to load that body. They register no tool, prompt, or turn-end enforcement
hooks. Packaging and lifecycle details belong in
[`harness-support.md`](harness-support.md).

Resident instructions can influence a non-deterministic agent; they do not prove
that another skill loaded or that its procedure was followed. A live activation
observation describes one run in its harness and conditions. Reading a body,
following it, and producing an acceptable result are separate observations.

## Gates govern the result

Tests, compilers, static analysis, controlled review, differential checks, and
release criteria inspect artifacts or promotion state. Projects bind applicable
gates to specific candidates and wire them into CI, protected integration paths,
and release controls. The commands, thresholds, environments, and failure
responses belong to the adopting project; this library supplies no universal
project CI template.

Acceptance supports the claims covered by those checks and decisions. A green
but incomplete check does not establish an untested requirement. Keep raw
failures, missing evidence, and uncertainty visible.

Structural checks establish packaging and script predicates. Behavioral tests
observe sampled actions and outputs. Neither is a substitute for the other; see
[`testing.md`](testing.md) for interpreting their results.
