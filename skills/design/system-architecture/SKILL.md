---
name: system-architecture
description: "Use when approved requirements need a target system design before planning or implementation: components, boundaries, data flow, failure and recovery, and which seams are worth their cost. Fires on how should we structure this and what are the moving pieces, even if nobody says architecture. Skip the transition from an existing system, and skip a small feature whose structure fits inside its own task or plan."
---

# System Architecture

Design the shape of the solution before anyone builds it: what the pieces are, how they fit, and where the seams go. Aim for **deep modules**, not a sprawl of shallow ones.

## When to use

- You have approved requirements and the work is non-trivial — a new subsystem, several components, real integration.
- **Skip** for a small feature; keep its structure in the bounded task or plan
  rather than creating a separate architecture artifact.
- This skill owns the target system's structure. `migration-strategy` owns how an
  existing system reaches that target; `verification-strategy` owns the
  initiative-wide proof battery.

## Step 1: Trace and structure

Open `assets/architecture-section.md` now. Each step fills its section.

1. Map every requirement, preserved obligation, and material risk to the
   component, interface, and owning evaluator reference covering it. Define no
   assurance gates here. Unmapped row → approval blocked.
2. Name each module by what it does and does not do. Removing it would spread
   its complexity across callers → it stays. Complexity merely relocates →
   merge it.
3. Follow request, response, event, and sensitive-data paths from entry to
   effect. Mark ownership, authorization boundaries, source-of-truth
   transitions.
4. Per dependency and asynchronous path, write timeouts, retry and
   idempotency, degraded operation, recovery, how each is exercised.

## Step 2: Operational views and seams

1. Cover each view that affects correctness: deployment and runtime topology,
   scale and resource budgets, observability, rollout and compatibility
   capabilities. Transition procedure belongs to the migration contract; do
   not restate it.
2. Omitted view → a skip record with the fields in the template's
   operational-views table. Never drop one as "inapplicable" without it.
3. Place a seam only for repeated behavior with a stable owner and measured
   change friction, or one real volatile or external boundary with measured
   impedance, failure policy, or test isolation. Hypothetical variation earns
   none.
4. Hard-to-reverse choice → invoke `architecture-decisions`. Unresolved
   material choice → invoke `interview-me`. Use the domain's language
   throughout.

## Step 3: Write, review, present

1. Write the immutable section to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it. Fill the header: identity,
   predecessor, approval rule, ledger location, stable ID delta.
2. Classified high-risk on any of `migration-strategy`'s four questions
   (reviewability, preservation, breadth, failure surfaces), or marked so
   by the user → run `references/design-review.md` before presenting.
   Blocking.
3. Present and end the turn:

   ```text
   {{Section}} {{path}} — version {{identity}}
   {{summary lines}}

   1. Approve and hand off to planning
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

4. Only option 1 authorizes planning. Praise, silence, prior-version approval
   → nothing. Record lifecycle externally.
5. Normative change after issue → a successor with a per-ID `added / changed /
   removed / preserved` delta. Removal needs owning approval. Never edit an
   issued identity.
6. Option 1, and every design section the work needs is approved →
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Common mistakes

- Shallow modules — an interface as wide as the implementation behind it.
- Untested external-service paths — "it'll work in prod" is not a design.
- Components with no trace back to a requirement, or requirements with no
  component and evaluator.
- A happy-path diagram with no trust, recovery, runtime, or rollout view despite
  risks on those surfaces.
- Designing for hypothetical futures with no measured boundary pressure.
- Generic vocabulary that hides the domain.

For a high-risk design, use `references/design-review.md` before anyone plans
against it.
