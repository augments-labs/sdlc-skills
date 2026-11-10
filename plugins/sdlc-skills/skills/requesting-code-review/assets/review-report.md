# Review report template

Fill the report for the assigned role. Copy both full identities from the
descriptor, and compute `State read` yourself before reading anything: if it
differs from `Candidate`, stop and report only that. Use the role prompt's
verdicts and finding format. A finding that another
skill owns names it as the suggested owner, and the caller routes it. Keep clean
assessments brief. A missing check belongs in Limitations, never a clean result.

```markdown
# {{role}} review

- Candidate: {{exact result identity}}
- State read: {{the identity you computed yourself where you read the files: the full revision you read by, or in working-tree mode the digest printed by rerunning the descriptor's verification-state command there; never copied from the descriptor}}
- Review inputs: {{exact review-input identity}}
- Role: {{breadth, adversarial, or assigned specialist axis}}
- Verdict: {{verdict allowed by the role prompt}}

## Assessment

{{role-specific assessment; breadth separates Standards and Spec}}

## Coverage

| File/range or obligation | Evidence and traversal reason | Result or limitation |
| --- | --- | --- |
| {{reviewed scope}} | {{what you read or ran, and why}} | {{finding or clean result}} |

## Findings

{{repeat the finding block supplied in the role prompt, each with a `Suggested owner:` line naming `security-audits`, `complexity-audit`, or `verification-strategy` when that skill owns the resolution, else `none`; write none when there are no findings}}

## Declined to judge

{{obligation inside the review scope and the reason; or none}}

## Limitations

{{unexamined scope, missing/failed checks, uncertainty, and effect on the verdict; or none}}

## Next action

{{shortest correction or required follow-up, and who owns it; or none}}
```
