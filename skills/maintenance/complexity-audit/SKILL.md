---
name: complexity-audit
description: "Audits existing code for accidental complexity: abstraction nothing needs, ownership it should not hold, flexibility nobody uses, or custom machinery a library already provides. Use when existing code should be examined for accidental complexity, or when the user asks whether this is over-engineered, why it is so complicated, or whether all of it is still needed. Skip implementation choices, review of a frozen change, and structural work already approved."
---

# Complexity Audit

Find accidental complexity without calling essential guarantees bloat. This is
diagnosis, not permission to change code.

## When to use

- Audit an existing module or repository independently of a current candidate.
- **Skip** choosing an implementation (`yagni`), reviewing an exact candidate
  (`requesting-code-review`), or applying known structural work
  (`refactor-architecture`).
- A whole-repository claim requires explicit whole-repository scope; otherwise
  name the bounded surface and make no wider claim.

## Step 1: Freeze

1. Open `assets/audit-report.md` before the inventory. Fill *What was
   frozen* first: identity, goal, path boundary, guarantees in force,
   admissible evidence.
2. Predeclare the report path
   `.sdlc-skills/audits/{{YYYY-MM-DD}}-{{topic}}.md`, coordinator-owned,
   outside the audited target's identity. Target drifts → stop or restart.
3. Fill the inventory table: code, dependencies, configuration, build and
   test machinery, generated sources, dynamic, reflection, and registration
   paths, external consumers, operational ownership.
4. Prefer one bounded audit. Large surface → partitions with stable IDs,
   exclusive inventories, cross-boundary edges. Invoke
   `dispatching-parallel-agents` only when read sets, resources, data
   boundaries, and outputs reconcile independently.

## Step 2: Challenge read-only

1. Fill `assets/yagni-auditor.md` with `assets/partition-report.md` before
   dispatching each exact partition, then dispatch per `dispatching-parallel-agents` Step 2.
2. Empty, refused, or unavailable → follow the no-dispatch rule in
   `dispatching-parallel-agents` Step 2.
3. Fill the reconciliation block before any finding: every partition,
   exclusion, cross-boundary candidate, duplicate, failed attempt,
   inconclusive area.
4. Read each returned partition report; open its file if only a location was
   returned. Match Target, Audit inputs, Partition, and Verdict to the frozen
   request and auditor's allowed verdicts. Missing, unreadable, conflicting,
   or mismatched fields → that partition is inconclusive. Retain the report
   unchanged; never infer a repository-wide conclusion from partial coverage.

## Step 3: Publish decisions

1. Per finding: `keep`, `simplify`, `remove`, `decision`, or `investigate`,
   with evidence, guarantee at stake, replacement, how it is verified, what a
   migration or recovery owes. Line count is not authority.
2. Apply or approve nothing. Accepted structural change → `refactor-architecture`.
   Behavior work → its feature or bug route, producing a new verified
   candidate.
3. Verify the report's coverage, then stop. Review or branch finishing runs
   only if the user separately asks to ship the report.

## Gotchas

- Code with no static caller can still be reached through reflection,
  registration, or configuration. A search that finds no caller has not proved
  a removal safe.
- A reconciliation that lists no failed or inconclusive area reads as full
  coverage. Count what was not examined, or a silent gap passes as clean.

## Common mistakes

- “No direct caller” → dynamic, configured, generated, or external use remains
  `investigate` until disproved or deprecated.
- “One implementation” → a seam containing real impedance, policy, or test
  isolation may be justified; apply the deletion test, not a slogan.
- “Tests and rollback are overhead” → a current assurance or recovery guarantee
  owns them; duplicate machinery with no distinct guarantee is the candidate.
- Editing during the audit → freezes neither evidence nor conclusions; report
  first, then obtain separate implementation authority.
