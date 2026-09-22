# Session diagnosis report template

Fill every section. A claim with no `path:line` does not go in. Quote only
the user's own prompts; describe everything else by its line. Keep a clean
dimension to one line, and put anything you could not search under
`Evidence not available`, never under a finding.

```markdown
# Session diagnosis — {{symptom in a few words}}

- Transcript: {{absolute path}} ({{line count}} lines at {{time read}})
- Session: {{which run — time, branch, or topic}}
- Symptom as stated: {{the user's words}}
- Expected instead: {{what the user expected}}
- Workspace unchanged: `git status --short` {{before}} → {{after}}

## Timeline

| Line | Time | What happened |
| --- | --- | --- |
| {{path:line}} | {{timestamp}} | {{one sentence, in order}} |

## Findings

### {{dimension}} — {{one-line statement}}

- Evidence: `{{path:line}}` — {{distinctive fragment}}
- What it shows: {{one or two sentences, no motive}}
- Consequence for the symptom: {{how this produced what the user saw}}

{{repeat per finding; write `none found` for a dimension searched and clean}}

## Dimensions searched

| Dimension | Searched with | Result |
| --- | --- | --- |
| Skills invoked | {{the search}} | {{finding, or none found}} |
| Gates run and returned | {{the search}} | {{finding, or none found}} |
| Decisions left unanswered | {{the search}} | {{finding, or none found}} |
| Writes outside the owned scope | {{the search}} | {{finding, or none found}} |
| Ordering against the user's instructions | {{the search}} | {{finding, or none found}} |

## Evidence not available

{{what could not be read or searched, and how it limits the conclusion; or none}}

## Notes for a skill's own repository

{{a finding about a skill's behaviour, named and left unjudged and unfixed; or none}}

## Next action

{{the single shortest next step, and who owns it; or none}}
```
