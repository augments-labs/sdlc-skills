# Worked example: a lending library

Expanded example behind `../SKILL.md`, loaded on demand. Shows the level of rigor the procedure asks for on a small domain: track which physical copies of books are on loan to which patrons.

## Requirements in one paragraph

The library owns many *copies* of each *book*. A *patron* borrows a copy; a *loan* records when it went out, when it's due, and when it came back. A patron may hold at most five open loans. Staff need to answer: what does this patron currently hold, what is overdue, and is this copy available?

## Entities and attributes

**Book** — the title as a catalog entry, not a physical object.

- `id` — unique identifier.
- `title` — text, required.
- `author` — text, required.
- `isbn` — text, unique, required.

**Copy** — one physical item on a shelf. Separate from Book because availability is per physical item.

- `id` — unique identifier.
- `book_id` — reference to Book, required.
- `status` — enumeration: `available | on_loan | lost | withdrawn`. Never null; every copy is always in exactly one state.
- `acquired_at` — timestamp, required.

**Patron** — someone allowed to borrow.

- `id` — unique identifier.
- `name` — text, required.
- `email` — text, unique, optional. Null means "no email on file" — it does *not* mean "unverified". If unverified vs absent matters, that's a second attribute, not an overloaded null.

**Loan** — the fact that one copy was with one patron for one period.

- `id` — unique identifier.
- `copy_id` — reference to Copy, required.
- `patron_id` — reference to Patron, required.
- `checked_out_at` — timestamp, required.
- `due_at` — timestamp, required.
- `returned_at` — timestamp, optional. **Null semantics: null means the loan is still open.** This one column is how "currently held" and "overdue" are answered, so its meaning must be stated, not implied.

Note the deliberate choice: a loan is never deleted and never edited into a new loan. Returning closes it; borrowing again creates a new row. History is free; mutable loans would erase it.

## Relationships

- **Book 1—N Copy.** A copy belongs to exactly one book. Ownership: Book owns Copy; withdrawing a book withdraws its copies. Deleting a Book with loan history is not allowed — history must stay readable.
- **Patron 1—N Loan.** A loan names exactly one patron. Ownership: the loan's lifecycle is independent — a closed loan remains a historical record under the retention policy; closing it or anonymizing the patron does not delete it.
- **Copy 1—N Loan (over time), Copy 1—0..1 open Loan (at any instant).** This is the relationship everyone gets wrong: the *lifetime* cardinality is one-to-many, but the *at-any-moment* cardinality is one-to-one. Both must be written down; the second is the invariant below.

## State transitions

`Copy.status` is a lifecycle, not just an enumeration — write down the moves, because a transition you don't draw is one the code will permit by accident:

- `available → on_loan` — borrow; the only way a copy leaves the shelf legitimately.
- `on_loan → available` — return closes the open loan and frees the copy in the same transaction.
- `on_loan → lost` — reported lost mid-loan; the open loan stays open (see edge cases).
- `lost → available` — found; any open loan is closed in the same transaction.
  A lost copy is found *before* it can be borrowed again—never
  `lost → on_loan`.
- `available | lost → withdrawn` — terminal and allowed only with no open loan.
  A lost copy with an open loan must settle that loan before withdrawal.

## Invariants

Rules that must always hold — each becomes a constraint where the store can enforce it, and a test everywhere:

1. A copy has **at most one open loan** (`returned_at` is null). Enforce with a uniqueness constraint over open loans per copy — application checks alone race under concurrency.
2. `due_at` is always **after** `checked_out_at`; `returned_at`, when present, is **at or after** `checked_out_at`.
3. A patron has **at most five open loans**. This one is a policy, not a structural rule — enforce it atomically in the borrow operation, cover concurrent borrows with a test, and expect it to change; don't bake "five" into the schema.
4. `Copy.status` **agrees with** the loans: `on_loan` requires exactly one open
   loan; an open loan requires `on_loan` or `lost`; `available` and `withdrawn`
   require no open loan. `lost` may have zero or one open loan because a copy can
   be reported lost before its loan is closed.
5. Every loan references an **existing** copy and patron. Referential integrity on both foreign keys.
6. An `available` or `lost` copy cannot gain a new loan without its status changing first — borrow transitions the copy; it doesn't just insert a row.

## Deliberate denormalization

The `available`/`on_loan` part of `Copy.status` duplicates whether an open loan
exists; the loan is the source of truth for occupancy. The `lost`/`withdrawn`
part is instead the copy's authoritative disposition. State that split plainly:
the borrow/return transaction updates the occupancy projection, loss/withdrawal
updates disposition, and invariant 4 plus a reconciliation query detects any
illegal combination. Calling the whole enum “a cache” would be false because a
loan cannot derive whether a copy was lost or withdrawn.

## Operational challenge

- **Identity and tenancy:** identifiers are stable and globally unique. This
  single-library example has no tenant boundary; if branches become tenants,
  uniqueness, access, and transfer rules must be remodeled rather than assumed.
- **Concurrency and retry:** borrow checks the patron limit and copy state and
  creates the loan in one transaction. Serialize all open-loan changes for a
  patron, then lock the copy in a consistent order; locking only the copy lets
  a patron at four loans borrow two different copies concurrently. The
  open-loan uniqueness constraint guards each copy. An idempotency key prevents
  a retried request from creating a second loan.
- **Time and ordering:** timestamps use one defined time basis. A late return
  event cannot close a newer loan for the same copy; the operation names the
  loan identity, not merely the copy.
- **Retention and privacy:** loan history is retained; patron deletion
  anonymizes identifying attributes under a stated retention policy while
  preserving referential integrity.
- **Compatibility and migration:** derive occupancy from loans and import
  lost/withdrawn disposition from its authoritative records; missing disposition
  is unresolved, never inferred from loan history. During mixed versions and
  rollback, preserve that disposition and reconcile occupancy against loans.
  Revert a reader only to a version that understands both facts; a loan-only
  reader is not a valid rollback target.

The design records the representative transaction tests and reconciliation
query that prove these claims. Until those evaluators run against representative
existing data and concurrent operations, the model is proposed rather than
validated.

## Edge cases the model must answer

- **Due date lands while the copy is already overdue** — fine; overdue is derived (`due_at < now and returned_at is null`), not stored, so no state goes stale at midnight.
- **A copy is reported lost mid-loan** — status `lost` with an open loan is a
  legal, meaningful state; closing the loan does not resurrect the copy.
  Invariant 4 includes this case explicitly.
- **Reborrowing the same copy immediately** — a new loan row, never a reopened old one; overlapping-open-loan checks stay trivial.
- **Patron deleted with history** — don't. Anonymize the patron; loans keep pointing at a real row so reports stay correct.

## Failure patterns this example guards against

- **Two sources of "is it out"** (status column + loans, no named truth for
  occupancy versus disposition) → drift, and no query to trust.
- **Null meaning two things** ("no email" vs "email unverified") → unanswerable queries; split the attribute.
- **Cardinality stated only for the lifetime** ("a copy has many loans") while the real rule is momentary ("one open loan") → the constraint that matters never gets written.
- **Editing history** (updating a loan on renewal) → the audit trail silently disappears.
- **A policy ("five loans") frozen into the schema** → a rule change becomes a migration instead of a config edit.

## Writing your own model

This example shows the rigor, not the format. The section you actually fill in
and emit is `../assets/data-model-section.md`.
