#!/usr/bin/env bash
# Trigger eval — scores a DESCRIPTION, not a run.
#
# THIS IS AN OPTIMIZATION INSTRUMENT, NOT A TEST. It lives under tests/optimizing/
# for that reason. It implements the standard's description-tuning loop: score,
# revise against TRAIN failures, repeat, then select the iteration with the best
# VALIDATION rate. Both splits are consumed by that loop, so neither is a held-out
# result and a red sheet here is not a regression — see tests/optimizing/README.md.
#
# ============================ THIS COSTS REAL MONEY ============================
# Every query is a live session against your own harness account, and the default
# is 20 queries x 3 runs = 60 CALLS PER SKILL. `--all` is 33 skills — roughly
# 2,000 calls, hours of wall time, and enough usage to exhaust a plan's quota.
#
# Price any selection first:  --dry-run  prints the budget and calls nothing.
# ==============================================================================
#
# A description's job is to fire on the openings it should and stay quiet on the
# ones it shouldn't. Routing is non-deterministic, so neither fact is observable
# in one run: the unit of evidence is a QUERY REPEATED N TIMES, reduced to a
# trigger rate. A query passes when the rate lands on the right side of 0.5 —
# above for a should-trigger query, below for a should-not.
#
# The near-miss negatives are the point. A description that fires on its own
# happy-path opening has proven nothing; every description does that. What
# separates a tuned description from a greedy one is the query that shares its
# vocabulary and needs a different skill.
#
# Query sets live beside this script at <phase>/<skill>.json — an array of
#   { "query": TEXT, "should_trigger": BOOL, "split": "train"|"validation",
#     "expect": SKILL|"none" }   # `expect` = the correct route, diagnostic only
# `should_trigger` is about THIS skill. `expect` records where a negative should
# have gone instead, so a miss and a misroute are distinguishable in the report.
#
# The split is fixed in the files and never reshuffled between iterations —
# rotating it turns validation into a second training set. Tune against train;
# report validation; pick the iteration with the best VALIDATION pass rate, which
# is often not the last one.
#
# Manual tool, never CI.
#
# Flags and exit codes: --help.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$scriptdir/../../.." && pwd)"
harnessdir="$repo/tests/harnesses"

usage() {
  cat <<'EOF'
test-triggering-on-queries.sh — score a skill DESCRIPTION against its query set.

  --harness NAME    claude-code | codex | kimi-code   (required)
  --skill NAME      the skill to score                (or --all)
  --all             every query set beside this script
  --split WHICH     all | train | validation          (default: all)
  --runs N          repetitions per query             (default: 3)
  --jobs N          repetitions to run concurrently   (default: 3, 1 = serial)
  --timeout N       seconds per run                   (default: 120)
  --max-turns N     turns before a run is cut off     (default: 6)
  --json PATH       write the per-query records as a JSON array
  --dry-run         print the API-call budget and exit without calling
  --no-fixture      run queries in a bare directory instead of a seeded project
  --help            this text

COST: live sessions against your own harness account. One skill at the defaults
is 20 queries x 3 runs = 60 calls; --all is ~2,000. Always --dry-run first.

Exit codes: 0 every scored query passed · 1 at least one FAIL
            2 bad or missing arguments · 3 `jq` or the harness CLI is missing

Examples:
  tests/optimizing/descriptions/test-triggering-on-queries.sh --harness codex --all --dry-run
  tests/optimizing/descriptions/test-triggering-on-queries.sh --harness claude-code --skill yagni
  tests/optimizing/descriptions/test-triggering-on-queries.sh --harness claude-code --skill yagni --split train
  tests/optimizing/descriptions/test-triggering-on-queries.sh --harness claude-code --skill yagni --json out.json
EOF
}

harness=""; skill=""; runs=3; split="all"; dry=""; jsonout=""; all=""; fixture="1"; jobs=3
timeout_s=120; maxturns=6
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)    usage; exit 0;;
    --harness)    harness="$2"; shift 2;;
    --skill)      skill="$2"; shift 2;;
    --all)        all="1"; shift;;
    --runs)       runs="$2"; shift 2;;
    --jobs)       jobs="$2"; shift 2;;
    --split)      split="$2"; shift 2;;
    --timeout)    timeout_s="$2"; shift 2;;
    --max-turns)  maxturns="$2"; shift 2;;
    --dry-run)    dry="1"; shift;;
    --json)       jsonout="$2"; shift 2;;
    --no-fixture) fixture=""; shift;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }
