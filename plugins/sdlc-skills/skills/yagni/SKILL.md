---
name: yagni
description: "Use when code, files, flags, or dependencies are being removed as unused, dead, or legacy; when behavior-affecting implementation or configuration is being written or proposed; when scope drifts toward speculative or incomplete delivery; or when a proposal needs a strict pre-edit challenge. Fires on we might need this later and let's make it configurable, even if nobody says scope or YAGNI. Skip throwaway spikes and nonbehavioral content or configuration."
---

# YAGNI — build only what's needed, and make it work

Cut scope, never correctness. "Needed" means: satisfies the accepted task and
every commitment it inherits — preserved behavior, durable data, public
compatibility, supported environments, security, privacy, accessibility,
observability, recovery, rollback, accepted assurance gates — and runs. The
latest prompt need not repeat those for them to bind.

## When to use

- Before the first edit of any behavior-affecting task, alongside
  `test-driven-development`, and again before calling the work ready.
- **Skip** a throwaway spike answering one question, and non-behavioral config
  or content: nothing there has task behavior to scope.

## Step 1: Before the first edit

1. Write the completion checklist from the accepted task, the commitments
   above, and the project's `coding-standards` exemplar. No exemplar → the
   nearest file in the codebase that does the same kind of thing. List names,
   structure, idioms, where a non-obvious why is explained.
2. Trace the real flow. Change the owner of the behavior, not the first path
   that shows the symptom. Unknown cause → invoke `debugging` first.
3. For each piece of the change, walk the ladder and stop at the first rung
   that holds:
   1. Speculative need → skip it and say so.
   2. Something in the codebase fits, same semantics, owner, dependency,
      lifecycle → reuse it.
   3. Standard library → use it.
   4. A native feature or constraint → use it over owned machinery.
   5. An installed dependency → use it. Add none for a few lines.
   6. One line → one line.
   7. Only then, the minimum code that fully works.

   Arguable rung → read `references/yagni-in-depth.md`.
4. Add no abstraction for hypothetical variation. One real volatile or
   external boundary earns a seam only for measured impedance, a failure
   policy, or test isolation.
5. Lasting surface (new dependency, service or process, generalized
   abstraction, public extension point or config knob, verification system),
   or a strict challenge requested → dispatch `references/yagni-challenger.md`
   read-only and wait. `revise` or `decision` → blocked as written.
   `inconclusive` → not clearance.

## Step 2: Before calling it ready

1. Read every changed line against the Step 1 checklist. A green test waives
   no convention visible in the file. A neighbour already drifted → report it;
   do not migrate it.
2. Sort every candidate cut into two lists. Cut only from the first.
   - *Minimal:* removes abstractions, files, dependencies, or lines while
     every guarantee holds.
   - *Unfinished:* removes behavior or an inherited commitment, or leaves a
     stub, TODO, unhandled path, untested logic, unreadable code.
3. Delete only what you proved unused: no static, runtime, reflection, config,
   generated, or external consumer, or a completed deprecation. Unknown →
   stays, or goes to migration or refactor ownership.
4. **REQUIRED SUB-SKILL:** invoke `verifying-completion` before the claim
   leaves this skill.

## When you're tempted to call it done

| The thought | The reality |
| --- | --- |
| "Simplest version: just stub this / return a placeholder" | A stub is an *unsolved* task, not a simpler solution. |
| "I'll keep it minimal and leave a TODO" | YAGNI defers *unneeded* features, never *needed* behaviour. |
| "Shortest diff wins, so I'll touch the smallest spot" | Smallest diff in the wrong place is a second bug. |
| "Skipped the error/edge handling to stay lean" | Correctness is never the thing you minimise. |
| "Simple enough to be obviously right — didn't run it" | Unverified is not done. Run it. |
| "Deleted that code, it looked unused" | Removing needed behaviour to shrink the diff is under-delivery. |
| "Ship the quick version, clean it up later" | Later never comes; every future change pays the re-reading cost. Readable now is the cheaper path. |
| "Clear names and comments are gold-plating" | Gold-plating is unneeded *features*. Clarity is maintenance cost — the thing this skill exists to protect. |
| "My usual style beats this file's conventions" | A codebase in one voice is cheaper to change than your personal best practice. Match it. |

## Hard stops

- **Minimal ≠ incomplete.** Smaller breaks ties only between solutions that both
  solve the task and run.
- Before done: real checks pass, implied inputs work, and no required path has a
  stub/TODO/placeholder; confirm through `verifying-completion`.
- Never cut trust-boundary validation, data-loss prevention, security,
  accessibility, or explicit user scope.
- **Never minimise away:** preservation, compatibility/parity, durable-data
  safety, observability, recovery/rollback, or a required migration/assurance
  gate. Their owning contracts define the guarantee; YAGNI cannot silently
  weaken it.
- Minimise only ceremony owning no guarantee: duplicate gates, speculative
  abstractions, and uncommitted platforms/knobs.
- Never compress domain names, non-obvious why, or governing conventions.
- Never delete by confidence. Prove static/runtime/reflection/config/generated/
  external consumer absence or completed deprecation; unknowns stay or route to
  migration/refactor ownership.

