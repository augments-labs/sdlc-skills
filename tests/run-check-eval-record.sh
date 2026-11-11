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
    $0 == "---" { printf "%s", d; exit } d == "" && /^description:/ { d = $0 }' | sha256
}
sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -d' ' -f1
}

# bench <record dir> <skill> <plugin tree> <second arm> <baseline tree|null>
#       [runs_per_eval] [second pass_rate|null] [indeterminate] [needs_review]
# A record as the evals lab writes it: one row per run of eval e1 in each
# arm, each scored, then the arm summary. The optional arguments spoil it.
bench() {
  local d="$evals/results/$1"; mkdir -p "$d"
  jq -n --arg skill "$2" --arg pt "$3" --arg arm "$4" --arg bt "$5" \
    --argjson n "${6:-3}" --argjson pr2 "${7:-0.5}" --argjson ind "${8:-0}" --argjson nr "${9:-0}" '
    def row($c; $k; $p): {eval_id: "e1", configuration: $c, run_number: $k, outcome: "ok",
                          pass_rate: $p, passed: 1, failed: 1, needs_review: 0, total: 2};
    {metadata: {skill: $skill, harness: "fake", harness_version: null, model: null,
                eval_ids: ["e1"], configurations: ["with_skill", $arm], runs_per_eval: $n,
                plugin: {commit: "c0ffee", skill_tree: $pt},
                baseline: (if $bt == "null" then null else {commit: "c0ffee", skill_tree: $bt} end)},
     runs: ([range(1; $n + 1) as $k | row("with_skill"; $k; 0.9)]
            + [range(1; $n + 1) as $k | row($arm; $k; $pr2)]
            | .[0].needs_review = $nr
            | if $ind > 0 then .[0] |= (.outcome = "indeterminate" | .pass_rate = null) else . end),
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
# spoil <src dir> <dst dir> <file> <jq filter> — a copy of a record, edited
spoil() {
  mkdir -p "$evals/results/$2"
  jq "$4" "$evals/results/$1/$3" > "$evals/results/$2/$3"
}

body="$tmp/body.txt"
run() {  # <expected exit> <label> [extra args...]; body is $body
  local want="$1" label="$2"; shift 2
  local out code
  out="$(cd "$repo" && bash "$S" --base "${BASE:-base}" --head HEAD --evals "$evals" --body "$body" "$@" 2>&1)"
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

start notes-note; printf 'more\n' >> "$repo/notes/a.md"; commit notes
printf 'Eval record: results/nowhere\n' > "$body"
run 0 "a bad record line on a pull request that changes no skill only notes it"
has "the bad line is reported as a note" "note: results/nowhere"

echo "--- every file the agent reads counts"
: > "$body"
start assets; printf 'x\n' >> "$repo/$skill/assets/t.md"; commit assets
run 1 "a change to a skill's assets/ needs a record"
has "it names the skill" "foo (skills/common/foo) needs an evaluation record"
bench assets-ok foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
printf 'Eval record: results/assets-ok\n' > "$body"
run 0 "an assets/ change with a matching record passes"

: > "$body"
start refs; mkdir -p "$repo/$skill/references"; printf 'ref\n' > "$repo/$skill/references/r.md"; commit refs
run 1 "a change to a skill's references/ needs a record"

start rename-out; git -C "$repo" mv "$skill/assets/t.md" skills/common/gone/assets/t2.md; commit rename-out
run 1 "a file moved from one skill to another needs records for both"
has "the skill the file left is named" "foo (skills/common/foo)"
has "the skill the file joined is named" "gone (skills/common/gone)"

start rename-scripts; git -C "$repo" mv "$skill/assets/t.md" "$skill/scripts/t.md"; commit rename-scripts
run 1 "a file moved from assets/ to scripts/ still changes what the agent reads"

start nonascii; printf 'x\n' > "$repo/$skill/assets/caf"$'\303\251'".md"; commit nonascii
run 1 "a change to a file with a non-ASCII name is seen"

echo "--- a body change needs an evaluation record of exactly its text"
start body; write_skill "$skill" "$desc_line" "Step one, changed."; commit body
H="$(tree_at HEAD "$skill")"; B="$(tree_at base "$skill")"

: > "$body"
run 1 "a body change with no record line fails"
has "the failure names the skill and the record kind it needs" "foo (skills/common/foo) needs an evaluation record"

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

printf 'Eval record: results/body-ok' > "$body"
run 0 "a record line with no final newline is read"
printf '    Eval record: results/body-ok\n' > "$body"
run 1 "an indented record line (the template's example) is not read"
printf 'Eval record: results/body-ok\nEval record: results/missing\n' > "$body"
run 1 "a bad record line fails even when every skill has its record"
has "the bad line is named" "results/missing"
run 0 "a bad record line passes under --exempt" --exempt

spoil body-ok run-unscored benchmark.json '(.runs[] | select(.configuration == "old_skill" and .run_number == 2)).pass_rate = null'
printf 'Eval record: results/run-unscored\n' > "$body"
run 1 "a record with one unscored run fails, though its arm mean is scored"
has "it says a run has no score" "no score"

spoil body-ok with-unscored benchmark.json '(.runs[] | select(.configuration == "with_skill" and .run_number == 3)).pass_rate = null'
printf 'Eval record: results/with-unscored\n' > "$body"
run 1 "an unscored with_skill run fails"

spoil body-ok base-indet benchmark.json '(.runs[] | select(.configuration == "old_skill" and .run_number == 1)) |= (.outcome = "indeterminate" | .pass_rate = null)'
printf 'Eval record: results/base-indet\n' > "$body"
run 1 "an indeterminate run in the old_skill arm fails"

spoil body-ok late-review benchmark.json '.runs[-1].needs_review = 1'
printf 'Eval record: results/late-review\n' > "$body"
run 1 "one assertion awaiting review in the last run fails"

spoil body-ok no-runs benchmark.json 'del(.runs)'
printf 'Eval record: results/no-runs\n' > "$body"
run 1 "a record with no runs fails"

spoil body-ok short-eval benchmark.json 'del(.runs[0])'
printf 'Eval record: results/short-eval\n' > "$body"
run 1 "an eval with two runs in one arm fails, whatever runs_per_eval says"

spoil body-ok no-skill benchmark.json '.metadata.skill = null'
printf 'Eval record: results/no-skill\n' > "$body"
run 1 "a record that names no skill fails"
has "the near miss is explained" "names no skill"

mkdir -p "$evals/results/empty-bench"; : > "$evals/results/empty-bench/benchmark.json"
printf 'Eval record: results/empty-bench\n' > "$body"
run 1 "an empty benchmark.json fails"
has "it says the record is unreadable" "not a readable record"

mkdir -p "$evals/results/two-docs"
cat "$evals/results/body-ok/benchmark.json" "$evals/results/body-ok/benchmark.json" > "$evals/results/two-docs/benchmark.json"
printf 'Eval record: results/two-docs\n' > "$body"
run 1 "a benchmark.json holding two documents fails"

printf 'Eval record: results/missing\n' > "$body"
run 1 "a record the evals checkout does not hold fails"
has "it says the directory is missing" "results/missing: the evals repository holds no"
mkdir -p "$evals/results/hollow"
printf 'Eval record: results/hollow\n' > "$body"
run 1 "a record directory with no record file in it fails"

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

trig desc-tworuns foo "$D" 2
printf 'Eval record: results/desc-tworuns\n' > "$body"
run 1 "a triggering record with two runs per query fails"

trig desc-other bar "$D"
printf 'Eval record: results/desc-other\n' > "$body"
run 1 "a triggering record of another skill fails"

spoil desc-ok desc-inc-train triggering.json '.splits.train.inconclusive = 1'
printf 'Eval record: results/desc-inc-train\n' > "$body"
run 1 "a triggering record with an inconclusive train query fails"
has "it says a query is inconclusive" "inconclusive"
spoil desc-ok desc-inc-val triggering.json '.splits.validation.inconclusive = 2'
printf 'Eval record: results/desc-inc-val\n' > "$body"
run 1 "a triggering record with an inconclusive validation query fails"
spoil desc-ok desc-hold triggering.json '.splits.holdout = {queries: 4, passed: 4, failed: 0, inconclusive: 0, pass_rate: 1}'
printf 'Eval record: results/desc-hold\n' > "$body"
run 0 "a triggering record with a conclusive holdout split passes"
spoil desc-ok desc-noval triggering.json 'del(.splits.validation)'
printf 'Eval record: results/desc-noval\n' > "$body"
run 1 "a triggering record with no validation split fails"

mkdir -p "$evals/results/empty-trig"; printf '  \n' > "$evals/results/empty-trig/triggering.json"
printf 'Eval record: results/empty-trig\n' > "$body"
run 1 "a whitespace-only triggering.json fails"

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
echo "--- the records measure the text the merge will hold"
git -C "$repo" checkout -q -B dev-moved base
write_skill "$skill" "$desc_line" "Step one, as dev has it now."; commit dev-moved
git -C "$repo" checkout -q -B dev-other base
printf 'x\n' >> "$repo/skills/common/gone/assets/t.md"; commit dev-other
start pr-on-old; write_skill "$skill" "$desc_line" "Step one, as the branch has it."; commit pr-on-old
bench moved-ok foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
printf 'Eval record: results/moved-ok\n' > "$body"
BASE=dev-other run 0 "a base that moved in another skill keeps the branch-point record valid"
has "it compares nothing from the other skill" "ok    foo: evaluation record results/moved-ok"
BASE=dev-moved run 1 "a base that changed this skill since the branch point fails"
has "it asks for a rebase" "rebase"
has "the moved skill is named" "foo (skills/common/foo)"
BASE=dev-moved run 0 "--exempt passes a moved base" --exempt

git -C "$repo" checkout -q --orphan unrelated; git -C "$repo" rm -rqf . >/dev/null
printf 'x\n' > "$repo/x.md"; commit unrelated
run 2 "a head with no merge base with the base exits 2"
git -C "$repo" checkout -q case-body

echo "--- usage"
out="$(cd "$repo" && bash "$S" --base base 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "a missing argument exits 2"; else bad "a missing argument exits 2 (got $code)"; fi
out="$(cd "$repo" && bash "$S" --base nosuchrev --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "an unknown revision exits 2"; else bad "an unknown revision exits 2 (got $code)"; fi
exit2() {  # <label> <command...>
  local label="$1" code; shift
  (cd "$repo" && "$@") >/dev/null 2>&1; code=$?
  if [ "$code" = 2 ]; then ok "$label"; else bad "$label (got $code)"; fi
}
exit2 "an unknown argument exits 2" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" --bogus
exit2 "a flag with no value exits 2" bash "$S" --base base --head HEAD --evals "$evals" --body
exit2 "a missing body file exits 2" bash "$S" --base base --head HEAD --evals "$evals" --body "$tmp/nope"
exit2 "an evals checkout with no results/ exits 2" bash "$S" --base base --head HEAD --evals "$tmp" --body "$body"
nojq="$tmp/nojq"; mkdir -p "$nojq"
for c in git awk sed grep cut sort tr sha256sum shasum cat env bash dirname head wc; do
  p="$(command -v "$c" 2>/dev/null)" && ln -sf "$p" "$nojq/$c"
done
out="$(cd "$repo" && env PATH="$nojq" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
if [ "$code" = 2 ] && printf '%s' "$out" | grep -q 'jq is required'; then ok "a machine without jq exits 2 and says so"
else bad "a machine without jq exits 2 and says so (got $code: $out)"; fi
out="$(bash "$S" --help 2>&1)"; code=$?
if [ "$code" = 0 ]; then ok "--help exits 0"; else bad "--help exits 0 (got $code)"; fi

echo
if [ "$fails" = 0 ]; then echo "all check-eval-record checks passed"; else echo "check-eval-record checks FAILED"; fi
exit "$fails"
