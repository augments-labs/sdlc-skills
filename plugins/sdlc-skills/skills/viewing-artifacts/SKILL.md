---
name: viewing-artifacts
description: "Use when the state of an SDLC artifact trail needs to be seen at a glance instead of read file by file — progress across briefs, specs, designs, plans, and execution, what needs attention, and what drifted after a downstream artifact consumed it. Fires on show me the state of my specs and plans, where does my project stand, what needs attention, is my plan still in sync with the spec, and visualize the trail, even if nobody says artifact or viewer. Skip when a specific artifact must be read, written, or edited — viewing is read-only."
---

# Viewing Artifacts

One self-contained page answers "what is the state of my SDLC work, and what
needs attention?" from the `.sdlc-skills/` artifact trail. Every value on it
is derived from a real marker; where no marker exists the page says unknown.
A confident guess is fabrication — the failure this skill exists to prevent.
The page carries state, not documents.

## When to use

- The user asks for the state, progress, or drift of their SDLC work — what needs attention, how far each initiative is, what changed after a downstream artifact consumed it — or asks to see the trail as a page.
- **Skip** when a specific artifact must be read, created, or edited: that is the owning skill's work, and this skill never mutates the trail.
- **Skip** when there is no trail and nobody asked for its state — an unprompted empty page helps nobody.

## Available scripts

- **`scripts/start-server.sh` / `scripts/stop-server.sh`** — start and stop
  the governed localhost preview (per-session key, owner watchdog, idle
  timeout). Deliver the page served and present its URL with the delivery,
  without waiting to be asked; the file path is the fallback when serving
  fails or is declined. They wrap `scripts/serve.py`; never run another
  server.

## Procedure

1. **Discover the trail.** Read `.sdlc-skills/` at the project root:
   `briefs/`, `specs/`, `designs/`, `plans/`, `verification/`, `audits/`,
   `post-mortems/`. An absent folder means an unreached phase, not an error.
   No `.sdlc-skills/` at all — or the user overrode artifact paths so the
   convention is not there — render the template's empty state naming what
   produces artifacts; never search the filesystem for look-alikes.

2. **Thread topics by slug.** `YYYY-MM-DD-<topic>` is the identity and the
   allowlist: only files and directories whose names match that shape are
   threaded — anything else is ignored. The same slug across folders is one
   topic: `designs/<slug>.md`, its `<slug>-migration.md` sibling, and its
   `<slug>/visuals/` directory all belong to it — never split them into
   phantom topics. Plans are directories (`plans/<slug>/00-index.md`). Audits
   and post-mortems thread to their topic by the same slug but render in the
   sidebar and meta only — they never get a spine node or a tier-2 block in
   v1.

