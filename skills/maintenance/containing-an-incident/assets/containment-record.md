# Containment record template

`containing-an-incident` fills this when the lever is pulled, not afterwards —
its job is to make the mitigation reversible by somebody who was not here.
Write it to `.sdlc-skills/handoffs/{{YYYY-MM-DD}}-{{topic}}-containment.md`
unless the user or the incident owner names another place, and commit it only
under the handoff store's rule.

```markdown
# Containment record — {{incident-short-name}}

## Impact

- **What failed:** {{user-visible symptom, in the words a user would use}}
- **Who was affected:** {{scope — all users, one region, one tenant, one plan}}
- **From:** {{first observation, with timezone}} **to:** {{when the signal returned to normal, or "ongoing"}}
- **Observed in:** {{the signal that showed it — error rate, failing request, report}}

## Lever pulled

| | |
| --- | --- |
| Action | {{what was changed, exactly — file, flag, setting, command}} |
| Pulled at | {{timestamp with timezone}} |
| By | {{who, and under whose authority if it was not theirs to make}} |
| Blast radius | {{what else this affects, stated as one sentence}} |
| Alternatives rejected | {{wider or slower levers, and why this one instead}} |

## Proof it worked

{{The outside signal, before and after. Not "the flag is now false" — the error
rate, the request that failed and now succeeds, the queue that is draining.}}

## What this costs while it holds

{{The feature that is off, the capacity that is reduced, the customers on a
degraded path, the work that is queuing. If it costs nothing, say so — that is
worth knowing too.}}

## Reversing it

- **Precondition:** {{what has to be true before this is safe to undo — usually the fix shipped and verified}}
- **How:** {{the exact inverse action}}
- **Owner:** {{who is accountable for undoing it}}
- **Review by:** {{a date, so an indefinite mitigation gets noticed}}

## Evidence preserved

{{What was captured before containment could erase it, and where it is. "None,
containment could not wait" is a valid entry.}}

## Still open

- **Cause:** {{unknown / under investigation / known — hand to `debugging`}}
- **Why it escaped:** {{hand to `post-mortem` once cause and containment are known}}
```
