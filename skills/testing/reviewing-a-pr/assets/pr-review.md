# PR review template

`reviewing-a-pr` fills this after the independent reports return and each
finding carries a disposition, and writes the filled copy under
`.sdlc-skills/evidence/{{YYYY-MM-DD}}-pr-{{number}}/`; the fenced document is
what gets posted when the user chooses to post it. It is written for the
PR's author, so it carries no descriptor, review-input, or dispatch identity,
no evidence path, and never a secret. A finding without a `path:line` at
the head revision, or a recommendation the findings do not support, means the
review is not ready to show.

```markdown
# Review of PR {{number}}: {{title}}

- PR: {{host, repository, number}}, by {{author}}
- Reviewed head: {{full head revision}} onto {{base ref}} at {{full base revision}}
- Reviewed by: {{the user's name}}, with independent review ({{roles that ran}})
- Recommendation: {{approve | request changes | comment}}

## Summary

{{two to four sentences: what the change does as read from the code, whether it does what the PR says it does, and what decides the recommendation}}

## What was checked

| File or area | What was checked | Result |
| --- | --- | --- |
| {{path or area}} | {{read, traced, or compared against what}} | {{clean, or the finding title}} |

## Findings

### {{finding title}}

- Blocking: {{yes | no}}
- Where: `{{path}}:{{line}}`
- What fails: {{the observable failure, or the contract it breaks}}
- Why: {{the evidence read or traced}}
- Suggested fix: {{the smallest change that closes it}}

{{repeat the block per finding; write none when there are no findings}}

## Questions for the author

- {{what could not be verified without running or asking, and what answer would settle it; or none}}

## Strengths

- {{a specific thing done well, with its location; or none}}

## Limitations

{{what was not examined and why: code not executed, dependencies not installed, host checks read as reported for their revision, areas outside the change not traced; or none}}

## Next action

{{the single next step and who owns it: the author addresses the blocking findings, or the user decides on merging; never this reviewer}}
```
