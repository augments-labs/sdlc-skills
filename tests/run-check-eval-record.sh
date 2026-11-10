#!/usr/bin/env bash
# Offline tests for scripts/sh/check-eval-record.sh, the eval-record CI job.
#
# What this guards: a pull request that changes what a skill makes an agent
# do must name an eval record of exactly its skill text. The checker decides
# which records a change needs from the git trees alone, and accepts a record
# only when its identity matches the pull request's trees and every run in it
# was scored. Each rejection below is pinned next to the near-miss that must
# pass, so a checker that over-matches goes red as well as one that misses.
#
# Deterministic on purpose: fixture git repositories and fixture records
# under a temporary directory removed on exit. No model runs, no network.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
ROOT="$PWD"

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-check-eval-record.sh — offline unit checks for check-eval-record.sh.

Takes no arguments; builds a fixture repository with one skill and fixture
eval records, then runs the checker against changes to that skill. Never
mutates the checkout and never reads the network.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the
repo, or jq is missing
EOF
    exit 0;;
esac

S="$ROOT/scripts/sh/check-eval-record.sh"
[ -f "$S" ] || { echo "not run from the repository root" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }

tmp="$(mktemp -d)" || exit 2
trap 'rm -rf "$tmp"' EXIT
repo="$tmp/repo"
evals="$tmp/evals"
mkdir -p "$repo" "$evals/results"

git -C "$repo" init -q
git -C "$repo" config user.email t@example.invalid
git -C "$repo" config user.name tester
git -C "$repo" config core.autocrlf false

skill=skills/common/foo
desc_line='description: "Does foo. Use when foo is asked for."'
write_skill() {  # <dir> <description line> <body line>
  mkdir -p "$repo/$1/assets" "$repo/$1/scripts"
  printf -- '---\nname: %s\n%s\n---\n\n# Foo\n\n%s\n' "$(basename "$1")" "$2" "$3" > "$repo/$1/SKILL.md"
  printf 'template\n' > "$repo/$1/assets/t.md"
  printf 'echo hi\n' > "$repo/$1/scripts/x.sh"
}
write_skill "$skill" "$desc_line" "Step one."
write_skill skills/common/gone "description: \"Gone.\"" "Old."
mkdir -p "$repo/notes"; printf 'doc\n' > "$repo/notes/a.md"
git -C "$repo" add -A
git -C "$repo" commit -qm base
git -C "$repo" branch -q base

# Each case starts from base on a fresh branch.
start() { git -C "$repo" checkout -q -B "case-$1" base; }
commit() { git -C "$repo" add -A && git -C "$repo" commit -qm "$1"; }
tree_at() { git -C "$repo" rev-parse "$1:$2"; }
desc_sha() {  # sha256 of the description line at <rev>:<skill dir>
  git -C "$repo" show "$1:$2/SKILL.md" | LC_ALL=C awk 'NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { printf "%s", d; exit } d == "" && /^description:/ { d = $0 }' | sha256sum | cut -d' ' -f1
}

# bench <record dir> <skill> <plugin tree> <second arm> <baseline tree|null>
#       [runs_per_eval] [second pass_rate|null] [indeterminate] [needs_review]
bench() {
  local d="$evals/results/$1"; mkdir -p "$d"
  jq -n --arg skill "$2" --arg pt "$3" --arg arm "$4" --arg bt "$5" \
    --argjson n "${6:-3}" --argjson pr2 "${7:-0.5}" --argjson ind "${8:-0}" --argjson nr "${9:-0}" '
    {metadata: {skill: $skill, harness: "fake", harness_version: null, model: null,
                configurations: ["with_skill", $arm], runs_per_eval: $n,
                plugin: {commit: "c0ffee", skill_tree: $pt},
                baseline: (if $bt == "null" then null else {commit: "c0ffee", skill_tree: $bt} end)},
     runs: [{eval_id: "e1", configuration: "with_skill", run_number: 1, needs_review: $nr},
            {eval_id: "e1", configuration: $arm, run_number: 1, needs_review: 0}],
     run_summary: ({with_skill: {pass_rate: {mean: 0.9, stddev: 0}, indeterminate_count: $ind}}
                   + {($arm): {pass_rate: (if $pr2 == null then null else {mean: $pr2, stddev: 0} end),
                               indeterminate_count: 0}}
                   + {delta: {pass_rate: 0.4}})}' > "$d/benchmark.json"
}
# trig <record dir> <skill> <description sha> [runs] [validation pass_rate|null]
trig() {
  local d="$evals/results/$1"; mkdir -p "$d"
  jq -n --arg skill "$2" --arg sha "$3" --argjson n "${4:-3}" --argjson vp "${5:-0.9}" '
    {metadata: {skill: $skill, harness: "fake", plugin: {commit: "c0ffee", skill_tree: "abc"},
                description_sha256: $sha, runs: $n, threshold: 0.5},
     splits: {train: {queries: 12, passed: 11, failed: 1, inconclusive: 0, pass_rate: 0.92},
              validation: {queries: 8, passed: 7, failed: 1, inconclusive: 0, pass_rate: $vp}},
     queries: []}' > "$d/triggering.json"
}

