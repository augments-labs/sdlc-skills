# Deriving state from the artifact trail

The rules the page's every value comes from. Read this while threading topics
and deriving phase status; the page shows `unknown` wherever these rules do not
produce a value.

## Threading by slug

`YYYY-MM-DD-<topic>` is the identity and the allowlist: only files and
directories whose names match that shape are threaded; anything else is
ignored. The same slug across folders is one topic — `designs/<slug>.md`, its
`<slug>-migration.md` sibling, and its `<slug>/visuals/` directory all belong
to it. Plans are directories (`plans/<slug>/00-index.md`). Audits and
post-mortems thread to their topic by the same slug but render in the sidebar
and meta only; they never get a spine node or a tier-2 block.

## Phase status

The spine is brief, spec, design, plan, execute. For each phase of each topic:

- **No artifact** → a pending node naming what produces it; no fabricated
  dates or counts.
- **Presence** → the artifact exists, even without a `**Status:**` field.
  Decision state is external; its identity, per its template's `**Identity:**`
  line, is what approval binds to. A draft or proposed label is never approval.
- **Derive state and dependencies per section.** Shared files can hold goals,
  scope, feasibility, or ADRs with separate identities and ledger rows. A
  change in one section does not invalidate an unrelated section's approval.
- **Execute** derives from the plan index's checkbox rows. Only the exact marker
  `[x] done` counts complete; `[x] done with concerns`, `blocked`,
  `in progress`, `needs context`, `cancelled`, `superseded`, and `todo` each
  count separately — the same label under a different checkbox is a different
  signal.

## Approval comes only from the decision ledger

Follow the section's ledger pointer. A pointer that names no path means the
ledger beside the artifact: its path with .ledger.md in place of .md, or
00-index.ledger.md in a plan directory. Preserve the pointer's vocabulary:

- `**External decision ledger:**` — pending, changes requested, approved,
  rejected, cancelled, or superseded.
- `**External lifecycle ledger:**` on an ADR — pending, accepted, in force,
  rejected, cancelled, retired, or superseded.
- `**External condition and decision ledger:**` on feasibility — go, go-if,
  no-go, or cancel, plus each condition's pending, satisfied, or failed state.
  Render go-if with its unmet conditions; recording the decision does not
  satisfy them. Unknown conditions stay unknown, not ready.

Parse best-effort and only the markdown-table form. The matching row is the one
whose `Identity` equals the artifact's identity and whose location and section
identify that content. The same identity on another file or section is a
different decision. Preserve a missing or ambiguous section match as unknown.

Any of these renders approval `external/unknown` (pill `pending`, content
`… unknown`): no ledger file where the pointer, or the artifact's own path,
puts it; non-table content; an ambiguous parse; or no matching row. When the pointer exists but could not be
honored — present but unparsable, or ambiguous — the report names that cause
class rather than a bare `unknown`.

## ADR chains

A chain exists only through `Predecessor` links plus ledger state, rendered
newest first in the ADR vocabulary; a superseded record stays `superseded`.
Omit the block when the topic has no decision records.

## Drift

Compare the upstream identity or content bound by the downstream artifact with
the current normative content, including uncommitted changes. A mismatch proves
drift for that dependency; a matching checked identity establishes freshness
only for that dependency. Never trust a reused version label over changed
content. Normalize the plan index's mutable task checkboxes and execution
labels away; keep task definitions and other normative content in the check.

When the consumed identity or content is unavailable, report freshness unknown.
File times can raise **possible staleness**, not prove drift or freshness: a
later unrelated section, an uncommitted edit, or equal timestamps defeat that
inference. For tracked history use `git log -1 --format=%ct --` with the path as
a separate argument. Never interpolate artifact text into shell code. Outside
Git, use mtime only as that qualified signal and disclose the fallback.

## Attention grouping

Needs attention first — drift or possible-staleness flags, blocked tasks,
unmet feasibility conditions, decisions derivably pending
from a parsed ledger row — and its first topic is the preselected one. Then
Waiting: active, nothing flagged. Then Complete: everything reached is done,
nothing flagged. With no attention topics, preselect the first waiting, else the
first complete.
