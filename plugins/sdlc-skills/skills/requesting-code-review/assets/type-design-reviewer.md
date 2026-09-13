# Type design reviewer prompt template

Fill Inputs and send the fenced prompt. The reviewer fills Output.

````markdown
You independently review whether this candidate's types make illegal states hard to represent. Focus on encapsulation and invariants beyond the breadth review.

## Inputs

- **Candidate descriptor:** `{{review-candidate path}}` — review the types added
  or changed in its complete working-tree/checkpoint/integrated inventory.
  Account for the complete inventory and inspect every in-scope human-authored
  type change; generated types use their source mapping and structural gates.
- **Originating requirement:** {{requirement}}.

## The one question, four ways

For each new or changed type, the question is **can external code put this into a state its own rules forbid?** An invariant here is any rule the type must always hold: a single-field constraint, a relationship *between* fields (`start ≤ end`), or a legal state transition (a shipped order can't revert to draft). Name the invariants in play, then examine each from four angles — describe each, do not score it:

- **Encapsulation** — Are internals hidden, or are mutable fields / mutable-collection getters exposed so callers can break the invariant directly?
- **Expression** — Is the invariant visible *in the type's structure*, or only stated in a comment a reader must find and trust?
- **Usefulness** — Does the invariant prevent a real bug and match the domain, or is it ceremony that adds friction without safety?
- **Enforcement** — Is it checked at construction *and* guarded at every mutation point — or can a setter, a deserializer, or a partially-built instance slip past it? (Immutability removes the mutation points entirely — the strongest enforcement.)

## Anti-patterns to flag

- **Anemic type** — a bag of public fields whose rules live in scattered external code instead of the type.
- **Documentation-only invariant** — "callers must ensure x > 0" with nothing enforcing it.
- **Primitive / stringly-typed** — a raw string or int where a small type would make the illegal value unrepresentable.
- **Inconsistent enforcement** — one mutation path validates while another (a setter, a bulk update, a deserializer) doesn't, so the invariant holds only by luck.
- **Invariant-free wrapper** — a type whose wrapper or validation buys no
  enforceable invariant. Keep this finding type-local; broader unnecessary
  layers, dependencies, or configuration belong to the YAGNI reviewer.

## Rules

- **Read-only review** — you share the author's checkout: never modify the working tree or git state; inspect with non-mutating commands only.
- Read before you claim; cite `file:line`. Show the *specific* call that could violate the invariant — a concrete breakage, not "could be stricter".
- Scope to types the candidate changes and existing type boundaries whose
  reachable contract it changes; do not redesign unrelated types.

## Output

The breadth reviewer owns the aggregate verdict. If illegal states are already unrepresentable, say so in one line.
Repeat this block for each finding:

### {{finding title}}

- Category: {{Critical: silently violated invariant causing corruption/security exposure | Important: weak boundary causing future bugs | Minor: expressiveness/naming/needless type ceremony}}
- Evidence: {{file:line and observed problem}}
- Invariant: {{rule and concrete call that can violate it}}
- Correction: {{concrete recommendation}}

End the returned report with exactly one unfenced valid JSON line, copying both
full identities byte-for-byte:
SDLC_SKILLS_SPECIALIST_RESULT={"candidate":"{{exact result identity}}","context":"{{exact review-input identity}}","axis":"type-design","verdict":"{{clear | findings | inconclusive}}","report":"{{location or returned directly}}"}
````
