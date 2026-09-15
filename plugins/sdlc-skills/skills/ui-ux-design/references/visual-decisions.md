# Visual Decisions

Use a visual comparison when the answer depends on seeing spatial, perceptual, or temporal relationships. The goal is a decision with evidence, not a gallery of attractive options.

## Choose the medium per question

Visualize when comparing layout, grouping, density, navigation, component composition, typography, color roles, imagery, responsive transformation, or motion. Keep the discussion in conversation when deciding requirements, scope, terminology, data rules, technical architecture, or prose-only trade-offs.

A UI topic is not automatically a visual question. “Which steps belong in checkout?” is conceptual. “Which arrangement makes those agreed steps easiest to understand?” is visual.

## Use the first capability that fits

1. **Existing project preview.** Inspect project instructions, scripts, routes, component examples, design-system documentation, fixtures, visual tests, and development tooling. Build isolated variants from the real components, tokens, content shapes, and states. Do not replace the setup or change the production screen before a direction is chosen.
2. **Private native interactive page.** If the environment can create a private, self-contained interactive page, use it for side-by-side comparison or direct tuning. Keep the page grounded in project assets available to the session. Review its audience and content before publishing or sharing it.
3. **Self-contained local page.** Write one page per decision at `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}/visuals/{{decision-slug}}.html` (another path only if the user set one). One stable path per decision — never one file per version, and never a `-v2` sibling: the path the user opened the first time keeps working. Start from `assets/comparison-template.html` — it carries the chrome (tokens, variant and version switchers, decision scaffolding, status pills) and its own fill rules; author only the variants. Use inline styles and vector or embedded assets; make no external requests. Deliver the file path and offer to serve the surface. Only after the user accepts, run `bash scripts/start-server.sh --root .sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}/visuals --entry {{decision-slug}}.html`, with the user-set directory as `--root` when there is one, and hand over the printed URL (it carries a one-time key that plants a cookie) — and never run an ad-hoc server. Stop the preview with `scripts/stop-server.sh` and the `pid` from its startup record when it is no longer needed. If the script answers `needs python3`, say so, name the platform's install route, and deliver the file path instead — install a runtime on the user's machine only when the user explicitly asks. Where nothing can display the page, give the path and preserve a text summary.
4. **Screenshots or wireframes.** Use rendered screenshots when a real preview exists but cannot be shared interactively. Use annotated wireframes when structure is the question and polished visuals would create false confidence. Use text diagrams only when they preserve the relationship being judged.

The richer medium is not automatically better. Match fidelity to the decision: low fidelity for flow and hierarchy, realistic components for density and states, high fidelity for typography, color, imagery, and motion.

## Keep the comparison honest

- Show **2–4 variants**. Fewer can hide a real alternative; more diffuses attention.
- Make variants meaningfully different in structure, hierarchy, affordance, or visual direction. Color swaps are not different layout directions.
- Hold requirements, content, data, device, and baseline accessibility constant so the chosen axis is what changes.
- Use the same realistic happy and unhappy state in every variant. Never make a preferred option look better through better copy or easier data.
- State the question and 2–4 comparison dimensions on the surface: for example task clarity, information density, recovery, scanability, or brand fit.
- Give every viable option its strongest fair version and a one-line trade-off. Do not include a straw option.
- When tuning a continuous value such as density, scale, or motion timing, provide a bounded control only if the medium supports it and the value can be returned explicitly.

## Protect the project and its data

- Start local and private. Do not expose a listener, bind a public interface, or publish/share a page without explicit user approval. The only listener to offer is `scripts/start-server.sh` — key-gated, loopback by default, self-terminating — and it starts only after the user accepts.
- Do not include secrets, credentials, private production data, or unnecessary personal information. Use representative sanitized content.
- Do not fetch external scripts, fonts, images, or data unless the project already depends on them or the user approves the request.
- A comparison page is not an application: do not add a backend, authentication flow, or event receiver for it.
- A click or control state does not count as approval. Browser interaction may inform the discussion, but the user confirms the decision in the conversation.

## Run the decision loop