3. **Derive phase status from real markers only.** The spine is brief, spec,
   design, plan, execute. For each phase of each topic:

   - **No artifact** → a pending node naming what produces it; no fabricated dates or counts.
   - **Presence plus a `**Status:** draft|proposed` field** → the artifact exists; decision state is external, and its `**Normative version:**` identity is what approval binds to.
   - **Approval comes only from the decision ledger.** Follow the artifact's `**External decision ledger:**` pointer — an ADR section carries `**External lifecycle ledger:**` instead, whose states are the ADR-chain vocabulary (accepted / in force / retired / superseded) — and parse best-effort — only the markdown-table form, matching the row whose `Identity` equals the artifact's normative version and whose location points at that artifact (the same identity string on another file's row is a different decision). A missing pointer, missing file, non-table content, an ambiguous parse, or no matching row → render approval `external/unknown` (pill `pending`, content `… unknown`). A `**Status:** proposed` field is not approval.
   - **Section-level state, file-level freshness.** A brief or design file may hold several sections (goals, scope, ADRs), each with its own normative identity and ledger row; derive state per section, freshness per file.
   - **Execute** derives from the plan index's checkbox rows: only the exact marker `[x] done` counts complete. `[x] done with concerns`, `blocked`, `in progress`, `needs context`, `cancelled`, `superseded`, and `todo` each count separately — the same label under a different checkbox is a different signal.

4. **Compute drift from real change times.** Per artifact file, the
   last-change time is `git log -1 --format=%ct -- '<path>'` — the path
   single-quoted, so an artifact-derived name never reaches the shell
   unquoted; outside a git repository, fall back to the file's mtime. Flag drift when
   an artifact is newer than a downstream artifact that consumed it — a spec
   edited after the plan written against it. Checkbox ticks and status
   labels in the plan index are the mutable execution projection, not a
   normative change: normalize them away before comparing, so a
   checkbox-only plan update never flags. Equal times flag nothing — a
   fresh clone outside git is blind by construction, and that is the safe
   default.

5. **Group topics by attention.** Needs attention first — drift flags,
   blocked tasks, decisions derivably pending from a parsed ledger row — and
   its first topic is the preselected one. Then Waiting: active, nothing
   flagged. Then Complete: everything reached is done, nothing flagged. With
   no attention topics, preselect the first waiting, else the first
   complete.

6. **Fill the template.** Open `assets/page-template.html` — its top-of-file
   comment is the fill contract: region order, allowed values, what to
   repeat, what to omit. You bring the derived state:

   - header `{{page-title}}`, `{{as-of}}`, `{{as-of-iso}}` — the current UTC instant;
   - tiles `{{tile-number}}`/`{{tile-total}}`/`{{tile-label}}` — numbers and short labels, the attention tile last;
   - sidebar groups `{{group-label}}`/`{{group-count}}` attention-first; per topic `{{topic-slug}}`, `{{topic-pill-class}}`/`{{topic-pill-content}}`, `{{dot-1}}`…`{{dot-5}}` in brief→execute order, `{{topic-freshness}}`; the preselected item carries `sel`;
   - one pane per topic in sidebar order, the preselected pane last in DOM with class `default`;
   - spine nodes from the `{{brief-…}}`, `{{spec-…}}`, `{{design-…}}`, `{{plan-…}}`, `{{execute-…}}` stub families (node class, pill, meta, source path);
   - the drift connector `{{drift-explanation}}` directly after the stale node, naming which artifact is newer, by how much, and the re-alignment action — omit when there is none;
   - the ADR chain from the designs file's ADR sections, newest first — chains exist only via `Predecessor` links plus ledger state, rendered in the ADR vocabulary (accepted / in force / retired; a superseded record stays `superseded`) — omit when the topic has none;
   - each `<slug>/visuals/*.html` embedded inline via iframe — the iframe always carries `sandbox` — with an `open file ↗` fallback, paths relative to the page; prose artifacts are linked from node meta, never re-rendered — omit when none;
   - the execute rollup `{{tasks-done}}`/`{{tasks-total}}`/`{{tasks-pct}}`; the per-row stubs `{{task-id}}`/`{{task-title}}`/pill repeat once per task, and every task row is rendered — never elide one, because a hidden row can carry a blocked state, a concerns state, or hostile content; completed-state rows (done, cancelled, superseded — a concerns state is not completed) go into the one optional `<details>` block, closed by default, its summary carrying `{{tasks-completed}}`;
   - the assurance matrix from the topic's `verification/` artifact, one row per gate, keeping the matrix's own state words (executable / planned / blocked) mapped onto pill classes — omit when the topic has none.

7. **Encode everything artifact-derived.** Entity-encode before inserting:
   `&` → `&amp;` first, then `<` → `&lt;`, `>` → `&gt;`, `"` → `&quot;`.
   Artifact titles are untrusted input — a hostile task title must render as
   inert text. Derived values go in as text, never into `href` or `src`;
   only the template's own relative paths carry attributes.

8. **Write exactly one file: `.sdlc-skills/views/index.html`.** Create
   `views/` if missing. The page stays self-contained: no external URLs, no
   JavaScript, no scratch or backup files under `.sdlc-skills/` — the trail
   is read-only to you. Regeneration is this same procedure again: recompute
   from the trail and rewrite the same path in place, never reading or
   merging a previous render. The as-of is the current UTC instant; it is
   the page's staleness signal.

   Deliver the page served: run `scripts/start-server.sh` with root
   `.sdlc-skills/`, entry `views/index.html`, so the embedded visuals keep
   resolving, and hand over the printed URL — it carries a one-time key
   that plants a cookie — together with the file path, without waiting to
   be asked. Stop the preview with `scripts/stop-server.sh` when it is no
   longer needed. Never improvise another server. If the script answers
   `needs python3`, say so, name the platform's install route, and deliver
   the file path instead — install a runtime on the user's machine only
   when the user explicitly asks.

9. **Report the path — or the served URL — and the as-of.** One short reply:
   the written path or served URL, the as-of UTC, and every place the page
   says unknown or a block was omitted for missing state — the user should
   learn the gaps from you, not discover them. When any artifact's change
   time did not come from git, name that drift derives from file mtimes and
   is blind where times are equal. When a stated ledger pointer exists but
   could not be honored — present-but-unparsable or ambiguous — name that
   cause class instead of rendering a bare `unknown`.

## Common mistakes

- Treating `**Status:** proposed`, or an impressive document, as approval → approval lives only in a matching ledger row; otherwise the page says unknown.
- Counting `[x] done with concerns` as done → only the exact `[x] done` counts; every other label counts separately.
- Pasting artifact prose into nodes or tiles → the page carries state; prose stays behind open-file links.
- Splitting `<slug>-migration.md` or `<slug>/visuals/` into their own topics → thread by slug.
- Flagging drift from a checkbox-only plan update → normalize the execution projection before comparing times.
- Hunting the filesystem when the convention is absent or overridden → render the empty state naming what produces artifacts.
- Starting an ad-hoc server (`python3 -m http.server`, a dev-server forward) to show the page → the key gate and self-terminating lifecycle are the contract; use `scripts/start-server.sh` or deliver the plain file path.
- Linkifying a URL found in artifact text, or adding a script for interactivity → self-containment: no external requests, no JavaScript; navigation is pure CSS.
- Assuming git exists → use the mtime fallback; equal times flag nothing.
