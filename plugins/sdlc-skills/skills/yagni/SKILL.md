---
name: yagni
description: "Use when code, files, flags, or dependencies are being removed as unused, dead, or legacy; when behavior-affecting implementation, including configuration, is being written or proposed; when scope drifts toward speculative or incomplete delivery; or when a proposal needs a strict pre-edit challenge. Fires on we might need this later and let's make it configurable, even if nobody says scope or YAGNI. Skip throwaway spikes and nonbehavioral content or configuration."
---

# YAGNI — build only what's needed, and make it work

YAGNI minimizes **scope**, never correctness or effort. A smaller solution that
does not solve the accepted task is unfinished. Under pressure, aim the
minimum-diff reflex at unnecessary surface, not at completion.

## The one definition everything hangs on

**"Needed" = satisfies the accepted task and every commitment it inherits, and
runs.** Inherited commitments include preserved behavior and durable data,
public compatibility and supported environments, security/privacy/accessibility,
operational observability and recovery, rollback, and accepted assurance gates.
Latest prompt need not repeat them.

Cutting speculative scope is YAGNI. Cutting a requested or inherited guarantee
is under-delivery wearing YAGNI as a costume. Code size breaks ties only between
equal guarantees and lifecycle risk.

## Completion gate

Before the first edit, derive a checklist of what done will require — from the
accepted contracts, and from the project's current `coding-standards` exemplar or,
where there is none, the nearest analogue already in the codebase.

Before calling the work ready, read the lines you changed against that checklist:
its names, its structure, its idioms, and where it explains a non-obvious why. A
green test run does not waive a convention you can see in the file. Apply the
standard only inside your own scope — where a neighbour has already drifted,
report it rather than silently migrating it. `references/yagni-in-depth.md` holds
the full craft checklist, the ladder worked through in depth, examples, and the
carve-outs.

Some choices are too enduring to make alone. Before committing to a material
lasting surface — a new dependency, a service or process, a generalized
abstraction, a public extension point or configuration knob, a verification
system — or whenever a strict challenge is explicitly requested, dispatch
`references/yagni-challenger.md` read-only. Local, easily reversed choices stay
inline.

A `revise` or `decision` verdict blocks the proposal as it stands, and
`inconclusive` is not clearance. No verdict it returns narrows the accepted scope
or grants authority you did not already have.

## Make the correct path the lazy path

A stub is deferred work plus a bug and future re-reading. The cheapest path is
the smallest complete solution now.

## The ladder — stop at the first rung that holds

1. **Needed at all?** Speculative need → skip it and say so.
2. **Already a real fit?** Reuse only with semantic, owner, dependency, and
   support/security-lifecycle equivalence.
3. **Standard library?** Use it.
4. **Native feature?** Prefer built-ins and constraints over owned machinery.
5. **Installed dependency?** Use it; do not add one for a few lines.
6. **One line?** One line.
7. **Only then:** minimum code that fully works.

No abstraction for hypothetical variation. One real volatile/external boundary
may justify a seam when it contains measured impedance, failure policy, or test
isolation; implementation count alone neither requires nor forbids it.

## The ladder runs AFTER comprehension, never instead of it

Trace the real flow before minimising. The smallest change in the wrong place is
a second bug. Fix the root-cause owner once, not one named path while siblings
stay broken; pair with `debugging` when cause is unknown.

## Minimal ≠ unreadable — craft is not scope

Minimise how much, never how well: use domain names, explain non-obvious why,
and prefer simple over clever.

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

## Final cut audit

**Minimal** removes abstractions, files, dependencies, or lines while preserving
all guarantees. **Unfinished** removes behavior or inherited commitments, or
leaves stubs, unhandled paths, untested logic, or unreadable code. Cut only from
the first list.

## The one exception

A throwaway spike answering a single question, or non-behavioral config/content,
has no task behavior to scope; minimise freely. Everything that affects behavior
gets the full discipline.
