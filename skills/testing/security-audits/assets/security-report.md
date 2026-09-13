# Security report template

Fill this report for the exact candidate. Copy both full identities from its
descriptor. Write only to the assigned location outside the candidate, or
return the report directly. Include no secret values.

```markdown
# Security review

- Candidate: {{exact result identity}}
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

## Limitations and next action

{{missing evidence, open blockers, and shortest next action; or none}}
```