[ -n "$skill" ] || [ -n "$all" ] || { echo "needs --skill NAME or --all" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }
case "$split" in all|train|validation) ;; *) echo "--split all|train|validation" >&2; exit 2;; esac
# Counters this script feeds straight to `seq` and to arithmetic. A non-numeric
# --runs yields an empty `seq`, which scores every query zero-valid and reports a
# full sheet of INCONCLUSIVE — a wrong measurement that still looks like a
# measurement, rather than an error anyone would notice.
for n in runs jobs timeout_s maxturns; do
  case "${!n}" in ''|*[!0-9]*|0) echo "--${n%_s} needs a positive integer" >&2; exit 2;; esac
done

sets=()
if [ -n "$all" ]; then
  while IFS= read -r f; do sets+=("$f"); done \
    < <(find "$scriptdir" -name '*.json' -type f | sort)
else
  while IFS= read -r f; do sets+=("$f"); done \
    < <(find "$scriptdir" -name "$skill.json" -type f | sort)
  [ "${#sets[@]}" -gt 0 ] || { echo "no query set for skill: $skill" >&2; exit 2; }
fi

# jq filter selecting the queries this invocation runs.
sel='.[] | select($split == "all" or .split == $split)'

if [ -n "$dry" ]; then
  total=0
  for f in "${sets[@]}"; do
    n="$(jq --arg split "$split" "[$sel] | length" "$f")"
    printf '%-34s %3d queries x %d runs = %4d calls\n' \
      "$(basename "$f" .json)" "$n" "$runs" "$((n * runs))"
    total=$((total + n * runs))
  done
  printf '\n%d API call(s) total, billed to your own harness account. A negative\n' "$total"
  printf 'query runs to --max-turns, so budget roughly a full short session each.\n'
  exit 0
fi

