#!/usr/bin/env bash
# Structural validator for SDLC skills.
# Enforces the authoring rules in CLAUDE.md across every skill in skills/.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/validate-skills.sh — structural gate for every skill in skills/.

Takes no arguments. Checks frontmatter shape, line and description budgets,
directory layout, resolvable reference paths, absent external references and
vendor model names, and that every skill is registered in each plugin manifest.
CI runs this on every push and PR.

  --help    this text

Exit codes: 0 every skill passed · 1 violations printed above the summary
            2 not run from the repo
EOF
    exit 0;;
esac

fail=0
note() { printf '  %s\n' "$1"; }
err()  { printf '  FAIL: %s\n' "$1"; fail=1; }

# Patterns that must never appear in shipped skills (see CLAUDE.md).
EXT_REFS='superpowers|obra|mattpocock|pocock|ousterhout|github\.com|https?://|#[0-9]{2,}'
VENDORS='\b(haiku|sonnet|opus|claude|gpt-?[0-9o]|gemini|flash|llama|mistral|openai|anthropic)\b'
# Skill text is part of the harness's scan surface: a literal trigger-word in a
# body can hijack the session (fire a thinking mode, trip an injection detector)
# every time the skill loads. Keep shipped text inert to keyword scanners.
SCANNER_TRIGGERS='\bultrathink\b'
# A skill whose name matches a common built-in slash command gets mis-invoked —
# the harness or model picks the wrong one. Names must not shadow them.
SHADOWED_COMMANDS='^(review|init|compact|clear|help|config|status|commit|test|run|plan|resume|doctor|login|logout|memory|mcp|model|agents|hooks|settings|todos|cost|export|bug|vim)$'

mapfile -t skills < <(find skills -name SKILL.md | sort)
[ ${#skills[@]} -eq 0 ] && { echo "no skills found under skills/"; exit 2; }

# The standard's checks are delegated to the conformance script this library
# ships (see the per-skill loop). Delegation fails open — a moved or renamed
# script would produce no findings and every skill would pass — so prove it is
# there and runnable before trusting a silent result.
CONFORMANCE=skills/common/writing-skills/scripts/check-skill.sh
[ -f "$CONFORMANCE" ] || { echo "missing $CONFORMANCE — the standard's checks are delegated to it"; exit 2; }
bash "$CONFORMANCE" --help >/dev/null 2>&1 || { echo "$CONFORMANCE does not run"; exit 2; }

for skill in "${skills[@]}"; do
  dir=$(dirname "$skill")
  name_dir=$(basename "$dir")
  echo "• $skill"

  # What the STANDARD requires — frontmatter shape, name/directory agreement,
  # the 1024-character description limit, the 500-line and 5000-token body
  # ceilings, resolvable links, and bundled scripts that answer `--help` — is
  # checked by the skill-conformance script this library ships, not by a second
  # copy of those rules here. One implementation means the two cannot disagree,
  # and it puts the shipped script on the CI path instead of taking its
  # correctness on trust. Everything below this call is a HOUSE rule the
  # standard does not cover.
  # Both severities are surfaced. Reading only `fail` would discard a whole
  # class of findings — presentation, register, anything the script is confident
  # enough to flag but not to block on — and discarding them silently is the
  # same failure mode as delegating to a checker that is not there.
  while IFS=$'\t' read -r level check detail; do
    case "$level" in
      fail) err  "$check: $detail" ;;
      warn) note "warn: $check: $detail" ;;
    esac
  done < <(bash "$CONFORMANCE" "$dir" 2>/dev/null)

  fname=$(awk -F': ' '/^name:/{print $2; exit}' "$skill")

  # name must not shadow a common harness slash command.
  [ -n "$fname" ] && echo "$fname" | grep -qiE "$SHADOWED_COMMANDS" && err "name '$fname' shadows a common harness command — rename to avoid mis-invocation"

  # House size targets, tighter than the standard's ceilings because many skills
  # coexist in one session — and only ever warnings.
  #
  # The line target was once a hard failure at 120, and that was a mistake with a
  # visible cost: authors bought line count by dropping articles and verbs until
  # the prose read as a noun stack. Compression is not concision. A body that
  # needs 140 clear lines should take them; see docs/agent-skills-conformance.md.
  lines=$(wc -l < "$skill")
  [ "$lines" -gt 200 ] && note "warn: $lines lines (>200; well over the house target — is every line earning its place?)"

  words=$(wc -w < "$skill")
  tokens=$(( words * 13 / 10 ))
  [ "$tokens" -gt 2500 ] && note "warn: ~$tokens tokens (>2500; over the house target)"

  # (Per-skill triggering records retired — activation is proven by the shared
  # harness-backed runners under tests/, not a static record. See tests/README.md.)

  # No external references, vendor model names, or <angle> placeholders — in every
  # .md of the skill, RECURSIVELY (covers references/ and scripts/ subfolders).
  while IFS= read -r f; do
    body=$(sed 's/`[^`]*`//g' "$f")   # ignore inline code spans
    echo "$body" | grep -qiE "$EXT_REFS"        && err "$(basename "$f"): external reference (repo/issue/URL) — state the principle directly"
    echo "$body" | grep -qiE "$VENDORS"         && err "$(basename "$f"): vendor model name — use a capability tier (small|medium|large)"
    echo "$body" | grep -qiE "$SCANNER_TRIGGERS" && err "$(basename "$f"): harness scanner trigger-word — rephrase so a keyword scan can't hijack the session"
    echo "$body" | grep -qE  '<[a-z][a-z0-9 -]*>' && err "$(basename "$f"): bare <angle> placeholder — use {{double-curly}}"
    # The .sdlc-skills/ output location is mandatory (overridable only by the user),
    # never an optional "default" — keep the convention from drifting back.
    grep -nE '\.sdlc-skills/' "$f" | grep -qi 'default' && err "$(basename "$f"): frames an .sdlc-skills/ path as a 'default' — that location is mandatory (overridable only by the user), not a default"
  done < <(find "$dir" -name '*.md')
