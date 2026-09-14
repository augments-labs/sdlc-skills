# Coding-standards section template

Copy this into the project's coding-standards section (see `../SKILL.md`) and
fill every `{{placeholder}}`. Delete the guidance italics as you fill; what
remains is the standard itself. Keep it short — a section nobody reads governs
nothing.

## The template

````markdown
## Coding standards

**Status:** {{draft | proposed; lifecycle stays external}}
**Identity:** recorded in the ledger row, never here: the first 7 characters of
`git hash-object --stdin` over this section, from its heading to the next `##`
heading, without trailing blank lines
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

## Worked example (filled, minimal)

```markdown
### Vocabulary

| Concept                          | Canonical term | Banned synonyms                |
| -------------------------------- | -------------- | ------------------------------ |
| A request to move money          | transfer       | payment, transaction, remittance |
| The party the transfer pays      | payee          | recipient, beneficiary, vendor   |
| A transfer that failed to settle | reversal       | rollback, refund, undo           |

### Patterns

- **Errors:** functions return a result object with `ok` or `err`; exceptions only for programmer bugs.
- **Validation:** request bodies are parsed once at the route boundary into domain types; inner layers never re-check.
- **Dependencies:** passed as constructor parameters; no imports of concrete infrastructure from domain modules.

### Never

- No business logic in route handlers — they parse, call a use case, render.
- No string-typed identifiers across layer boundaries; wrap in a domain type.
- No catching an error and returning a generic 500 without logging the cause.

### Exemplar

`src/transfers/create-transfer.ts`

### Enforcement

- Formatter/linter and type checks block automatable violations.
- The architecture reviewer applies the vocabulary/layering rubric.
- The technical lead owns time-bounded exceptions and quarterly exemplar review.
```

## Edge cases and failure patterns

- **A real project has legacy synonyms everywhere.** Standardize on the term going forward and rename opportunistically on touch; don't schedule a mass rename as a condition of adopting the standard.
- **Two candidate canonical terms, both in use.** If domain meaning differs,
  route to `data-model`. Otherwise propose one code representation with
  transition evidence and obtain the standards decision; never self-select it.
- **A pattern with two legitimate uses** (e.g. two error idioms, one for the CLI edge, one for the core) is fine — say where each applies. "One way" means one way *per situation*, not one way per universe.
- **The exemplar drifts.** Suspend adoption when it fails. Propose a successor
  standards version naming the new exemplar, approve it, then rerun adoption;
  never silently re-point an immutable standard.
- **Failure: the standards file becomes a style guide.** Indentation, brace placement, and import order belong to the formatter and linter — automatable, so automate them. Reference the enforcing configuration instead of duplicating its settings. Keep vocabulary, layering, pattern choice, and their human review criteria here.
- **Failure: nevers with no teeth.** Every "never" must be something a reviewer will actually send back. A never nobody enforces trains readers to ignore the whole list.
