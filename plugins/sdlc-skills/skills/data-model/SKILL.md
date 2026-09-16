---
name: data-model
description: "Defines domain concepts, relationships, state transitions, and invariants before implementation. Use when any of them needs to be introduced, changed, or removed, including stateless rules and pricing engines. Skip when those semantics stay unchanged or are already settled for this task."
---

# Data Model

Model the domain before the code that manipulates it. A domain model is more than columns — it's the concepts, how they relate, the transitions they may make, and the invariants that must always hold. That is true whether or not any of it is ever stored.

## When to use

- The work introduces or changes domain concepts — persistent entities, or the in-memory ones a stateless engine computes over (pricing, rules, workflow).
- **Skip** when domain concepts, relationships, transitions, and invariants are
  unchanged or already settled for this task. Existing concepts can still need
  remodeling; adding no new entity is not a skip.

## Step 1: Model the domain

Open `assets/data-model-section.md` before the steps below fill it in.

1. Name one concept per entity in the domain's language: what it represents,
   the words experts use. This vocabulary is a deliverable consumed downstream
   without redefinition.
2. List each entity's attributes with type and meaning. Write null semantics
   and allowed enumeration values, not just the column.
3. Map relationships: cardinality, ownership, what cascades on delete.
4. Draw state transitions per concept with a lifecycle. An undrawn transition
   is one the code permits by accident.
5. Per invariant that must never break, name the constraint, transaction
   boundary, test, or reconciliation enforcing it, and who owns failures.

## Step 2: Lenses, storage, evidence

1. Apply each of the template's eight operational lenses that matches the
   risk. Omitted lens → a skip record with that row's fields. Never drop one
   as "inapplicable" without it.
2. Anything persists → note denormalized or cached data with source of truth,
   update boundary, drift repair. Existing-model change → fill the classification block.
   On the ordinary route → define migration, mixed-version, rollback. Any
   answer off the ordinary route → record domain constraints;
   `migration-strategy` owns the contract.
3. Trace representative reads, writes, transitions, concurrent operations,
   deletion, existing-data migration. Record the runnable query and result
   when one exists. Otherwise name the future gate and owner; never
   pretend it ran.

## Step 3: Write and present

1. Write the immutable section to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it. Fill the header: identity,
   predecessor, approval rule, the location of its ledger (append-only,
   outside the design), stable ID delta.
2. Present:

   ```text
   {{Section}} {{path}} — version {{identity (per template)}}
   {{summary lines}}

   1. Approve and hand off to planning
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `clarifying-intent` owns what closes it.
3. Option 1, and every design section the work needs is approved →
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Gotchas

- The eight operational lenses in Step 2 are counted, and an omitted one
  needs its own skip record — but the lenses themselves live in the
  template, not in this file. Working from memory instead of the
  template's list is how a lens gets skipped with no skip record, because
  nothing here tells you which eighth lens you forgot.
- Cardinality has a steady-state value and a momentary one — during
  creation, before a required relationship holds, and during deletion,
  when a cascade fires into one. Step 1's cardinality mapping doesn't
  separate the two, so documenting only the steady state leaves the code
  free to do anything at those edges without that being a documented
  deviation.

See `references/worked-example.md` when a full domain needs modeling end to
end at this level of rigor: null semantics, momentary vs lifetime cardinality,
state transitions, invariants, denormalization.
