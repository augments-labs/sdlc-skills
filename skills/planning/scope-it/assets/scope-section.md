Copy this section into the brief, replacing every `{{placeholder}}`. It is one
`##` section of a shared brief — leave the other approved sections untouched.

```markdown
## Scope

- **Identity:** recorded in the ledger row, never here: this section's identity
  under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
- **Predecessor:** {{prior normative identity, or none}}
- **External decision ledger:** {{ledger path: the brief's path with .ledger.md
  for .md, rows naming this section, unless the user sets another; holds pending
  / changes requested / approved / rejected / cancelled / superseded, bound to
  the version above — lifecycle never mutates this section}}

### Constraints on every cut

Carried forward, not negotiable, and never moved out of scope to make the cut
look smaller.

- {{goal guardrail, existing contract, or commitment}}
- {{preserved behavior or data}}
- {{security, accessibility, compatibility, operability, or recovery obligation}}

### Preserved invariants

- {{what must still hold afterwards, and how anyone would observe it broke}}

### In scope

The smallest set of capabilities that achieves the approved outcome under those
constraints.

- {{capability}}

### Explicitly out of scope

| ID | Excluded | Why | Impact on the goal | Owner | Revisit when |
| --- | --- | --- | --- | --- | --- |
| {{O1}} | {{tempting capability deferred}} | {{rationale}} | {{what the goal loses}} | {{owner}} | {{trigger}} |

Never list a preserved invariant or an existing commitment here.

### The MVP cut

{{the thinnest version that still meets the goal AND every non-negotiable above}}

Smaller but unsafe, incompatible, or unrecoverable is not an MVP.

### Assumptions and dependencies

| Assumption or dependency | Validation action | Owner | Expires / decides by |
| --- | --- | --- | --- |
| {{what is being taken as true}} | {{what would confirm it}} | {{owner}} | {{date or decision point}} |

A whole project hidden inside "assumes X" is scope, not an assumption.

### Change rules

- **Aborts this cut:** {{observation that invalidates it}}
- **Reopens approval:** {{change material enough to need a new decision}}
- **Decided by:** {{who}}
```
