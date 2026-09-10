---
name: complexity-audit
description: "Use when existing code should be examined for accidental complexity — abstraction nothing needs, ownership it should not hold, flexibility nobody uses, or custom machinery a library already provides. Fires on is this over-engineered, why is this so complicated, and do we still need all of this, even if nobody says complexity or audit. Diagnoses only; it changes no code. Skip implementation choices, exact-candidate review, and structural work already approved."
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

1. Open `assets/audit-report.md`. Fill *What was frozen* first: identity,
   goal, path boundary, guarantees in force, admissible evidence.
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

1. Read `references/yagni-auditor.md`. Dispatch it against each exact
   partition. Record real receipts and terminal outcomes; a name or prompt is
   not dispatch.
2. No independent action available → write that an inline pass ran. An
   explicitly requested independent audit stays pending.
3. Fill the reconciliation block before any finding: every partition,
   exclusion, cross-boundary candidate, duplicate, failed attempt,
   inconclusive area.
4. Copy each auditor's terminal `SDLC_SKILLS_YAGNI_AUDIT` receipt verbatim.
   Missing, malformed, or bound to another identity → that partition is
   inconclusive. Never state a repository-wide conclusion from partial
   coverage.

## Step 3: Publish decisions

1. Per finding: `keep`, `simplify`, `remove`, `decision`, or `investigate`,
   with evidence, guarantee at stake, replacement, how it is verified, what a
   migration or recovery owes. Line count is not authority.
2. Apply or approve nothing. Accepted structural change → `refactor-architecture`.
   Behavior work → its feature or bug route, producing a new verified
   candidate.
3. Verify the report's coverage, then stop. Review or branch finishing runs
   only if the user separately asks to ship the report.

## Common mistakes

- “No direct caller” → dynamic, configured, generated, or external use remains
  `investigate` until disproved or deprecated.
- “One implementation” → a seam containing real impedance, policy, or test
  isolation may be justified; apply the deletion test, not a slogan.
- “Tests and rollback are overhead” → a current assurance or recovery guarantee
  owns them; duplicate machinery with no distinct guarantee is the candidate.
- Editing during the audit → freezes neither evidence nor conclusions; report
  first, then obtain separate implementation authority.
