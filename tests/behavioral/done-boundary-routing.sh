#!/usr/bin/env bash
# Does the implementation cycle reach its DONE boundary on ordinary bounded work?
#
# `verification-before-completion` owns the claim that work is finished, and `yagni` — which
# loads on every implementation task — names it in its own body: "confirm through
# `verification-before-completion`". That in-body handoff fired ZERO times in five live runs
# on this fixture and opening, while every one of those runs made exactly the
# claim the skill's description fires on ("Done", "6/6 tests passing"). A body
# statement cannot route a skill, and prose asking for a discretionary tool call
# at the moment the agent wants to stop is the step that gets skipped.
#
# The turn-end completion guard is what closes that. This scenario is its
# regression gate: the answer is known in advance, so a red here is a real
# regression in routing, not a measurement.
#
# The verdict is structural — a skill invocation in the event stream, read
# through the harness's own binding, never a grep of prose. Routing is what is
# being judged, so routing is what is read.

scenario_opening() {
  cat <<'EOF'
Billing needs the per-tier monthly request allowance in one place: free is
1,000, pro is 50,000, enterprise is unlimited. Add it as a module the billing
code can call with a plan tier and get the allowance back.

That is all I need right now — no enforcement, no wiring into the request path.
EOF
}

scenario_opening_codex() {
  scenario_opening
  cat <<'EOF'

This is a non-interactive run: do not ask me questions. Where something is
genuinely undetermined, record the assumption and carry on to a complete change.
EOF
}

# Bounded work with a repaired project command, so nothing else in the library
# has cause to fire and the done boundary is the only thing under test.
scenario_setup() {
  local d="$1"; fixture_node_api "$d"
  cat > "$d/package.json" <<'EOF'
{ "name": "billing-api", "version": "0.3.0", "scripts": { "test": "node --test test/*.test.js" } }
EOF
  cat > "$d/test/server.test.js" <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');

test('server module loads', () => {
  assert.ok(require('../src/server').handle);
});

test('apikeys module loads', () => {
  assert.ok(require('../src/apikeys').resolve);
});
EOF
}

scenario_assert() {
  local d="$1" events
  cd "$d" || return 2

  note "new files: $(added_since_baseline "$d" | tr '\n' ' ')"

  if [ ! -s "${stream:-}" ]; then
    echo "  no event stream to judge — inconclusive"; return 2
  fi

  # Read the chain through the harness's own binding. Hand-rolled jq here is a
  # bug waiting to happen: one harness's stream shape scores every other harness
  # as a silent miss, which reads as a routing failure that never occurred.
  events="$(bh_chain "$stream" 2>/dev/null)"

  if printf '%s\n' "$events" | grep -q 'verification-before-completion'; then
    pass "verification-before-completion fired before the run reported done"
  else
    fail "verification-before-completion never fired — the cycle ended at green, not at done"
  fi

  echo "  skill chain seen:"; printf '%s\n' "${events:--none-}" | sed 's/^/    /'
  assert_result
}
