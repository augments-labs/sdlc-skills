# YAGNI in depth

Expanded technique behind `../SKILL.md`. Loaded on demand.

## The ladder, with the reasoning

1. **Need at all?** Build for the requirement in front of you; the future requirement, when it arrives, will be more specific than today's guess.
2. **Already here?** Search before you write, then prove the existing surface is
   semantically equivalent, owned at the right layer, permitted by dependency
   direction, and compatible in support/security lifecycle. Mere proximity is
   not reuse evidence.
3. **Standard library?**
4. **Native platform feature?** A platform primitive (a built-in control, a database constraint, a language feature) beats hand-rolled code you now own and must maintain.
5. **Installed dependency?** If it's already in the tree, use it. Adding a *new* dependency for what a few lines do imports a maintenance and supply-chain cost forever.
6. **One line?**
7. **Minimum that fully works** — and not a rung lower.

## A worked example: minimal vs bloated

Task: debounce one text input's change handler.

- **Bloated:** a generic debounce hook with configurable delay, leading/trailing options, cancellation, its own test suite, exported from a shared `utils` barrel — ~100 lines, serving one caller.
- **Minimal:** a few inline lines that clear and reset a timer. Promote only when
  repeated behavior has one stable owner and measured change friction; caller
  count alone neither requires nor forbids a shared utility.

## Craft is not scope

- **Match the governing convention.** Use the approved current coding-standards
  contract/exemplar when one exists; otherwise use the file's naming, structure,
  and idioms. If they conflict, apply the approved rule only inside task scope
  and report adjacent drift—do not import a personal style or sweep unrelated code.
- **One concept, one name,** taken from the codebase's own vocabulary; a synonym you introduce is a second concept the next reader must disprove.
- **Simple beats clever.** If the clever version needs a comment to be parseable, the plain version is the minimal one.

## The carve-out list — never minimise these away

- Input validation at any trust boundary (user input, network responses, deserialization).
- Error handling that prevents data loss or corruption.
- Security controls (authorization checks, output escaping, secrets handling).
- Accessibility affordances the interface needs to be usable.
- Preserved public behavior, durable data, and approved intentional deviations.
- Compatibility directions and supported platform/build-mode parity.
- Observability that detects failure and supplies required gate evidence.
- Recovery, retained artifacts, named rollback, and validated restoration.
- Migration and assurance gates required by an accepted contract, including
  expensive phase/cutover/release gates.
- Real-world calibration (timeouts, retries, limits tuned to how the system actually behaves).
- Anything the task explicitly asked for.

These are not permission to invent a maximal platform. The accepted
requirements, migration contract, and assurance matrix bound what is required.
Between two approaches that satisfy the same guarantees, compare operational
and lifecycle risk first, then choose the smaller design. An approach with fewer
lines but no recovery or parity is not the same solution.

## Mark deliberate simplifications

When you knowingly take the simpler road, name its ceiling and the upgrade path in one line — "single global lock now; per-key locks if throughput becomes a problem" — so the next reader knows it was a decision, not an oversight.
