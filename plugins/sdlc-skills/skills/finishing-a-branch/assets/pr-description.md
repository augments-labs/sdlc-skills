# Pull request description template

`finishing-a-branch` opens this in Step 1.9, when a PR is created or its
description updated and the project has no PR template or contribution rule
naming one; a project's own template always wins. Fill every slot from the
bound verification ledger and review verdict for the one candidate identity in
the header, then post the filled copy as the PR body; it never goes into the
candidate. Never write a secret, a claim the ledger does not carry, or evidence
from another revision. A section left empty means the evidence for it does not
exist yet; write `none` only after checking and finding nothing to report.

```markdown
# {{what changes, in one line}}

- Candidate: {{full revision or working-tree digest every claim below is bound to}}
- Base: {{base ref at revision}}
- Requested by: {{who asked and where the request lives, or none recorded}}
- Supersedes: {{earlier PR or round this replaces, or none}}
- Owner: {{person accountable for this PR}}
- Decided in: {{where approval and the merge choice are recorded; this PR's review thread unless the project names another place}}
- Review verdict: {{self-reviewed: ready | independent verdict as written in the report}}

## Why

{{the problem in the requester's terms: what fails or is missing today, and for whom}}

## What changes

{{the change by behaviour, then by path only where the reviewer must open it}}

## How it was verified

Every row is a ledger row run on the candidate above; nothing wider.

| Gate | Command or action | Raw result | Where the output is kept |
| --- | --- | --- | --- |
| {{gate}} | {{exact invocation}} | {{exit and counts as returned}} | {{location, or returned inline}} |

## Review

- Depth: {{shallow | standard | deep | high-risk transformation}}
- Reviewed candidate: {{identity, equal to the header byte-for-byte}}
- Open findings: {{none, or each finding and its disposition}}

## Risk and rollback

- Affected surfaces: {{contracts, data, consumers, operations this can break}}
- Rollback: {{reverting this PR alone restores the base, or the exact steps and order}}

## Not verified

{{gates pending, blocked, or inconclusive; cells not run; behaviour not exercised; or none}}

## Next action

{{each decision only the reviewer can make, with the options; or merge after review}}
```
