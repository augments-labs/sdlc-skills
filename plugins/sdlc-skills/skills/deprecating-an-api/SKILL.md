---
name: deprecating-an-api
description: "Retires a public function, method, class, endpoint, response field, CLI flag, config key, event, or message type without breaking callers. Use when removing, replacing, renaming, or sunsetting something others call, setting a removal date or sunset, or when the user says deprecate this, retire this, or stop supporting this. Skip interfaces whose callers are all inside this repository and stored data shapes, which changing-a-live-schema owns."
---

# Deprecating an API

Deprecating and removing are two changes, and only the second one breaks
anyone. This skill produces what `yagni` and `refactor-architecture` wait
for before they delete: a record with the measured remaining use and the
owner's `remove` row (*removal approved*). It never removes an interface in
the change that marks it, and never without that row.

## When to use

- A function, method, class, endpoint, response field, CLI flag, config key,
  event, or message type that other code, other repositories, or other
  teams call is being removed, replaced, renamed, or given a sunset date.
- A metric name, label, or log field that a dashboard or alert reads is
  being renamed or removed; its readers are the callers, and the skip
  below does not apply to it.
- **Skip** when every caller is in this repository and a search finds all
  of them: change the callers and the interface in one change under
  `test-driven-development`.
- **Skip** a stored data shape (a column, field, or document shape):
  `changing-a-live-schema` owns that; hand off and say so. An interface
  that returns the stored shape stays here.

## Step 1: Measure the old path first

Open `assets/deprecation-record.md` before the actions below; they fill its
header, Callers, and Use sections.

1. Record the interface, its owner, and every caller a search finds. A
   search is a lower bound: external consumers, other repositories,
   generated clients, reflection and dynamic dispatch, and old app versions
   that never update do not show in it.
2. If the old path has no per-caller count (a metric or log line carrying
   the caller's identity: client id, package version, user agent, or call
   site), add one and ship it before anything else. The removal date is
   set from what it reports, not from the search.
3. If use cannot be measured, write `unknown` in the Use section. Never
   write zero for a path nothing counts.

## Step 2: Ship the replacement first

1. The replacement exists, is tested, and is documented before the old
   interface is marked; fill the record's Interface section as it ships. If
   there is no replacement, say so in the record;
   the signal in Step 3 then names the end of support, not a replacement.
2. Where the old path can call the new one, make it do so, so the two
   cannot drift apart.
3. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for the
   replacement. The tests of the old path stay green and in place until the
   removal change; they are preserved behaviour, not dead tests.

## Step 3: Mark it and set the date

1. The signal goes where the caller will see it, through the mechanism the
   language or protocol defines; a changelog line or a document alone is
   not a signal:
   - a library: the language's deprecation marker, with the replacement and
     the sunset date in its message;
   - an HTTP endpoint or response field: the `Deprecation` and `Sunset`
     response headers, and a `Link` with `rel="deprecation"` to the
     migration notes;
   - a CLI flag or config key: a warning on the error stream when the flag
     or key is read;
   - an event or message type: a warning logged by the producer where it is
     built, since consumers cannot see a marker;
   - an interface clients are generated from (an API schema or interface
     definition): the schema's own deprecation field, since a marker in the
     handler never reaches a generated client;
   - a metric name, label, or log field: emit both the old and the new
     name until the sunset date, and name the old one in the record's
     Signal section, since a dashboard or alert cannot see a marker.

   Read `references/signal-mechanics.md` before writing an HTTP header, a
   schema deprecation, or a Python, Java, TypeScript, or Go marker: each has
   a form that looks right and signals nothing.
2. A runtime warning fires once per process, or once per caller identity,
   never once per call: a warning on every call floods the logs and gets
   silenced along with the signal.
3. The sunset date belongs to the owner. Use the project's deprecation
   policy if one exists; if none does, ask and end the turn:

   ```text
   Sunset date for {{interface}}: replacement {{name}} shipped in {{version or revision}}; measured use {{n callers per period, or unknown}}; known callers {{list}}.

   1. {{the project's usual notice period, or one release cycle}} from the deprecation release
   2. Another date: print it

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Record the date and its source, the policy or the answer, as the
   sunset-date row in the ledger beside the record.
4. Ship the deprecation as its own change through the ordinary chain. It
   removes nothing. If a caller is in another team's hands, the record's
   Callers table names who was told and how.

## Step 4: Watch, then decide the removal

1. After the sunset date, read the per-caller count over a span that covers
   every caller's cycle (a monthly job calls once a month) and update the
   Use section with the current number and who is behind it.
2. If use is above zero or `unknown` and the system can switch the old path
   off and on, ask the owner for one brownout and end the turn: the old path
   off for a short stated window, back on, then read who complained or
   errored. Run it only on their yes; record the answer and the result.
3. Removal is the point of no return. Put it to the owner with the measured
   use and who breaks, and end the turn; `clarifying-intent` owns what
   closes it:

   ```text
   Remove {{interface}}: sunset {{date}} passed; measured use {{n per period, or unknown}} from {{callers, or "cannot be identified"}}; brownout {{result, or not run}}.
   Removing it breaks {{who}}; they recover by {{replacement}}.

   1. Remove: ship the removal change
   2. Hold until {{condition}}: keep the old path and the signal

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Use that never reaches zero is the owner's call, never the agent's.
   Record the answer as a row in the ledger beside the record; without a
   row, the removal does not ship.
4. The removal is its own change through the ordinary chain, built under
   `test-driven-development`: the old path's tests go in the same change
   as the old path, not before. **REQUIRED SUB-SKILL:** at the release
   step, invoke `release-readiness` and hand it the record.
5. *Removal approved* is this record plus the owner's `remove` row in the
   ledger: the removal change may proceed on it, and a skill that asks for a
   completed deprecation before it deletes accepts it. The deprecation is
   complete only when the record's Status is `removed` and names the ledger
   row; until then, any other ask gets "in progress" and this record's path.

## Hard stops

- Removing the interface in the same change that marks it deprecated.
- Marking an interface deprecated before its replacement ships, when one
  is planned.
- Shipping a removal without a ledger row from the owner, even when the
  measured use is zero.
- Writing zero for use that nothing counts.

## Gotchas

- Where the build treats warnings as errors, the marker turns callers and
  the old path's own tests red. Exempt those tests and each known call site
  by name; never switch the warning class off project-wide or delete the
  tests — shows when the deprecation change itself fails CI.
