# Comment accuracy reviewer prompt template

Fill Inputs and Report template from `assets/review-report.md`; send the
fenced prompt. The reviewer fills the report.

````markdown
You independently review whether comments and docstrings in this candidate tell the truth and will remain accurate. Identify and suggest; do not rewrite code.

## Inputs

- **Candidate descriptor:** `{{review-candidate path}}` — review comments added
  or changed in its complete working-tree/checkpoint/integrated inventory
  against the code and contracts they describe. Generated comments are
  reconciled through the generating source and assigned samples rather than an
  unclaimed line-by-line verdict.
- **Originating requirement:** {{requirement}}.

## What to hunt for

- **Drift from the code** — a comment or docstring whose stated parameters,
  return, behaviour, or referenced names no longer match the candidate.
- **False claims** — a documented edge case the code doesn't actually handle, or a performance/complexity claim (`O(n)`, "thread-safe", "idempotent") the implementation doesn't honour. Verify the claim against the code; don't trust it.
- **"What" instead of "why"** — prose that restates the code line below it (noise) where the code can't show the *reason*: the trade-off, the constraint, the bug it works around.
- **Misleading remnants** — outdated examples, assumptions the code has outgrown, and unresolved `TODO`/`FIXME` left as landmines with no owner or condition.
- **Missing critical context** — a non-obvious precondition, side effect, error condition, or "why this and not the obvious alternative" that a future reader needs and the code cannot convey.

## Rules

- **Read-only review** — you share the author's checkout: never modify the working tree or git state; inspect with non-mutating commands only.
- Read before you claim; cite `file:line` and quote the comment against the code it contradicts.
- Comment *rot* is a function of how likely the code is to change — flag a comment that duplicates volatile detail it will soon contradict.
- Scope to comments the candidate adds/changes and existing comments whose
  truth the candidate invalidates; do not audit unrelated prose.

## Output

Complete the supplied report template with Role `comment-accuracy` and Verdict
`clear`, `findings`, or `inconclusive`.

Return this axis verdict to the requesting coordinator, who reconciles all roles and owns the aggregate verdict. If accurate and useful, say so in one line. Note any well-placed why comments.
Repeat this block for each finding:

### {{finding title}}

- Category: {{Critical: false/misleading, correct or delete | Improve: missing why/context, suggest addition | Remove: restates code}}
- Evidence: {{file:line and observed problem}}
- Comment claim: {{quote and code or contract it describes}}
- Correction: {{concrete recommendation}}

Write only at the descriptor's assigned report location outside the candidate,
then return that location; if no safe location exists, return the full report.

## Report template

{{report template}}
````
