#!/usr/bin/env bash
# Behavioural test — ONE runner for every harness.
#
# Activation asks "did the skill fire?" — one generic verdict. This asks "did the
# skill change what got BUILT?", which has no generic verdict: success differs
# per skill. So the scenario owns the judgement (`scenario_assert`, exit code)
# and the harness owns only how its CLI is driven (`tests/harnesses/<harness>.sh`).
#
# The plumbing below was briefly a separate lib; with one runner
# instead of three it had a single consumer, so it lives here. assert.sh
# stays split — every scenario uses it.
#
# THREE ARMS, because a behavioural claim is a comparison — and there are two
# different comparisons worth making:
#   --arm green   loads the skills from the working tree (your edit)
#   --arm red     loads them from a throwaway `git worktree` at --base, so the
#                 before-arm stays reproducible AFTER the change is committed.
#                 Running RED by hand before editing works exactly once.
#   --arm none    loads NO skills at all — a bare agent on the same opening.
#
# RED vs GREEN is the regression question: did my edit change anything?
# NONE vs GREEN is the value question: is the skill doing the work, or would
# the model have done this unaided? A skill whose assertions pass just as well
# on NONE is spending context for nothing, however well written it is. That is
# the arm that can retire a skill, and the only one that can.
#
# Each arm also reports what it COST — wall clock, and tokens where the harness's
# own stream reports them. Value is a ratio, not a pass rate: a skill that lifts
# the assertions but triples the tokens is a different trade from one that is
# both better and cheaper, and a pass rate alone cannot tell those apart. Run two
# arms and the difference between their cost lines is the price of the skill.
#
# Real API calls, roughly a full agent task per arm. Manual tool, never CI.
#
# Flags and exit codes: --help.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
harnessdir="$(cd "$(dirname "$0")/harnesses" && pwd)"
cd "$scriptdir/.." || exit 2
repo="$PWD"

usage() {
  cat <<'EOF'
tests/run-behavioral.sh — did the skill change what got BUILT?

  --harness NAME    claude-code | codex | kimi-code      (required)
  --scenario NAME   a file at tests/behavioral/NAME.sh  (required)
  --arm WHICH       green | red | none                   (required)
                      green  skills from the working tree (your edit)
                      red    skills from a worktree at --base (the before)
                      none   no skills at all (is the skill earning its context?)
  --base REF        git ref the red arm checks out       (default: origin/dev)
  --timeout SEC     per-arm wall clock                   (default: 1800)
  --keep            keep the scenario workdir for inspection
  --help            this text

Exit codes: 0 the scenario's own assertions passed · 1 they failed
            2 bad or missing arguments · 3 harness or tooling unavailable

Examples:
  tests/run-behavioral.sh --harness claude-code --scenario spec-it --arm green
  tests/run-behavioral.sh --harness claude-code --scenario spec-it --arm none
  tests/run-behavioral.sh --harness codex --scenario spec-it --arm red --base origin/dev
EOF
}

harness=""; args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    --harness) harness="$2"; shift 2;;
    *) args+=("$1"); shift;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }
[ -f "$harnessdir/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }

. "$harnessdir/$harness.sh"

# Optional per-adapter primitive: print the run's total token count for $1, or
# print nothing when that harness's stream does not report one. Defined here
# only as a fallback, so an adapter that implements it wins. Never guess a field
# name to fill this in — a fabricated number is worse than an absent one, since
# it silently becomes the denominator of a value judgement.
declare -F adapter_usage >/dev/null 2>&1 || adapter_usage() { :; }

# --- harness-agnostic plumbing ------------------------------------------------
. "$scriptdir/assert.sh"
. "$scriptdir/fixtures.sh"

# Fills: scenario arm base timeout_s keep
bh_parse_args() {
  scenario=""; arm=""; base="origin/dev"; timeout_s="${BH_DEFAULT_TIMEOUT:-1800}"; keep=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --scenario) scenario="$2"; shift 2;;
      --arm)      arm="$2"; shift 2;;
      --base)     base="$2"; shift 2;;   # RED arm: ref holding the pre-change skills
      --timeout)  timeout_s="$2"; shift 2;;
      --keep)     keep="1"; shift;;
      *) echo "unknown argument: $1" >&2; return 2;;
    esac
  done
  [ -n "$scenario" ] || { echo "needs --scenario NAME" >&2; return 2; }
  case "$arm" in red|green|none) ;; *) echo "needs --arm red|green|none" >&2; return 2;; esac
}

