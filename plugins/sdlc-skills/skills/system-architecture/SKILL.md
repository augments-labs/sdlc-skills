---
name: system-architecture
description: "Designs the target system for approved requirements: components, boundaries, data flow, failure and recovery, and which seams are worth their cost. Use when approved requirements need a system design before planning or implementation, or when the user asks how to structure this or what the moving pieces are. Skip the transition from an existing system and a small feature whose structure fits inside its own task or plan."
---

# System Architecture

## When to use

- You have approved requirements and the work is not trivial: a new subsystem,
  several components, real integration.
- **Skip** a small feature; keep its structure in its own task or plan rather
  than writing a separate architecture document.
- This skill owns the target system's structure. `migration-strategy` owns how
  an existing system reaches that target; `verification-strategy` owns the set
  of checks the whole initiative runs.

## Step 1: Trace and structure

Open `assets/architecture-section.md` before the steps below fill it in.

1. Map every requirement, preserved obligation, and significant risk to the
   component, the interface, and the owning gate reference that cover it.
   Its owner defines the gate elsewhere; define no assurance gates here.
   Look each gate reference
   up where its owner keeps it: a placeholder, an invented ID, or a gate that
   does not exist there leaves its row unmapped. If a row is unmapped,
   approval is blocked.
2. Name each module by what it does and by what it does not do. If removing it
   would spread its complexity across its callers, it stays. If the complexity
   would merely move elsewhere, merge it.
3. Follow each request, response, event, and sensitive-data path from entry to
   effect. Mark who owns it, where it crosses an authorization boundary, and
   where the source of truth changes hands.
4. For each dependency and each asynchronous path, write its timeout, its
   retry and idempotency, what still works when it is degraded, how it
   recovers, and how each is exercised (the test, fault injection,
   or drill).

## Step 2: Operational views and seams

1. Cover each view that affects correctness: deployment and runtime topology,
   scale and resource budgets, observability, and the capabilities that make
   rollout and compatibility possible. The transition procedure belongs to the
   migration contract; do not restate it here.
2. If a view is left out, write a skip record with the fields the template's
   operational-views table lists. Never drop a view as "inapplicable" without
   one.
3. Place a seam only for repeated behavior with a stable owner and measured
   change friction, or for one real volatile or external boundary with
   measured impedance, a failure policy, or test isolation. Variation that
   is only hypothetical earns none.
4. If a choice is hard to reverse, invoke `architecture-decisions`. If a
   choice that would change the design is unresolved, invoke
   `clarifying-intent`.

## Step 3: Write, review, present

1. Write the section, which is never edited once its identity is issued, to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving the approved sections around it. Fill the header:
   predecessor, approval rule, where its decision record lives (the ledger:
   add to it, never rewrite it, and keep it outside the design), and the
   stable ID delta. The identity goes in the ledger row, never the header.
2. Fill the high-risk classification block. If any answer is off the ordinary
   route, or the user marks the work high-risk, run
   `assets/design-review.md` before presenting. That review is blocking.
3. Present:

   ```text
   {{Section}} {{path}} — version {{identity (per template)}}
   {{summary lines}}

   1. Approve and hand off to planning
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
4. On option 1, if every design section the work needs is approved,
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Gotchas

- Step 1's mapping table needs a real owning gate for every row, but this
  skill defines no assurance gates itself. A row that names a placeholder, or
  a gate its owner never defined, still reads as mapped on the page; only the
  lookup in Step 1 shows that it is unmapped.
- The Skip condition in *When to use* is checked once, at intake. Nothing
  here re-checks it as scope grows, so a feature that starts small and later
  crosses into several components can stay embedded in its task plan instead
  of getting this skill's own architecture record.