done

# Cross-skill routing lives in the bodies: a precondition, boundary, or handoff
# names its peer in backticks. A rename or removal must not leave stale names
# behind — a handoff to a skill that no longer exists routes nowhere, silently.
# Backticked kebab-case tokens that are not skill names go on the allowlist.
echo "• backticked skill names resolve to skills on disk"
skill_names="$(find skills -mindepth 3 -maxdepth 3 -name SKILL.md -exec dirname {} \; | xargs -n1 basename | sort -u)"
name_allowlist='common-dir git-dir integrated-regression'
while IFS=: read -r file token; do
  printf '%s\n' "$skill_names" | grep -qx "$token" && continue
  printf '%s\n' $name_allowlist | grep -qx "$token" && continue
  err "$file: backticked \`$token\` matches no skill on disk (stale cross-reference, or add it to the allowlist)"
done < <(find skills -name 'SKILL.md' -exec grep -oH '`[a-z][a-z]*\(-[a-z][a-z]*\)\{1,\}`' {} + | tr -d '\`' | sort -u)

# Progressive-disclosure links are executable navigation for an agent. Resolve
# them in the canonical install tree; adapter-specific layouts run the same
# helper against their own tree.
echo "• skill reference paths resolve"
if ! bash scripts/sh/validate-skill-reference-paths.sh skills; then fail=1; fi

# Progressive disclosure only works if SKILL.md names the file and says when to
# open it. A support file nothing links to is dead weight the agent never finds.
# Both standard support directories are checked: references/ (documentation read
# on demand) and assets/ (templates the agent fills in).
echo "• every sibling reference is directly disclosed"
while IFS= read -r ref; do
  skill_dir="$(dirname "$(dirname "$ref")")"
  skill_file="$skill_dir/SKILL.md"
  ref_dir="$(basename "$(dirname "$ref")")"
  ref_name="$(basename "$ref")"
  grep -Fq "$ref_dir/$ref_name" "$skill_file" ||
    err "$ref: not referenced directly from $skill_file"
done < <(find skills \( -path '*/references/*.md' -o -path '*/assets/*.md' \) -type f | sort)

# That a bundled script is executable and answers `--help` is the standard's
# rule, already checked per skill above. These two are the house additions: an
# agent that cannot find the script in SKILL.md never runs it, and a `--help`
# that omits exit codes leaves the caller unable to branch on the result.
echo "• every bundled script is disclosed and documents its exit codes"
while IFS= read -r s; do
  skill_file="$(dirname "$(dirname "$s")")/SKILL.md"
  name="$(basename "$s")"

  grep -Fq "scripts/$name" "$skill_file" ||
    err "$s: not named in $skill_file — an agent cannot run what it never sees"
  grep -q '^## Available scripts' "$skill_file" ||
    err "$skill_file: bundles scripts but has no '## Available scripts' section"

  { timeout 20 "$s" --help 2>/dev/null || timeout 20 bash "$s" --help 2>/dev/null; } | grep -qi 'exit code' ||
    err "$s: --help does not document its exit codes"
done < <(find skills -path '*/scripts/*' -type f | sort)

