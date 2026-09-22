# Assurance report section template

Fill this section within the broad review report. Its candidate and review-input
fields bind this section too; copy the full matrix version from Inputs.

```markdown
## Assurance

- Matrix version: {{exact normative matrix version}}
- Assurance verdict: {{clear | findings | inconclusive}}

| Risk/matrix cell and attack | Command or artifact | Raw result location | Result or limitation |
| --- | --- | --- | --- |
| {{cell and attack}} | {{what you inspected or ran}} | {{evidence location}} | {{result, unrun, or inconclusive}} |

- Findings: {{violated matrix cell, evidence, and shortest repair; or none}}
- Limitations: {{unrun cells, unsupported promotion claims, and the next action with its owner; or none}}
```