1. **Name the decision.** State the question, fixed constraints, open axis, fidelity, and evaluation dimensions.
2. **Build one comparison surface.** Put variants together whenever possible so memory and viewport differences do not distort the comparison. Include viewport or state switches only when they serve the decision.
3. **Orient the user.** Say where the surface is, what is controlled, what differs, and what feedback is needed. Preserve an equivalent text summary for accessibility and environments that cannot render it.
4. **Collect reasons, not only a letter.** Ask what works, what fails, and which
   dimension drove the preference. Label it as stakeholder preference unless it
   came from a defined research or usability observation. If the surface can
   prepare a structured decision for copying, still treat the pasted result as
   feedback until confirmed.
5. **Iterate visibly.** Change only the axes implicated by feedback, then
   **append** the new version to the same page as an added version block and
   move the selector's default to it. Never edit the content of a version block
   already issued, and never fork a second file. Keeping prior versions
   selectable beside the new one is what makes them comparable — separate files
   defeat the comparison the retention rule exists for, and leave the user
   guessing which path is current.

   Do not silently overwrite the evidence, and prove it rather than intending
   it: a new version's diff on the surface adds a block and changes only which
   radio carries `checked`. If `git diff` shows deletions inside an existing
   version block, an earlier comparison was rewritten — restore it before
   presenting. Retire a version in metadata outside its immutable block; do not
   delete it.

   Bind each version block to its own content identity and controlled inputs; a
   changed surface/input invalidates affected comparison evidence until
   reconfirmed. Cite evidence as path plus version identity — once versions
   share one path, the path alone no longer identifies what was seen.
6. **Confirm and record.** Write the decision into the versioned whole design.
   Variant confirmation alone does not approve the combined flow; obtain direct
   approval of the exact compiled version before implementation planning.

   Before compiling that whole, freeze **Selected visual references** as a
   keyed collection, with one reference per independently selected decision.
   Each record carries its Reference ID, Decision ID, Medium, Approved design
   artifact version, Artifact locator, Artifact version, Content digest,
   Selection ID, Rendering-input identity, Freshness evaluator, Normative
   conditions, and Distinguishing invariants. A downstream UI task consumes only
   the applicable references.

   Make identity fit the medium. For local HTML, put immutable start/end markers
   around each issued version and identify the stable path, version ID, selected
   variant ID, marker-bounded version bytes, and their SHA-256; appending a new
   version must not alter that digest. Bind shared chrome, assets, controlled
   inputs, and their digest or revision as the Rendering-input identity, so
   unchanged block bytes cannot hide a changed presentation.

   For an existing project preview, or a native preview, bind an immutable
   source or artifact revision plus the route, fixture, environment,
   selected state, and capture set. For a screenshot or wireframe, bind its
   immutable artifact ID, selected frame or region, and whole-file digest.

   A path, visible label, or mutable whole-surface digest is not an identity.
   Before downstream use, run every applicable Freshness evaluator. Its contract
   has exactly four literal outcomes: `pass`, proved `mismatch`, `unavailable`,
   and `error`. A mismatch makes planning, implementation, and visual evidence
   stale: either restore the binding and rerun, or approve a successor design
   and then, when plan-bound, a successor plan. `unavailable` means the required
   environment is absent; `error` means the evaluator failed. Either outcome
   leaves the gate pending until repaired and rerun and proves no drift. Owner
   reconciliation alone cannot change an approved binding.

## Decision record

Record enough for an implementer or reviewer to reconstruct the choice:

- **Question:** the visual or interaction decision being made.
- **Constraints:** existing system, content, states, devices, and accessibility floor held constant.
- **Dimensions:** the named criteria used to compare.
- **Variants:** each direction and its strongest trade-off.
- **Evidence:** preview content identity, controlled inputs, paths/images, and
  classified project fact, research, usability observation, constraint,
  preference, or inference.
- **Decision:** the chosen direction and why it best serves the dimensions.
- **Selected visual references:** the complete keyed records above, one per
  decision, including the applicable medium-specific identity and evaluator.
- **Rejected:** why the other viable directions lost; avoid “not preferred” with no reason.
- **Follow-ups:** unresolved details and usability or implementation risks, each
  with an evaluator and owner; route feasibility uncertainty to `prototyping`.

Keep final comparison evidence with the design record. Record retention, exact
cleanup targets/effects/recoverability, cleanup authority, and disposition.
Only pre-authorized scratch inside an explicitly disposable boundary may be
removed directly. Repository/workspace disposal routes through
`finishing-a-branch`; otherwise cleanup remains pending. Never delete
pre-existing, shared, user-owned, or ownership-uncertain artifacts.
