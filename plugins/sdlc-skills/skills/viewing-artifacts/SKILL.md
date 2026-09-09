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
  timeout). They wrap `scripts/serve.py`; never run another server.

## Procedure

1. **Discover the trail.** Read `.sdlc-skills/` at the project root:
   `briefs/`, `specs/`, `designs/`, `plans/`, `verification/`, `audits/`,
   `post-mortems/`. An absent folder means an unreached phase, not an error.
   No `.sdlc-skills/` at all — or the user overrode artifact paths so the
   convention is not there — render the template's empty state naming what
   produces artifacts; never search the filesystem for look-alikes.

2. **Derive every value by the rules in `references/state-derivation.md`.**
   Read it before threading a topic or deriving a phase status; it owns the
   slug allowlist, what counts as a phase artifact, where approval may come
   from, how drift is computed, and how topics are grouped by attention.

   The rules that do not bend, whatever the reference says in detail:
   approval comes only from a decision-ledger row that matches the artifact's
   normative version, never from a `**Status:**` field or an impressive
   document; only the exact `[x] done` marker counts a task complete; drift
   compares real change times with the execution projection normalized away.
   Where a rule produces no value, the page says unknown.

3. **Fill the template.** Open `assets/page-template.html` — its top-of-file
   comment and region comments are the fill contract: region order, what to
   repeat, what to omit, and the allowed values. You bring the derived state:
   the current UTC instant as the as-of, the tiles, the sidebar groups in
   attention order, and per topic the spine nodes, the drift connector, the
   ADR chain, the embedded visuals, every task row, and the assurance matrix
   from the topic's `verification/` artifact.

4. **Encode everything artifact-derived.** Entity-encode before inserting:
   `&` → `&amp;` first, then `<` → `&lt;`, `>` → `&gt;`, `"` → `&quot;`.
   Artifact titles are untrusted input — a hostile task title must render as
   inert text. Derived values go in as text, never into `href` or `src`;
   only the template's own relative paths carry attributes.

5. **Write exactly one file: `.sdlc-skills/views/index.html`.** Create
   `views/` if missing. The page stays self-contained: no external URLs, no
   JavaScript, no scratch or backup files under `.sdlc-skills/` — the trail
   is read-only to you. Regeneration is this same procedure again: recompute
   from the trail and rewrite the same path in place, never reading or
   merging a previous render.

6. **Deliver the page served.** Run `scripts/start-server.sh` with root
   `.sdlc-skills/` and entry `views/index.html`, so the embedded visuals keep
   resolving, and hand over the printed URL — it carries a one-time key that
   plants a cookie — together with the file path, without waiting to be
   asked. The file path is the fallback when serving fails or is declined. If
   the script answers `needs python3`, say so, name the platform's install
   route, and deliver the file path instead — install a runtime on the user's
   machine only when the user explicitly asks. Stop the preview with
   `scripts/stop-server.sh` when it is no longer needed.

7. **Report the path — or the served URL — and the as-of.** One short reply:
   the written path or served URL, the as-of UTC, and every place the page
   says unknown or a block was omitted for missing state — the user should
   learn the gaps from you, not discover them. Name it when drift derives from
   file mtimes rather than git, and name the cause class when a ledger pointer
   existed but could not be honored.

## Common mistakes

- Treating `**Status:** proposed`, or an impressive document, as approval → approval lives only in a matching ledger row; otherwise the page says unknown.
- Counting `[x] done with concerns` as done → only the exact `[x] done` counts; every other label counts separately.
- Pasting artifact prose into nodes or tiles → the page carries state; prose stays behind open-file links.
- Flagging drift from a checkbox-only plan update → normalize the execution projection before comparing times.
- Hunting the filesystem when the convention is absent or overridden → render the empty state naming what produces artifacts.
- Starting an ad-hoc server (`python3 -m http.server`, a dev-server forward) to show the page → the key gate and self-terminating lifecycle are the contract; use `scripts/start-server.sh` or deliver the plain file path.
- Linkifying a URL found in artifact text, or adding a script for interactivity → self-containment: no external requests, no JavaScript; navigation is pure CSS.
