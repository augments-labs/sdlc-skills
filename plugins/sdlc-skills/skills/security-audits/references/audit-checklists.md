# Audit checklists

Expanded per-category checklists behind `../SKILL.md`. Loaded on demand.

One category per section. Walk each against the changed attack surface:
candidate lines plus security-relevant old code, consumers, dependencies,
generated/build inputs, configuration, and deployment made newly reachable. A
finding is not a finding until you can name the actor, asset,
**source → propagation → sink/effect** path, abuse case, and consequence.

Freeze a stable threat/category/cell inventory and digest. Each omitted category
needs skip ID, rationale/evidence, owner, expiry/revisit, compensating gate, and
approval.

Before any exploit/probe, bind exact candidate copy, platform/build/environment,
data/process/external effects, authority, resources, timeout/kill,
cleanup/recovery, and pre/post state. Never target shared or production state
without direct exact authority.

## 1. Authn / authz

Look for:

- Every new or touched endpoint, handler, or mutation: where is the identity established, and where is the permission checked? Both, in order, before the action.
- The object-level check, not just the route-level one: "is logged in" is not "owns {{resource-id}}". Follow every ID taken from the request to an ownership/scope check.
- Removed or narrowed checks: a decorator dropped, an `if` deleted, a role list widened, a check moved *after* the operation it guards (the action runs, then fails — side effects already happened).
- Default-deny: does a new route fall through to an allow-by-default framework convention instead of inheriting the guard its neighbors have?
- Client-side-only enforcement: hidden UI is not authorization; the server path must refuse on its own.

Commonly missed:

- **Insecure direct object reference** — the route checks authentication but never checks that `{{resource-id}}` in the path/body belongs to the caller.
- **Guard ordering** — the check still exists but now runs after the write/send/enqueue it was protecting.
- **The second path** — the UI route is guarded, but the bulk-export, retry, or
  admin variant made reachable by the candidate is not.

## 2. Input validation

Look for:

- Validation at the trust boundary, once, before first use — not scattered per-sink, and not after the value has already been used once.
- Type, range, length, and an allowlist where one exists (enum values, expected formats) — not just "is a string".
- Validation surviving re-serialization: a value parsed, transformed, decoded (base64, URL-decode, unicode normalization) can change shape after the check.
- Mass assignment: request bodies merged wholesale into a model or record, picking up fields the caller was never meant to set.

Commonly missed:

- **Validation that checks then transforms** — the check passes on the raw value; the decoded/normalized value reaching the sink is different.
- **Server trusts a client-computed value** — price, total, role, or checksum computed in the browser and re-accepted server-side.
- **One path validated, sibling paths not** — the form handler validates; the API, import, or webhook handler for the same data does not.

## 3. Injection

Look for:

- Every place untrusted input is *built into* an interpreter's input: query strings, shell commands, filesystem paths, URLs fetched server-side, templates, headers, serialized formats.
- Parameterized/escaped APIs used at the sink — string concatenation or interpolation into any of the above is a finding even if "the input is validated".
- Path construction: join a base with user input, then confirm the result stays under the base (traversal via `..`, absolute paths, symlinks).
- Server-side fetches of a caller-supplied URL: scheme and destination allowlisted, internal addresses and link-local ranges refused (SSRF).
- Second-order flows: input stored now, interpreted later by another component (a report renderer, an email template, an admin view).

Commonly missed:

- **"The ORM/builder makes it safe"** — until a newly reachable raw-fragment
  escape hatch takes concatenated input.
- **Escaping at the wrong layer** — input escaped for one sink (HTML) later reaches a different one (shell, SQL) where that escaping means nothing.
- **SSRF via indirection** — the URL is checked, but a redirect, a DNS name under attacker control, or a file fetched by its hostname resolves somewhere internal.

## 4. Secrets

Look for:

- Any literal credential, key, token, or connection string in code, config, fixtures, or test data — including "temporary" ones.
- Candidate configuration and packaged files: is there a value only the
  environment or a secret store should hold?
- Secrets in logs, error messages, exception payloads, or telemetry — a value printed for debugging stays printed.
- Secrets flowing to places with weaker retention: client-side bundles, analytics events, third-party error reporting, build artifacts.
- Never copy a secret value into a finding, prompt, log, or report. Record a
  redacted location/fingerprint under the descriptor's evidence controls.

Commonly missed:

- **Test fixtures with live-looking credentials** — a real key copied into a fixture "temporarily" is a leaked key regardless of intent.
- **The secret in the error path** — connection failure logs the full connection string, credentials included.
- **History, not just current files** — a secret added and removed in the same
  branch still ships in history.

## 5. Data exposure

Look for:

