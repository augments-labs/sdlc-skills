Fill this in as the audit runs, and write the completed file to
`.sdlc-skills/audits/{{YYYY-MM-DD}}-{{topic}}.md`. The coordinator alone writes
it; dispatched auditors return partition reports that get reconciled into it.

```markdown
# Complexity audit: {{topic}}

## What was frozen

- **Target identity:** {{exact revision; the working-tree digest only when the report path is git-ignored}}
- **Goal of this audit:** {{the question it answers}}
- **Included paths:** {{what is in scope}}
- **Excluded paths:** {{what is out, and why}}
- **Requirements and guarantees in force:** {{what the target currently owes —
  these are not candidates for removal}}
- **Evidence allowed:** {{what counts here: static reads, existing test output,
  dependency metadata — and what does not}}

This report is owned by the coordinator and lives outside the audited target's
identity. If the target drifts from the frozen identity, stop or restart; do not
reconcile a moving target.

## Inventory

Everything the surface actually contains, not only what is easy to see.

| Kind | Present | Notes |
| --- | --- | --- |
| Code | {{modules, files}} | |
| Dependencies | {{direct and transitive that matter}} | |
| Configuration | {{files, environment, feature state}} | |
| Build and test machinery | {{what runs, and what it guards}} | |
| Generated sources | {{generator, output, regeneration step}} | |
| Dynamic, reflection, registration paths | {{how things get wired at runtime}} | |
| External consumers | {{who depends on this from outside}} | |
| Operational ownership | {{dashboards, alerts, runbooks, on-call surface}} | |

## Partitions, if the surface was split

| ID | Inventory covered | Cross-boundary edges | Auditor report | Outcome |
| --- | --- | --- | --- | --- |
| {{P1}} | {{exclusive, complete slice of the inventory}} | {{what crosses into other partitions}} | {{report location and exact target/audit-input identities}} | {{reported / inconclusive}} |

A missing, unreadable, or identity-mismatched report makes that partition
`inconclusive`. Never state a repository-wide conclusion from partial coverage.

## Coverage reconciliation

- Partitions accounted for: {{n of n}}
- Exclusions restated: {{list}}
- Cross-boundary candidates resolved: {{list}}
- Duplicates merged: {{list}}
- Attempts that failed or returned nothing: {{list}}
- Areas left inconclusive: {{list — this is a finding, not a gap to hide}}

## Findings

Decisions, not a deletion score. Line count is not authority.

| ID | Subject | Decision | Evidence | Guarantee it carries | Replacement | How the replacement is verified | Migration / recovery needed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| {{F1}} | {{module, dependency, flag, or machinery}} | keep / simplify / remove / decision / investigate | {{what was actually observed}} | {{what breaks if this goes}} | {{what takes it over, or none}} | {{the gate, and that it can fail}} | {{what a rollout would owe}} |

## What this audit does not authorize

Nothing here has been applied, and nothing here is approved. Accepted structural
changes route to `refactor-architecture`; behavior changes follow their own
feature or bug route and produce a new, separately verified candidate.
```
