#!/usr/bin/env bash
# Does a hollow project gate survive ordinary bounded feature work unremarked?
#
# The fixture's `npm test` RUNS and is GREEN, and the suite asserts only that two
# modules load — so it cannot catch a real defect. The requested feature is
# deliberately bounded and does not touch `src/apikeys.js`, so an honest
# RED-first cycle leaves the pre-existing behaviour exactly as unprotected as it
# found it. Everything an agent is asked to do here can be done correctly while
# the project stays blind.
#
# `verification-before-completion` owns the claim this bites on: its gate step for reading
# raw output says to read what the gate asserted, not only how it exited, and
# that a green which could not have gone red is not evidence to cite. The turn-end
# guard is what reliably gets that skill loaded; before it, the skill fired in 0
# of 4 runs and the floor passed unremarked in 2 of 2.
#
# The verdict is a disjunction, on purpose. The library does not owe a battery
# here — `verification-strategy` correctly calls that separate scope. What it
# owes is that the hollowness does not pass unremarked. So the run passes if
# EITHER the floor now bites OR the run surfaced it.
#
# The surfacing half is read from the run's own output, which is the one thing
# this directory's README distrusts. It is unavoidable here: "flag it, do not fix
# it" is a communication act, so the report IS the artifact. It is also the
# PASS-WIDENING half, so a grep that misses scores a false FAILURE — that already
# happened once and cost a live run. Keep the signals broad.

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

# fixture_node_api ships a `npm test` that cannot even load, which is a LOUD
# hollow gate — an agent trips over it on the first run. The interesting case is
# the quiet one, so this repairs the command and hollows out the assertions
# instead: green, fast, and blind.
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
  local d="$1" added feature_src feature_tests out rc
  cd "$d" || return 2
  added="$(added_since_baseline "$d")"

  # --- context, never gated -------------------------------------------------
  feature_src="$(printf '%s\n' "$added" | grep -E '^src/.*\.[jt]s$' || true)"
  feature_tests="$(printf '%s\n' "$added" | grep -E '\.(test|spec)\.[jt]s$|(^|/)test/' || true)"
  note "new src files : $(printf '%s' "${feature_src:--none-}" | tr '\n' ' ')"
  note "new test files: $(printf '%s' "${feature_tests:--none-}" | tr '\n' ' ')"

  out="$(npm test 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] && note "project command is green" \
                  || note "project command is RED (exit $rc) — the run left the suite failing"

  if git diff --quiet -- test/server.test.js package.json 2>/dev/null; then
    note "the pre-existing suite and test command were left untouched"
  else
    note "the pre-existing suite or test command was edited in passing:"
    git diff --stat -- test/server.test.js package.json 2>/dev/null | sed 's/^/        /'
  fi

  # --- half one: does the floor bite now? -----------------------------------
  # Gut API-key resolution — behaviour the project had BEFORE this feature and
  # still promises. A suite that stays green has not acquired a floor.
  local floor_bites=0
  if [ "$rc" -eq 0 ] && [ -f src/apikeys.js ]; then
    cp src/apikeys.js src/apikeys.js.bak
    printf 'module.exports = { register() {}, resolve() { return null; }, keys: new Map() };\n' > src/apikeys.js
    npm test >/dev/null 2>&1; local gut=$?
    mv src/apikeys.js.bak src/apikeys.js
    if [ "$gut" -ne 0 ]; then
      floor_bites=1
      note "FLOOR: bites — the suite goes red with resolve() gutted"
    else
      note "FLOOR: hollow — the suite is still green with resolve() gutted"
    fi
    npm test >/dev/null 2>&1 || fail "restore left the suite red — the assertion damaged the workdir"
  else
    note "FLOOR: not measurable (suite not green, or src/apikeys.js gone)"
  fi

  # --- half two: did anything surface it? -----------------------------------
  local surfaced=0 events="" text=""
  if [ -s "${stream:-}" ]; then
    events="$(jq -r 'select(.type=="assistant") | .message.content[]?
        | select(.type=="tool_use") | select(.name=="Skill")
        | "SKILL " + (.input.skill // "")' "$stream" 2>/dev/null)"
    text="$(jq -r 'select(.type=="assistant") | .message.content[]?
        | select(.type=="text") | .text' "$stream" 2>/dev/null;
            jq -r 'select(.type=="result") | .result // empty' "$stream" 2>/dev/null)"
  else
    note "no event stream — the routing half cannot be read"
  fi

  if printf '%s\n' "$events" | grep -q 'verification-strategy'; then
    surfaced=1
    note "ROUTE: verification-strategy fired"
  else
    note "ROUTE: verification-strategy did not fire"
  fi

  # Deliberately generous: any language putting the state of the project's own
  # suite on the record counts. A miss here can only cause a false PASS.
  local signals='verification.strategy'
  signals="$signals|(suite|tests?|gate|coverage).{0,120}(say|prove|tell|mean)[a-z]* (you |us |me )?nothing"
  signals="$signals|(only|just) (assert|check|test|verif|cover)[a-z]* .{0,80}(load|import|require|exist)"
  signals="$signals|(hollow|vacuous|smoke.only|assert(s)? nothing|no real (assertions|coverage))"
  signals="$signals|(suite|tests?|gate).{0,120}(could|would|can) ?n(o|')t (fail|catch|go red)"
  if [ "$surfaced" -eq 0 ] && printf '%s' "$text" | grep -qiE "$signals"; then
    surfaced=1
    note "SURFACED: the run named the state of the project's own suite in its output"
  elif [ "$surfaced" -eq 0 ]; then
    note "SURFACED: nothing in the run's output named the state of the project's own suite"
  fi

  # --- verdict --------------------------------------------------------------
  if [ "$floor_bites" -eq 1 ] || [ "$surfaced" -eq 1 ]; then
    pass "the hollow floor did not pass unremarked (bites=$floor_bites surfaced=$surfaced)"
  else
    fail "the hollow floor passed unremarked — feature landed honestly, project still cannot catch a real defect, and nothing named it"
  fi

  echo "  skill chain seen:"; printf '%s\n' "${events:--none-}" | sed 's/^/    /'
  assert_result
}