- Response serialization: whole-object returns where the object now carries a sensitive field (hashes, tokens, internal IDs, other users' data) — check what the serializer includes, not what the handler intends.
- Added, changed, or newly reachable logs: what do they capture and retain?
- Error responses: stack traces, internal paths, query text, or existence-oracle differences (distinct messages for "no such user" vs "wrong password").
- Over-fetching for filtering: sensitive rows fetched and filtered in code, but the unfiltered set left reachable through another accessor on the same object.

Commonly missed:

- **The response DTO grew a field** — the change adds one sensitive field to a shared serializer, and every endpoint using it now leaks it.
- **Verbose errors only in the failure path** — the happy path is clean; the 500 handler dumps internals.
- **Logs at debug level treated as harmless** — production incident response routinely runs at debug; level is not a boundary.

## 6. Security regression

Look for:

- Every *removed* line with a security meaning: a validation, an escape, a rate limit, a permission check, an expiry, a secure flag on a cookie or header.
- Loosened configuration: CORS widened to `*`, TLS verification disabled, a signature check made optional, an allowlist turned into a denylist.
- Defaults flipped: a feature flag defaulting to the permissive mode, a new code path that bypasses the hardened old one.
- "Refactors" of guard code: behavior-preserving claims on security logic deserve line-by-line comparison, not trust.

Commonly missed:

- **The disabled check left disabled** — a guard commented out for local
  debugging and shipped in the candidate.
- **A timeout or limit removed as "cleanup"** — brute-force and resource-exhaustion protections deleted because they looked like clutter.
- **Weakening hidden in a rename/move** — the check survives in name but the new wiring never calls it on this path.

## 7. Tenancy, isolation, and sessions

Look for:

- Tenant or account identity included in every query, cache key, queue message,
  object path, background job, authorization decision, and cleanup.
- Cross-request mutable state, pooled resources, or reused fixtures that can
  carry one principal's data into another's result.
- Session creation, fixation resistance, rotation after privilege change,
  expiry, revocation, replay prevention, and appropriate transport/browser
  protections.
- Request-forgery defenses on state-changing session-authenticated actions.

Commonly missed:

- **Cache-key isolation failure** — the data query is scoped but a shared cache
  key omits tenant identity.
- **Background privilege drift** — a job records object ID but not the actor or
  authorization context needed when it later executes.
- **Logout without revocation** — the client forgets a token while the server
  still accepts it.

## 8. Cryptography, races, and availability

Look for:

- Established cryptographic primitives and safe modes; key generation, storage,
  rotation, revocation, nonce/IV uniqueness, randomness, signature verification,
  downgrade behavior, and error handling.
- Check-then-act gaps between authorization/validation and mutation, concurrent
  duplicate execution, replay, lost updates, and lock or transaction boundaries.
- Unbounded input, recursion, allocation, fan-out, retries, queues, regex work,
  decompression, or response size.
- Rate limits, quotas, timeouts, cancellation, backpressure, circuit breaking,
  and degraded/recovery behavior on attacker-amplifiable paths.

Commonly missed:

- **Verification after effect** — a signature, permission, or state check happens
  after writing, sending, or enqueueing.
- **Nonce or idempotency reuse under retry** — one logical request becomes
  multiple accepted operations.
- **Cheap request, expensive work** — a tiny input triggers unbounded CPU,
  memory, storage, network, or third-party cost.

## 9. Dependencies, build, and deployment

Look for:

- Manifest and lock changes, dependency source/integrity, executable install or
  build hooks, generated artifacts, and whether the reviewed source is what the
  release actually packages.
- Build/CI credentials and permissions, untrusted contribution execution,
  artifact provenance, signing/verification, cache poisoning, and secret
  exposure in logs or outputs.
- Deployment defaults, public listeners/routes, firewall or origin policy,
  debug/admin endpoints, environment separation, and secret/config injection.
- Runtime/version or feature-mode skew that disables a security guard in one
  supported platform/build cell.

Commonly missed:

- **Source clean, artifact unsafe** — generated or packaged output includes a
  file, dependency, or secret absent from the reviewed source candidate.
- **Privileged build on untrusted input** — contribution-controlled scripts run
  with release or secret-bearing credentials.
- **Secure local default, exposed deployment default** — the service binds or
  routes publicly only in the production configuration.

## Writing the finding

Use the security report template supplied with the audit. Trace each finding
from attacker-controlled source through propagation to its sink or effect;
include the concrete exploit, observed gate result, and smallest correction.

Then issue only a revision-bound security verdict: **security clear** (no
security blocker open), **security blocked** (name blockers), or
**inconclusive** (name missing evidence). The fixer cannot issue the closing
verdict, and this verdict does not replace release readiness.
