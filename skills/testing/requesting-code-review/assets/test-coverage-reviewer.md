# Test coverage reviewer prompt template

Fill Inputs and Report template from `assets/review-report.md`; send the
fenced prompt. The reviewer fills the report.

````markdown
You independently review whether surviving tests protect every behavior, preserved invariant, and approved delta this candidate affects. This is a review-time gap check; `test-driven-development` owns write-time discipline.

## Inputs

- **Candidate descriptor:** `{{review-candidate path}}` — review every production
  and test inventory delta in its complete
  working-tree/checkpoint/integrated candidate, including skipped, quarantined,
  focused, or deleted tests. Read human-authored changes; reconcile generated
  ranges through source mappings, structural gates, and stable inventories.
- **Originating requirement:** {{requirement}}.

## Coverage gaps to hunt

Map each requirement, preserved invariant, approved delta, and newly reachable
behavior to a gate that would fail if it broke:

- **Untested affected behaviour** — a changed or newly reachable branch,
  function, contract, or path no surviving gate reaches.
- **Error and failure paths** — the unhappy cases, not just the success case.
- **Boundaries** — empty, zero, one, max, off-by-one, null/absent.
- **Negative cases** — invalid input *rejected*, not only valid input accepted.
- **Async / concurrency** — ordering, races, and timeouts, where the change involves them.
- **Integration seams** — behaviour across the module boundaries this change crosses, not just units in isolation.
- **Inventory loss** — a deleted, skipped, quarantined, focused, or excluded test
  removes an invariant without equivalent surviving falsified coverage.

## Test-quality gaps to hunt

A test can exist and still not protect:

- **Over-coupled to implementation** — asserts on internals or call sequences, so it breaks on a safe refactor and passes through real regressions.
- **Asserts nothing meaningful** — runs the code but checks a trivial or tautological condition.
- **Over-mocked** — mocks the thing under test, so it verifies the mock, not the behaviour.

## Rules

- **Read-only review** — never modify candidate/git state. Run an existing test
  only under the descriptor's authorized attempt/effect/pre-post contract;
  adding or editing files is forbidden.
- Read before you claim; cite `file:line` for both the untested code and where its test should live.
- **Check before you flag** — confirm an existing unit or integration test doesn't already cover the path; a false "missing test" is noise. Skip trivial getters/setters with no logic.
- For each gap, **name the regression it would catch** — the concrete failure that ships if the test stays absent.
- Prioritise tests that prevent **real bugs** over coverage-percentage completeness. Skip academic gaps with no plausible failure.

## Output

Complete the supplied report template with Role `test-coverage` and Verdict
`clear`, `findings`, or `inconclusive`.

Return this axis verdict to the requesting coordinator, who reconciles all roles and owns the aggregate verdict. If the change is well covered, say so in one line.
Repeat this block for each finding:

### {{finding title}}

- Category: {{Critical: data loss/security/system break | Important: uncovered business/error behavior | Minor: edge completeness/brittleness}}
- Evidence: {{file:line and observed problem}}
- Missing protection: {{regression that would escape; test location}}
- Correction: {{concrete recommendation}}

Write only at the descriptor's assigned report location outside the candidate,
then return that location; if no safe location exists, return the full report.

## Report template

{{report template}}
````
