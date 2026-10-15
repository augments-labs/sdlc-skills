---
name: test-driven-development
description: "Makes a test fail for the right reason before the code exists, then makes it pass. Use when any behavior is being added, changed, or fixed — features, fixes, refactors, migrations, generators, or configuration, including behavior that must be preserved — even if the user names only the feature or the bug and never mentions tests or TDD. Skip throwaway spikes and nonbehavioral content or configuration."
---

# Test-Driven Development

Make an executable check fail for the right reason before the code exists, or
make an existing check fail on purpose before you preserve behavior through a
change. Watch it happen; keep the output.

## When to use

- Any feature, fix, refactor, migration, generator, or config that changes
  behavior.
- **Skip** disposable spikes and non-behavioral content or config. Behavior
  from a spike that is then accepted gets rebuilt under a check.
- High-risk target code waits for its approved migration and assurance
  contracts and their entry gates. Work authorized only to build a check
  cannot edit the target or satisfy entry on its own.

## Step 1: Before the first test command

1. If the test command reaches outside the repository (a shared service, a
   real database, the network, a path outside the worktree), write down what
   it touches: the environment and data, the effects, the time and resources,
   the cleanup, and your authority for each. Never aim a test at a shared or
   production surface not written here. If it stays entirely inside the
   repository, write no record.
2. Pin down the public interface and the behavior it promises, from the task,
   the spec, or the approved design. If the meaning is unresolved, invoke
   `clarifying-intent`. Never guess it into a test.
3. Pick the cycle:
   - For new or intentionally changed behavior, go to Step 2.
   - For behavior that must survive a change unchanged, go to Step 3.
   - For a bugfix, go to Step 2, starting from its runnable reproduction.

   Never invent a failure for behavior that already works.

   A task: move `parse_price` into the `money` module, keeping its old import
   working, and make it reject a negative amount, which it accepts today.
   That is two cycles. The move is behavior that must survive unchanged:
   Step 3, with the existing green tests as the check once they are accepted
   as Step 3.1 requires. The rejection is new behavior: Step 2, with its own
   RED first. One test that fails because the import path moved proves
   neither.

## Step 2: New behavior, RED then GREEN

1. Write one test for the next approved behavior.
2. Run it through the project's real test command.
3. Read the failure. Confirm it is the right one: the test was discovered,
   executed, and failed at the intended assertion.

   ```text
   RED, right reason:   FAIL test_rejects_expired_token — AssertionError: expected 401, got 200
   RED, wrong reason:   ERROR test_rejects_expired_token — ImportError: cannot import name 'verify'
   Not RED:             1 skipped, 0 failed
   ```

   On a wrong reason whose cause is not directly visible, or an unexplained
   result, invoke `debugging` before any product code, passing back the
   attempt count `debugging` handed this cycle when the cycle came from
   `debugging`.
4. Keep the output.
5. Record the test's identity, the identity of the evaluator, and the
   expected observable as of this RED, under
   `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/`. If any of the three
   changes later, the cycle is invalid: restart and reach RED again.
6. Write only the code that makes this test pass.
7. Run the new test, then the project's whole test command. Both must be
   green. Report every failing test by name, unrelated ones included; stop,
   and do not filter.
8. Refactor under green. Rerun both. An intended behavior change is a new RED
   cycle under the approval that owns it.

## Step 3: Preserved behavior, GREEN, then a deliberate RED, then GREEN

1. Take the characterization check the task or plan accepted; for high-risk
   work, use the differential check
   from the assurance matrix. An inherited green suite counts only once it
   has been accepted as covering the preservation contract independently of
   the target. Strengthen smoke-only coverage before the first checkpoint.
2. Run it on the current behavior. See it green. Keep the output.
3. Introduce one controlled, representative divergence. Run the same check.
   Watch it go red the way you intended. Keep the output.
4. Restore the exact state. Watch it go green again.
5. Transform one slice, keeping that check green. Read
   `references/preservation-cycle.md` when you pick the oracle, when you meet
   the generator or config case, or when you decide which evidence to keep.

## Step 4: Close the cycle

1. If chronology is part of the claim, use an external observer or immutable
   checkpoints that the evaluator reruns. Logs written by the state under
   check are not evidence. Never write checkpoint history after the fact.
2. Restore only the mutations this task made whose pre-state you recorded.
   Leave anything else pending for `finishing-a-branch`. Never delete
   inherited, shared, or user state to manufacture a cycle.
3. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` on the exact state
   you are about to call done. This cycle's check is one row of that skill's
   evidence record (the ledger: add to it, never rewrite it, and keep it
   outside the state under check), not the whole record.
4. Return to whatever invoked this skill: a plan task, a worktree checkpoint,
   or a fix under `debugging`. Run no commit, push, or PR here.

## Gotchas

- A `debugging` detour does not reset its attempt count. Handing the count back
  on every wrong-reason RED is what lets `debugging`'s circuit breaker trip at
  all.

## Hard stops

- New behavior code created by the current work has no observed behavior RED.
- A new-behavior test passes first run, or fails only because the test cannot
  execute.
- A preservation oracle was never seen green, never made red by a deliberate
  divergence, or derives expected results from the target it judges.
- A preservation checkpoint contains no new oracle even though inherited tests
  were never accepted as covering the preservation contract.
- A behavioral generator or config change tests only text presence or
  generated file existence.
- A test or evaluator, expected observable, corpus, or oracle changed after
  its RED or falsification without invalidating and restarting that cycle.
- A command or divergence lacks authority for its environment, data, effects,
  or cleanup, or lacks verified restoration.
- Throwaway or out-of-cycle code is being copied into the product.

## When you are tempted to skip

| The thought | The reality |
| --- | --- |
| "Too simple to test" | Simple behavior still breaks; use the smallest real check. |
| "I'll write the test after" | For new behavior, that records the implementation instead of leading it. |
| "The port already works, so I need a fake RED" | No: start green, falsify the independent oracle, restore, then preserve it. |
| "I tested it by hand" | An unrepeatable observation cannot guard the next change. |
| "I'd lose the code I wrote" | Revert only your out-of-cycle implementation; sunk cost is not evidence. |
| "The test is hard to write" | The interface or oracle is exposing a design problem; fix that seam. |
| "There's no test framework" | Use the smallest executable assertion that can fail. |
| "It's just generated/config code" | Test the behavioral source and regeneration contract, not text presence. |

## Common mistakes

- Testing internals or mock calls instead of public behavior. Read
  `references/reference.md` and `references/mocking.md` when a test reaches past
  the public interface.
