---
name: complexity-audit
description: "Audits existing code for accidental complexity: abstraction nothing needs, ownership it should not hold, flexibility nobody uses, or custom machinery a library already provides. Use when existing code should be examined for accidental complexity, or when the user asks whether this is over-engineered, why it is so complicated, or whether all of it is still needed. Skip implementation choices, review of a frozen change, and structural work already approved."
---

# Complexity Audit

Find accidental complexity without calling essential guarantees bloat. This is
diagnosis, not permission to change code.

## When to use

- Audit an existing module or repository independently of any state currently
  under check (the exact state being judged right now).
- **Skip** choosing an implementation (`yagni`), reviewing a frozen change
  (`requesting-code-review`), or applying known structural work
  (`refactor-architecture`).
- A whole-repository claim requires explicit whole-repository scope; otherwise
  name the bounded surface and make no wider claim.

## Step 1: Freeze

1. Open `assets/audit-report.md` before the inventory. Fill *What was
   frozen* first: identity, goal, path boundary, guarantees in force, and the
   evidence allowed.
2. Declare the report path up front:
   `.sdlc-skills/audits/{{YYYY-MM-DD}}-{{topic}}.md`. The coordinator (the one
   running this audit, as opposed to a dispatched auditor) owns it, and it
   sits outside the audited target's identity. Identify the target by
   revision. Use a working-tree hash (the template calls it the working-tree
   digest) only when the report path is outside the repository or
   `git check-ignore -q` passes for it: a report inside the tree that is not
   ignored changes the hash the audit froze. If the target is uncommitted and
   the report path is in-tree and unignored, stop; ask for a checkpoint or an
   ignored or out-of-repository report path. If the target drifts, stop or
   restart.
3. Fill every row of the template's inventory table.
4. Prefer one bounded audit. If the surface is large, split it into
   partitions with stable IDs, exclusive inventories, and cross-boundary
   edges. Invoke `dispatching-parallel-agents` only when read sets,
   resources, data boundaries, and outputs reconcile independently.

## Step 2: Challenge read-only

1. Fill `assets/yagni-auditor.md` with `assets/partition-report.md` before
   dispatching each exact partition, then dispatch as
   `dispatching-parallel-agents` Step 2 says.
2. If the dispatch is empty, refused, or unavailable, follow the no-dispatch
   rule in `dispatching-parallel-agents` Step 2.
3. Fill every line of the template's coverage-reconciliation block before any
   finding.
4. Read each returned partition report; open its file if only a location was
   returned. Match Target, Audit inputs, Partition, and Verdict to the frozen
   request and to the auditor's allowed verdicts. If a field is missing,
   unreadable, conflicting, or mismatched, that partition is inconclusive.
   Keep the report unchanged; never infer a repository-wide conclusion from
   partial coverage.

## Step 3: Publish decisions

1. Fill every column of the template's findings table, one row per finding.
   Line count is not authority.
2. Apply or approve nothing. If a structural change is accepted, invoke
   `refactor-architecture` for it. Behavior work goes to its feature or bug
   route, which produces a new, verified state under check.
3. Verify the report's coverage, then stop. Review or branch finishing runs
   only if the user separately asks to ship the report.

## Gotchas

- Code with no static caller can still be reached through reflection,
  registration, or configuration. A search that finds no caller has not proved
  a removal safe.
- A reconciliation that lists no failed or inconclusive area reads as full
  coverage. Count what was not examined, or a silent gap passes as clean.
- A working-tree hash captured before the audit reports DRIFT once the
  report lands at an unignored path under the audited tree, though no audited
  code changed.

## Common mistakes

- “No direct caller”: dynamic, configured, generated, or external use remains
  `investigate` until disproved or deprecated.
- “One implementation”: a seam containing real impedance, policy, or test
  isolation may be justified; apply the deletion test, not a slogan.
- “Tests and rollback are overhead”: a current assurance or recovery guarantee
  owns them; duplicate machinery with no distinct guarantee is the candidate.
- Editing during the audit freezes neither evidence nor conclusions; report
  first, then obtain separate implementation authority.
