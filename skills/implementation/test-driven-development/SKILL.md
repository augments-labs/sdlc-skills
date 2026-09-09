---
name: test-driven-development
description: "Use before behavior-affecting implementation — features, fixes, refactors, migrations, generators, or configuration, including behavior meant to be preserved. Fires on any request to add, change, or fix behavior, even when the user names only the feature or the bug and never mentions tests or TDD. Skip only throwaway spikes and nonbehavioral content or configuration."
---

# Test-Driven Development

Let an executable behavioral gate lead the code. New behavior begins with a
meaningful RED; already-correct behavior begins with a falsified GREEN oracle.
Inventing failure for behavior that should already work is not discipline.

## When to use

- Any feature, fix, refactor, migration, generator, or config that changes
  behavior.
- **Skip** disposable spikes and non-behavioral content or config. Behavior from
  a spike that then gets accepted is rebuilt under a gate.
- For generated output, test the source, the config, the regeneration step, and
  the invariants — not every generated line.
- High-risk target code waits for an approved, current migration and assurance
  contract and for its entry gates to pass. Work authorized only to build a gate
  consumes only its exact proposal: it cannot edit the target, approve the
  contracts, or satisfy entry on its own.

## Choose the entry cycle

Before running any test command, know what it will touch: the environment and
data it runs against, the external effects it causes, the time and resources it
may spend, how it cleans up or recovers, and the authority you hold for all of
that. Never aim a "test" at a shared or production surface you have not declared.

Before writing code, pin the approved public interface and the behavior it
promises. Meaning that is still unresolved goes back to its owner rather than
into a guess.

Then choose the cycle:

### New or intentionally changed behavior: RED first

Write one test for the next approved behavior and run it through the project's
real command. Watch it fail for the missing or incorrect behavior — not for an
import, a syntax error, the harness, an unrelated case, a skip, or a flake — and
retain the output.

Confirm the test you selected was discovered, was executed, and failed at the
intended observation, against a baseline that is otherwise usable. Intermittence
you cannot explain routes to `debugging`.

Freeze the test's identity, the evaluator's identity, and the expected observable
at RED; implementation cannot weaken any of them. If a normative correction turns
out to be required, that invalidates the cycle, and its successor has to reach
RED independently.

A bugfix starts from its runnable failing reproduction. An approved migration
deviation uses this cycle for the behavior it changes.

### Preserved behavior: GREEN → deliberate RED → GREEN

Use the characterization gate accepted with the task or plan — or, for high-risk
work, the assurance matrix's differential gate. An inherited green suite is not
accepted merely because it exists: it has to cover the preservation contract
independently of the target. Strengthen smoke-only coverage before the first
checkpoint, because an empty "characterization" commit proves nothing.

Run the accepted source or current behavior and see it green. Introduce a
controlled, representative divergence, run the same gate, and watch it go red the
way you intended. Restore the exact state and watch it go green again. Only then
transform one slice, keeping that gate green as you go.

Read `references/preservation-cycle.md` for the oracle, generator and config, and
evidence details.

### Implement and refactor

Write only what the current failing behavior or preservation slice requires. Run the relevant gate, then the gate the project
requires; both must be green. Refactor under green and re-run.

When chronology is part of the claim, logs written by the candidate are not
evidence. Use an external observer, or retain immutable checkpoints that the
evaluator independently reruns. Never manufacture checkpoint history after the
cycle.

Refactor only while the observable contract is unchanged. An intended behavior
change returns to the new-behavior RED cycle and to the approval that owns it.

A green cycle ends by invoking `verifying-completion` on the exact state you
are about to call done — the gate this cycle ran is one row of its ledger, not
the ledger. Then return to whatever invoked this skill: a plan task, a worktree
checkpoint, or a fix under `debugging`. This skill never commits, pushes, or
opens a PR on its own.

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

Restore only exact task-created mutations under current authority with known
pre-state/effects/recoverability. Otherwise preserve pending and route workspace
disposition to `finishing-a-branch`; never delete inherited/shared/user state to
manufacture a cycle.

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
