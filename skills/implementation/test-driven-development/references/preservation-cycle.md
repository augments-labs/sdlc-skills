# Preservation-first cycle

Use this when accepted behavior already exists and the work should preserve it:
a refactor, port, rewrite, migration, generator change, or behavior-affecting
configuration change. The goal is not to invent a missing behavior. It is to
prove an implementation-independent gate can catch divergence before relying on
it during transformation.

## 1. Bind the preservation contract

Take facts, invariants, and approved deviations from the current requirements
and task/plan gate. High-risk work also consumes its migration contract and
assurance matrix. Record exact source and target identities. Do not silently
turn a known defect into either a preserved invariant or a fix.

Choose observations visible outside the target implementation: public inputs and
outputs, errors, side effects, data state, ordering, supported
platform/build-mode behavior, or resource floors when contractual. Normalize
only fields approved as nondeterministic.

## 2. Establish GREEN on the accepted source

Run the real characterization or differential gate against the accepted current
implementation and representative corpus. It must be green before target work.
If it is red, the baseline or contract is unresolved; do not weaken it to begin
the migration.

Record:

- source revision/artifact and environment;
- corpus/inventory identity and digest;
- controlled data/external-effect boundary, resource limits, current authority,
  cleanup/recovery contract, and exact pre-state identity;
- exact command or controlled action;
- raw green output and timestamp.

## 3. Falsify the oracle

In an isolated authorized copy, freeze gate/corpus identities and predeclare the
exact divergence targets, effects, resource boundary, recovery, and authority.
Alter one outcome, error, state transition, ordering rule, translation, or
resource limit that must be preserved. Run the unchanged gate and require the
intended red. Syntax failure, pre-observation crash, or target-specific assertion
is not successful falsification.

Restore and compare the complete controlled candidate plus data/external effects
to the pre-state identity, then rerun green. Preserve divergence, red,
restoration comparison, and green evidence. Unknown residue blocks target work;
ownership alone never authorizes mutation or cleanup.

## 4. Transform under green

Move one representative slice at a time. Run the differential/characterization
gate and required project gates after each slice. An intentional approved delta
gets a separate new-behavior RED before its target implementation; update the
oracle only from the approved contract, never from whatever output the target
currently emits.

## Generators and configuration

For a generator, test the source-to-output transformation, deterministic
regeneration where required, semantic invariants, and affected build/runtime
behavior. Generated file existence or string presence proves little.

For configuration, decide whether it changes behavior. A behavioral change uses
the new or preservation cycle through the system's real entry point. Pure
non-behavioral metadata may skip TDD but still runs its structural validator.

## Completion evidence

Retain source/target and pre/post effect identities, corpus digest, deliberate
divergence, observed red, restoration comparison/green, slice result, approved
deviations, and every required platform/build-mode result. Hand these checks to
`verification-before-completion`; this reference defines the TDD cycle, not a completion
claim.
