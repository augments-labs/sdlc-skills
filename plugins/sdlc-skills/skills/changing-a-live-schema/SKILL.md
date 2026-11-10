---
name: changing-a-live-schema
description: "Phases a live schema change so the store serves both code versions through deploy and rollback. Use when adding, renaming, dropping, or retyping a column or field, adding an index or constraint, splitting a table, changing a stored document shape, or backfilling data on a live store. Skip stores nothing live reads yet or with recorded accepted downtime, and whole-store migrations, which migration-strategy owns."
---

# Changing a Live Schema

Every phase before contract leaves the store in a shape both the new and the
previous code version can use. This skill never runs a migration or backfill
against a shared or production store; that runs under the project's deploy
process and authority.

## When to use

- A change to a persisted schema that a running system reads or writes while
  the change deploys: a table, column, index, constraint, or a stored
  document or record shape. A backfill on such a store counts.
- **Skip** a store nothing live reads yet (pre-release, development only), or
  one whose owner has accepted downtime for this change. Acceptance is a
  record you can point at: who accepted, when, and the window. Assumed
  acceptance counts as no acceptance; ask the owner and wait.
- **Skip** a rewrite, a migration of a whole store or system, or any change
  that `data-model`'s classification took off the ordinary route:
  `migration-strategy` owns its contract, cutover, and rollback. Say so.
- **Skip** while the domain semantics are unsettled. `data-model` decides
  what the data means before anything decides how it moves.

## Step 1: Bind the inputs

1. Open `assets/schema-change-record.md` before sequencing, and fill every
   row of its Inputs table from the project, each with its source. A missing
   input is a question for its owner, never a value to assume.
2. In its header, record the settled `data-model` section and the
   storage-mapping rows this change touches: its identity and the route its
   classification block records, or "new model" when there is no existing
   one. If the semantics are unchanged, as for an index or a backfill,
   record "no data-model section" with the reason.

## Step 2: Sequence as expand, migrate, contract

Each phase is its own deployable change with a stated gate to advance and a
stated rollback. Write every phase into the record's Phases section now; ship them
one at a time, in this order. Record a phase this change does not need (an
index alone, a standalone backfill) as `not needed: {{reason}}` in its
Phases row, its own section, and its rows in Tests; never leave one empty.

1. **Expand.** Add the new column, table, index, or field so the previous
   code version runs against it unchanged: additive, nullable or defaulted
   in a form the engine applies without rewriting the table, and no
   constraint the old version's writes would violate. The migration runs
   before the code. Rollback: revert the code; the expansion stays and is
   harmless.
2. **Dual-write and tolerant reads.** The new code writes both shapes and
   reads either, treating a row not yet backfilled as old-shape. The old
   shape is the source of truth until Switch reads: where a row holds both,
   read the old one. Rollback: the previous version, which still reads and
   writes the old shape alone.
3. **Backfill.** Start it once no version that writes only the old shape is
   live. Batch it over a key the store indexes. Make it idempotent;
   resumable from a recorded cursor; throttled against replication lag and
   lock wait; and observable through remaining rows, rate, and errors. It
   rewrites every row whose two shapes differ, not only rows that lack the
   new one. Write each batch as one conditional statement, or guard each
   row by its version, so it never overwrites a row a live write changed
   after the batch read it. Verification compares the two shapes' values, by
   checksum or row by row, never by count alone, and goes in the record.
   Gate to advance: remaining rows zero and verification passed. Never one
   transaction over the table.
4. **Switch reads.** Rollback: the previous change, which reads either
   shape.
5. **Stop old writes.** Rollback: the previous change, which still writes
   both shapes.
6. **Contract.** Drop the old column, table, or field. Code stops using it
   in one deploy; the drop ships in a later one, and only when no live
   version reads the old shape, the rollback target does not read it
   either, verification passed on its last run before old writes stopped,
   no old-shape write has been observed since, no row lacks the new shape,
   and retention allows. This is the point of no return: its rollback is a
   restore from the retained backup or snapshot, never an application
   rollback. Name it in the record. In the pass whose phase is contract,
   after Stop old writes has shipped, put it to the data owner:

   ```text
   Contract for {{change}}: drops {{old column, table, or field}}; no live version or rollback target reads it as of {{evidence}}; verification last passed {{date}}, before old writes stopped; no old-shape write since and no row without the new shape as of {{evidence}}; retention {{satisfied how}}.
   After this ships, rolling the application back to {{rollback target}} is no longer possible; recovery is {{restore path and its recovery time}}.

   1. Accept: ship the contract
   2. Hold: keep both shapes until {{condition}}

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it. Record
   the answer as a row in the ledger beside the record (add to it, never
   rewrite it). If there is no row, the contract does not ship.
7. A rename or a type change is done as add, copy, switch, drop, never in
   place.
8. Add a new constraint in the form the engine offers that does not validate
   existing rows under a lock, then validate it as a separate step. If the
   engine offers no such form, the lock is measured in Step 3. Relax the
   old column's NOT NULL, or give it a default, in a migration before Stop
   old writes; add the new column's NOT NULL or foreign key only once no
   live version or rollback target writes rows without it.

## Step 3: Build each phase under test

1. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for each phase
   this change needs. Five tests are new behaviour, each red before its code:
   - the migration applies to the previous schema version;
   - the backfill run twice changes nothing the second time;
   - the backfill interrupted mid-run resumes to the same end state;
   - a live write landing between a backfill batch's read and its write is
     not overwritten;
   - reads handle a row not yet backfilled.

   The compatibility test, the previous code version's suite against the
   expanded schema, is preserved behaviour: the plan or task accepts that
   suite as covering its contract, and it runs under that skill's
   preserved-behaviour cycle: the suite is seen green, one controlled
   divergence (an expansion the old version cannot tolerate, such as a
   required column with no default) is watched red, and after it is restored
   the suite is seen green again.
2. For every operation that may lock or rewrite (index build, default, type
   change, constraint, drop): read the engine's documentation for that exact
   operation on the exact version and record what it says. If a
   production-sized copy exists, run the operation on it and record the
   duration, the lock held, and whether the table was rewritten. If there is
   none, record the operation as **unverified**, in its evidence row and in
   the record's Not verified section, which goes to `release-readiness` as
   it stands. Never leave it blank.
3. Give every schema statement that takes an exclusive lock, however brief,
   a lock-wait limit and a retry: queued behind one long transaction, it
   stalls every query behind it. Run an online or concurrent index build
   outside the migration tool's transaction, and drop the invalid index a
   failed build leaves before the retry.
4. Write the deploy-versus-migration order for this phase where the deploy
   process reads it, matching Step 2.
5. A migration already applied anywhere, including a shared test store, is
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
5. If a feature flag or staged rollout is also requested, `rollout-controls`
   owns it. It does not replace the phasing here, and the phasing does not
   supply it.

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

- Expanding and contracting in one migration because the change "is small":
  split it.
- Backfilling from the deploy session by hand to finish faster: the
  backfill is a job the deploy process runs, with its cursor and progress
  where the operator reads them.
- Treating a passing compatibility test as proof that contract is safe: the
  test proves the old version tolerates the expanded store; only the
  conditions in Step 2.6 make the drop safe.