# The governed preview (serve.py + start/stop wrappers) ships one copy per
# skill that offers it: skill-local resolution survives every adapter layout,
# and a cross-skill link would not. The copies must stay byte-identical —
# two drifting previews are two contracts.
echo "• preview scripts are identical across skills"
preview_dirs=$(find skills -path '*/scripts/serve.py' -type f -exec dirname {} \; | sort)
if [ -n "$preview_dirs" ]; then
  ref_dir=$(printf '%s\n' "$preview_dirs" | head -1)
  for d in $preview_dirs; do
    [ "$d" = "$ref_dir" ] && continue
    for f in "$ref_dir"/*; do
      name=$(basename "$f")
      [ -f "$d/$name" ] || { err "preview script missing: $d/$name"; continue; }
      cmp -s "$f" "$d/$name" || err "preview scripts drifted: $f vs $d/$name"
    done
  done
fi

# The standard splits support files by what the agent does with them. A template
# it fills in and emits is a static resource; documentation it reads to decide is
# not. Keep the two from drifting back together.
echo "• templates live in assets/, not references/"
while IFS= read -r ref; do
  # The file's own opening sentence is the honest classifier: a template tells
  # the agent to fill or copy it; documentation tells it what to know or check.
  opening="$(grep -m1 -v '^#\|^$' "$ref")"
  case "$opening" in
    [Ff]ill*|[Cc]opy\ this*|[Uu]se\ this\ template*|[Ww]rite\ the\ completed*|[Cc]reate\ one\ row*)
      err "$ref: opens as a fill-in template — the standard puts document templates in assets/";;
  esac
done < <(find skills -path '*/references/*.md' -type f | sort)

# The nudge ships too — and is injected into every session, so a scanner
# trigger-word there fires constantly, not just when one skill loads.
echo "• hooks (scanner trigger-words)"
while IFS= read -r f; do
  sed 's/`[^`]*`//g' "$f" | grep -qiE "$SCANNER_TRIGGERS" && err "$f: harness scanner trigger-word"
done < <(find hooks -name '*.md' 2>/dev/null)

# Routing belongs in session-start context; no tool or turn-end hooks ship.
echo "• session-start-only activation"
if ! bash tests/run-session-start.sh >/dev/null; then
  err "tests/run-session-start.sh failed"
fi
for retired_script in \
  scripts/sh/implementation-remind.sh \
  scripts/sh/stop-nudge.sh \
  scripts/sh/stop-nudge-detect.sh \
  scripts/sh/stop-nudge-kimi.sh \
  tests/run-stop-nudge.sh \
  scripts/sh/implementation-guard.sh \
  scripts/sh/completion-guard.sh \
  tests/run-implementation-guard.sh \
  tests/run-completion-guard.sh \
  tests/run-plan-execution-contract.sh; do
  [ ! -e "$retired_script" ] || err "obsolete $retired_script still exists"
done

# Manifest sync: a harness discovers skills only through its manifest, so every
# leaf skill dir must be listed explicitly in the plugin's "skills" array — a
# skill missing from it silently fails to load; a dead entry points nowhere.
actual=$(printf '%s\n' "${skills[@]}" | sed 's|/SKILL.md$||; s|^|./|' | sort -u)
manifest=.claude-plugin/plugin.json
echo "• $manifest (skills array sync)"
if [ ! -f "$manifest" ]; then
  err "missing $manifest"
else
  declared=$(grep -oE '"\./skills/[^"]+"' "$manifest" | tr -d '"' | sort -u)
  missing=$(comm -23 <(printf '%s\n' "$actual") <(printf '%s\n' "$declared"))
  dead=$(comm -13 <(printf '%s\n' "$actual") <(printf '%s\n' "$declared"))
  [ -n "$missing" ] && while IFS= read -r m; do err "skill not in $manifest 'skills' (won't load): $m"; done <<< "$missing"
  [ -n "$dead" ]    && while IFS= read -r d; do err "$manifest 'skills' entry has no SKILL.md: $d"; done <<< "$dead"
fi

echo "• Codex adapter"
if ! bash scripts/sh/validate-codex-plugin.sh; then fail=1; fi

echo "• Kimi adapter"
if ! bash scripts/sh/validate-kimi-plugin.sh; then fail=1; fi

# Version sync: the release version is declared in three manifests and bumped
# together in one release commit (see RELEASING.md). A half-done bump ships
# disagreeing versions, so any disagreement fails.
echo "• manifest versions agree"
versions=""
for manifest in .claude-plugin/plugin.json .claude-plugin/marketplace.json .kimi-plugin/plugin.json; do
  if [ ! -f "$manifest" ]; then err "missing $manifest"; continue; fi
  v=$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$manifest" | sed -E 's/.*"([^"]+)"$/\1/')
  if [ -z "$v" ]; then err "$manifest: no \"version\" field"; continue; fi
  versions="$versions$v"$'\n'
done
distinct=$(printf '%s' "$versions" | sort -u | grep -c .)
[ "$distinct" -gt 1 ] && err "manifest versions disagree: $(printf '%s' "$versions" | sort -u | tr '\n' ' ')"

# Internal references: any repo-root docs/ or tests/ markdown path named in a
# shipped or meta file must exist — a broken link ships straight to users.
#
# Trigger-eval query sets are excluded, and must be. A query is written to sound
# like a real request, which means naming real-looking files — "the spec is at
# docs/invites.md, follow it". Those paths belong to the *hypothetical* project
# in the query, not to this repository, so requiring them to resolve here would
# force every query into vague phrasing and destroy the realism the queries exist
# to provide. Nothing gates their shape; tests/optimizing/README.md says what a
# set has to contain, and a reader checks it.
#
# The query sets fall out of this scan for free, being .json. fixtures.sh does
# not, and needs naming: it is the file that BUILDS that hypothetical project, so
# every path it writes is a path in the fixture tree by definition, not a link
# into this repository.
echo "• internal references (docs/ and tests/ paths resolve)"
while IFS=: read -r src ref; do
  [ -f "$ref" ] || err "$src: internal reference '$ref' does not exist"
done < <(grep -roE --include='*.md' --include='*.sh' --exclude='fixtures.sh' \
           '(docs|tests)/[A-Za-z0-9._/-]+\.md' skills docs tests README.md CLAUDE.md | sort -u)

# Conformance record freshness. docs/agent-skills-conformance.md
# states how much headroom the library actually has against the standard's
# ceilings, and how many skills use each directory kind. Those are measurements
# of this tree, so they rot on any edit — and a conformance record with stale
# numbers is worse than one with none, because it reads as checked.
#
# This compares measurements, not limits. The ceilings themselves (1024, 500,
# 5000) live in check-skill.sh alone and are deliberately not restated here.
echo "• conformance record matches the tree"
CONF_DOC=docs/agent-skills-conformance.md
if [ ! -f "$CONF_DOC" ]; then
  err "$CONF_DOC is missing — the conformance record is part of the gate"
else
  max_desc=0; max_lines=0; max_tokens=0
  for skill in skills/*/*/SKILL.md; do
    fm_end=$(awk 'NR>1 && /^---[[:space:]]*$/{print NR; exit}' "$skill")
    d=$(awk -v e="${fm_end:-0}" '
             NR>=e{exit}
             /^description:/{found=1; sub(/^description:[[:space:]]*/,""); printf "%s", $0; next}
             found && /^[a-z_-]+:/{exit}
             found{printf " %s", $0}' "$skill" | sed 's/^"//; s/"$//')
    [ "${#d}" -gt "$max_desc" ] && max_desc=${#d}
    l=$(awk -v e="${fm_end:-0}" 'NR>e' "$skill" | wc -l | tr -d ' ')
    [ "$l" -gt "$max_lines" ] && max_lines=$l
    w=$(awk -v e="${fm_end:-0}" 'NR>e' "$skill" | wc -w | tr -d ' ')
    t=$(( w * 13 / 10 ))
    [ "$t" -gt "$max_tokens" ] && max_tokens=$t
  done
  n_refs=$(ls -d skills/*/*/references 2>/dev/null | wc -l | tr -d ' ')
  n_assets=$(ls -d skills/*/*/assets 2>/dev/null | wc -l | tr -d ' ')
  n_scripts=$(ls -d skills/*/*/scripts 2>/dev/null | wc -l | tr -d ' ')

  # Each claim is matched by a phrase unique to its row. A phrasing change that
  # breaks the match fails loudly rather than passing an unchecked number.
  conf_claim() {  # <label> <actual> <regex with one capture group>
    got=$(grep -oE "$3" "$CONF_DOC" | head -1 | grep -oE '[0-9]+' | head -1)
    if [ -z "$got" ]; then
      err "$CONF_DOC: no '$1' claim found — the gate cannot check it (expected a row matching /$3/)"
    elif [ "$got" != "$2" ]; then
      err "$CONF_DOC: states $1 = $got, tree says $2 — update the conformance record"
    fi
  }
  conf_claim "longest description"  "$max_desc"   'longest is [0-9]+ \|'
  conf_claim "longest body"         "$max_lines"  'longest is [0-9]+ \([0-9]+% of ceiling\)'
  conf_claim "largest body tokens"  "$max_tokens" 'largest is ~[0-9]+'
  conf_claim "references/ count"    "$n_refs"     '\| [0-9]+ skills; rubrics'
  conf_claim "assets/ count"        "$n_assets"   '\| [0-9]+ skills; every fill-in template'
  conf_claim "scripts/ count"       "$n_scripts"  '\| [0-9]+ skills — see below'
fi

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ all skills pass structural validation"; else echo "✗ violations found"; fi
exit "$fail"
