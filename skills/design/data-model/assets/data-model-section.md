Copy this section into the design document, replacing every `{{placeholder}}`.
Preserve the sections already approved around it; this one is immutable once its
identity is issued. Every concept, relationship, transition, invariant, and
mapping gets a stable ID, and a successor never recycles one.

```markdown
## Data model

**Status:** {{draft | proposed; decision state stays external}}
**Identity:** recorded in the ledger row, never here: this section's identity
under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
**Predecessor:** {{prior normative identity, or none; a proposal only links it}}
**Approval rule:** {{one accountable decision owner, or the required approvers
plus the conflict resolver and the rule that decides}}
**External decision ledger:** {{location; pending / changes requested / approved /
rejected / cancelled / superseded by approved normative identity, with trusted
evidence bound to this exact version}}
**Stable ID delta:** {{every concept, relationship, transition, invariant, and
mapping ID as added / changed / removed / preserved; a removal needs owning
approval}}

**Domain:** {{one paragraph — what this system holds or computes over, and why}}

### Concepts

One concept per entity, named in the domain's language. Downstream skills consume
this vocabulary without redefining what a term means.

| ID | Entity | One row / instance represents | Domain term it is known by |
| --- | --- | --- | --- |
| {{C-001}} | {{name}} | {{in the domain's language}} | {{what experts call it}} |

### Attributes

State what absence means, not just that the field is optional.

| Entity | Attribute | Type | Required? | Null semantics / allowed values |
| --- | --- | --- | --- | --- |
| {{C-001}} | {{attribute}} | {{type}} | {{required / optional}} | {{what null means here, or the enum's allowed values}} |

### Relationships

| ID | From | Cardinality | To | Lifecycle owner | On delete |
| --- | --- | --- | --- | --- | --- |
| {{R-001}} | {{entity-a}} | {{one-to-many, many-to-many, …}} | {{entity-b}} | {{who controls whose lifetime}} | {{cascade / restrict / anonymize}} |

Say whether a cardinality is momentary or lifetime where the two differ.

### State transitions

A transition you do not draw is one the code will permit by accident.

| ID | Concept | From state | To state | Operation that moves it | Guard |
| --- | --- | --- | --- | --- | --- |
| {{T-001}} | {{C-001}} | {{state}} | {{state}} | {{the operation}} | {{what must hold first}} |

### Invariants

An invariant with no enforcement path is only an intention.

| ID | Rule that must always hold | Enforced by | Owner of failures |
| --- | --- | --- | --- |
| {{I-001}} | {{the rule}} | {{constraint / transaction boundary / test / reconciliation}} | {{who is paged, or who repairs it}} |

### Operational lenses

Apply the lens where the risk is real; record a skip rather than skipping by
ritual.

| Lens | Applied | Finding, or skip record |
| --- | --- | --- |
| Identity and uniqueness | {{yes / skipped}} | {{the finding, or: skip ID, rationale and evidence, owner, expiry or revisit date, compensating evaluator, and who approved}} |
| Source of truth vs derived | | |
| Tenancy and authorization | | |
| Time, ordering, late events | | |
| Concurrency and atomicity | | |
| Idempotency and retry | | |
| Retention, privacy, deletion | | |
| Compatibility and versioning | | |

### Storage mapping

Fill this only where something actually persists.

| ID | Concept | Where it lives | Deliberately denormalized or cached | Source of truth | Update boundary | Drift caught by |
| --- | --- | --- | --- | --- | --- | --- |
| {{M-001}} | {{C-001}} | {{table, collection, stream}} | {{copied value, or none}} | {{where truth lives}} | {{when and where it updates}} | {{the check}} |

For a bounded change to an existing model, state migration, mixed-version, and
rollback behavior here. For a high-risk transition, record the domain constraints
and let the migration contract own the transition.

### Challenge evidence

Trace real operations rather than asserting the model works.

| Scenario | Query, command, or trace | Result | Evaluator owner |
| --- | --- | --- | --- |
| {{representative read, write, transition, concurrent operation, deletion, or existing-data migration}} | {{what was actually run, or "none exists yet"}} | {{raw result}} | {{who owns the future evaluator, where none ran}} |

Never present a named future evaluator as though it had already run.

### High-risk classification

Classify before implementing, on risk evidence rather than line count. The
ordinary route is ordinary feature planning and line-by-line review; an
answer is off it when the ordinary route cannot make those surfaces
reviewable and recoverable.

- Can independent humans or gates inspect the result (**reviewability**)?
  {{answer and evidence}}
- Must behavior, compatibility, data, or operations match (**preservation**)?
  {{answer and evidence}}
- How many owners, consumers, platforms, or modes change (**breadth**)?
  {{answer and evidence}}
- Can data, security, concurrency, resources, cutover, or recovery fail
  independently (**failure surfaces**)? {{answer and evidence}}
- **Route:** {{ordinary | high-risk | pending classification}}. Any answer off
  the ordinary route, or the user marking the work high-risk, makes it
  high-risk. Reclassify when inputs change.
```
