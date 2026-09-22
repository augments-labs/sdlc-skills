# Coding-standards section template

Copy this into the project's coding-standards section and fill every
`{{placeholder}}`. Delete the guidance italics as you fill; what remains is
the standard itself. Keep it short — a section nobody reads governs nothing.

````markdown
## Coding standards

**Status:** {{draft | proposed; lifecycle stays external}}
**Identity:** recorded in the ledger row, never here: this section's identity
under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
**Predecessor:** {{prior normative identity or none; proposal only links it}}
**External decision ledger:** {{location or returned record; pending / changes
requested / approved / rejected / cancelled / superseded by approved normative
identity, with trusted exact-version evidence}}
**External adoption ledger:** {{location or returned record; pending / in force /
suspended / superseded, with exemplar/enforcement identities and freshness}}
**Stable rule IDs and successor delta:** {{each vocabulary/pattern/never/
exception/exemplar/enforcement ID as added / changed / removed / preserved;
removed IDs need owning approval}}

### Vocabulary

One canonical term per concept. Use the canonical term in names, comments,
docs, and conversation — never the banned synonym.

| Concept            | Canonical term   | Banned synonyms            |
| ------------------ | ---------------- | -------------------------- |
| {{concept}}        | {{term}}         | {{synonym-1}}, {{synonym-2}} |
| {{concept}}        | {{term}}         | {{synonym}}                |

Generic labels banned where a domain term exists: {{service, manager, handler, util — adjust}}.

### Patterns

The one way this project does each of these. Anything else is a defect in review.

- **Errors:** {{how errors are represented and propagated — e.g. typed result objects returned, never thrown across module boundaries}}
- **Validation:** {{where input is validated and what it returns — e.g. at the trust boundary only, returning the parsed value or a typed error}}
- **Async:** {{the project's async idiom — e.g. promises with async/await, no raw callbacks}}
- **Dependencies:** {{how modules get their collaborators — e.g. constructor injection, no ambient singletons}}
- **Testing seams:** {{how tests substitute collaborators — e.g. inject fakes through the constructor, no module monkey-patching}}

Example — the pattern as it should look:

```{{language}}
{{short, real example of one pattern above, in this project's style}}
```

### Never

- {{hard rule — e.g. no business logic in the UI layer}}
- {{hard rule — e.g. no raw queries outside the data layer}}
- {{hard rule — e.g. no swallowing errors silently}}
- {{at most ~7 rules total; each must be something a reviewer will actually reject}}

### Exemplar

`{{path/to/exemplar-file, or pending first artifact + owner}}` does all of the
above right. A pending greenfield exemplar blocks an adoption claim until its
checks and rubric pass.

### Enforcement

| Rule | Gate or review rubric | Owner | Failure response |
| --- | --- | --- | --- |
| {{automatable rule}} | `{{command/check}}` | {{role}} | {{block/fix}} |
| {{judgment rule}} | {{named rubric}} | {{review role}} | {{block/exception}} |

**Strictness:** {{the level each automated check runs at, and its warning budget — zero unless an approved exception says otherwise}}

**Precedence:** {{which project instruction wins on conflict}}

**Exceptions:** {{approver, required reason/scope/expiry, compensating check}}

**Drift review:** {{cadence or trigger, owner, and exemplar-validation action}}
````
