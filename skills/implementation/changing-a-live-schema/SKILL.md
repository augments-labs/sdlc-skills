---
name: changing-a-live-schema
description: "Builds an ordinary schema change in phases so a live store serves both code versions during a deploy and after a rollback: expand, backfill, switch, then contract, each its own deploy with its own rollback. Use when adding, renaming, dropping, or retyping a column or field, adding an index or constraint, splitting a table, changing a stored document shape, or backfilling or fixing data on a store a running system reads. Skip a store nothing live reads yet or whose owner has recorded accepted downtime, and a rewrite or whole-store migration, which migration-strategy owns."
---

# Changing a Live Schema

The store outlives every deploy. During a rolling deploy, and again after a
rollback, two versions of the code read and write it at once, so every phase
has to leave the store in a shape both versions can use. This skill never
runs a migration or backfill against a shared or production store; that runs
under the project's deploy process and authority.

## When to use

- A change to a persisted schema that a running system reads or writes while
  the change deploys: a table, column, index, constraint, or a stored
  document or record shape. A backfill or a data fix on such a store counts.
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

Open `assets/schema-change-record.md` before the actions below; each fills
the section it names. A missing input is a question for its owner, asked
through the harness's user-input action when one exists and printed
otherwise, never a value to assume.

1. The settled `data-model` section on the ordinary route, and the
   storage-mapping rows this change touches. Record its identity.
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
stated rollback. Write every phase into the record now; ship them one at a
time, in this order.

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
4. **Switch reads**, then **stop the old writes**, each its own change.
   Rollback: the previous change, which still writes both shapes.
5. **Contract.** Drop the old column, table, or field. Code stops using it
   in one deploy; the drop ships in a later one, and only when no live
   version reads the old shape, the rollback target does not read it
   either, verification passed, and retention allows. This is the point of
   no return. Name it in the record and put it to the data owner:

   ```text
   Contract for {{change}}: drops {{old column, table, or field}}; no live version or rollback target reads it as of {{evidence}}; retention {{satisfied how}}.
   After this ships, rolling the application back to {{rollback target}} is no longer possible without {{restore path, or "a restore from backup"}}.

   1. Accept: ship the contract
   2. Hold: keep both shapes until {{condition}}

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print
   this block; end the turn; `clarifying-intent` owns what closes it. Record
   the answer as a ledger row beside the record. No row → the contract does
   not ship.
6. A rename or a type change is add, copy, switch, drop, never in place.
7. A new constraint is added in the form the engine offers that does not
   validate existing rows under a lock, then validated as a separate step.
   The engine offers no such form → the lock is measured in Step 3.

## Step 3: Build each phase under test

1. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for each phase,
   with these tests, each failing before its code exists:
   - the migration applies to the previous schema version;
   - the previous code version's suite passes against the expanded schema
     (the compatibility test);
   - the backfill run twice changes nothing the second time;
   - the backfill interrupted mid-run resumes and reaches the same end
     state;
   - reads handle a row not yet backfilled.
2. For every operation that may lock or rewrite (index build, default, type
   change, constraint, drop): read the engine's documentation for that exact
   operation on the exact version and record what it says. A
   production-sized copy exists → run the operation on it and record the
   duration, the lock held, and whether the table was rewritten. None →
   record the operation as **unverified** in the record. `release-readiness`
   reads that line; never leave it blank.
3. Write the deploy-versus-migration order for this phase where the deploy
   process reads it, matching Step 2.
4. A migration already applied anywhere, including a shared test store, is
   never edited. Fix forward with a new one.

## Step 4: Record and hand off

1. Fill every section of `assets/schema-change-record.md` after the phase's
   tests are green, written to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-schema-change.md` unless
   the user names another place. A later phase names this record as its
   predecessor.
2. Report four lines and decide nothing:

   ```text
   Schema change: {{what}}, phase {{n}} of {{n}} ({{expand | dual-write | backfill | switch | contract}}), engine {{name and version}}
   Order: {{migration before code | code before migration}}; rollback: {{target}} against {{store state it will meet}}
   Lock and rewrite: {{measured on a production-sized copy | documented, not measured | unverified}}
   Point of no return: {{not reached | contract, accepted by whom and when}}
   ```

3. Continue the ordinary chain to verification, review, and the branch
   decision unchanged. **REQUIRED SUB-SKILL:** at the release step, invoke
   `release-readiness` with the record; it exercises the recovery and binds
   the rollback target.
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
  conditions in Step 2.5 make the drop safe.
