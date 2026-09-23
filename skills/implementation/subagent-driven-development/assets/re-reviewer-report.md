# Re-reviewer report template

The re-reviewer writes this report at the path its brief gives, outside the
candidate, and returns nothing that is not also in here. Every finding given
to the round appears below with its disposition and the `path:line` that
shows it; a finding left out reads as fixed and is how a defect ships.
Describe the correction, never write the patch. No secret is copied here. A
section with nothing to record says `none`, and a check you could not run
belongs under `## Limitations`.

```markdown
# Re-review — {{task ID}}: {{task title}}, round {{round number}} of the fix loop

- Task file: {{absolute path, as the brief gave it}}
- Findings answered this round: {{absolute path of the findings file}}
- Workspace: {{absolute path}}
- Base revision: {{the revision this fix round started from}}
- Result revision: {{the revision after the fix}}
- Diff range: {{base..result, as a range the controller can run}}
- Status: {{DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT}}

## Findings disposition

### F-{{n}} — {{fixed | not fixed | partly fixed}}

- Evidence: {{path:line in the fix diff, and what it now does}}
- Still open: {{for `partly fixed` or `not fixed`, the part that is not addressed; else none}}
- Blast radius: {{the callers, contracts, or covered paths this fix touches, and the one check you ran on each}}

{{repeat for every finding the round was given — one block each, none omitted}}

Fixed {{count}} of {{count}} given.

## Settled items preserved

| Settled item | How it was checked | Still holds |
| --- | --- | --- |
| {{the behavior, gate, or clause an earlier round settled}} | {{the command or the read}} | {{yes, or the finding number}} |

## New findings

### N-{{n}} ({{blocking | advisory}}) — {{title}}

- Severity: {{Critical | Important | Minor}}
- Caused by this fix set: {{the change in this round's diff that introduced it}}
- Where: {{path:line}}
- What breaks: {{the failure a user or a caller sees}}
- Evidence: {{what you read or ran, and what it returned}}
- Correction: {{the smallest change that fixes it, described — no patch}}

{{only findings this fix set caused; anything the first review could have caught is a note under `## Limitations`. Write `none` when there are none}}

## Limitations

{{what you did not examine, a check that could not run, a note the fix loop is not re-opening, and what each leaves unjudged; or none}}

## Next action

{{the single shortest next step, and who owns it; or none}}
```
