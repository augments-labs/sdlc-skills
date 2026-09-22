# Audit partition report template

Fill one report per assigned partition. Copy the full target and audit-input
identities and the exact partition ID from Inputs. Retain all coverage limits;
never estimate a repository-wide total from one partition. Repeat the finding
block for each candidate.

```markdown
# Partition audit

- Target: {{exact target identity}}
- Audit inputs: {{exact audit-input identity}}
- Partition: {{stable partition ID}}
- Verdict: {{clear | findings | inconclusive}}

## Coverage

| Partition item | Evidence inspected | Result or limitation |
| --- | --- | --- |
| {{item}} | {{paths, commands, and results}} | {{covered, excluded, unreadable, drifting, or unexamined}} |

## Findings

### {{stable finding ID}} — {{current surface and paths/lines}}

- Owner and preserved guarantees: {{requirement/guarantee}}
- Evidence inspected: {{paths, commands, and results}}
- Smaller replacement: {{replacement or none}}
- Verification and migration/rollback: {{required checks and transition}}
- Disposition: {{keep | simplify | remove | decision | investigate}}
- Next action: {{shortest next action}}

## Limitations

{{missing evidence, excluded or unexamined items, and uncertainty; or none}}

## Next action

{{the single shortest next step across all findings, and who owns it; or
none}}
```
