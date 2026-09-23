# Handoff template

`handoff` fills this before writing, once Step 1 has settled where it goes.
Copy it, fill every `{{placeholder}}`, and delete nothing silently — a section
you can't fill is a signal the handoff isn't ready, and "next step unknown" is
honest where an omitted section is a trap. Record the destination itself,
along with who may access it and its cleanup owner, in `Storage controls`
below.

```markdown
# Handoff: {{work item name}}

## Storage controls
{{location, intended recipient/storage boundary, disclosure authority, data
class, allowed access, retention/expiry, exact cleanup targets/effects/
recoverability, cleanup owner, cleanup authority, and pending/completed state}}

## Handoff identity
- ID: {{stable handoff ID; the note's digest goes in its ledger, never here}}
- Created / sender / intended recipient and scope: {{exact transfer facts}}
- Predecessor: {{prior handoff identity, or "none"; records are append-only}}

## Goal
{{what this work is trying to achieve, in one or two lines — the WHY}}

## State identity
- Plan/artifact: {{path and version}}
- Branch / commit / workspace: {{exact identity}}
- Workspace inputs: {{staged/unstaged/untracked/relevant ignored/generated paths
  plus controlled external gate-input identities, or "none"}}
- Done: {{what is complete and verified — cite the check that proved it}}
- In flight: {{what is half-done, exactly where it stopped}}

## Decisions and authority
- {{decision and scope}} — because {{reason}} — authorized by {{direct answer or standing default}}
- Pending: {{decision or permission, named options, and who can answer}}

## Evidence
- {{claim}} — `{{command/action}}` from `{{cwd}}` on {{tree/artifact,
  environment, timestamp}} → {{result, stale, or unrun}}

## Gotchas and permissions
{{traps discovered, with file and line references so they can be verified}}
- {{file:line}} — {{what bites and why}}
- {{external/destructive action still awaiting permission, or "none"}}

## Resume first action
Refresh repository, artifact, approval, and time-sensitive external state. Then:
{{single mutation to take only if it remains authorized}}

## Suggested skills
{{which skills the next session should reach for, and at what point}}

## References
{{paths to existing specs, plans, ADRs, commits — the documents NOT duplicated into this handoff}}
```
