---
name: test-driven-development
description: "Use before behavior-affecting implementation — features, fixes, refactors, migrations, generators, or configuration, including behavior meant to be preserved. Fires on any request to add, change, or fix behavior, even when the user names only the feature or the bug and never mentions tests or TDD. Skip only throwaway spikes and nonbehavioral content or configuration."
---

# Test-Driven Development

Make an executable gate fail for the right reason before the code exists, or
make an existing gate fail on purpose before you preserve behavior through a
change. Watch it happen; keep the output.

## When to use

- Any feature, fix, refactor, migration, generator, or config that changes
  behavior.
- **Skip** disposable spikes and non-behavioral content or config. Behavior
  from a spike that is then accepted gets rebuilt under a gate.
- High-risk target code waits for its approved migration and assurance
  contracts and their entry gates. Work authorized only to build a gate
  cannot edit the target or satisfy entry on its own.

## Before the first test command

1. **Write down what the test command will touch:** the environment and data
   it runs against, the effects it causes outside the repository, the time and
   resources it may spend, how it cleans up, and the authority you hold for
   each. Never aim a test at a shared or production surface you have not
   written down here.

2. **Pin the public interface and the behavior it promises** from the task,
   spec, or approved design. A meaning still unresolved goes back to its owner
   through `interview-me`; do not guess it into a test.

3. **Pick the cycle.** New or intentionally changed behavior: RED first.
   Behavior that must survive a change unchanged: GREEN → deliberate RED →
   GREEN. A bugfix takes the RED cycle starting from its runnable
   reproduction. Never invent a failure for behavior that already works.

## New behavior: RED → GREEN

1. **Write one test for the next approved behavior** and run it through the
   project's real test command.

2. **Read the failure and confirm it is the right one.** The test was
   discovered, it executed, and it failed at the intended assertion — not on
   an import, a syntax error, the harness, an unrelated case, a skip, or a
   flake. Keep the output. A failure you cannot explain: invoke `debugging`
   before writing product code.

3. **Record the test's identity, the evaluator's identity, and the expected
   observable** as of this RED. If any of the three has to change later, the
   cycle is invalid: restart it and reach RED again with the new one.

4. **Write only the code that makes this test pass.** Run the test, then the
   gate the project requires; both green.

5. **Refactor under green** and rerun both. An intended behavior change is a
   new RED cycle and goes back to the approval that owns it.

## Preserved behavior: GREEN → deliberate RED → GREEN

1. **Take the characterization gate the task or plan accepted** — for
   high-risk work, the assurance matrix's differential gate. An inherited
   green suite does not count until it is accepted as covering the
   preservation contract independently of the target; strengthen smoke-only
   coverage before the first checkpoint.

2. **Run it on the current behavior and see it green.** Keep the output.

3. **Introduce one controlled, representative divergence, run the same gate,
   and watch it go red** the way you intended. Keep the output.

4. **Restore the exact state and watch it go green again.**

5. **Transform one slice, keeping that gate green.** Read
   `references/preservation-cycle.md` for the oracle, the generator and config
   case, and what evidence to keep.

## Closing the cycle

1. **When chronology is part of the claim, use an external observer** or
   immutable checkpoints the evaluator reruns. Logs the candidate wrote are
   not evidence, and checkpoint history is never written after the fact.

2. **Restore only the mutations this task made** and whose pre-state you
   recorded. Leave anything else pending and let `finishing-a-branch` decide
   its disposition; never delete inherited, shared, or user state to
   manufacture a cycle.

3. **REQUIRED — invoke `verifying-completion`** on the exact state you are
   about to call done; the gate this cycle ran is one row of its ledger, not
   the ledger. Then return to whatever invoked this skill: a plan task, a
   worktree checkpoint, or a fix under `debugging`. Run no commit, push, or PR
   from this skill.

## Hard stops

- New behavior code created by the current work has no observed behavior RED.
- A new-behavior test passes first run, or fails only because the test cannot
  execute.
- A preservation oracle was never seen green, never made red by a deliberate
  divergence, or derives expected results from the target it judges.
- A preservation checkpoint contains no new oracle even though inherited tests
  were never accepted as covering the preservation contract.
- A behavioral generator/config change tests only text presence or generated
  file existence.
- A test/evaluator, expected observable, corpus, or oracle changed after its RED/
  falsification without invalidating and restarting that cycle.
- A command/divergence lacks environment/data/effect/cleanup authority or
  verified restoration.
- Throwaway or out-of-cycle code is being copied into the product.

## When you are tempted to skip

| The thought | The reality |
| --- | --- |
| "Too simple to test" | Simple behavior still breaks; use the smallest real gate. |
| "I'll write the test after" | For new behavior, that records the implementation instead of leading it. |
| "The port already works, so I need a fake RED" | No: start green, falsify the independent oracle, restore, then preserve it. |
| "I tested it by hand" | An unrepeatable observation cannot guard the next change. |
| "I'd lose the code I wrote" | Revert only your out-of-cycle implementation; sunk cost is not evidence. |
| "The test is hard to write" | The interface or oracle is exposing a design problem; fix that seam. |
| "There's no test framework" | Use the smallest executable assertion that can fail. |
| "It's just generated/config code" | Test the behavioral source and regeneration contract, not text presence. |

## Common mistakes

- Testing internals or mock calls instead of public behavior — see
  `references/reference.md` and `references/mocking.md`.
- Writing all tests first instead of advancing one behavior or preservation
  slice at a time.
- Treating coverage, compilation, snapshots of noise, or a target-derived oracle
  as equivalence proof.
- Over-building in GREEN instead of letting the current gate bound the change.
