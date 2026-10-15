# Dispatch briefs in depth

Worked examples behind `../SKILL.md` — loaded on demand. Each pair shows a weak brief and the strong one for the same task, filled from `../assets/dispatch-packet.md`. The examples show the slim packet; a high-risk run or a phase queue fills `../assets/dispatch-packet-controlled.md` as well.

## Pair 1 — separate failing tests

Two failing tests in two test files. Independent: disjoint files, no shared state, no ordering.

**Weak:**

```text
Fix the failing tests in test/auth and test/billing. Run the suite when done.
```

Why it fails: the agent touches both — that was one agent doing two tasks serially, so the fan-out bought nothing; "the suite" runs the other agent's half-fixed code and muddies the verdict; no report shape, so you get prose you can't reconcile.

**Strong:**

```markdown
## Task

- **Task:** Make the failing test 'rejects an expired token' pass in tests/auth/expiry_test.go.
- **Tier:** medium
- **Base:** {{immutable revision shared by all writers}}

## Boundary

- **Owns:** tests/auth/expiry_test.go, src/auth/expiry.go
- **Do not touch:** anything under tests/billing/ or src/billing/ — another agent owns it.

## Inputs

- **Start from:** failing assertion, verbatim:
  expected status 401, got 200 for a token expired 1 minute ago
- **Read:** {{path to the token-lifetime docs}} — skim only if expiry.go isn't self-explanatory.

## Done when

- **Done when:** `go test ./tests/auth/ -run TestExpiredToken` exits 0. Run the command; read the output.

## Output

- **Report:** base/result revisions and diff; root cause; files changed; exact
  command and raw verdict; authorized checkpoint commits or none; scope
  exceptions.
```

Dispatch the billing test as a second, symmetric brief.

## Pair 2 — unrelated bugs

Two bug reports: a crash in export, a typo in a settings label. Independent: different subsystems.

**Weak:**

```text
Here's the session so far: [dumps session history]. Fix the export crash and the settings typo.
```

Why it fails: session history is not context — it carries your dead ends and misreadings, and the agent inherits them. Two bugs in one brief means the agent sequences them anyway and can half-finish both.

**Strong (export crash):**

```markdown
## Task

- **Task:** Find and fix the crash when exporting a project with zero images.
- **Tier:** medium
- **Base:** {{immutable revision shared by all writers}}

## Boundary

- **Owns:** src/export/
- **Do not touch:** src/settings/ or anything UI-facing — another agent owns a separate fix there.

## Inputs

- **Start from:** reproduce: 1) new project, 2) delete all images, 3) Export → crash with
  "TypeError: cannot read 'width' of undefined" at export/render.ts:88
- **Read:** src/export/render.ts, src/export/pipeline.ts

## Done when

- **Done when:** the reproduce steps complete and produce a valid export file; `npm test -- export` exits 0.

## Output

- **Report:** base/result revisions and diff; root cause; fix location; raw
  command verdicts; authorized checkpoint commits or none; checked edge
  cases; scope exceptions.
```

The typo gets its own brief at the small tier. The worker still observes the
named RED under TDD; it need not run a broad suite merely to discover which
failure owns the task.

## Pair 3 — parallel research

Compare three caching approaches for a read-heavy endpoint; recommend one. Research agents write no code, so the file-collision risk is nil — the real risk is three incompatible report shapes you can't reconcile.

**Weak:**

```text
Research caching options for the product list endpoint and tell me which is best.
```

Why it fails: "best" undefined — each agent optimises a different axis; no criteria, no report shape, so you get three essays that don't line up; no scope, so one agent reads the whole codebase for a week.

**Strong:**

```markdown
## Task

- **Task:** Evaluate {{approach}} as the cache for the product-list endpoint.
- **Tier:** small
- **Base:** {{immutable repository revision}}

## Boundary

- **Owns:** nothing — read-only. Do not modify files.

## Inputs

- **Read:** src/api/product_list.ts (the endpoint), src/api/README.md (current load profile).

## Done when

- **Judge against, in order:** 1) correctness under concurrent writes, 2) p95
  read latency at the load in README, 3) operational cost (new infra? new
  failure modes?), 4) lines-of-code cost to adopt.
- **Done when:** you can answer all four criteria from evidence you actually
  read — a file, a measurement, or the approach's documented semantics. No
  "it should be fine."

## Output

- **Report, exactly this shape:**
  - Approach: {{approach}}
  - Per criterion: verdict (good/bad/risky) + one line of evidence + where you read it
  - Deal-breaker if any, else "none"
  - Unknowns: what you could not determine from the repo
```

One brief per approach, identical except `{{approach}}`.

## Failure patterns to check before dispatching

- **The brief that needs the session.** Any reference to "the earlier discussion," "as we decided," or "the bug I showed you" — the agent has none of that. Paste it or point at a file.
- **Bulk pasted, definition pointed.** A 500-line log inline and "the spec is at {{path/to/spec}}" is backwards.
- **Tier without selection.** The brief names the capability needed; apply the skill's **Model selection** section to configure the model that will actually run.
- **Verification by description.** "Make sure it works" is not DONE WHEN. Name the command; the exit code is the verdict.
- **Symmetric overlap.** Two briefs that each say "and tidy up anything nearby" touch the same files. Generosity is a race condition.
- **Report shapes that don't reconcile.** If you can't put the agents' outputs side by side, you didn't specify the shape — you specified an essay contest.
- **Disjoint files, exhausted host.** No per-worker and aggregate resource
  envelope, reserve, enforcement, or cleanup means the work is not independent
  enough to dispatch.
- **Unbounded data handoff.** “Read the repository” without classification,
  allowed worker/provider/storage, prohibited material/effects, or evidence
  lifecycle can leak data even when file ownership is perfect.
