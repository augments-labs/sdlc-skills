# Handoff template

`handoff` fills this before writing, once Step 1 has settled where it goes.
Copy it, fill every `{{placeholder}}`, and delete nothing silently — a section
you can't fill is a signal the handoff isn't ready, and "next step unknown" is
honest where an omitted section is a trap. Record the destination itself,
along with who may access it and its cleanup owner, in `Storage controls`
below.

```markdown
# Handoff: {{work item name}}

## Storage controls
{{location, intended recipient/storage boundary, disclosure authority, data
class, allowed access, retention/expiry, exact cleanup targets/effects/
recoverability, cleanup owner, cleanup authority, and pending/completed state}}

## Handoff identity
- ID: {{stable handoff ID; the note's digest goes in its ledger, never here}}
- Created / sender / intended recipient and scope: {{exact transfer facts}}
- Predecessor: {{prior handoff identity, or "none"; records are append-only}}

## Goal
{{what this work is trying to achieve, in one or two lines — the WHY}}

## State identity
- Plan/artifact: {{path and version}}
- Branch / commit / workspace: {{exact identity}}
- Workspace inputs: {{staged/unstaged/untracked/relevant ignored/generated paths
  plus controlled external gate-input identities, or "none"}}
- Done: {{what is complete and verified — cite the check that proved it}}
- In flight: {{what is half-done, exactly where it stopped}}

## Decisions and authority
- {{decision and scope}} — because {{reason}} — authorized by {{direct answer or standing default}}
- Pending: {{decision or permission, named options, and who can answer}}

## Evidence
- {{claim}} — `{{command/action}}` from `{{cwd}}` on {{tree/artifact,
  environment, timestamp}} → {{result, stale, or unrun}}

## Gotchas and permissions
{{traps discovered, with file and line references so they can be verified}}
- {{file:line}} — {{what bites and why}}
- {{external/destructive action still awaiting permission, or "none"}}

## Resume first action
Refresh repository, artifact, approval, and time-sensitive external state. Then:
{{single mutation to take only if it remains authorized}}

## Suggested skills
{{which skills the next session should reach for, and at what point}}

## References
{{paths to existing specs, plans, ADRs, commits — the documents NOT duplicated into this handoff}}
```

## A worked example: bad vs good

Bad handoff — a summary of the conversation:

> We spent a while trying to get the cache invalidation working. Tried a few approaches, some didn't work. Eventually got somewhere with the TTL approach. There's still an issue with stale entries. Good luck!

The next session learns nothing resumable: no goal, no state, no next step, and "tried a few approaches" forces it to rediscover each failure.

Good handoff — the state to resume from:

```markdown
# Handoff: cache invalidation for the session store

## Storage controls
Harness handoff store; direct task transfer covers the named successor session;
internal engineering; project-team access; delete only this handoff record after
the task merges or in 14 days; deletion effects are loss of the resume snapshot,
recoverable from retained task artifacts; current session owner has not yet
received cleanup authority, so cleanup is pending.

## Handoff identity
- ID: session-idle-expiry-h4
- Created / sender / intended recipient and scope: 2026-07-30 10:05 UTC /
  current task session / successor task session, resume-only
- Predecessor: session-idle-expiry-h3; this is an append-only successor

## Goal
Entries in the session store expire on idle timeout, not just on absolute TTL.

## State identity
- Plan/artifact: docs/plans/session-expiry/ at revision 3
- Branch / commit / workspace: fix/session-idle-expiry / a1b2c3d / primary checkout
- Uncommitted: src/store/memory.js — half-done sweep pass, not yet wired in
- Done: TTL-based expiry (commit a1b2c3d), covered by store-expiry test
- In flight: idle-expiry sweep — the sweep function exists but is never scheduled

## Decisions and authority
- Sweep-based expiry — direct option selected for revision 3 after the load comparison
- Pending: sweep interval — 30s vs 60s; no answer yet

## Evidence
- TTL behavior — `npm test -- store-expiry` from the repository root on a1b2c3d,
  local test environment, 2026-07-30 10:00 UTC → 12 passed

## Gotchas and permissions
- src/store/memory.js:88 — expiry timestamps are stored in seconds, not milliseconds; mixing them silently expires entries 1000x early
- tests/store-expiry.test.js — the fake-clock helper must be reset between cases or tests pass individually but fail together
- No external or destructive permission pending

## Resume first action
Refresh branch/status, confirm plan revision 3 is still current, and rerun the
store-expiry baseline. Then ask for the pending interval decision; do not wire it
from this handoff alone.

## Suggested skills
- test-driven-development — the sweep scheduling has no failing test yet; write one first
- verification-before-completion — before claiming the idle-expiry behaviour works

## References
- plan directory from writing-plans: docs/plans/session-expiry/
- TTL work: commit a1b2c3d
```

The difference is not length — it's that every line lets the next session *act* without re-deriving.

## What NOT to include

A handoff is a state transfer, not a transcript. Cut all of these:

- **Narration of the session.** What was tried in what order, who said what, how long it took. The next session needs where things *stand*, not how they got there. A failed approach earns one line under Decisions ("rejected X — because Y") only if it would otherwise be retried.
- **Duplicated artifacts.** If the plan, spec, or ADR exists on disk, point to it. Copying its content in creates a second version that drifts the moment either changes.
- **Your working notes verbatim.** Scratch reasoning, dead-end dumps, half-formed ideas. Distill to the decision or the gotcha, delete the journey.
- **Obvious context.** Anything the next session will read from the repo itself in seconds (file listings, the test command in the project README). Handoffs age; the repo doesn't lie at the time it's read.
- **Secrets and personal data.** Keys, tokens, passwords, credentials — redact, always. If a secret is *relevant* (e.g. "the API key expired mid-session"), say that it expired, never what it was.
- **False certainty.** Don't smooth over a half-understood bug with a confident summary. "Root cause not yet found; suspicion is the retry loop, unverified" is a good line. A guessed explanation the next session trusts is worse than none.

## Edge cases

- **Handing off to yourself after compaction.** Write it as if to a stranger — you will have lost exactly the context you're tempted to leave implicit.
- **Multiple open threads.** One handoff document, but a Next step per thread, ordered — never one blended paragraph.
- **Nothing is in flight, only decisions pending.** Still write the handoff; a pending decision with its options recorded is resumable work.
- **The failure is the finding.** If the session's result is "this approach doesn't work," the handoff's Goal stays, State says "approach rejected," and Decisions carries the evidence — so the next session doesn't repeat the experiment.
- **Long-lived handoffs.** If a handoff may sit for days, add a date at the top and double-check every branch/commit reference still exists when you resume.
