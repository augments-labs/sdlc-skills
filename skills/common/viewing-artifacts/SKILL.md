---
name: viewing-artifacts
description: "Use when the state of the artifact trail — briefs, specs, designs, plans, execution — needs to be seen at a glance instead of read file by file. Fires on show me the state of my specs and plans, where does my project stand, what needs attention, is my plan still in sync with the spec, and visualize the trail, even if nobody says artifact or viewer. Skip when one artifact must be read, written, or edited."
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

## Step 1: Read the trail

1. Read `.sdlc-skills/` at the project root: `briefs/`, `specs/`,
   `designs/`, `plans/`, `verification/`, `audits/`, `post-mortems/`. Absent
   folder → unreached phase.
2. No `.sdlc-skills/`, or artifact paths overridden → render the template's
   empty state naming what produces artifacts. Never search the filesystem
   for look-alikes.
3. Read `references/state-derivation.md`. Derive every value by its rules:
   slug allowlist, phase artifacts, approval sources, drift, attention
   grouping.
4. Whatever the reference says in detail: approval comes only from a
   decision-ledger row matching the artifact's normative version; only the
   exact `[x] done` marker counts complete; drift compares real change times
   with the execution projection normalized away. No value → the page says
   unknown.

## Step 2: Render

1. Open `assets/page-template.html`. Follow its top-of-file and region
   comments: region order, repeats, omissions, allowed values.
2. Fill: current UTC as-of, tiles, sidebar groups in attention order, and per
   topic the spine nodes, drift connector, ADR chain, embedded visuals, every
   task row, the assurance matrix from `verification/`.
3. Entity-encode every artifact-derived value before inserting: `&` first,
   then `<`, `>`, `"`. Derived values go in as text, never into `href` or
   `src`.
4. Write exactly one file: `.sdlc-skills/views/index.html`. Create `views/`
   if missing. No external URLs, no JavaScript, no scratch or backup files.
   Regeneration recomputes from the trail and rewrites in place; never merge
   a previous render.

## Step 3: Deliver

1. Serve it, root `.sdlc-skills/`, entry `views/index.html`:

   ```bash
   bash scripts/start-server.sh
   ```

2. Hand over the printed URL and the file path without being asked. Serving
   fails or declined → file path. `needs python3` → say so, name the
   platform's install route, deliver the file path. Install a runtime only on
   explicit request.
3. Reply in one short message: path or URL, as-of UTC, every place the page
   says unknown or omitted a block, whether drift came from file mtimes, and
   the cause class of any ledger pointer that could not be honored.
4. No longer needed → `bash scripts/stop-server.sh`.

## Common mistakes

- Treating `**Status:** proposed`, or an impressive document, as approval → approval lives only in a matching ledger row; otherwise the page says unknown.
- Counting `[x] done with concerns` as done → only the exact `[x] done` counts; every other label counts separately.
- Pasting artifact prose into nodes or tiles → the page carries state; prose stays behind open-file links.
- Flagging drift from a checkbox-only plan update → normalize the execution projection before comparing times.
- Hunting the filesystem when the convention is absent or overridden → render the empty state naming what produces artifacts.
- Starting an ad-hoc server (`python3 -m http.server`, a dev-server forward) to show the page → the key gate and self-terminating lifecycle are the contract; use `scripts/start-server.sh` or deliver the plain file path.
- Linkifying a URL found in artifact text, or adding a script for interactivity → self-containment: no external requests, no JavaScript; navigation is pure CSS.
