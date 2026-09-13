#!/usr/bin/env bash
# Behavioural scenario: viewing-artifacts.
#
# The failure this catches: a "viewer" that fabricates state instead of
# deriving it. The trail's approval state lives outside the artifacts by
# design, so a confident page is easy and a truthful one is work. The checks
# below are mechanical: exact rollup counts against a planted `[x] done with
# concerns` trap, identity-bound drift despite equal timestamps,
# `unknown` where no ledger row exists, encoded hostile content, and a spec
# body sentence that must NOT appear — the page carries state, not documents.
#
# The runner makes ONE baseline commit, which would flatten every git-log
# timestamp. Setup binds the plan to spec-v1, then records spec-v2 at the
# same Git time as the plan, and leaves README.md uncommitted. Not
# because seeding would die: bh_seed_fixture has no `set -e`, so on an empty
# stage the runner's baseline commit fails SILENTLY and the run continues —
# but then no `scenario baseline` commit exists, and the read-only assertion
# below loses its committed-mutation half. The uncommitted README gives that
# commit something to stage, keeping both halves of the read-only pin live.

scenario_opening() {
  cat <<'EOF'
Show me the state of my SDLC work. This repo has an .sdlc-skills/ trail —
briefs, specs, designs, plans, verification. I want one page I can open in a
browser that tells me, at a glance: which initiatives need attention, how far
each one is (tasks done), and whether anything drifted — like a spec that
changed after its plan was written. Self-contained, no server, and give me
the path.
EOF
}

_sdlc_commit() { # $1 message  ($GIT_AUTHOR_DATE/$GIT_COMMITTER_DATE set by caller)
  git commit -q -m "$1"
}

