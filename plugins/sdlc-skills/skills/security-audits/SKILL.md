---
name: security-audits
description: "Use when a change touches a trust boundary, attacker-controlled input, authentication or authorization, secrets, sensitive data, isolation, a dependency, build or deploy exposure, availability, session handling, cryptography, or security-relevant reachability. Fires on anything touching login, tokens, permissions, uploads, or user-supplied input reaching a query or a shell, even if nobody says security. A generic security review, scanner, or ordinary code review is not a substitute. Skip only when evidence shows no security surface changed."
---

# Security Audits

Trace what an adversary can make the exact candidate do, from every
attacker-controlled source to the sink it reaches. Audit the changed attack
surface, not the changed lines. Never copy a prior finding, scanner summary,
or comment as a verdict.

## When to use

- The candidate changes a trust boundary, or changes how untrusted actors reach
  data, operations, dependencies, runtime resources, or deployment.
- **Skip** only after inspecting reachability and confirming that no security
  surface changed. “Small diff” and “internal refactor” are not evidence.

## Step 1: Freeze and model

1. Stop anything still writing to the candidate.
2. Reuse a current `requesting-code-review` descriptor, or invoke that skill
   and fill its review-candidate descriptor.
3. **REQUIRED SUB-SKILL:** invoke `verifying-completion` for the exact-state
   gates that apply. Join its state identity byte-for-byte.
4. Inventory the threat model: protected assets, trusted and untrusted actors,
   entry points, trust boundaries, privileges, assumptions, abuse cases. Give
   each a stable ID and the source digest it was taken against.
5. For each assumption record: supporting evidence, how it is validated, its
   owner, its expiry, and what happens if it is false.

## Step 2: Trace

1. Expand scope by reachability from the changed code: newly reachable old
   code, callers, shared serializers and guards, generated sources, data
   stores, dependencies, build and CI, configuration, deployment. Record why
   each expansion is relevant.
2. Note pre-existing unrelated issues separately. Keep them out of this verdict.
3. Work every category checklist in `references/audit-checklists.md`.
4. Mark each category covered, or obtain an omission through Step 4.
5. Write each finding in three parts: attacker-controlled source, propagation,
   the sink or effect it actually reaches.
6. Run the assurance-matrix security gates for every relevant platform, build
   mode, and environment cell, under `verifying-completion`'s effect authority.
   Never exploit shared or production state without exact, direct authority.
7. Missing or stale gate: record a blocker and go to Step 4. Do not work
   around it.
8. Write findings in the shape of the checklist file's *Writing the finding*
   section, bound to the revision. Fix = the smallest change that closes the
   path. Sensitive evidence = redacted location or digest, never the value.

## Step 3: Verdict

1. Dispatch an auditor independent of the implementer through a real callable
   action. Dispatched = a nonempty receipt. Empty, refused, or unavailable:
   issue `inconclusive` with the gate pending. Never self-certify.
2. Poll the exact receipt to its deadline. Failure or passed deadline: write
   `cancellation requested`, wait for quiet, quarantine partial output; a
   retry links its predecessor and rejects its late results.
3. **REQUIRED SUB-SKILL:** invoke `receiving-code-review` for every finding
   that comes back.
4. After a fix: new candidate, rerun the affected gates, independent focused
   re-audit. Never certify your own correction.
5. Issue one verdict: `security clear`, `security blocked`, or
   `inconclusive`, bound to the candidate and review-input identities.
   `security clear` requires the independent auditor.
6. Return it to the review that requested it. Leave releasability to
   `release-readiness`. Any security-relevant edit invalidates the verdict.
7. End the report with exactly one valid JSON line, both identities copied
   byte-for-byte:

   ```text
   SDLC_SKILLS_SECURITY_RESULT={"candidate":"{{exact result identity}}","context":"{{exact review-input identity}}","verdict":"{{security clear | security blocked | inconclusive}}","report":"{{nonempty location or returned directly}}"}
   ```

## Step 4: When a category cannot be covered

No gate exists, or the probe needs shared or production state you cannot
touch. Do not approve the omission yourself.

1. State the candidate, the blocked category and reason, and the exposure.
2. Ask one question offering: authorize the exact probe with its effects and
   blast radius; accept the omission with owner, expiry, and compensation;
   keep the candidate security-blocked.
3. Recommend the safest evidence-supported answer with one sentence. Stop.
4. Unanswered, silence, urgency: verdict stays `inconclusive`.
5. An accepted omission binds to this exact candidate and dies with the
   verdict on any security-relevant edit.
6. Missing auditor independence is not on this menu; Step 3 settles it.
