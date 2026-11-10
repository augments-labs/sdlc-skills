# Security report template

The independent auditor fills this report for the exact candidate; the author
never fills it. Copy both full identities from its
descriptor, and compute `State read` yourself before reading anything: if it
differs from `Candidate`, stop and report only that. Write only to the
assigned location — under
`.sdlc-skills/evidence/`, which the content digest leaves out, or outside the
candidate workspace — or return the report directly. Include no secret values.

```markdown
# Security review

- Candidate: {{exact result identity}}
- State read: {{the identity you computed yourself where you read the files: the full revision you read by, or in working-tree mode the digest printed by rerunning the descriptor's verification-state command there; never copied from the descriptor}}
- Review inputs: {{exact review-input identity}}
- Role: security
- Verdict: {{security clear | security blocked | inconclusive}}

## Coverage

| Threat/category and environment | Evidence or approved omission | Result |
| --- | --- | --- |
| {{coverage cell}} | {{what was inspected/run, or exception owner and expiry}} | {{covered or unresolved}} |

## Findings

### {{finding title, or none}}

- Severity: {{Critical: remote exploit/auth bypass/secret or bulk-data leak | Important: second condition or insider position | Minor: hardening}}
- Actor/asset/abuse case: {{who targets what, how, and consequence}}
- Path: {{attacker-controlled source → propagation → sink/effect, with evidence}}
- Exploit: {{concrete input or sequence}}
- Gate/reproduction: {{command/action, environment, and raw result}}
- Coverage cell: {{threat/category and platform/build/environment ID}}
- Sensitive evidence: {{redacted location or digest}}
- Fix: {{smallest correction}}
- Re-audit: {{affected gates and independent review scope}}

## Limitations

{{missing evidence and open blockers; or none}}

## Next action

{{shortest next action, and who owns it; or none}}
```