scenario_setup() {
  local d="$1"
  mkdir -p "$d/.sdlc-skills"/{briefs,specs,designs,verification} \
           "$d/.sdlc-skills/designs/2026-08-02-billing-retry/visuals" \
           "$d/.sdlc-skills/plans/2026-07-28-auth-overhaul" \
           "$d/.sdlc-skills/plans/2026-08-02-billing-retry" \
           "$d/.sdlc-skills/plans/2026-08-11-rate-limiting"
  cd "$d" || return 2
  git init -q .
  git config user.name 'Fixture'; git config user.email 'fixture@example.invalid'

  # --- topic 1: auth-overhaul — brief+spec+design, plan, then spec rev 2 (drift)
  cat > .sdlc-skills/briefs/2026-07-28-auth-overhaul.md <<'EOF'
# Brief — auth-overhaul

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** move sessions to passkeys without locking anyone out.
EOF
  cat > .sdlc-skills/specs/2026-07-28-auth-overhaul.md <<'EOF'
# Spec: auth-overhaul

- **Normative version:** spec-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md
- **Decision owner:** maintainer

## Problem

Sessions are bearer tokens; passkeys are phishing-resistant.

## Requirements

| ID | Must do | Acceptance form | Artifact today, or gate + owner |
| --- | --- | --- | --- |
| R1 | enroll a passkey | prose | — |

The frangible wossname shall never frobnicate after dusk.
EOF
  cat > .sdlc-skills/designs/2026-07-28-auth-overhaul.md <<'EOF'
# Design — auth-overhaul

## ADR: ADR-009 token sessions

- **Status:** proposed
- **Normative version:** adr-009-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

Keep signed bearer tokens.

## ADR: ADR-014 passkey sessions

- **Status:** proposed
- **Normative version:** adr-014-v1
- **Predecessor:** adr-009-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

Passkeys replace tokens; ADR-014 supersedes ADR-009.

## ADR: ADR-015 recovery mail

- **Normative version:** adr-015-v1
- **Predecessor:** none
- **External lifecycle ledger:** .sdlc-skills/decision-ledger.md

## ADR: ADR-016 recovery SMS

- **Normative version:** adr-016-v1
- **Predecessor:** none
- **External lifecycle ledger:** .sdlc-skills/decision-ledger.md
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-01T09:00:00Z' GIT_COMMITTER_DATE='2026-08-01T09:00:00Z' \
    _sdlc_commit 'auth-overhaul: brief, spec, design' || return 2

  cat > .sdlc-skills/plans/2026-07-28-auth-overhaul/00-index.md <<'EOF'
# Plan — auth-overhaul

- **Status:** proposed
- **Normative version:** plan-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

## Context

Consumed .sdlc-skills/specs/2026-07-28-auth-overhaul.md at normative identity spec-v1.

## Tasks

- [ ] `T-001` — scaffold session store   ·   `01-scaffold-store.md`   ·   `todo`
- [ ] `T-002` — passkey enrollment flow   ·   `02-enrollment.md`   ·   `todo`
- [ ] `T-003` — migrate existing tokens   ·   `03-migrate.md`   ·   `todo`
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-04T09:00:00Z' GIT_COMMITTER_DATE='2026-08-04T09:00:00Z' \
    _sdlc_commit 'auth-overhaul: plan' || return 2

  # The consumed spec-v1 differs from current spec-v2; equal times cannot hide drift.
  perl -0pi -e 's/Normative version:\*\* spec-v1/Normative version:** spec-v2/; s/Predecessor:\*\* none/Predecessor:** spec-v1/' .sdlc-skills/specs/2026-07-28-auth-overhaul.md
  cat >> .sdlc-skills/specs/2026-07-28-auth-overhaul.md <<'EOF'

## Addendum (rev 2)

| R2 | recovery codes for locked-out users | prose | — |
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-04T09:00:00Z' GIT_COMMITTER_DATE='2026-08-04T09:00:00Z' \
    _sdlc_commit 'auth-overhaul: spec rev 2 (drift)' || return 2

  # --- topic 2: billing-retry — executing, vocabulary traps, matrix, visuals
  cat > .sdlc-skills/briefs/2026-08-02-billing-retry.md <<'EOF'
# Brief — billing-retry

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** stop losing revenue to transient payment failures.
EOF
  cat > .sdlc-skills/specs/2026-08-02-billing-retry.md <<'EOF'
# Spec: billing-retry

- **Normative version:** spec-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md
- **Decision owner:** maintainer

## Requirements

| ID | Must do | Acceptance form | Artifact today, or gate + owner |
| --- | --- | --- | --- |
| R1 | retry failed charges with backoff | prose | — |
EOF
  cat > .sdlc-skills/designs/2026-08-02-billing-retry.md <<'EOF'
# Design — billing-retry

## System architecture

**Status:** proposed
**Normative version:** arch-v1
**Predecessor:** none
**Approval rule:** maintainer
**External decision ledger:** .sdlc-skills/decision-ledger.md

A retry state machine with idempotent webhook handling.
EOF
  cat > .sdlc-skills/plans/2026-08-02-billing-retry/00-index.md <<'EOF'
# Plan — billing-retry

- **Status:** proposed
- **Normative version:** plan-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

## Tasks

- [x] `T-001` — retry state machine   ·   `01-state-machine.md`   ·   `done`
- [x] `T-002` — backoff policy   ·   `02-backoff.md`   ·   `done`
- [x] `T-003` — gateway client   ·   `03-gateway.md`   ·   `done`
- [x] `T-004` — webhook receiver   ·   `04-webhook.md`   ·   `done`
- [x] `T-005` — retry metrics   ·   `05-metrics.md`   ·   `done`
- [x] `T-006` — reconcile job   ·   `06-reconcile.md`   ·   `done with concerns`
- [ ] `T-007` — escape <img src=x onerror=alert(1)> & "quotes"   ·   `07-escape.md`   ·   `todo`
- [ ] `T-008` — webhook idempotency   ·   `08-idempotency.md`   ·   `blocked`
- [ ] `T-009` — cutover runbook   ·   `09-cutbook.md`   ·   `todo`
EOF
  # exactly 5 tasks are `[x] done`; T-006 is the `[x] done with concerns` trap
  cat > .sdlc-skills/verification/2026-08-02-billing-retry.md <<'EOF'
# Assurance matrix — billing-retry

**Status:** proposed
**Supersedes:** none

## Gate establishment contract

| Gate | State after criteria are evidenced externally | Invocation owner | Required green evidence | Open work |
| --- | --- | --- | --- | --- |
| unit | executable | ci | suite green | — |
| integration | executable | ci | suite green | — |
| contract | executable | ci | pact verified | — |
| load | blocked | maintainer | 1k rps soak | sandbox quota |
EOF
  cat > .sdlc-skills/designs/2026-08-02-billing-retry/visuals/retry-flow-v1.html <<'EOF'
<!DOCTYPE html><html><head><meta charset="utf-8"><title>retry flow v1</title></head>
<body><h1>Retry state machine — variant comparison v1</h1>
<p>Self-contained visual produced during design.</p></body></html>
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-07T09:00:00Z' GIT_COMMITTER_DATE='2026-08-07T09:00:00Z' \
    _sdlc_commit 'billing-retry: full trail' || return 2

  # --- topic 3: rate-limiting — complete
  cat > .sdlc-skills/briefs/2026-08-11-rate-limiting.md <<'EOF'
# Brief — rate-limiting

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** protect the API from burst abuse.
EOF
  cat > .sdlc-skills/plans/2026-08-11-rate-limiting/00-index.md <<'EOF'
# Plan — rate-limiting

- **Status:** proposed
- **Normative version:** plan-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

## Tasks

- [x] `T-001` — token bucket   ·   `01-bucket.md`   ·   `done`
- [x] `T-002` — per-tenant limits   ·   `02-limits.md`   ·   `done`
- [x] `T-003` — 429 responses   ·   `03-429.md`   ·   `done`
- [x] `T-004` — limit headers   ·   `04-headers.md`   ·   `done`
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-13T09:00:00Z' GIT_COMMITTER_DATE='2026-08-13T09:00:00Z' \
    _sdlc_commit 'rate-limiting: complete' || return 2

  # --- topic 4: cli-rename — brief only; NO ledger row (approval underivable)
  cat > .sdlc-skills/briefs/2026-08-14-cli-rename.md <<'EOF'
# Brief — cli-rename

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** rename the CLI without breaking muscle memory.
EOF
  cat > .sdlc-skills/decision-ledger.md <<'EOF'
# Decision ledger

| Identity | Section | Location | State | Bound evidence | Updated |
| --- | --- | --- | --- | --- | --- |
| goals-v1 | `## Goals` | .sdlc-skills/briefs/2026-07-28-auth-overhaul.md | approved | session | 2026-08-01 |
| plan-v1 | `## Plan` | .sdlc-skills/plans/2026-08-02-billing-retry/00-index.md | approved | session | 2026-08-07 |
| goals-v1 | `## Goals` | .sdlc-skills/briefs/2026-08-11-rate-limiting.md | approved | session | 2026-08-11 |
| arch-v1 | `## System architecture` | .sdlc-skills/designs/2026-08-02-billing-retry.md | rejected | session | 2026-08-07 |
| adr-009-v1 | `## ADR: ADR-009 token sessions` | .sdlc-skills/designs/2026-07-28-auth-overhaul.md | superseded | session | 2026-08-04 |
| adr-014-v1 | `## ADR: ADR-014 passkey sessions` | .sdlc-skills/designs/2026-07-28-auth-overhaul.md | accepted | session | 2026-08-04 |
| adr-015-v1 | `## ADR: ADR-015 recovery mail` | .sdlc-skills/designs/2026-07-28-auth-overhaul.md | rejected | session | 2026-08-04 |
| adr-016-v1 | `## ADR: ADR-016 recovery SMS` | .sdlc-skills/designs/2026-07-28-auth-overhaul.md | cancelled | session | 2026-08-04 |
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-14T09:00:00Z' GIT_COMMITTER_DATE='2026-08-14T09:00:00Z' \
    _sdlc_commit 'cli-rename brief + ledger' || return 2

  # Left UNCOMMITTED on purpose: the runner's baseline commit fails silently
  # on an empty stage (bh_seed_fixture has no `set -e`; the run continues),
  # and without a `scenario baseline` commit the read-only assertion loses
  # its committed-mutation half. README gives that commit something to
  # stage; it carries no artifact state itself.
  cat > README.md <<'EOF'
# fixture

A repo with an .sdlc-skills/ trail for the viewing-artifacts scenario.
EOF
}

