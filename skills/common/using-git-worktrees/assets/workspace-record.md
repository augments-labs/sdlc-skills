# Workspace record — {{task-name}}

Fill this as you work through the procedure, and hand it to whatever finishes
the branch. Every field below is something a later step needs and cannot
re-derive: which resources may be cleaned up, which base the work is relative
to, and what the suite looked like before you touched anything.

## Identity

| Field | Value |
| --- | --- |
| Workspace path | {{path}} |
| Branch or HEAD | {{branch-or-detached-revision}} |
| Base | {{base-ref}} at {{revision}} |
| Remote freshness | {{fetched-at}} / {{stale}} |
| Isolation kind | worktree / harness-native workspace / user-okayed current checkout |
| Ignore rule | `.gitignore` / `info/exclude` / outside the repository / native tool owns it |
| Owner of the checkout | this task / user / host |

## Inventory

Everything present in the workspace, separated by who created it. Only the first
column may ever be cleaned up.

| Task-owned | Pre-existing, user-owned, shared, or host-owned |
| --- | --- |
| {{path-or-resource}} | {{path-or-resource}} |

Unknown provenance goes in the right column. It is not a placeholder to resolve
later — unknown provenance blocks cleanup and any change to that checkout.

## Gate inputs outside the source tree

Ignored, generated, and external inputs the baseline and later gates depend on.
The source revision does not capture these, so record them here or they are not
captured at all.

- {{input}} — {{how it is produced or fetched}} — {{version or digest}}

## Baseline

See `references/baseline-contract.md` for what makes each of these valid.

| Field | Value |
| --- | --- |
| Command | {{command}} |
| Authority covered it | yes / no — baseline is **pending** |
| Pre-state | {{captured}} |
| Post-state | {{captured}} |
| Result | {{green}} / {{red-cells}} |
| Raw output | {{where it is kept, outside the candidate}} |

### Red cells

| Cell | Bound to | Evidence | Owner | Expiry | Discriminator |
| --- | --- | --- | --- | --- | --- |
| {{cell}} | reproduction / exclusion | {{raw-output}} | {{owner}} | {{date-or-rule}} | {{compensating-check}} |

## Runtime identities

Ports, databases, migrations, fixtures, caches, and environments this workspace
claims — so a parallel writer does not claim the same ones.

- {{resource}} — {{identity}}

## Side effects

Every effect the baseline left behind, classified.

| Effect | Intended | Restored |
| --- | --- | --- |
| {{effect}} | yes / no | yes / no / n/a |

## Cleanup

Resources this task created and may remove once an owning transition permits it.
Nothing else appears here.

- {{resource}}