[ -f "$harnessdir/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }
# shellcheck source=/dev/null
. "$harnessdir/$harness.sh"
# shellcheck source=/dev/null
. "$repo/tests/fixtures.sh"
adapter_check || exit 3
# Default for the optional structural refusal check (see `observe_once`).
# Conservative on purpose: an adapter that does not implement it is assumed to
# have run, so no harness silently loses runs from its denominator.
declare -F adapter_ran >/dev/null 2>&1 || adapter_ran() { return 0; }

# --- the observation primitive ------------------------------------------------
# ONE query, ONE run, emitting one JSON record. Non-deterministic by nature, so a
# single run is never a verdict — the scoring loop below repeats it and reduces
# the repetitions to a rate.
#
# Detection reads a STRUCTURED tool call from the harness's own stream, never a
# prose grep and never a self-report. A raw grep reports phantom activations: the
# SessionStart nudge and the init manifest both contain `sdlc-skills:` tokens that
# are not actions. The first version of this harness fell for exactly that.
observe_once() { # $1 query text  $2 subject skill
  local text="$1" subject="$2"
  local workdir stream errlog harness_home="" chain inconclusive="false"
  workdir="$(mktemp -d)"; stream="$(mktemp)"; errlog="$(mktemp)"

  # An EMPTY workdir silently invalidates any realistic query. Asked to "add the
  # config flag" in a bare temp dir, the model correctly answers that there is no
  # project to add it to — and never routes at all, which scores as a trigger miss
  # when nothing was wrong with the description. Queries name real files because
  # the standard's guidance is to make them realistic, so they need a real project.
  ( cd "$workdir" && git init -q -b main 2>/dev/null || { git init -q && git checkout -qb main; }
    if [ -n "$fixture" ]; then
      fixture_node_api "$workdir"; fixture_activation_paths "$workdir"
    else
      printf '# Fixture\n\nA disposable repository for skill-routing probes.\n' > README.md
    fi
    git add -A
    git -c user.name='SDLC skills Harness' -c user.email='harness@example.invalid' \
        commit -q -m 'fixture baseline' ) || { rm -rf "$workdir" "$stream" "$errlog"; return 2; }

  adapter_install "$repo" || { rm -rf "$workdir" "$stream" "$errlog"; return 3; }
  local prompt; prompt="$text$(adapter_prompt_suffix 2>/dev/null || true)"
  local -a xflags; mapfile -t xflags < <(adapter_activation_flags 2>/dev/null || true)

  ( adapter_run_activation "$workdir" "$prompt" "$stream" ${xflags[@]+"${xflags[@]}"} ) &
  local cpid=$!
  # Skills CHAIN: using-sdlc-skills routes, then task-branches, then TDD, then
  # yagni. So stopping at the first non-router skill truncates a correct chain and
  # scores it as a miss — that is exactly what happened to test-driven-development
  # (killed at using-git-worktrees, which the router correctly sends you to first)
  # and to finishing-a-branch (killed at verifying-completion). Wait for the
  # SUBJECT; --max-turns bounds a run that never reaches it, which is every
  # correctly-behaving negative.
  local want="sdlc-skills:${subject}"
  while kill -0 "$cpid" 2>/dev/null; do
    adapter_chain "$stream" | grep -qx "$want" && { kill "$cpid" 2>/dev/null; break; }
    sleep 2
  done
  wait "$cpid" 2>/dev/null

  chain="$(adapter_chain "$stream" | awk 'NF && !seen[$0]++')"

  # A run that never reached the model is NOT evidence about a description, and
  # scoring it as "did not fire" is how a dead provider gets reported as a result.
  # Observed: a kimi eval returned exactly 50%/50% — every positive scored a miss,
  # every negative "passed" for free — because all 60 calls died at auth and no
  # assistant record was ever emitted. The rate looked like a measurement.
  #
  # Two independent detectors, because neither is sufficient alone.
  #
  # (a) The provider says so, in its own words. Split by file on purpose: $errlog
  # is the CLI's own stderr, so an auth or quota phrase there is the CLI talking.
  # The same phrase inside $stream may be MODEL OUTPUT quoting an error, so that
  # side keeps only the narrow patterns that appear as error records.
  if grep -qiE 'usage limit|login_required|api_error: 4' "$stream" 2>/dev/null \
    || grep -qiE 'usage limit|login_required|authorization grant|no credential|credential configured|not authenticated|invalid_grant|unauthorized' \
         "$errlog" 2>/dev/null; then
    inconclusive="true"
  fi

  # (b) Structural: did the CLI complete a model turn at all? This catches the
  # failure whose wording nobody has seen yet — (a) was written against kimi's
  # older `auth.login_required` and silently missed 0.34.0's "The provided
  # authorization grant is invalid", which is how the 50%/50% sheet happened.
  #
  # Exit status CANNOT serve here, and that is worth stating so it is not "fixed"
  # later: `claude` exits 1 on max-turns exhaustion, the same code as an auth
  # failure. Since every negative query runs to max-turns by design, keying on
  # status would drop half of every set from the denominator — far worse than the
  # bug. The discriminator is the stream: a max-turns run still emits a full turn
  # and a terminal record; the dead auth run emitted one bare `meta` line.
  #
  # `adapter_ran` is OPTIONAL and defaults to "it ran", so a harness that has not
  # had its failure shape observed behaves exactly as before. Claiming otherwise
  # would be inventing evidence.
  adapter_ran "$stream" || inconclusive="true"

  printf '%s\n' "$chain" | jq -cRn --argjson inconclusive "$inconclusive" \
    '{chain: [inputs | select(length > 0)], inconclusive: $inconclusive}'

  [ -n "$harness_home" ] && rm -rf "$harness_home"
  rm -rf "$workdir"; rm -f "$stream" "$errlog"
}

# --- scoring loop -------------------------------------------------------------
results="$(mktemp)"; trap 'rm -f "$results"' EXIT
sets_failed=0

for f in "${sets[@]}"; do
  subject="$(basename "$f" .json)"
  printf '\n=== %s (%s split, %d run(s) per query) ===\n' "$subject" "$split" "$runs"

  qcount=0
  while IFS= read -r q; do
    text="$(jq -r '.query' <<<"$q")"
    want="$(jq -r '.should_trigger' <<<"$q")"
    qsplit="$(jq -r '.split' <<<"$q")"
    route="$(jq -r '.expect // "none"' <<<"$q")"
    qcount=$((qcount + 1))

    # The repetitions of ONE query are independent — each gets its own workdir,
    # harness home, and stream — so they fan out. Repetitions, not queries: a
    # query's verdict is printed as soon as it is decided, so the report stays in
    # file order and reads the same as it did serially.
    #
    # Why this is worth doing: a positive can stop the moment the expected skill
    # fires, but a negative has nothing to wait for and burns --max-turns or the
    # timeout. Half of every set is negatives by design, so the back half of a
    # serial run costs multiples of the front half.
    #
    # Concurrency does not change what is measured — each call is a separate
    # session against the same catalogue — but it can change whether a call
    # COMPLETES, and a timeout is scored as "did not fire" rather than dropped.
    # So keep --jobs equal across the runs you intend to compare: a before/after
    # pair split across two concurrency levels is confounded, and the artifact
    # would look like a description regression.
    fired=0; valid=0; chains=""
    rundir="$(mktemp -d)"
    launched=0
    for i in $(seq 1 "$runs"); do
      ( observe_once "$text" "$subject" 2>/dev/null > "$rundir/$i" ) &
      launched=$((launched + 1))
      # No `$jobs -gt 1` guard: at --jobs 1 this must wait after EVERY launch,
      # which is exactly what `launched % 1 == 0` gives. Guarding it would skip
      # the wait entirely and make the documented serial mode fully concurrent.
      [ "$((launched % jobs))" -eq 0 ] && wait
    done
    wait

    for i in $(seq 1 "$runs"); do
      rec="$(cat "$rundir/$i" 2>/dev/null)"
      # A malformed record means the runner itself failed; that is not a miss.
      jq -e . >/dev/null 2>&1 <<<"$rec" || continue
      [ "$(jq -r '.inconclusive' <<<"$rec")" = "true" ] && continue
      valid=$((valid + 1))
      chains="$chains$(jq -r '.chain | join(">")' <<<"$rec")"$'\n'
      jq -e --arg s "sdlc-skills:$subject" 'any(.chain[]; . == $s)' >/dev/null <<<"$rec" &&
        fired=$((fired + 1))
    done
    rm -rf "$rundir"

    # Provider refusals are dropped from the denominator, never averaged in as
    # misses. Zero valid runs is an INCONCLUSIVE query, not a failing one.
    if [ "$valid" -eq 0 ]; then
      verdict="INCONCLUSIVE"; rate="-"
    else
      rate="$(awk -v f="$fired" -v v="$valid" 'BEGIN{printf "%.2f", f/v}')"
      if [ "$want" = "true" ]; then
        awk -v r="$rate" 'BEGIN{exit !(r > 0.5)}' && verdict="PASS" || verdict="FAIL"
      else
        awk -v r="$rate" 'BEGIN{exit !(r < 0.5)}' && verdict="PASS" || verdict="FAIL"
      fi
    fi

    printf '  %-12s %s rate=%s (%d/%d)  %s\n' "$verdict" \
      "$([ "$want" = "true" ] && echo '+' || echo '-')" "$rate" "$fired" "$valid" \
      "$(printf '%.68s' "$text" | tr '\n' ' ')"
    # Both failure directions need the observed routing to be actionable. A
    # positive miss is diagnosed by what fired *instead* — that is the whole
    # evidence for revising a trigger — so printing this only for negatives left
    # the more expensive failure with nothing to revise against.
    observed="$(printf '%s' "$chains" | sort -u | paste -sd' | ' -)"
    [ -n "$observed" ] || observed="(nothing routed)"
    if [ "$verdict" = "FAIL" ]; then
      if [ "$want" = "true" ]; then
        printf '               expected %s to fire | observed: %s\n' "$subject" "$observed"
      else
        printf '               should have routed to: %s | observed: %s\n' "$route" "$observed"
      fi
    fi

    jq -cn --arg skill "$subject" --arg split "$qsplit" --arg verdict "$verdict" \
           --arg rate "$rate" --argjson want "$want" --arg query "$text" \
           --arg observed "$observed" \
           --argjson fired "$fired" --argjson valid "$valid" \
      '{skill:$skill, split:$split, should_trigger:$want, query:$query,
        fired:$fired, valid:$valid, rate:$rate, verdict:$verdict,
        observed:$observed}' >> "$results"
  done < <(jq -c --arg split "$split" "$sel" "$f")

  [ "$qcount" -gt 0 ] || printf '  (no queries in this split)\n'