# Sources the scenario (one file: fixture, opening, optional follow-up turns,
# assertions) and picks the opening and setup for this adapter. Fills:
# opening_file opening_kind setup_kind followups
bh_resolve_scenario() {
  local adapter="$1" f="$scriptdir/behavioral/$scenario.sh"
  [ -f "$f" ] || { echo "no scenario at $f" >&2; return 2; }
  # assert helpers already sourced above
  . "$f"
  for fn in scenario_opening scenario_setup scenario_assert; do
    command -v "$fn" >/dev/null 2>&1 || { echo "$scenario.sh defines no $fn()" >&2; return 2; }
  done
  # Per-adapter overrides exist only for a real harness constraint.
  local override="scenario_opening_${adapter//-/_}"
  if command -v "$override" >/dev/null 2>&1; then opening_kind="$override"; else opening_kind="scenario_opening"; fi
  opening_file="$(mktemp)"; "$opening_kind" > "$opening_file"
  local setup_override="scenario_setup_${adapter//-/_}"
  if command -v "$setup_override" >/dev/null 2>&1; then setup_kind="$setup_override"; else setup_kind="scenario_setup"; fi
  followups=()
  if command -v scenario_followups >/dev/null 2>&1; then
    scenario_followups
  fi
}

# Fills: plugin_src redtree.  RED builds a throwaway worktree at $base so the
# before-arm stays reproducible AFTER the change is committed — running it by
# hand before editing works exactly once. NONE leaves plugin_src empty, which
# every adapter reads as "install nothing"; the agent runs bare.
bh_setup_arm() {
  redtree=""
  case "$arm" in
    none)
      plugin_src="" ;;
    red)
      git -C "$repo" rev-parse --verify "$base" >/dev/null 2>&1 || {
        echo "--base '$base' is not a valid ref (fetch first?)" >&2; return 2; }
      redtree="$(mktemp -d)"; rm -rf "$redtree"
      git -C "$repo" worktree add --detach "$redtree" "$base" >/dev/null 2>&1 || {
        echo "could not create worktree at $base" >&2; redtree=""; return 2; }
      plugin_src="$redtree" ;;
    *)
      plugin_src="$repo" ;;
  esac
}

# Fills: workdir — a disposable copy of the fixture, committed on a task branch
# so branch-discipline skills see a settled repo.
bh_seed_fixture() {
  workdir="$(mktemp -d)"
  "$setup_kind" "$workdir" || return 2
  (
    cd "$workdir" || exit 2
    git init -q . 2>/dev/null || exit 2
    git add -A
    git -c user.name='SDLC skills Harness' -c user.email='harness@example.invalid' \
        commit -q -m 'scenario baseline'
    git switch -qc task/behavioral-probe
  ) || { echo "failed to seed fixture repo" >&2; return 2; }
}

bh_cleanup() {
  [ -n "${redtree:-}" ] && git -C "$repo" worktree remove --force "$redtree" >/dev/null 2>&1
  [ -n "${harness_home:-}" ] && rm -rf "$harness_home"
  if [ -n "${keep:-}" ]; then
    echo "kept: workdir=$workdir stream=$stream errlog=$errlog"
  else
    rm -rf "${workdir:-}"; rm -f "${stream:-}" "${errlog:-}"
  fi
}

# Committed AND uncommitted. An agent that wraps its branch commits its work, and
# a status-only view then shows a clean tree and reads as "produced nothing" —
# that scored a real PASS as absence once.
bh_show_artifacts() {
  ( cd "$workdir" && {
      local root; root="$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
      [ -n "$root" ] && git diff --name-status --diff-filter=A "$root" HEAD 2>/dev/null \
        | sed 's/^/  committed /'
      git status --porcelain -uall | sed 's/^/  /'
    } )
}

