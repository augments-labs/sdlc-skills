# Coding standards worked example

This file is a filled example and failure catalogue to compare a draft against, not a file to copy.

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
