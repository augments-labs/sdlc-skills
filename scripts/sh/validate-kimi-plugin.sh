#!/usr/bin/env bash
# Structural validator for the repo-local Kimi Code plugin adapter.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/validate-kimi-plugin.sh — structural gate for the Kimi Code adapter.

Takes no arguments. Checks the Kimi manifest parses, carries only supported
fields, and that its skill paths resolve to the canonical set.

  --help    this text

Exit codes: 0 the adapter is consistent · 1 violations printed above
            2 not run from the repo · requires `jq`
EOF
    exit 0;;
esac

fail=0
err() { printf '  FAIL: %s\n' "$1"; fail=1; }

manifest=".kimi-plugin/plugin.json"

echo "• $manifest"
if [ ! -f "$manifest" ]; then
  err "missing Kimi plugin manifest"
else
  command -v jq >/dev/null || { echo "  FAIL: jq is required to validate $manifest"; exit 1; }
  jq -e . "$manifest" >/dev/null 2>&1 || err "$manifest does not parse as JSON"

  [ "$(jq -r '.name // ""' "$manifest")" = "sdlc-skills" ] || err "plugin name is not sdlc-skills"
  [ -n "$(jq -r '.version // ""' "$manifest")" ] || err "Kimi manifest has no version"
  while IFS= read -r field; do
    err "unsupported Kimi manifest field present: $field"
  done < <(
    jq -r '
      keys_unsorted[] as $field
      | select(
          [
            "name", "version", "description", "keywords", "author",
            "homepage", "license", "skills", "sessionStart", "mcpServers",
            "hooks", "commands", "interface", "skillInstructions"
          ]
          | index($field) | not
        )
      | $field
    ' "$manifest"
  )

  for field in displayName shortDescription longDescription developerName websiteURL; do
    [ -n "$(jq -r ".interface.$field // \"\"" "$manifest")" ] || err "missing interface.$field"
  done

  echo "• Kimi skill exposure (skills paths cover the canonical set)"
  canonical="$(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sed 's|^skills/||; s|/SKILL.md$||' | sort)"
  exposed=""
  while IFS= read -r path; do
    dir="${path#./}"
    dir="${dir%/}"
    [ -d "$dir" ] || { err "Kimi skills path does not exist: $path"; continue; }
    case "$(realpath -m "$dir")" in
      "$(realpath -m .)"/*) ;;
      *) err "Kimi skills path escapes the plugin root: $path" ;;
    esac
    found="$(find "$dir" -mindepth 2 -maxdepth 2 -name SKILL.md | sed "s|^$dir/||; s|/SKILL.md$||; s|^|$dir/|" | sed 's|^skills/||')"
    exposed="$exposed$found"$'\n'
  done < <(jq -r '.skills[]? // empty' "$manifest")
  exposed="$(printf '%s' "$exposed" | grep . | sort -u)"
  missing="$(comm -23 <(printf '%s\n' "$canonical") <(printf '%s\n' "$exposed"))"
  extra="$(comm -13 <(printf '%s\n' "$canonical") <(printf '%s\n' "$exposed"))"
  [ -n "$missing" ] && while IFS= read -r m; do err "skill not exposed by the Kimi manifest: $m"; done <<< "$missing"
  [ -n "$extra" ]   && while IFS= read -r e; do err "Kimi manifest exposes a non-canonical skill: $e"; done <<< "$extra"

  echo "• Kimi session-start router"
  router="$(jq -r '.sessionStart.skill // ""' "$manifest")"
  [ -n "$router" ] || err "missing sessionStart.skill"
  [ -n "$router" ] && printf '%s\n' "$exposed" | grep -qx "common/$router" || err "sessionStart.skill '$router' is not an exposed skill"

  echo "• Kimi session-start-only activation"
  jq -e '(.hooks // []) | length == 0' "$manifest" >/dev/null ||
    err "Kimi activation belongs in sessionStart.skill; lifecycle hooks must not ship"

  echo "• Kimi skill instructions (tool binding)"
  instructions="$(jq -r '.skillInstructions // ""' "$manifest")"
  [ -n "$instructions" ] || err "missing skillInstructions"
  for token in AskUserQuestion TodoList Agent Skill; do
    case "$instructions" in *"$token"*) ;; *) err "skillInstructions does not bind $token" ;; esac
  done
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✓ Kimi plugin adapter passes structural validation"
else
  echo "✗ Kimi plugin adapter violations found"
fi
exit "$fail"
