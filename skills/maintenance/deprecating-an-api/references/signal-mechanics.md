# Signal mechanics by protocol and language

Read before writing an HTTP deprecation header, a schema deprecation, or a
Python, Java, TypeScript, or Go deprecation marker. Each has a form that looks
right and signals nothing.

- The HTTP `Deprecation` header's value is a structured-field date such as
  `@1688169599`, never an HTTP-date and never `true`; older drafts used
  those forms and clients built on them misparse it. The `Sunset` header
  uses an HTTP-date (`Sun, 30 Jun 2024 23:59:59 GMT`), and its date must
  not be earlier than the `Deprecation` date — shows when a client library
  that reads both rejects the response, or logs the deprecation as unset.
- An interface that clients are generated from is marked in its schema:
  `deprecated: true` on an OpenAPI operation, parameter, or property; the
  `@deprecated(reason: ...)` directive on a GraphQL field or enum value; the
  `deprecated = true` option on a Protocol Buffers field. A marker only in
  the handler never reaches a generated client — shows when a regenerated
  client still offers the old call with no warning.
- Python hides `DeprecationWarning` by default except for code run from
  `__main__`, so a warning raised inside a library is never seen by an
  application's users; use `FutureWarning` when end users must see it, and
  pass `stacklevel=2` so the warning points at the caller, not at the
  deprecated function — shows when a deprecated call runs through a test
  suite and a production service for a month and nobody saw a line.
- Java emits no deprecation warning for a use inside the same outermost
  class or inside a declaration that is itself `@Deprecated`, so a chain of
  deprecated wrappers goes silent; `@Deprecated(forRemoval = true)` emits a
  removal warning that ignores the deprecated-caller exemption — shows when
  a caller behind an old adapter reports it never saw a warning.
- A TypeScript `@deprecated` JSDoc tag surfaces only as an editor
  suggestion and a strike-through; the build neither fails nor warns, so a
  caller who never opens the file in an editor gets no signal — shows when
  a generated or scripted caller keeps using the old export past sunset.
- Go reads a deprecation only from a doc-comment paragraph that begins
  `Deprecated:`; the compiler never warns on use, only a separate static
  checker does — shows when a `// deprecated` comment without the colon is
  picked up by nothing.
