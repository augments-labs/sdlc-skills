---
name: test-driven-development
description: "Use before behavior-affecting implementation — features, fixes, refactors, migrations, generators, or configuration, including behavior meant to be preserved. Fires on any request to add, change, or fix behavior, even if the user names only the feature or the bug and never mentions tests or TDD. Skip throwaway spikes and nonbehavioral content or configuration."
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

## Step 1: Before the first test command

1. Write down what the test command touches: environment and data, effects
   outside the repository, time and resources, cleanup, and your authority
   for each. Never aim a test at a shared or production surface not written
   here.
2. Pin the public interface and the behavior it promises from the task, spec,
   or approved design. Unresolved meaning → `interview-me`. Never guess it
   into a test.
3. Pick the cycle:
   - new or intentionally changed behavior → Step 2
   - behavior that must survive a change unchanged → Step 3
   - bugfix → Step 2, starting from its runnable reproduction
   Never invent a failure for behavior that already works.

## Step 2: New behavior — RED → GREEN

1. Write one test for the next approved behavior.
2. Run it through the project's real test command.
3. Read the failure. Confirm it is the right one: the test was discovered,
   executed, and failed at the intended assertion.

   ```text
   RED, right reason:   FAIL test_rejects_expired_token — AssertionError: expected 401, got 200
   RED, wrong reason:   ERROR test_rejects_expired_token — ImportError: cannot import name 'verify'
   Not RED:             1 skipped, 0 failed
   ```

   Wrong reason or unexplained → invoke `debugging` before any product code.
4. Keep the output.
5. Record the test's identity, the evaluator's identity, and the expected
   observable as of this RED. Any of the three changes later → the cycle is
   invalid; restart and reach RED again.
6. Write only the code that makes this test pass.
7. Run the test, then the gate the project requires. Both green.
8. Refactor under green. Rerun both. An intended behavior change is a new RED
   cycle under the approval that owns it.

## Step 3: Preserved behavior — GREEN → deliberate RED → GREEN

1. Take the characterization gate the task or plan accepted; high-risk work
   uses the assurance matrix's differential gate. An inherited green suite
   counts only once accepted as covering the preservation contract
   independently of the target. Strengthen smoke-only coverage before the
   first checkpoint.
2. Run it on the current behavior. See it green. Keep the output.
3. Introduce one controlled, representative divergence. Run the same gate.
   Watch it go red the way you intended. Keep the output.
4. Restore the exact state. Watch it go green again.
5. Transform one slice, keeping that gate green. Read
   `references/preservation-cycle.md` for the oracle, the generator and
   config case, and the evidence to keep.

## Step 4: Close the cycle

1. Chronology part of the claim → use an external observer or immutable
   checkpoints the evaluator reruns. Logs the candidate wrote are not
   evidence. Never write checkpoint history after the fact.
2. Restore only the mutations this task made whose pre-state you recorded.
   Leave anything else pending for `finishing-a-branch`. Never delete
   inherited, shared, or user state to manufacture a cycle.
3. **REQUIRED SUB-SKILL:** invoke `verifying-completion` on the exact state
   you are about to call done. This cycle's gate is one row of its ledger,
   not the ledger.
4. Return to whatever invoked this skill: a plan task, a worktree checkpoint,
   or a fix under `debugging`. Run no commit, push, or PR here.

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
