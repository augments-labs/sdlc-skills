# Implementer report template

The implementer writes this report at the path its brief gives, before it
returns, and returns nothing that is not also in here. Every line carries a
`path:line`, a command with its raw output, or a clause of the contract; a
claim with none of the three does not go in. No secret is copied here — name
where it lives instead. A section with nothing to record says `none`, which
is a statement the controller can act on, not an omission.

```markdown
# Implementer report — {{task ID}}: {{task title}}

- Task file: {{absolute path, as the brief gave it}}
- Workspace: {{absolute path}}
- Base revision: {{the revision the work started from}}
- Result revision: {{the revision this report describes}}
- Diff range: {{base..result, as a range the controller can run}}
- Status: {{DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT}}

## Files changed

| File | Change | Why the contract needs it |
| --- | --- | --- |
| {{path}} | {{what changed, in a few words}} | {{the clause that requires it}} |

{{one row per file in the diff; a file the contract did not name is a row here and a line under `## Outside the contract`}}

## Disciplines

- Behavior changes: {{for each one, the RED command and the failing output, then the GREEN command and the passing output; or `none — nothing in this task changes behavior`, and why}}
- Cut as unneeded: {{what the contract did not need and you left out, one line each; or none}}

## Gates

| Command | Raw verdict | Where the output is |
| --- | --- | --- |
| {{the command exactly as run}} | {{exit code and the line that decides it, quoted}} | {{path to the kept output, or `quoted in full above`}} |

{{one row per gate the contract names, plus every gate you ran that failed}}

## Checkpoints

| Revision | What it completes | Gates green at it |
| --- | --- | --- |
| {{short revision}} | {{the independently testable piece}} | {{the gates that passed before it}} |

{{or `none — the work is a single uncommitted change`}}

## Outside the contract

- Defects noticed and not edited: {{`path:line` and the defect, one line each; or none}}
- Done beyond the contract: {{what, and why it could not wait for its own task; or none}}

## Gaps outside this task

{{file and the missing detail, one line each — reported here, never edited; or none}}

## Unresolved

{{what is unfinished, which gate stayed red, which question the contract does not answer, and what each one blocks; or none}}

## Next action

{{the single shortest next step, and who owns it; or none}}
```