body="$tmp/body.txt"
run() {  # <expected exit> <label> [extra args...]; body is $body
  local want="$1" label="$2"; shift 2
  local out code
  out="$(cd "$repo" && bash "$S" --base base --head HEAD --evals "$evals" --body "$body" "$@" 2>&1)"
  code=$?
  if [ "$code" = "$want" ]; then ok "$label"; else bad "$label (expected exit $want, got $code)"; printf '%s\n' "$out" | sed 's/^/        /'; fi
  last_out="$out"
}
has() {  # <label> <fixed string> — the last run's output names it
  if printf '%s\n' "$last_out" | grep -qF -- "$2"; then ok "$1"; else bad "$1 (no '$2' in output)"; printf '%s\n' "$last_out" | sed 's/^/        /'; fi
}

echo "--- changes that need no record"
start docs; printf 'more\n' >> "$repo/notes/a.md"; commit docs
: > "$body"
run 0 "a change outside skills/ needs no record"

start script; printf 'echo bye\n' >> "$repo/$skill/scripts/x.sh"; commit script
run 0 "a change to a skill's scripts/ alone needs no record"

start revert; printf 'x\n' >> "$repo/$skill/assets/t.md"; commit touch
git -C "$repo" checkout -q base -- "$skill"; commit revert
run 0 "a skill touched and restored on the branch needs no record"

echo "--- a body change needs an evaluation record of exactly its text"
start body; write_skill "$skill" "$desc_line" "Step one, changed."; commit body
H="$(tree_at HEAD "$skill")"; B="$(tree_at base "$skill")"

: > "$body"
run 1 "a body change with no record line fails"
has "the failure names the skill and the record kind it needs" "foo"

bench body-ok foo "$H" old_skill "$B"
printf 'Some text.\nEval record: results/body-ok\n' > "$body"
run 0 "a body change with a matching old_skill record passes"

printf 'Eval record: results/body-ok\r\n' > "$body"
run 0 "a record line with a CRLF ending is read"

printf 'Eval record: results/body-ok/\n' > "$body"
run 0 "a record line with a trailing slash is read"

bench body-stale foo "$B" old_skill "$B"
printf 'Eval record: results/body-stale\n' > "$body"
run 1 "a record of another skill text (the base's) fails"
has "the failure says the plugin tree does not match" "plugin.skill_tree"

bench body-wrongbase foo "$H" old_skill "$H"
printf 'Eval record: results/body-wrongbase\n' > "$body"
run 1 "a record whose baseline is not the base's skill text fails"

bench body-noskill foo "$H" without_skill null
printf 'Eval record: results/body-noskill\n' > "$body"
run 1 "an edited skill measured against no skill fails (it needs old_skill)"

bench body-other bar "$H" old_skill "$B"
printf 'Eval record: results/body-other\n' > "$body"
run 1 "a record of another skill fails"

bench body-onerun foo "$H" old_skill "$B" 1
printf 'Eval record: results/body-onerun\n' > "$body"
run 1 "a record with one run per eval fails"
bench body-tworuns foo "$H" old_skill "$B" 2
printf 'Eval record: results/body-tworuns\n' > "$body"
run 1 "a record with two runs per eval fails"

bench body-pending foo "$H" old_skill "$B" 3 null
printf 'Eval record: results/body-pending\n' > "$body"
run 1 "a record with an unscored arm (a null pass rate) fails"

