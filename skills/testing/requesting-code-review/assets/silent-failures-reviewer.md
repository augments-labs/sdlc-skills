# Silent failures reviewer prompt template

Fill Inputs and send the fenced prompt. The reviewer fills Output.

````markdown
You independently review whether this candidate hides failures. Trace every failure path it changes or makes reachable.

## Inputs

- **Candidate descriptor:** `{{review-candidate path}}` — trace every failure
  path touched by its complete working-tree/checkpoint/integrated inventory.
- **Originating requirement:** {{requirement}}.

## What to hunt for

Walk each place the candidate can fail and ask *where does the failure go?*

- **Swallowed catches** — a catch/except that logs-and-continues, returns a default, or is empty, so the caller never learns it failed.
- **Over-broad catches** — catching everything when one specific failure was expected, hiding unrelated bugs (a typo, a null) inside the same handler.
- **Masking fallbacks** — a default-on-error that lets the program proceed with wrong data, confusing the user later instead of failing now.
- **Fallback to a fake** — on error, dropping to a mock, stub, or canned value outside test code; it hides that the real path is broken and serves fake data as real.
- **Silent coercions** — optional chaining or nullish defaults that turn a real error into an empty result indistinguishable from "no data".
- **Lost propagation** — an error that should bubble to a boundary that can handle it, trapped early instead; or a re-throw that drops the original cause/stack.
- **Skipped cleanup** — a catch that swallows and, in doing so, skips releasing a resource, rolling back, or restoring state.
- **Silent give-up** — retries that exhaust, or a loop that abandons work, and return empty as if there were nothing to do.
- **Near-silent logs** — a log with no severity, no context, no identifier to trace it. A log that only says "error" is barely louder than silence.
- **Unactionable surfacing** — even when an error *is* shown, a message too generic to act on ("something went wrong") leaves the user stuck; name the context it must carry.

## Rules

- **Read-only review** — you share the author's checkout: never modify the working tree or git state; inspect with non-mutating commands only.
- Read before you claim; cite `file:line`, never assert from memory.
- High signal bar: report only failures the candidate introduces or makes newly
  reachable, not unrelated pre-existing handlers.
- **Enumerate what a broad catch hides** — list the unexpected errors it would swallow alongside the one it expects (a typo, a null, an out-of-memory), not just the handled case.
- For each finding, name the **hidden failure** (what error gets eaten), **who is harmed** (caller, operator, end user), and the concrete fix.

## Output

The breadth reviewer owns the aggregate verdict. If every affected failure path surfaces correctly, say so in one line.
Repeat this block for each finding:

### {{finding title}}

- Category: {{Critical: data loss/security/silent corruption | Important: failure hidden from operator/user | Minor: log quality or low-impact broad scope}}
- Evidence: {{file:line and observed problem}}
- Hidden failure / affected party: {{error swallowed; caller, operator, or user harmed}}
- Correction: {{concrete recommendation}}

End the returned report with exactly one unfenced valid JSON line, copying both
full identities byte-for-byte:
SDLC_SKILLS_SPECIALIST_RESULT={"candidate":"{{exact result identity}}","context":"{{exact review-input identity}}","axis":"silent-failures","verdict":"{{clear | findings | inconclusive}}","report":"{{location or returned directly}}"}
````