# $1 = adapter, $2 = CLI exit status. Prints the report, runs the probe, and
# returns the verdict as THIS script's exit code — prose in a summary is written
# by the same agent that wants it green; an exit code is not.
bh_report() {
  local adapter="$1" status="$2" chain
  chain="$(bh_chain "$stream" 2>/dev/null | awk '!seen[$0]++' | paste -sd' ' -)"
  local src
  case "$arm" in
    none) src='no skills installed' ;;
    red)  src="$base" ;;
    *)    src='working tree' ;;
  esac
  echo "scenario   : $scenario"
  echo "adapter    : $adapter"
  echo "arm        : $arm  (skills from: $src)"
  echo "opening    : $opening_kind"
  echo "setup      : $setup_kind"
  echo "exit       : $status"
  local toks; toks="$(adapter_usage "$stream" 2>/dev/null | tr -dc '0-9')"
  if [ -n "$toks" ]; then
    echo "cost       : ${bh_elapsed_s}s · ${toks} tokens"
  else
    echo "cost       : ${bh_elapsed_s}s · tokens not reported by this harness"
  fi
  echo "skill chain: ${chain:-(none)}"
  echo "artifacts  :"
  bh_show_artifacts

  if [ "$status" -eq 124 ]; then
    echo "verdict    : TIMEOUT after ${timeout_s}s — cut off, treat as inconclusive"; return 1
  elif [ "$status" -ne 0 ]; then
    echo "verdict    : ERROR — $adapter exited $status (see $errlog)"; return 1
  fi
  if grep -qiE 'usage limit|login_required|api_error: 4' "$stream" "$errlog" 2>/dev/null; then
    echo "verdict    : BLOCKED — provider refused (quota/auth); not a behavioural result"; return 1
  fi
  # A NONE arm that loaded a skill anyway is contaminated, and contamination
  # points the wrong way: the baseline looks strong, so the skill looks useless.
  # Usually a copy installed in the real user home that the adapter did not
  # isolate. Refuse the result rather than score it.
  if [ "$arm" = none ] && [ -n "$chain" ]; then
    echo "verdict    : CONTAMINATED — arm=none but these skills loaded: $chain"
    echo "             an installed copy leaked in; this is not a baseline"
    return 1
  fi

  echo "assertions :"
  ( scenario_assert "$workdir" ) 2>&1 | sed 's/^/  /'
  local pstat="${PIPESTATUS[0]}"
  [ "$pstat" -eq 0 ] && echo "verdict    : PASS" || echo "verdict    : FAIL"
  return "$pstat"
}


bh_parse_args ${args[@]+"${args[@]}"} || exit 2
adapter_check || exit 3
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

stream="$(mktemp)"; errlog="$(mktemp)"; harness_home=""
trap bh_cleanup EXIT

bh_resolve_scenario "$harness" || exit 2
bh_setup_arm || exit 2
adapter_install "$plugin_src" || exit 3
bh_seed_fixture || exit 2

bh_started="$(date +%s)"
adapter_run_behavioral "$workdir" "$opening_file" "$stream"; status=$?
if [ "$status" -eq 0 ] && [ "${#followups[@]}" -gt 0 ]; then
  if ! declare -F adapter_continue_behavioral >/dev/null 2>&1; then
    echo "$harness adapter cannot continue a multi-turn behavioural session" >&2
    exit 3
  fi
  for followup in "${followups[@]}"; do
    turn_stream="$(mktemp)"
    adapter_continue_behavioral "$workdir" "$followup" "$turn_stream" "$stream"; status=$?
    cat "$turn_stream" >> "$stream"
    rm -f "$turn_stream"
    [ "$status" -eq 0 ] || break
  done
fi
bh_elapsed_s="$(( $(date +%s) - bh_started ))"
bh_chain() { adapter_chain "$1"; }
bh_report "$harness" "$status"
