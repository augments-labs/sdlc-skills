# Approaches section template

Copy this section into the brief, replacing every `{{placeholder}}`. It is one
`##` section of a shared brief — leave the other approved sections untouched,
and do not repeat a header the brief already carries. Step 1 fills the
question, facts, and criteria before any approach is written; Step 3 fills the
comparison, recommendation, and rejected rows from the approaches as returned.
An empty Rejected table means every approach survived the fact check; an empty
Open questions list means every criterion could be judged from a cited fact. A
successor section is headed `## Approaches (successor)`, the next
`## Approaches (successor 2)`, and so on, so no two share a heading.

```markdown
## Approaches

- **Identity:** recorded in the ledger row, never here: this section's identity
  under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
- **Predecessor:** {{prior section identity, or none}}
- **Source:** {{the Goals section identity, the captured ticket's path and
  identity, or the user's words quoted}}
- **Base revision:** {{revision the shared facts were checked against}}
- **Decision owner:** {{person or accountable role}}
- **External decision ledger:** {{ledger path: the brief's path with .ledger.md
  for .md, rows naming this section, unless the user sets another; holds
  pending / changes requested / approved, with the chosen approach named in
  Bound evidence / rejected / cancelled / superseded, bound to the identity
  above — lifecycle never mutates this section}}

**Question:** {{one sentence: the decision this section settles}}

### Shared facts

| Fact | Checked against |
| --- | --- |
| {{what is true of the current code, environment, or constraints}} | {{path and symbol at the base revision, or the quoted constraint}} |

### Criteria

| Criterion | From |
| --- | --- |
| {{what a good approach must do or must not degrade}} | {{Goals outcome, guardrail, failure criterion, or the user's quoted words}} |

### Approach {{letter}}: {{name}}

- **Perspective:** {{the constraint it was written under}}
- **Produced by:** {{dispatch ID | self pass, not independent | named agent}}
- **Fact check:** {{passed | corrected once: the claim | failed: the claim}}
- **What it does:** {{three to six sentences}}
- **What it changes:** {{files, components, interfaces, operations}}
- **What it reuses:** {{existing code or facility, cited}}
- **Cost and risk:** {{build effort, running cost, what breaks if a criterion
  turns out wrong}}
- **Undo:** {{what reversing it takes}}

### Comparison

| Criterion | {{Approach A}} | {{Approach B}} | {{Approach C}} |
| --- | --- | --- | --- |
| {{criterion}} | {{observation citing the approach's text}} | {{observation}} | {{observation}} |

### Recommendation

{{one approach, one sentence why, and what would change the pick}}

### Rejected

| Approach | Why |
| --- | --- |
| {{name}} | {{the fact it contradicted, the guardrail or constraint it broke, or incomplete}} |

### Open questions

- {{a fact no one could cite, and which criterion waits on it}}
```
