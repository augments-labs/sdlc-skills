---
name: yagni
description: "Challenges scope so only what the task needs gets built, and built completely. Use when code, files, flags, or dependencies are being removed as unused, dead, or legacy; when scope drifts toward speculative or incomplete delivery; when a proposal needs a strict pre-edit challenge; or when anyone says we might need this later or let's make it configurable. Skip throwaway spikes and content or configuration with no behavior."
---

# YAGNI — build only what's needed, and make it work

Cut scope, never correctness. "Needed" means: satisfies the accepted task and
every commitment it inherits (preserved behavior, durable data, public
compatibility, supported environments, security, privacy, accessibility,
observability, recovery, rollback, and the accepted assurance checks) and
runs. Those commitments bind even when the latest prompt does not repeat
them.

## When to use

- Code, files, flags, or dependencies are being removed as unused, dead, or
  legacy.
- Scope drifts toward a speculative addition or an incomplete delivery: "we
  might need this later".
- A proposal needs a strict pre-edit challenge.
- **Skip** a throwaway spike answering one question, and non-behavioral config
  or content.

## Step 1: Before the first edit

1. Write the completion checklist from the accepted task, the commitments
   above, and the project's `coding-standards` exemplar. Without an exemplar,
   use the nearest file in the codebase that does the same kind of thing. List
   names, structure, idioms, and where a non-obvious why is explained.
2. Trace the real flow. Change the owner of the behavior, not the first path
   that shows the symptom. If the cause is unknown, invoke `debugging` first.
3. For each piece of the change, walk the ladder and stop at the first rung
   that holds:
   1. If the need is speculative, skip it and say so.
   2. If something in the codebase fits, with the same semantics, owner,
      dependency, and lifecycle, reuse it.
   3. If the standard library does it, use it.
   4. If a native feature or constraint does it, use it over machinery you
      would own.
   5. If an installed dependency does it, use it. Add no new dependency for
      what a few lines would do.
   6. If one line does it, write one line.
   7. Only then, the minimum code that fully works.

   Read `references/yagni-in-depth.md` before choosing when a rung is arguable.
4. Add no abstraction for variation that is only hypothetical. One real
   boundary, volatile or external, earns a seam only for a measured mismatch
   across it, a failure policy, or test isolation.
5. Lasting surface is a new dependency, a service or process, a generalized
   abstraction, a public extension point or config knob, or a verification
   system. If the user explicitly asked for it, the request is its owner;
   dispatch nothing. For any other lasting surface, or when a strict challenge
   was requested, fill the challenger prompt,
   `assets/yagni-challenger.md` with `assets/challenge-report.md` before
   dispatching it read-only as `dispatching-parallel-agents` Step 2 says, and
   wait.

   Read the report; match its Proposal and Challenge inputs to the request. A
   verdict that is missing, mismatched, conflicting, or invalid counts as
   `inconclusive`. `revise` means the proposal is blocked as written.
   `decision` means its accountable owner decides (the user, unless a plan
   names another); wait for that. `inconclusive` is not clearance.

   The task says "add a retry to the upload call". The draft also adds a
   `maxRetries` setting and a hook for a custom backoff. Neither the task nor
   any commitment it inherits needs either, so each is a speculative knob or
   extension point: rung 1, skip it and say so. Had the user asked to "make the
   retry count configurable", that one setting would be requested surface with
   the request as its owner, and the backoff hook would still be speculative.

## Step 2: Before calling it ready

1. Read every changed line against the Step 1 checklist. A green test waives
   no convention visible in the file. If a neighbour has already drifted from
   one, report that; do not migrate it.
2. Sort every cut you are considering into two lists. Cut only from the first.
   - *Minimal:* removes abstractions, files, dependencies, or lines while
     every guarantee holds.
   - *Unfinished:* removes behavior or an inherited commitment, or leaves a
     stub, TODO, unhandled path, untested logic, unreadable code.
3. Delete only what you proved unused: no static, runtime, reflection, config,
   generated, or external consumer, or a completed deprecation. A search
   proves unused only when its scope is known: a tool skipping ignored,
   binary, generated, or vendored paths yields "not searched", not proof;
   state the scope or rerun without the skips. What stays unknown stays in
   place, or goes to migration or refactor ownership.
4. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` before the claim
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

## Hard stops

- **Minimal never means incomplete.** Smaller breaks ties only between
  solutions that both solve the task and run.
- Before calling it done: the real checks pass, the inputs the task implies
  work, and no required path has a stub, TODO, or placeholder; confirm this
  through `verification-before-completion`.
- Never cut validation at a trust boundary, protection against data loss,
  security, accessibility, or scope the user explicitly asked for.
- **Never minimise away:** preservation, compatibility or parity, durable-data
  safety, observability, recovery or rollback, or a required migration or
  assurance check (a command, a rubric, or an accountable decision that must
  accept the change). The contract that owns each one defines the guarantee;
  YAGNI cannot silently weaken it.
- Minimise only ceremony that owns no guarantee: duplicate checks, speculative
  abstractions, and platforms or knobs nobody committed to.
- Never compress domain names, a non-obvious why, or the conventions that
  govern the file.
- Never delete by confidence. Prove there is no static, runtime, reflection,
  config, generated, or external consumer, or that a deprecation completed;
  what stays unknown stays in place, or goes to migration or refactor
  ownership.

## Gotchas

- Only a strict challenge that was requested, with no action available to
  dispatch it, goes to the question `dispatching-parallel-agents` Step 2 asks.
  Answering `inconclusive` yourself blocks a surface the user explicitly asked
  for.
