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
- **Presence plus a `**Status:** draft|proposed` field** → the artifact exists.
  Decision state is external; its `**Normative version:**` identity is what
  approval binds to. A `**Status:** proposed` field is never approval.
- **Section-level state, file-level freshness.** A brief or design file may
  hold several sections — goals, scope, ADRs — each with its own normative
  identity and ledger row. Derive state per section, freshness per file.
- **Execute** derives from the plan index's checkbox rows. Only the exact marker
  `[x] done` counts complete; `[x] done with concerns`, `blocked`,
  `in progress`, `needs context`, `cancelled`, `superseded`, and `todo` each
  count separately — the same label under a different checkbox is a different
  signal.

## Approval comes only from the decision ledger

Follow the artifact's `**External decision ledger:**` pointer. An ADR section
carries `**External lifecycle ledger:**` instead, whose states are the ADR
vocabulary: accepted, in force, retired, superseded.

Parse best-effort and only the markdown-table form. The matching row is the one
whose `Identity` equals the artifact's normative version *and* whose location
points at that artifact — the same identity string on another file's row is a
different decision.

Any of these renders approval `external/unknown` (pill `pending`, content
`… unknown`): a missing pointer, a missing ledger file, non-table content, an
ambiguous parse, or no matching row. When the pointer exists but could not be
honored — present but unparsable, or ambiguous — the report names that cause
class rather than a bare `unknown`.

## ADR chains

A chain exists only through `Predecessor` links plus ledger state, rendered
newest first in the ADR vocabulary; a superseded record stays `superseded`.
Omit the block when the topic has no decision records.

## Drift

Per artifact file, the last-change time is `git log -1 --format=%ct -- '<path>'`
with the path single-quoted, so an artifact-derived name never reaches the shell
unquoted. Outside a git repository, fall back to the file's mtime and say so in
the report — mtimes are blind where times are equal.

Drift is an artifact newer than a downstream artifact that consumed it — a spec
edited after the plan written against it. Checkbox ticks and status labels in
the plan index are the mutable execution projection, not a normative change:
normalize them away before comparing, so a checkbox-only plan update never
flags. Equal times flag nothing.

## Attention grouping

Needs attention first — drift flags, blocked tasks, decisions derivably pending
from a parsed ledger row — and its first topic is the preselected one. Then
Waiting: active, nothing flagged. Then Complete: everything reached is done,
nothing flagged. With no attention topics, preselect the first waiting, else the
first complete.
