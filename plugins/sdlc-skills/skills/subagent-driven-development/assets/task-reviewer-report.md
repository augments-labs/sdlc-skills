# Task reviewer report template

The task reviewer writes this report at the path its brief gives, outside the
candidate, and returns nothing that is not also in here. Every finding
carries a `path:line` and the evidence read or run; a finding with neither
does not go in. Describe the correction, never write the patch. No secret is
copied here — name the line it sits at. A section with nothing to record says
`none`, and a check you could not run belongs under `## Limitations`, never
under a clean result.

```markdown
# Task review — {{task ID}}: {{task title}}

- Task file: {{absolute path, as the brief gave it}}
- Workspace: {{absolute path}}
- Base revision: {{the revision the diff starts from}}
- Result revision: {{the revision reviewed}}
- Diff range: {{base..result, as a range the controller can run}}
- Status: {{DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT}}

## Contract trace

| Contract clause | Evidence in the diff | Met |
| --- | --- | --- |
| {{the clause, quoted or named}} | {{`path:line`, or `nothing in the diff`}} | {{yes, no, or the finding number}} |

{{one row per clause of the contract, including the ones met}}

## Risks and checks

| Risk this diff carries | The one check run | Result |
| --- | --- | --- |
| {{the risk, in one line}} | {{the command or the read, exactly}} | {{what it returned, and the finding it produced or `clean`}} |

## Findings

### F-{{n}} ({{blocking | advisory}}) — {{title}}

- Severity: {{Critical | Important | Minor}}
- Where: {{path:line}}
- What breaks: {{the failure a user or a caller sees, not the style of the code}}
- Evidence: {{what you read or ran, and what it returned}}
- Correction: {{the smallest change that fixes it, described — no patch}}

{{repeat per finding; write `none` when the diff carries none}}

## Declined to judge

{{the obligation, and why you will not rate it; or none}}

## Limitations

{{what you did not examine, a check that could not run, remaining uncertainty, and what each leaves unjudged; or none}}

## Next action

{{the single shortest next step, and who owns it; or none}}
```
