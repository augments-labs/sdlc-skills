Copy this file to the spec path, replacing every `{{placeholder}}`. Delete a
section only by saying why it is empty — an absent risks section reads as "none
found", which is a claim.

```markdown
# Spec: {{topic}}

- **Identity:** recorded in the ledger row, never here: the first 7 characters of
  `git hash-object` over this artifact's own text as issued
- **Predecessor:** {{prior normative identity, or none; a successor carries a
  per-requirement added / changed / removed / preserved delta}}
- **External decision ledger:** {{ledger path: this spec's path with .ledger.md
  for .md unless the user sets another; holds pending / changes requested /
  approved / rejected / cancelled / superseded, bound to the version above —
  lifecycle never mutates this spec}}
- **Decision owner:** {{one accountable owner, OR the required approvers, the
  conflict resolver, and the decision rule}}

## Problem

{{one or two lines}} — serves {{the goal or brief this traces to}}

## Requirements

Each is observable: "rejects an expired token with a 401", not "good auth". IDs
are stable and never recycled by a successor.

| ID | Must do | Acceptance form | Artifact today, or gate + owner |
| --- | --- | --- | --- |
| {{R1}} | {{observable behavior}} | {{executable gate / mockup / source-fact contract / rubric / prose}} | {{a real path that exists now, OR the intended gate and who will own it}} |

Never name an artifact that does not exist. `references/reference-forms.md`
chooses the form; the cheapest honest one wins.

## Carried guardrails and obligations

Traced from the approved goal and scope — only those that actually apply. Do not
add a generic non-functional list.

| Obligation | Applies because | Requirement it binds |
| --- | --- | --- |
| {{trust/data, security, accessibility, compatibility, operational/recovery, performance/resource, or platform-mode}} | {{why this project has it}} | {{R-id}} |

## Edge cases and scenarios

- {{the case that breaks a naive build — empty input, concurrency, an unhappy path}}

## Assumptions and dependencies

| ID | Taken as true | Evidence / state | Validation action | Owner | Fresh until | If it fails |
| --- | --- | --- | --- | --- | --- | --- |
| {{A1}} | {{premise}} | {{what is known now}} | {{what would confirm it}} | {{owner}} | {{expiry}} | {{response}} |

Unresolved material state is an open decision, never a hidden premise.

## Open questions and risks

- {{unresolved ambiguity or requirement-level challenge that could derail the build}}

## Out of scope this round

- {{requirement deliberately not covered}}
```
