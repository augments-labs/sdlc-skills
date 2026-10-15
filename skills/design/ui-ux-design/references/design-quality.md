# Design Quality Reference

Use this when visual direction is open or an existing direction needs critique. It is a quality lens, not a house style: the product, audience, content, and established system decide what fits.

## Ground the direction

Before choosing visual treatments, write one sentence for each:

- **Subject:** what world does this product belong to, and what materials, language, or behavior are native to it?
- **Audience:** who is using it, in what setting, with what knowledge, ability, urgency, and device constraints?
- **Job:** what is the single most important thing this interface helps them understand or accomplish?
- **Character:** what should it feel like, and which concrete design decisions will create that feeling?

In an existing product, inventory its tokens, components, typography, imagery, motion, density, and content voice. Preserve coherent decisions. Treat inconsistency as evidence to investigate, not permission to replace the system. If the brief intentionally changes the identity, name that boundary and the migration impact.

Use realistic content early. Real names, amounts, timestamps, images, validation messages, and long or missing values expose design problems that polished placeholders conceal.

## Generate candidate directions

Critique needs something to judge. When the direction is open, generate two or
three *different* candidates before refining any of them — one candidate is a
preference, three are a decision. Derive each from the grounding sentence, not
from a generic gallery.

**Style families** — starting points, not costumes; mix deliberately:

- **Editorial minimal** — generous whitespace, strong type hierarchy, restrained
  color. Content-forward products, publishing, professional tools.
- **Soft depth** — low-contrast surfaces, subtle shadow, rounded shape. Wellness
  and calm consumer products; verify contrast floors early.
- **Brutalist** — exposed structure, hard borders, grotesque or mono type, high
  contrast. Developer tools and products whose character is anti-polish.
- **Layered glass** — translucency and blur over imagery. Media-rich consumer
  products; costly on low-end devices and a contrast risk.
- **Data-dense** — compact spacing, tabular numerals, muted palette, one reserved
  accent. Dashboards, operations consoles, finance.
- **Playful illustrated** — custom illustration, organic shapes, saturated
  palette, expressive motion. Consumer onboarding and education.
- **Premium** — serif display type, warm-neutral or dark palette, slow motion,
  wide spacing. Hospitality, fashion, high-end services.
- **System-native** — platform conventions and stock components. Internal tools,
  forms-heavy workflows, accessibility-critical products.

**Derive the palette from character.** Translate the character words into one
anchor hue from the product's world — a spa's calm reads as muted green or warm
clay; a bank's trust reads as deep blue. Build two or three supporting tones
around it, let neutrals carry most of the surface, and reserve exactly one
accent for the primary action and one for destructive acts. Check contrast at
decision time, not after implementation.

**Derive type from character and density.** One display face plus one text face
suffices for most products. Serif display reads editorial, premium, traditional;
grotesque reads neutral and modern; geometric sans reads friendly; monospace
accents read data and developer. Data-dense products need tabular figures and a
text face that stays legible at small sizes.

**Make candidates differ on a real axis.** Vary structure — layout, hierarchy,
navigation — or character, meaning two different families above. Two palettes
over one layout is one candidate, not two.

## Build a coherent visual language

- **Hierarchy and layout:** make reading order and the primary affordance obvious before styling details. Grids, alignment, grouping, dividers, labels, and numbering should encode real structure. Responsive design may change order, density, grouping, and navigation; it is not merely a smaller desktop.
- **Typography:** assign roles for display, body, controls, labels, and data. Choose scale, weight, width, line length, and spacing deliberately. A type treatment should support the product's character while remaining readable under real content and text scaling.
- **Color:** give each color a job such as action, status, surface, emphasis, or data distinction. Check contrast across states and themes. Do not make color the only carrier of meaning.
- **Spacing and shape:** use a consistent rhythm and let proximity express relationships. Radius, borders, shadows, and depth should reinforce the chosen character instead of appearing because they are common defaults.
- **Imagery and icons:** use them when they clarify subject, action, or state. Match their visual language and provide text alternatives where content would otherwise be lost.
- **Motion:** use motion to explain change, preserve orientation, provide feedback, or create one deliberate moment. Avoid scattered effects. Specify reduced-motion behavior and make completion independent of animation.
- **Signature:** choose at most one memorable element or interaction that expresses something true about the product. Keep surrounding decisions disciplined so the signature has room to work.

Distinctive does not mean loud. A restrained direction earns its identity through exact type, rhythm, proportion, copy, and interaction. A maximal direction earns it through coherent execution. In both cases, remove decoration that cannot explain its job.

## Critique before deciding

Ask these against the brief and real project:

1. Could this direction be dropped into an unrelated product with only the logo changed? If yes, ground it more deeply.
2. Is the primary job clear in the first few seconds, and does the visual order match the task order?
3. Does each structural or decorative device communicate something true?
4. Are real content extremes and every important unhappy state represented?
5. Does the layout remain coherent at narrow, wide, zoomed, and text-expanded conditions?
6. Are keyboard, focus, contrast, semantics, motion, and non-color cues designed rather than deferred?
7. Is the signature element carrying the character, or are several elements competing for attention?
8. What was removed after critique, and did clarity improve?

Capture the result as a compact direction: concept sentence, visual roles, layout logic, type roles, color roles, spacing/shape, imagery, motion, copy voice, responsive transformations, accessibility commitments, and the one signature if there is one.