bench body-indet foo "$H" old_skill "$B" 3 0.5 1
printf 'Eval record: results/body-indet\n' > "$body"
run 1 "a record with an indeterminate run fails"

bench body-review foo "$H" old_skill "$B" 3 0.5 0 2
printf 'Eval record: results/body-review\n' > "$body"
run 1 "a record with an assertion awaiting review fails"

printf 'Eval record: results/body-stale\nEval record: results/body-ok\n' > "$body"
run 0 "one matching record among several named passes"

printf 'Eval record: results/missing\n' > "$body"
run 1 "a record the evals checkout does not hold fails"

printf 'Eval record: results/../../etc\n' > "$body"
run 1 "a record path that leaves results/ is refused"
printf 'Eval record: body-ok\n' > "$body"
run 1 "a record line not under results/ is refused"

: > "$body"
run 0 "--exempt passes a body change with no record" --exempt
has "an exempt run says so" "no-eval"

echo "--- a description change needs a triggering record of exactly its line"
start desc; write_skill "$skill" 'description: "Does foo better. Use when foo is asked for."' "Step one."; commit desc
D="$(desc_sha HEAD "$skill")"
trig desc-ok foo "$D"
printf 'Eval record: results/desc-ok\n' > "$body"
run 0 "a description-only change with a matching triggering record passes"

trig desc-stale foo "$(desc_sha base "$skill")"
printf 'Eval record: results/desc-stale\n' > "$body"
run 1 "a triggering record of the base's description fails"

trig desc-onerun foo "$D" 1
printf 'Eval record: results/desc-onerun\n' > "$body"
run 1 "a triggering record with one run per query fails"

trig desc-unscored foo "$D" 3 null
printf 'Eval record: results/desc-unscored\n' > "$body"
run 1 "a triggering record whose validation split scored nothing fails"

H2="$(tree_at HEAD "$skill")"; B2="$(tree_at base "$skill")"
bench desc-bench foo "$H2" old_skill "$B2"
printf 'Eval record: results/desc-bench\n' > "$body"
run 1 "a description change with only an evaluation record fails"

echo "--- a change to both needs both records"
start both; write_skill "$skill" 'description: "Does foo best."' "Step two."; commit both
bench both-bench foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
trig both-trig foo "$(desc_sha HEAD "$skill")"
printf 'Eval record: results/both-bench\n' > "$body"
run 1 "a body and description change with only the evaluation record fails"
printf 'Eval record: results/both-bench\nEval record: results/both-trig\n' > "$body"
run 0 "a body and description change with both records passes"

echo "--- a new skill is measured against no skill"
start new; write_skill skills/build/newone 'description: "New one."' "Body."; commit new
NT="$(tree_at HEAD skills/build/newone)"
bench new-bench newone "$NT" without_skill null
trig new-trig newone "$(desc_sha HEAD skills/build/newone)"
printf 'Eval record: results/new-bench\nEval record: results/new-trig\n' > "$body"
run 0 "a new skill with a without_skill record and a triggering record passes"
bench new-old newone "$NT" old_skill "$NT"
printf 'Eval record: results/new-old\nEval record: results/new-trig\n' > "$body"
run 1 "a new skill measured against an old_skill arm fails"
printf 'Eval record: results/new-bench\n' > "$body"
run 1 "a new skill with no triggering record fails"

echo "--- a removed skill is the maintainer's call"
start removed; git -C "$repo" rm -rq skills/common/gone; commit removed
: > "$body"
run 1 "a removed skill fails without the exemption"
has "the failure names the removed skill" "gone"
run 0 "a removed skill passes with --exempt" --exempt

echo "--- usage"
out="$(cd "$repo" && bash "$S" --base base 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "a missing argument exits 2"; else bad "a missing argument exits 2 (got $code)"; fi
out="$(cd "$repo" && bash "$S" --base nosuchrev --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "an unknown revision exits 2"; else bad "an unknown revision exits 2 (got $code)"; fi
out="$(bash "$S" --help 2>&1)"; code=$?
if [ "$code" = 0 ]; then ok "--help exits 0"; else bad "--help exits 0 (got $code)"; fi

echo
if [ "$fails" = 0 ]; then echo "all check-eval-record checks passed"; else echo "check-eval-record checks FAILED"; fi
exit "$fails"
