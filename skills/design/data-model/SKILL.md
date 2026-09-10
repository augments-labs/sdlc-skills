---
name: data-model
description: "Use when the domain needs modeling before design or code — the concepts a system stores or computes over: entities, relationships, state transitions, and the invariants that keep them true. Fires for a stateless engine (pricing, rules, workflow) as much as for schema design, and on what are the core objects here, even if nobody says data model or schema. Skip a feature that adds no domain concepts."
---

# Data Model

Model the domain before the code that manipulates it. A domain model is more than columns — it's the concepts, how they relate, the transitions they may make, and the invariants that must always hold. That is true whether or not any of it is ever stored; getting it wrong is the most expensive mistake to fix later.

## When to use

- The work introduces or changes domain concepts — persistent entities, or the in-memory ones a stateless engine computes over (pricing, rules, workflow).
- **Skip** for a feature that adds no domain concepts (a pure UI tweak, plumbing between existing models).

## Step 1: Model the domain

Open `assets/data-model-section.md` now. Each step fills its section.

1. Name one concept per entity in the domain's language: what it represents,
   the words experts use. This vocabulary is a deliverable consumed downstream
   without redefinition.
2. List each entity's attributes with type and meaning. Write null semantics
   and allowed enumeration values, not just the column.
3. Map relationships: cardinality, ownership, what cascades on delete.
4. Draw state transitions per concept with a lifecycle. An undrawn transition
   is one the code permits by accident.
5. Per material invariant, name the constraint, transaction boundary, test,
   or reconciliation enforcing it, and who owns failures.

## Step 2: Lenses, storage, evidence

1. Apply each of the template's eight operational lenses that matches the
   risk. Omitted lens → a skip record with that row's fields. Never drop one
   as "inapplicable" without it.
2. Anything persists → note denormalized or cached data with source of truth,
   update boundary, drift repair. Existing-model change on the ordinary
   route by `migration-strategy`'s four questions → define migration,
   mixed-version, rollback. Classified high-risk → record domain
   constraints; `migration-strategy` owns the contract.
3. Trace representative reads, writes, transitions, concurrent operations,
   deletion, existing-data migration. Record the runnable query and result
   when one exists. Otherwise name the future evaluator and owner; never
   pretend it ran.

## Step 3: Write and present

1. Write the immutable section to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it. Fill the header: identity,
   predecessor, approval rule, ledger location, stable ID delta.
2. Present and end the turn:

   ```text
   {{Section}} {{path}} — version {{identity}}
   {{summary lines}}

   1. Approve and hand off to planning
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

3. Only option 1 hands off. Praise, silence, a partial reply → pending.
   Record lifecycle externally.
4. Normative change after issue → a successor with a per-ID `added / changed /
   removed / preserved` delta. Removal needs owning approval. Never edit an
   issued identity.
5. Option 1, and every design section the work needs is approved →
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Common mistakes

- Skipping the model because nothing is stored — a stateless engine's invariants are still the spec its tests come from.
- Columns without invariants — the schema says what *can* be stored, not what must be *true*.
- Ignoring null semantics and cardinality — where data bugs are born.
- Naming an invariant without the transaction, constraint, test, or repair that
  keeps it true under races and retries.
- Treating migration, deletion, or mixed-version operation as somebody else's
  problem after the model is approved.
- Modeling the UI's shape instead of the domain's.

For a full domain modeled end to end at this level of rigor — null semantics, momentary vs lifetime cardinality, state transitions, invariants, denormalization — see `references/worked-example.md`.
