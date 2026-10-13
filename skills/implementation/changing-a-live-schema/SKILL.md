---
name: changing-a-live-schema
description: "Builds an ordinary schema change in phases so a live store serves both code versions during a deploy and after a rollback, until the contract phase ends that. Use when adding, renaming, dropping, or retyping a column or field, adding an index or constraint, splitting a table, changing a stored document shape, or backfilling data on a store a running system reads. Skip a store nothing live reads yet or whose owner has recorded accepted downtime, and a rewrite or whole-store migration, which migration-strategy owns."
---

# Changing a Live Schema

The store outlives every deploy. During a rolling deploy, and again after a
rollback, two versions of the code read and write it at once, so every phase
before contract has to leave the store in a shape both versions can use. This
skill never runs a migration or backfill against a shared or production
store; that runs under the project's deploy process and authority.

## When to use

- A change to a persisted schema that a running system reads or writes while
  the change deploys: a table, column, index, constraint, or a stored
  document or record shape. A backfill on such a store counts.
- **Skip** a store nothing live reads yet (pre-release, development only), or
  one whose owner has accepted downtime for this change. Acceptance is a
  record you can point at: who accepted, when, and the window. Assumed
  acceptance is none; ask the owner and wait.
- **Skip** a rewrite, a migration of a whole store or system, or any change
  `data-model`'s classification put off the ordinary route:
  `migration-strategy` owns its contract, cutover, and rollback. Say so.
- **Skip** while the domain semantics are unsettled. `data-model` decides
  what the data means before anything decides how it moves.

## Step 1: Bind the inputs

Open `assets/schema-change-record.md` before the actions below: they fill
its Inputs section and the data-model identity in its header. A missing
input is a question for its owner, never a value to assume.

1. The settled `data-model` section and the storage-mapping rows this change
   touches. Record its identity and the route its classification block
   records, or "new model" when there is no existing one. Semantics
   unchanged, as for an index or a backfill → record "no data-model
   section" with the reason.
2. The project's migration tool and conventions: where migrations live, how
   they are versioned, and at which deploy step they run.
3. The deploy model: how many code versions run against the store at once
   during a roll, and the exact rollback target, the version that will run
   against the changed store if this deploy is reverted.
4. The store engine and its version. Whether one operation locks, blocks
   writes, or rewrites the table depends on both.
5. The size of the affected data: rows or volume, write rate, and whether
   replicas follow the store.

## Step 2: Sequence as expand → migrate → contract

Each phase is its own deployable change with a stated gate to advance and a
stated rollback. Write every phase into the record's Phases section now;
ship them one at a time, in this order. A phase this change does not need
(an index alone, a standalone backfill) is recorded `not needed: {{reason}}`
in its Phases row, its own section, and its rows in Tests, never left empty.

1. **Expand.** Add the new column, table, index, or field so the previous
   code version runs against it untouched: additive, nullable or defaulted
   in a form the engine applies without rewriting the table, and no
   constraint the old version's writes would violate. Migration runs before
   the code. Rollback: revert the code; the expansion stays and is harmless.
2. **Dual-write and tolerant reads.** The new code writes both shapes and
   reads either, treating a row not yet backfilled as old-shape. Rollback:
   the previous version, which still reads and writes the old shape alone.
3. **Backfill.** Batched over a key the store indexes; idempotent, so a
   batch applied twice leaves the same rows; resumable from a recorded
   cursor; throttled against replication lag and lock wait; observable
   through remaining rows, rate, and errors. Verification compares the two
   shapes by count or checksum and goes in the record. Gate to advance:
   remaining rows zero and verification passed. Never one transaction over
   the table.
4. **Switch reads.** Rollback: the previous change, which reads either
   shape.
5. **Stop old writes.** Rollback: the previous change, which still writes
   both shapes.
