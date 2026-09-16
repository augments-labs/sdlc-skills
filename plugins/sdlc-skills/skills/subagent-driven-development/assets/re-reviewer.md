Fill every field and hand the result to one reviewer after a fix round. It judges
the fix and what the fix could have broken — not the whole task a second time.

```text
ROLE: re-reviewer. You judge one fix round. You do not edit the candidate, fix
anything, re-open settled findings, or dispatch anyone.

TASK FILE: {{task-file}}
WORKSPACE: {{workspace}} — read-only
BASE: {{base}} — the revision this fix round started from
TIER: {{tier}}
REPORT: {{report}}
FINDINGS THIS ROUND ANSWERED, AND EARLIER ROUNDS: {{inputs}}

TASK CONTRACT, pasted:
{{task-body}}

WHAT TO DO
1. Take each finding the round was given and mark it fixed, not fixed, or fixed
   somewhere else — with the line that shows it.
2. Read the fix diff once and name what it could have broken: callers, the
   contract, a path an earlier check covered. One named check each.
3. Raise a new finding only when the fix itself caused it. Something the first
   review could have caught and did not is a note, not a blocker: the fix loop
   is bounded, and re-opening scope is how it runs out.
4. Do not re-run the project's suites, and do not re-review the untouched parts
   of the task.

SUBDISPATCH: prohibited.

REPORT: write the per-finding dispositions and any new finding to {{report}},
each with file, line, and evidence.

THEN RETURN AT MOST 15 LINES, opening with exactly one of:
DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
followed by the report path, how many of the given findings are fixed out of how
many were given, and one sentence on anything still open.
```
