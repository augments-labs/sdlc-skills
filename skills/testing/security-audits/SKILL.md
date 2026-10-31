---
name: security-audits
description: "Audits what an attacker can make a change do, from attacker-controlled input to its effect. Use when a change touches a trust boundary, attacker-controlled input, authentication or authorization, secrets, sensitive data, isolation, a dependency, build or deploy exposure, availability, sessions, or cryptography, including anything touching login, tokens, permissions, uploads, or user input reaching a query or a shell. Skip only when no security surface changed."
---

# Security Audits

Trace what an adversary can make the exact version under review do, from
every attacker-controlled source to the sink it reaches. Never copy a prior
finding, scanner summary, or comment as a verdict.

## When to use

- The version under review changes a trust boundary, or changes how untrusted
  actors reach data, operations, dependencies, runtime resources, or
  deployment.
- **Skip** only after inspecting what the change makes reachable and
  confirming that no security surface changed. “Small diff” and “internal
  refactor” are not evidence.

## Step 1: Freeze and model

1. Stop the writers this task started; report any other writer to its owner
   and keep review pending until it stops.
2. Take as input the review-candidate descriptor its caller passed, with
   the identities of the version under review and of its review inputs
   already frozen. If there is no descriptor, the
   audit is pending: ask the caller for one. Never obtain it by invoking a
   review skill; that dispatches a second review and routes this audit back
   here.
3. **REQUIRED SUB-SKILL:** invoke `verification-before-completion` for the
   checks on this exact state that apply. Join its state identity byte for
   byte.
4. Inventory the threat model: protected assets, trusted and untrusted actors,
   entry points, trust boundaries, privileges, assumptions, abuse cases. Give
   each a stable ID and the hash of the source it was taken against.
5. For each assumption record: supporting evidence, how it is validated, its
   owner, its expiry, and what happens if it is false.

## Step 2: Trace

1. Widen the scope to everything reachable from the changed code: newly
   reachable old code, callers, shared serializers and guards, generated
   sources, data stores, dependencies, build and CI, configuration,
   deployment. Record why each expansion is relevant.
2. Note pre-existing unrelated issues separately. Keep them out of this
   verdict.
3. Read `references/audit-checklists.md` before tracing, and work every
   category checklist in it.
4. Mark each category covered, or obtain an omission for it through Step 4.
5. Write each finding in three parts: attacker-controlled source, propagation,
   the sink or effect it actually reaches.
6. Run the security checks the assurance matrix names for every relevant
   platform, build mode, and environment cell, under
   `verification-before-completion`'s effect authority. Never exploit shared
   or production state without exact, direct authority.
7. If a check is missing or stale, record a blocker and go to Step 4. Do not
   work around it.
8. Write each traced finding (source, propagation, sink) to a working note at
   `.sdlc-skills/evidence/{{YYYY-MM-DD}}-{{topic}}/security-notes.md`, never
   into the report template. Fix means the smallest change that closes the
   path. Sensitive evidence means a redacted location or hash, never the
   value.

## Step 3: Verdict

1. Send the blank `assets/security-report.md` when you dispatch the
   independent auditor's instructions, following `dispatching-parallel-agents`
   Step 2; never send your working note or a filled copy. Only the auditor
   fills the report, `Verdict` included.
   Never self-certify: a labelled self-audit never issues `security clear`.
2. Only the auditor's completed result counts; a running, failed, or
   cancelled audit leaves the verdict pending.
3. **REQUIRED SUB-SKILL:** invoke `receiving-code-review` for every finding
   that comes back.
4. After a fix, or any later edit that touches a file, boundary, or path the
   report names or adds a security surface, there is a new version under
   review: rerun the affected checks and obtain a focused independent
   re-audit of that edit. An edit outside those leaves the verdict standing
   on the new version. Never certify your own correction.
5. Read the auditor's completed report. Match `Candidate` and
   `Review inputs` byte for byte to the descriptor, `Role` to `security`, and
   `Verdict` to step 6. If a field is missing, unreadable, conflicting, or
   mismatched, the verdict is `inconclusive`.
6. Issue one verdict: `security clear`, `security blocked`, or
   `inconclusive`, bound to the identities of the version under review and
   of the review inputs. `security clear` requires the independent auditor.
7. Return the report or its location to the requesting review. Leave
   releasability to `release-readiness`. Any security-relevant edit voids the
   verdict.

## Step 4: When a category cannot be covered

This is the case when no check exists, or the probe needs shared or
production state you cannot touch. Do not approve the omission yourself.

1. State the version under review, the blocked category and the reason, and
   the exposure.
2. Ask one question offering these choices: authorize the exact probe,
   with its effects and blast radius; accept the omission, with an owner, an
   expiry, and compensation; or keep the version under review
   security-blocked.
3. Recommend, in one sentence, the safest answer the evidence supports. Stop.
4. If there is no answer, or the reply is silence or urgency, the verdict
   stays `inconclusive`.
5. An accepted omission is bound to this exact version under review and is
   voided, with the verdict, by any security-relevant edit.
6. A lack of auditor independence is not on this menu; Step 3 settles it.

## Gotchas

- An audit of the changed lines misses old code the change newly exposes.
  What is reachable from the change sets the scope, not the diff.
- A scanner summary is not a traced path. A finding stands only with its
  source, propagation, and sink written out, and a summary names none of them.