6. **Contract.** Drop the old column, table, or field. Code stops using it
   in one deploy; the drop ships in a later one, and only when no live
   version reads the old shape, the rollback target does not read it
   either, verification has been re-run after old writes stopped and
   passed, and retention allows. This is the point of no return: its
   rollback is a restore from the retained backup or snapshot, never an
   application rollback. Name it in the record and put it to the data owner:

   ```text
   Contract for {{change}}: drops {{old column, table, or field}}; no live version or rollback target reads it as of {{evidence}}; verification re-run {{date, result}}; retention {{satisfied how}}.
   After this ships, rolling the application back to {{rollback target}} is no longer possible; recovery is {{restore path and its recovery time}}.

   1. Accept: ship the contract
   2. Hold: keep both shapes until {{condition}}

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it. Record the answer as a ledger row beside the record. No row →
   the contract does not ship.
7. A rename or a type change is add, copy, switch, drop, never in place.
8. A new constraint is added in the form the engine offers that does not
   validate existing rows under a lock, then validated as a separate step.
   The engine offers no such form → the lock is measured in Step 3.

## Step 3: Build each phase under test

1. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for each phase
   this change needs. Four tests are new behaviour, each red before its code:
   - the migration applies to the previous schema version;
   - the backfill run twice changes nothing the second time;
   - the backfill interrupted mid-run resumes to the same end state;
   - reads handle a row not yet backfilled.

   The compatibility test, the previous code version's suite against the
   expanded schema, is preserved behaviour: the plan or task accepts that
   suite as covering its contract, and it runs under that skill's
   preserved-behaviour cycle, seen green, one controlled divergence (an
   expansion the old version cannot tolerate, such as a required column
   with no default) watched red, restored, green again.
2. For every operation that may lock or rewrite (index build, default, type
   change, constraint, drop): read the engine's documentation for that exact
   operation on the exact version and record what it says. A
   production-sized copy exists → run the operation on it and record the
   duration, the lock held, and whether the table was rewritten. None →
   record the operation as **unverified**, in its evidence row and in the
   record's Not verified section, which goes to `release-readiness` as it
   stands. Never leave it blank.
3. Write the deploy-versus-migration order for this phase where the deploy
   process reads it, matching Step 2.
4. A migration already applied anywhere, including a shared test store, is
   never edited. Fix forward with a new one.

## Step 4: Record and hand off

1. Complete `assets/schema-change-record.md` after the phase's tests are
   green: update Tests, lock evidence, and Status, at
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-schema-change-{{phase}}.md`
   unless the user names another place. A later phase names this record as
   its predecessor.
2. Report four lines and decide nothing:

   ```text
   Schema change: {{what}}, phase {{n}} of {{n}} ({{expand | dual-write | backfill | switch-reads | stop-old-writes | contract}}), engine {{name and version}}
   Order: {{migration before code | code only | job under the deploy process | code before migration}}; rollback: {{target}} against {{store state it will meet}}
   Lock and rewrite: {{measured on a production-sized copy | unverified}}
   Point of no return: {{not reached | contract}}; acceptance: {{ledger row identity, or "no row"}}
   ```

3. Continue the ordinary chain to verification, review, and the branch
   decision unchanged. **REQUIRED SUB-SKILL:** at the release step, invoke
   `release-readiness` and hand it the record as evidence for its checks
   that migrations have exercised recovery, that the rollback target is
   named, and that downtime is none or scheduled. An unverified lock line is
   listed there as unverified.
4. Each later phase, contract above all, is its own change through the same
   chain, from Step 1, with the record's predecessor line filled.
5. A feature flag or staged rollout is also requested → that is a separate
   concern under the project's release policy. It does not replace the
   phasing here, and the phasing does not supply it.

## Hard stops

- Running a migration or backfill against a shared or production store from
  this skill. It runs under the deploy process and its authority.
- Removing or rewriting data or schema in the same deploy that stops using
  it.
- Editing a migration that has already been applied anywhere.

## Gotchas

- A column default or a type change that a small store applies in an instant
  rewrites the whole table on some engines and versions — shows when the
  expand migration that took a second in the test suite holds the table for
  minutes in the first shared environment.
- An index built the ordinary way blocks writes for the duration — shows
  when the write error rate climbs while the migration runs, and the
  engine's concurrent form was never checked in Step 3.
- A rename reads as one atomic line in the diff while old instances still
  run against the renamed column — shows when the old version's errors
  appear only during the roll and vanish when it completes.
- A data-access layer or a `SELECT *` that caches the column list at startup
  breaks when a column it never uses is dropped — shows when the old version
  passed the compatibility test against the expanded schema and still fails
  after contract.
- A backfill in one transaction holds locks and builds replication lag for
  its whole run — shows when readers on replicas see stale rows minutes after
  the write, and the backfill cannot be stopped without losing all of it.
- Rolling the application back after contract has run puts code that reads
  the old shape against a store that no longer has it — shows when the
  rollback target in the record was named before contract and never
  reconsidered when contract shipped.

## Common mistakes

- Expanding and contracting in one migration because the change "is small"
  → split it; the old version has to run against the result of every
  migration that ships with the new version.
- Backfilling from the deploy session by hand to finish faster → the
  backfill is a job the deploy process runs, with its cursor and progress
  where the operator reads them.
- Treating a passing compatibility test as proof that contract is safe →
  the test proves the old version tolerates the expanded store; only the
  conditions in Step 2.6 make the drop safe.
