# Pull request description template

`finishing-a-branch` opens this in Step 1.9, when a PR is created or its
description updated and the project has no PR template or contribution rule
naming one; the project's template and contribution rules win, and any section
the rules require is carried. The evidence slots — the header's Candidate and
Review verdict, How it was verified, Review, and Not verified — come only from
the bound verification ledger and review verdict for the one candidate in the
header; the rest come from the request and the diff. Never write a secret, an
evidence claim the ledger does not carry, or evidence from another revision. An
evidence section with no row is not posted until it is filled, or until `none`
is written after checking. The filled copy becomes the PR body at the
transition the user chose; it never goes into the candidate.

```markdown
# {{what changes, in one line}}

- Candidate: {{full revision; or the working-tree digest with, beside it, the head revision of the commit set that reproduces it, so the reviewer can match the PR head}}
- Base: {{base ref at revision}}
- Requested by: {{who asked and where the request lives, or none recorded}}
- Supersedes: {{earlier PR or round this replaces, or none}}
- Owner: {{person accountable for this PR}}
- Decided in: {{where approval and the merge choice are recorded; this PR's review thread unless the project names another place}}
- Review verdict: {{self-reviewed: ready | ready, with each role's verdict and report location}}

## Why

{{the problem in the requester's terms: what fails or is missing today, and for whom}}

## What changes

{{the change by behaviour, then by path only where the reviewer must open it}}

## How it was verified

Every row is a ledger row run on the candidate above, posted within the
ledger's evidence controls; nothing wider.

| Gate | Command or action | Raw result | Output: excerpt, or where kept |
| --- | --- | --- | --- |
| {{gate}} | {{exact invocation}} | {{exit and counts as returned}} | {{excerpt the reviewer can read, or a location the reviewer can reach}} |

## Review

- Depth: {{shallow | standard | deep | high-risk transformation}}
- Open findings: {{none, or each finding and its disposition}}

## Risk and rollback

- Affected surfaces: {{contracts, data, consumers, operations this can break}}
- Rollback: {{reverting this PR alone restores the base, or the exact steps and order}}

## Not verified

{{gates pending, blocked, or inconclusive; cells not run; behaviour not exercised; or none}}

## Next action

{{each decision only the reviewer can make, with the options; or merge after review}}
```