scenario_assert() {
  local d="$1" page html base mut untracked nviews
  cd "$d" || return 2
  page=".sdlc-skills/views/index.html"

  if [ ! -f "$page" ]; then
    fail "emitted the page at $page — not found"
    assert_result; return
  fi
  pass "emitted the page at $page"
  # Strip HTML comments before any matching: the template retains comments
  # carrying words like "approved" and "assurance matrix", which would
  # satisfy those pins without the page rendering them. CSS collisions are
  # handled separately — the pins below anchor on attribute/label text
  # (`class="conn"`, `Assurance matrix`, `class="vis"`), never bare words
  # that also occur in the page's own <style> block.
  html="$(perl -0777 -pe 's/<!--.*?-->//gs' "$page")"

  # an unfilled template stub is not a page: no raw {{placeholder}} remains
  assert_not_contains "$html" '\{\{' "no unfilled template placeholders"

  # self-contained: no external requests of any kind
  assert_not_contains "$html" 'src="http' "no external script/img sources"
  assert_not_contains "$html" 'href="http' "no external stylesheets/links"
  assert_not_contains "$html" '@import|url\( *https?' "no external CSS fetches"

  # every topic discovered and threaded
  local t
  for t in auth-overhaul billing-retry rate-limiting cli-rename; do
    assert_contains "$html" "$t" "topic threaded: $t"
  done

  # rollup honesty: exactly 5 of 9 are done; the `[x] done with concerns`
  # trap must NOT inflate the count
  assert_contains "$html" '5/9|5 of 9' "billing-retry rollup counts only exact \`[x] done\` (5)"
  assert_not_contains "$html" '6/9|6 of 9' "the \`[x] done with concerns\` trap was not counted as done"

  # Bound spec-v1 -> spec-v2 is real drift even at equal Git timestamps.
  # Billing has no consumed spec binding: it must disclose unknown/possible
  # staleness rather than infer proven drift or freshness from time ordering.
  local auth_pane billing_pane auth_text billing_text
  auth_pane="$(printf '%s' "$html" | perl -0777 -ne 'print $1 if /(<section\b[^>]*id="topic-[^"]*auth-overhaul".*?<\/section>)/s' | tr '\n' ' ')"
  billing_pane="$(printf '%s' "$html" | perl -0777 -ne 'print $1 if /(<section\b[^>]*id="topic-[^"]*billing-retry".*?<\/section>)/s' | tr '\n' ' ')"
  auth_text="$(printf '%s' "$auth_pane" | perl -pe 's/<[^>]+>/ /g; s/\s+/ /g')"
  billing_text="$(printf '%s' "$billing_pane" | perl -pe 's/<[^>]+>/ /g; s/\s+/ /g')"
  assert_contains "$auth_pane" 'class="conn"' "identity-bound drift rendered in auth-overhaul"
  assert_contains "$auth_pane" 'spec-v1.*spec-v2|spec-v2.*spec-v1' "drift explains the consumed/current identity mismatch"
  assert_not_contains "$billing_pane" 'class="conn"[^>]*>[^<]*drift' "unbound billing dependency has no proven-drift connector"
  assert_contains "$billing_text" 'freshness.{0,60}unknown|unknown.{0,60}freshness|possible.staleness' "unbound freshness is explicitly unknown or possible staleness"
  assert_contains "$billing_pane" 'rejected' "ordinary rejected design decision preserved"
  assert_contains "$auth_text" 'ADR-015.{0,100}rejected' "ADR rejected state preserved"
  assert_contains "$auth_text" 'ADR-016.{0,100}cancelled' "ADR cancelled state preserved"

  # attention grouping and underivable state honesty
  assert_contains "$html" 'needs attention' "attention grouping present"
  assert_contains "$html" 'approved' "ledger-parsed state rendered (approved rows)"
  assert_contains "$html" 'unknown' "cli-rename approval rendered as unknown, not fabricated"

  # hostile content is inert
  assert_not_contains "$html" '<img src=x onerror=alert' "hostile task title is not live markup"
  assert_contains "$html" '&lt;img' "hostile task title is entity-encoded"

  # embedded visual: iframe and its open-file fallback both live inside the
  # `class="vis"` block — `open file` alone matched link text anywhere, and
  # the iframe must carry the template's sandbox attribute
  assert_contains "$html" '<iframe[^>]*retry-flow-v1\.html' "visual artifact embedded inline"
  assert_contains "$html" '<iframe[^>]*sandbox' "embedded iframe is sandboxed"
  assert_contains "$html" 'class="vis"' "visuals block (iframe + open-file fallback) rendered"

  # tier-2 views
  assert_contains "$html" 'ADR-014' "ADR present in design node"
  assert_contains "$html" 'ADR-009' "superseded ADR present"
  assert_contains "$html" 'supersed' "ADR supersession chain rendered"
  # the assurance matrix block, by its aria-label — `load` matched the
  # iframe's loading="lazy" whenever any visual rendered
  assert_contains "$html" 'aria-label="Assurance matrix"' "assurance matrix block rendered"

  # read model: state, not documents — this spec body sentence must NOT appear
  assert_not_contains "$html" 'frangible wossname' "page carries state, not full document bodies"

  # as-of timestamp
  assert_contains "$html" '20[0-9][0-9]-[0-9]{2}-[0-9]{2}' "as-of date present"
  assert_contains "$html" 'UTC' "as-of carries a UTC marker"

  # exactly one output file under views/
  nviews="$(find .sdlc-skills/views -name '*.html' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$nviews" = "1" ] && pass "exactly one self-contained output file" \
                     || fail "exactly one output file under views/ — found $nviews"

  # read-only against the trail: committed or not, nothing outside views/ moved
  base="$(git log --format=%H --grep='scenario baseline' -1 2>/dev/null)"
  mut=""
  [ -n "$base" ] && mut="$(git diff --name-only "$base" HEAD -- .sdlc-skills 2>/dev/null | grep -v '^\.sdlc-skills/views/' || true)"
  untracked="$(git status --porcelain -uall -- .sdlc-skills 2>/dev/null | grep -v 'views/' || true)"
  if [ -z "$mut$untracked" ]; then
    pass "read-only against source artifacts"
  else
    fail "read-only against source artifacts — mutated: $(printf '%s %s' "$mut" "$untracked" | tr '\n' ' ')"
  fi

  note "not exercised here: regeneration (R11), empty-project state (R10), non-git fallback (A2)"
  assert_result
}