done

# --- summary ------------------------------------------------------------------
# Reported per split because they answer different questions: train drives the
# next revision, validation decides which iteration to keep.
echo
printf '%-12s %-7s %-7s %s\n' "SPLIT" "PASSED" "SCORED" "PASS RATE"
for s in train validation; do
  read -r p t < <(jq -rs --arg s "$s" \
    '[.[] | select(.split == $s and .verdict != "INCONCLUSIVE")]
     | "\([.[] | select(.verdict == "PASS")] | length) \(length)"' "$results")
  [ "${t:-0}" -gt 0 ] &&
    printf '%-12s %-7s %-7s %s\n' "$s" "$p" "$t" \
      "$(awk -v p="$p" -v t="$t" 'BEGIN{printf "%.0f%%", 100*p/t}')"
done
inc="$(jq -rs '[.[] | select(.verdict == "INCONCLUSIVE")] | length' "$results")"
[ "$inc" -gt 0 ] && printf '\n%s quer(y/ies) INCONCLUSIVE — provider refused every run.\n' "$inc"
failed="$(jq -rs '[.[] | select(.verdict == "FAIL")] | length' "$results")"
[ "$failed" -gt 0 ] && sets_failed=1

[ -n "$jsonout" ] && { jq -s '.' "$results" > "$jsonout"; echo "wrote $jsonout"; }

# Live, non-deterministic runs. A rate is evidence; one eval is not a mandate.
# Revise against TRAIN failures only — tuning on validation overfits it away.
exit "$sets_failed"
