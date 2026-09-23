# Goals section template

Copy this section into the brief, replacing every `{{placeholder}}`. It is one
`##` section of a shared brief — leave the other approved sections untouched, and
do not repeat a header the brief already carries.

```markdown
## Goals

- **Identity:** recorded in the ledger row, never here: this section's identity
  under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
- **Predecessor:** {{prior normative identity, or none}}
- **External decision ledger:** {{ledger path: the brief's path with .ledger.md
  for .md, rows naming this section, unless the user sets another; holds pending
  / changes requested / approved / rejected / cancelled / superseded, bound to
  the version above — lifecycle never mutates this section}}

**Objective:** {{the outcome, not the feature — what the world does differently}}

**Value in one sentence:** {{the elevator version}}

### Stakeholders

| Who | What changes for them | Role |
| --- | --- | --- |
| {{group or person}} | {{benefit, risk, or operational burden}} | {{beneficiary / operator / accountable owner}} |

Decision rule: {{one accountable decision owner, OR the required approvers, the
conflict resolver, and how a tie is broken}}

### Outcomes and how each is measured

| Outcome | Baseline (as of) | Target | Horizon | Measurement source | Owner |
| --- | --- | --- | --- | --- | --- |
| {{what changes}} | {{current number, date observed}} | {{number}} | {{by when}} | {{query, report, or instrument}} | {{who reads it}} |

A number with no source or date cannot be checked later. Competing goals get
their own rows — never one averaged metric.

### Guardrails

- {{what must not degrade — reliability, safety, accessibility, cost, trust}} —
  observed by {{how anyone would notice}}

### Failure criteria

- {{the observation that would mean this initiative failed even if the primary
  metric rose}}
```
