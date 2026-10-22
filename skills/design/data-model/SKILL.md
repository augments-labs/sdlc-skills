---
name: data-model
description: "Defines domain concepts, relationships, state transitions, and invariants before implementation. Use when any of them needs to be introduced, changed, or removed, including stateless rules and pricing engines. Skip when those semantics stay unchanged or are already settled for this task."
---

# Data Model

## When to use

- The work introduces or changes domain concepts: persistent entities, or the
  in-memory ones a stateless engine computes over (pricing, rules, workflow).
- **Skip** when domain concepts, relationships, transitions, and invariants are
  unchanged or already settled for this task. Existing concepts can still need
  remodeling; adding no new entity is not a skip.

## Step 1: Model the domain

Open `assets/data-model-section.md` before the steps below fill it in.

1. Name one concept per entity in the domain's language: what it represents,
   and the words experts use for it. This vocabulary is a deliverable: it is
   used downstream without being redefined.
2. List each entity's attributes with their type and meaning. Write what null
   means and which enumeration values are allowed, not just the column.
3. Map the relationships: cardinality, ownership, and what cascades on delete.
4. Draw the state transitions of each concept that has a lifecycle.
5. For each invariant that must never break, name what enforces it (a
   constraint, a transaction boundary, a test, or a reconciliation) and who
   owns failures.

## Step 2: Lenses, storage, evidence

1. Apply each of the template's eight operational lenses that matches the
   risk. If a lens is omitted, write a skip record with that row's fields.
   Never drop one as "inapplicable" without it.
2. If anything persists, note denormalized or cached data with its source of
   truth, update boundary, and drift repair. If the change is to an existing
   model, fill the template's High-risk classification block. If the route is
   the ordinary one, define migration, mixed-version, and rollback behavior
   (`changing-a-live-schema` builds them). If any answer is off the ordinary
   route, record the domain constraints; `migration-strategy` owns the
   contract.
3. Trace representative reads, writes, transitions, concurrent operations,
   deletions, and existing-data migrations. When a runnable query exists,
   record it and its result. Otherwise name the check that will run later and
   who owns it; never pretend it ran.

## Step 3: Write and present

1. Write the section to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path, preserving the approved sections around it; once its
   identity is issued, the section is never edited. Fill the header:
   predecessor, approval rule, the location of its ledger (the decision
   record: add to it, never rewrite it, and keep it outside the design), and
   the stable ID delta. The identity goes in the ledger row, never the header.
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

   Ask this and end the turn; `clarifying-intent` owns what closes it.
3. If option 1 is chosen and every design section the work needs is approved,
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Gotchas

- The eight operational lenses in Step 2 are counted, and an omitted one
  needs its own skip record, but the lenses themselves live in the template,
  not in this file. Working from memory instead of the template's list is how
  a lens gets skipped with no skip record, because nothing here tells you
  which eighth lens you forgot.
- Cardinality has a steady-state value and a momentary one: during creation,
  before a required relationship holds, and during deletion, when a cascade
  fires into one. Step 1's cardinality mapping does not separate the two, so
  documenting only the steady state leaves the code free to do anything at
  those edges without that being a documented deviation.

Read `references/worked-example.md` when a full domain needs modeling end to
end at this level of rigor: null semantics, momentary versus lifetime
cardinality, state transitions, invariants, denormalization.
