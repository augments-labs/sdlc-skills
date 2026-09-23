# Feasibility section template

Copy this section into the brief, replacing every `{{placeholder}}`. It is one
`##` section of a shared brief — leave the other approved sections untouched.
Drop a dimension row only by writing why it does not apply, never by silence.

```markdown
## Feasibility

- **Identity:** recorded in the ledger row, never here: this section's identity
  under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
- **Predecessor:** {{prior normative identity, or none}}
- **External condition and decision ledger:** {{ledger path: the brief's path
  with .ledger.md for .md, rows naming this section, unless the user sets
  another; holds each condition's pending / satisfied / failed state and the go /
  go-if / no-go / cancel outcome, bound to the version above — lifecycle never
  mutates this section}}
- **Accountable decision owner:** {{who commits the project}}

### Dimensions assessed

| Dimension | Constraint that binds it | Finding | Owner |
| --- | --- | --- | --- |
| Technical | {{constraint}} | {{what the evidence shows}} | {{who owns it}} |
| Delivery, team, budget | {{constraint}} | {{finding}} | {{owner}} |
| Operations and recovery | {{constraint}} | {{finding}} | {{owner}} |
| Security and compliance | {{constraint}} | {{finding}} | {{owner}} |
| Data | {{constraint}} | {{finding}} | {{owner}} |
| External dependencies | {{constraint}} | {{finding}} | {{owner}} |

"Technically possible" is not "operable and deliverable" — each row stands alone.

### Killer risks

Assumptions that sink the goal if false, ranked by likelihood × impact.

| Risk | Likelihood × impact | Evidence | Observed | Confidence |
| --- | --- | --- | --- | --- |
| {{if this is false, the goal fails}} | {{high/med/low each}} | {{source}} | {{date the evidence was taken}} | {{high / medium / low / unknown}} |

`unknown` is a valid confidence. A spike that answered one dimension has not
answered the others.

### Option Zero and smaller alternatives

| Alternative | Can it meet the goal and guardrails? | Evidence |
| --- | --- | --- |
| Do not build it | {{yes / no / partly}} | {{what was checked}} |
| {{existing tool, configuration, or process}} | {{yes / no / partly}} | {{evidence}} |
| {{a smaller initiative}} | {{yes / no / partly}} | {{evidence}} |

Convenience for the recommendation is not evidence against an alternative.

### Recommendation

**{{go | no-go | go-if}}** — {{one sentence}}

Go-if conditions, each independently checkable:

| ID | Condition | Evaluator / evidence | Owner | Fresh until | State | If it fails |
| --- | --- | --- | --- | --- | --- | --- |
| {{C1}} | {{what must be true}} | {{who or what decides, and on what}} | {{owner}} | {{expiry}} | pending | {{abort or fallback response}} |

This is advice to the accountable decision maker. It is not authority to commit
the project, and recording a go-if does not satisfy any condition.
```
