---
name: ui-ux-design
description: "Designs a user interface's flow, states, hierarchy, responsive behaviour, accessibility, content, and visual direction before it is built. Use when a new or revised interface still has open design decisions, or when the user says design this screen, asks what it should look like, or how the user gets through it. Skip backend-only work and cosmetic edits whose direction is already decided."
---

# UI/UX Design

Design the experience and decide its direction before anything is built. In an
existing product, the current system is evidence: extend it unless the brief
explicitly calls for change.

## When to use

- A new or revised flow, screen, or interface leaves behavior, hierarchy, or
  visual direction open.
- **Skip** for backend-only or non-interactive work, and for an exact cosmetic
  edit whose direction is already fixed.
- **Scale down:** a small, settled interface may need only one flow, its
  states, its hierarchy, and its acceptance checks; alternatives are not
  mandatory.

## Available scripts

- **`scripts/start-server.sh`** and **`scripts/stop-server.sh`** — start and
  stop the key-gated localhost preview of a comparison surface (a per-session key,
  an owner watchdog, and an idle timeout). They wrap `scripts/serve.py`; read
  [visual-decisions.md](references/visual-decisions.md) before starting or
  stopping a preview; it owns the details.

## Step 1: Read the real context

Open `assets/ui-ux-section.md` before the steps below fill it in.

1. Establish the requirements and the audience.
2. In an existing project, find its routes, screens, components, tokens, type
   and content patterns, preview tooling, responsive and accessibility
   conventions, and tests.
3. Sort what you found into two buckets: deliberate constraints that bind this
   work, and inconsistencies this work may correct.
4. In an existing product with no evidence reachable, stop. Ask for the
   repository, a preview, screenshots, or the system documentation. Never put
   a generic system in its place.

## Step 2: Frame, flow, hierarchy

1. Name the user's situation, the interface's single primary job, its primary
   affordance (the one control or gesture that does that job), and what
   success and failure each look like.
2. Write each key journey as *given / when / then*, with its entry,
   completion, escape, and recovery.
3. Cover the hidden states wherever they can occur: empty, loading, partial,
   validation, error, offline, no-permission.
4. For each screen, mark what is primary, secondary, contextual, and deferred.
5. Use realistic content in the user's vocabulary. Keep an action's name
   identical across its control, its confirmation, and its errors.

## Step 3: Decide the direction by seeing it

1. If the visual direction is open, read `references/design-quality.md` before
   defining layout, type, color, spacing, shape, imagery, and motion as one
   product-specific system. While the hierarchy is unresolved, add no
   decoration around it.
2. If a visual, spatial, or motion decision is open, read
   `references/visual-decisions.md` before building the comparison surface
   (what shows the variants for comparison: a project preview, a page,
   screenshots, or wireframes), then build it on the first medium in the
   reference's order that fits. A self-contained local page starts from
   `assets/comparison-template.html` before its first variant is written.
   Write 2–4 controlled, meaningfully different variants (requirements,
   content, data, device, and baseline accessibility held the same). Give every version block and every
   variant a stable ID.
3. Deliver the file path and offer to serve the surface. Start the preview
   only after the user accepts, then present its URL:

   ```bash
   bash scripts/start-server.sh --root .sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}/visuals --entry {{decision-slug}}.html
   ```

   If serving fails or is declined, the file path stands as what was
   delivered.
4. Skip the surface only with a recorded reason, which must be one of these:
   every open question is conceptual (its answer does not depend on seeing
   anything); the scale-down clause under *When to use* applies; or the
   uncertainty is feasibility, in which case invoke `prototyping`. Answering
   "what should this look like" in prose alone is the failure this step
   prevents.
5. Fill the template's *Conditions* table for all eight families. For each
   family not answered, write a skip record with an accountable owner.

## Step 4: Classify evidence, compile, present

1. Tag every claim with its kind in the template's *Evidence* table. A
   stakeholder's preference selects a direction; it never proves that users
   can complete the flow. If a usability risk is open, record it as open with
   a named check (the template's *Future evaluator*: what would settle it)
   and an owner.
2. If preferences selected rendered variants, freeze the keyed **Selected
   visual references** collection exactly as `visual-decisions.md` defines it
   before compiling. Memory, a path, or a label is not a contract.
3. Write the whole section to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path, preserving approved sections around it. Selected
   screens, a chosen variant, or an agreed flow are inputs to the section,
   not the section itself.
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

   Ask this and end the turn; `clarifying-intent` owns what closes it.
5. If a successor section replaces this one, its delta (the template's
   *Stable ID delta*) includes the selected visual references.
6. If option 1 is chosen and every design section the work needs is approved,
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

## Gotchas

- One open question can have a conceptual half and a visual half: whether an
  error should block submission, and separately whether that error should
  look alarming or subtle. The skip test in Step 3.4 asks whether every open
  question is conceptual, so settling the conceptual half in prose does not
  release the visual half from being rendered and compared.
- Step 1.3 sorts into two buckets, a deliberate constraint or an
  inconsistency this work may correct, and has none for a pattern that is
  neither: an undocumented accident nobody decided. Filing an unrecognized
  pattern as deliberate by default treats an accident as a constraint instead
  of flagging it as unknown.
- Run without `--root`, `bash scripts/start-server.sh` exits 1, and the
  file-path fallback in Step 3.3 then hides that no surface was served.
- Run without `--entry`, the printed URL opens the visuals directory; that
  directory holds `{{decision-slug}}.html` pages and no `index.html`, so the
  link the user gets returns 404.
- A design request is not consent to a background listener: a preview started
  unasked opens a local port the user never agreed to.

## Common mistakes

- Combining screens that were each selected on their own into a journey nobody
  reviewed.
