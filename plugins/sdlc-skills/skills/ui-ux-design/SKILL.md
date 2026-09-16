---
name: ui-ux-design
description: "Designs a user interface's flow, states, hierarchy, responsive behaviour, accessibility, content, and visual direction before it is built. Use when a new or revised interface still has open design decisions, or when the user says design this screen, asks what it should look like, or how the user gets through it. Skip backend-only work and cosmetic edits whose direction is already decided."
---

# UI/UX Design

Design the experience and decide its direction before implementation. In an existing product, the current system is evidence: extend it unless the brief explicitly calls for change.

## When to use

- A new or revised flow, screen, or interface leaves behavior, hierarchy, or visual direction open.
- Visual direction is open — the default is a rendered side-by-side comparison, not a prose description.
- **Skip** for backend-only or non-interactive work, and for an exact cosmetic edit whose direction is already fixed.
- **Scale down:** a small, settled interface may need one flow, its states, hierarchy, and acceptance checks; alternatives are not mandatory.

## Available scripts

- **`scripts/start-server.sh` / `scripts/stop-server.sh`** — start and stop
  the governed localhost preview (per-session key, owner watchdog, idle
  timeout) for a comparison surface. Offer to serve a surface; start the
  preview only after the user accepts, then present its URL. Always deliver
  the file path; it is the fallback when serving fails or is declined.
  They wrap `scripts/serve.py`; read
  [visual-decisions.md](references/visual-decisions.md) before starting or
  stopping a preview; it owns the details.

## Step 1: Read the real context

Open `assets/ui-ux-section.md` before the steps below fill it in.

1. Establish requirements and audience.
2. Existing project → find its routes, screens, components, tokens, type and
   content patterns, preview tooling, responsive and accessibility
   conventions, tests.
3. Sort findings: deliberate constraints you are bound by, and inconsistencies
   this work may correct.
4. Existing product and no evidence reachable → stop. Ask for the repository,
   a preview, screenshots, or the system documentation. Never substitute a
   generic system.

## Step 2: Frame, flow, hierarchy

1. Name the user's situation, the interface's single primary job, the primary
   affordance, what success and failure each look like.
2. Write each key journey as *given / when / then* with entry, completion,
   escape, recovery.
3. Cover the hidden states wherever they can occur: empty, loading, partial,
   validation, error, offline, no-permission.
4. Per screen, mark primary, secondary, contextual, deferred.
5. Use realistic content in the user's vocabulary. Keep an action's name
   identical across control, confirmation, errors.

## Step 3: Decide the direction by seeing it

1. Open visual direction → read `references/design-quality.md` before
   defining layout, type, color, spacing, shape, imagery, motion as one
   product-specific system. Decorate nothing around an unresolved hierarchy.
2. Open visual, spatial, or motion decision → read
   `references/visual-decisions.md` before building the comparison surface.
   Build it from `assets/comparison-template.html` before authoring any
   variant, then author 2–4 controlled, meaningfully different variants. Give
   every version block and variant a stable ID.
3. Deliver the file path and offer to serve the surface. Start the preview
   only after the user accepts, then present its URL:

   ```bash
   bash scripts/start-server.sh --root .sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}/visuals --entry {{decision-slug}}.html
   ```

   Serving fails or is declined → the file path stands.
4. Skip the surface only with a recorded reason: every open question is
   conceptual; the scale-down clause applies; the uncertainty is feasibility
   → `prototyping`. Prose alone for "what should this look like" is the
   failure this step prevents.
5. Fill the template's *Conditions* table for the eight families. Each one
   not answered → a skip record with an accountable owner.

## Step 4: Classify evidence, compile, present

1. Tag every claim with its *Evidence* kind. Stakeholder preference selects a
   direction; it never proves users can complete the flow. Open usability
   risk → record it open with a named gate and owner.
2. Preferences selected rendered variants → freeze the keyed **Selected
   visual references** collection exactly as `visual-decisions.md` defines
   before compiling. Memory, a path, or a label is not a contract.
3. Write the whole section to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path, preserving approved sections around it. Selected
   screens, a chosen variant, an agreed flow are inputs, not the section.
4. Present:

   ```text
   {{Section}} {{path}} — version {{identity (per template)}}
   {{summary lines}}

   1. Approve and hand off to planning
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `clarifying-intent` owns what closes it.
5. A successor's delta includes the selected visual references.
6. Option 1, and every design section the work needs is approved →
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Gotchas

- A single open question can mix a conceptual half with a visual one —
  say, whether an error should block submission, and separately what an
  alarming-versus-subtle error should look like. The skip-surface test in
  Step 3 asks whether every open question is conceptual, so settling the
  conceptual half in prose doesn't clear the visual half's obligation to
  be rendered and compared.
- Step 1's sort has two buckets — a deliberate constraint, or an
  inconsistency this work may correct — with nothing for a pattern that is
  neither, just an undocumented accident nobody decided. Filing an
  unrecognized pattern as deliberate by default is how an accident gets
  treated as a constraint instead of being flagged as unknown.
- Run without `--root`, `scripts/start-server.sh` exits 1, and the file-path
  fallback in Step 3.3 hides that no surface was served.
- Run without `--entry`, the printed URL opens the visuals directory, which
  holds `{{decision-slug}}.html` pages and no `index.html`, so the link the
  user gets returns 404.
- A design request is not consent to a background listener: a preview started
  unasked opens a local port the user never agreed to.

## Common mistakes

- Inventing a parallel design system before reading the one already in the project.
- Showing cosmetic variations when the decision is really hierarchy or flow.
- Describing visual directions in prose when the user needed to see them — the comparison surface is the default for an open direction, not an extra.
- Visualizing a question whose answer is requirements or technical trade-offs.
- Using placeholder content that hides overflow, density, error, and empty-state problems.
- Calling stakeholder preference “usability evidence,” or hiding an unresolved
  risk behind polished visuals.
- Combining individually selected screens into an unreviewed journey.
- Self-approving subjective criteria instead of assigning a human check.
