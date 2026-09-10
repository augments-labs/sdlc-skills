---
name: ui-ux-design
description: "Use when a new or revised user interface still has open decisions about flow, state, hierarchy, responsive behaviour, accessibility, content, or visual direction, before it is implemented. Fires on design this screen, what should this look like, and how does the user get through this, even if nobody says UX or design. Skip backend-only work and cosmetic edits whose direction is already decided."
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
  timeout) for a comparison surface. Deliver a surface served: run the
  preview and present its URL with the delivery, without waiting to be
  asked. The file path is the fallback when serving fails or is declined.
  They wrap `scripts/serve.py`;
  [visual-decisions.md](references/visual-decisions.md) owns the details.

## Step 1: Read the real context

Open `assets/ui-ux-section.md` now. Each step fills its section.

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

1. Open visual direction → read `references/design-quality.md`. Define
   layout, type, color, spacing, shape, imagery, motion as one
   product-specific system. Decorate nothing around an unresolved hierarchy.
2. Open visual, spatial, or motion decision → read
   `references/visual-decisions.md`. Build the comparison surface from
   `assets/comparison-template.html`. Author 2–4 controlled, meaningfully
   different variants. Give every version block and variant a stable ID.
3. Serve it and present the URL with the delivery:

   ```bash
   bash scripts/start-server.sh
   ```

   Serving fails or is declined → give the file path.
4. Skip the surface only with a recorded reason: every open question is
   conceptual; the scale-down clause applies; the uncertainty is feasibility
   → `prototyping`. Prose alone for "what should this look like" is the
   failure this step prevents.
5. Fill the template's *Conditions* table for the eight families. Each one
   not answered → a skip record with an accountable owner.

## Step 4: Classify evidence, compile, present

1. Tag every claim with its *Evidence* kind. Stakeholder preference selects a
   direction; it never proves users can complete the flow. Open usability
   risk → record it open with a named evaluator and owner.
2. Preferences selected rendered variants → freeze the keyed **Selected
   visual references** collection exactly as `visual-decisions.md` defines
   before compiling. Memory, a path, or a label is not a contract.
3. Write the whole section to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`
   or the user-set path, preserving approved sections around it. Selected
   screens, a chosen variant, an agreed flow are inputs, not the section.
4. Present and end the turn:

   ```text
   {{Section}} {{path}} — version {{identity}}
   {{summary lines}}

   1. Approve and hand off to planning
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

5. Only option 1 authorizes planning. A preference, praise, silence → nothing.
   Record lifecycle externally.
6. Normative change after issue → a successor with `added / changed / removed
   / preserved` IDs, selected visual references included. Removal needs
   owning approval. Never edit an issued identity.
7. Option 1, and every design section the work needs is approved →
   **REQUIRED SUB-SKILL:** invoke `writing-plans` against this version.

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
