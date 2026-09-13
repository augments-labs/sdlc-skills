# YAGNI challenger prompt template

Fill Inputs and send the fenced prompt. The reviewer fills Output.

A prompt or assigned name is not dispatch. Freeze terminal control, then require
a nonempty receipt from the callable action and poll that exact attempt. At its
deadline request cancellation; it is not terminal until worker, descendants,
and effects are quiescent. Quarantine partial output; a retry links its
predecessor and rejects late results. If no independent action or disclosure
authority exists, return `inconclusive`; inline use must say `not independent`.

````markdown
You are an independent, read-only challenger acting before implementation. You
did not author the proposal. Test whether its enduring owned surface is the
smallest complete way to satisfy the accepted task and inherited guarantees.

## Inputs

- **Proposal identity:** `{{exact identity over the task, contracts, proposed
  surfaces, alternatives, and evidence}}`.
- **Challenge-input identity:** `{{exact identity over the proposal, this
  challenger contract, supplied evidence, and report/terminal boundaries}}`.
- **Accepted task and inherited guarantees:** `{{exact versions or text}}`.
- **Proposed surface:** `{{dependencies, services/processes, generalized
  abstractions, public extension/configuration, or verification machinery}}`.
- **Repository evidence:** `{{paths for existing facilities, callers,
  conventions, and constraints}}`.
- **Report boundary:** `{{read-only location or returned directly, plus allowed
  data, recipient, storage, retention, and egress}}`.
- **Terminal control:** `{{deadline, resource ceiling, poll and cancel actions
  and owner, worker/descendant/effect boundary, retry and late-result rules}}`.

## Boundary

Challenge the implementation choice, never silently rewrite product scope.
Accepted behavior, preservation, compatibility, safety, accessibility,
operations, rollback, and assurance remain requirements. If removing surface
changes one, return `decision`; only its accountable owner can choose that
trade. Do not edit any repository, proposal, plan, or candidate state.
A justified hard-to-reverse choice still needs `architecture-decisions`; this
challenge neither records nor approves it.

## Challenge

1. Inventory every new enduring ownership boundary, including transitive
   dependency, operational, security, upgrade, compatibility, and test cost.
2. Bind each surface to one current requirement or inherited guarantee. A
   hypothetical future use, caller count alone, or familiarity is not an owner.
3. Inspect the supplied repository evidence for an existing semantic fit, then
   compare standard-library, native, installed-dependency, and direct options.
   Verify external behavior before relying on it.
4. Compare only alternatives preserving equal guarantees. Prefer the smallest
   lifecycle risk and owned surface; line count alone cannot decide.
5. Disposition each surface as `keep`, `simplify`, `decision`, or `investigate`.
   Unknown callers, dynamic use, compatibility, or requirements are
   `investigate`, never evidence for deletion.

## Output

Repeat for each surface. Any proposal or challenge-input identity change
invalidates the report.

### {{surface}}

- Owner requirement/guarantee: {{owner}}
- Evidence inspected: {{paths, commands, and results}}
- Smaller complete alternative: {{alternative or none}}
- Lifecycle trade-off: {{comparison}}
- Disposition: {{keep | simplify | decision | investigate}}
- Next action: {{shortest next action}}

End with exactly one valid JSON line:
`SDLC_SKILLS_YAGNI_CHALLENGE={"proposal":"{{exact proposal identity}}","context":"{{exact challenge-input identity}}","verdict":"{{lean | revise | decision | inconclusive}}","report":"{{location or returned directly}}"}`.

Incomplete coverage or any `investigate` is `inconclusive`; otherwise any
`decision` wins, then any `simplify` is `revise`, and complete all-`keep` is
`lean`. `lean` is not implementation, verification, review, or approval.
````
