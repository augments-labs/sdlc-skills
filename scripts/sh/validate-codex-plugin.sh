#!/usr/bin/env bash
# Structural validator for the repo-local Codex plugin adapter.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/validate-codex-plugin.sh — structural gate for the Codex adapter.

Takes no arguments. Checks the Codex plugin manifest, its marketplace entry,
and that the flattened skill mirror matches the canonical tree.

  --help    this text

Exit codes: 0 the adapter is consistent · 1 violations printed above
            2 not run from the repo
EOF
    exit 0;;
esac

fail=0
err() { printf '  FAIL: %s\n' "$1"; fail=1; }

plugin_root="plugins/sdlc-skills"
manifest="$plugin_root/.codex-plugin/plugin.json"
marketplace=".agents/plugins/marketplace.json"

echo "• $manifest"
[ -f "$manifest" ] || err "missing Codex plugin manifest"
[ -f "$marketplace" ] || err "missing Codex marketplace"

if [ -f "$manifest" ]; then
  grep -q '"name"[[:space:]]*:[[:space:]]*"sdlc-skills"' "$manifest" || err "plugin name is not sdlc-skills"
  grep -q '"skills"[[:space:]]*:[[:space:]]*"\./skills/"' "$manifest" || err "plugin skills path must be ./skills/"
  for field in displayName shortDescription longDescription developerName category defaultPrompt; do
    grep -q "\"$field\"" "$manifest" || err "missing interface.$field"
  done
fi

if [ -f "$marketplace" ]; then
  grep -q '"name"[[:space:]]*:[[:space:]]*"augments-labs-dev"' "$marketplace" || err "marketplace name is not augments-labs-dev"
  grep -q '"path"[[:space:]]*:[[:space:]]*"\./plugins/sdlc-skills"' "$marketplace" || err "marketplace source path must be ./plugins/sdlc-skills"
  grep -q '"installation"[[:space:]]*:[[:space:]]*"AVAILABLE"' "$marketplace" || err "marketplace policy.installation missing"
  grep -q '"authentication"[[:space:]]*:[[:space:]]*"ON_INSTALL"' "$marketplace" || err "marketplace policy.authentication missing"
  grep -q '"category"[[:space:]]*:[[:space:]]*"Developer Tools"' "$marketplace" || err "marketplace category missing"
fi

echo "• Codex skill mirror"
canonical_names="$(find skills -mindepth 3 -maxdepth 3 -name SKILL.md \
  -printf '%h\n' | xargs -r -n1 basename | sort)"
mirror_names="$(find "$plugin_root/skills" -mindepth 2 -maxdepth 2 \
  -name SKILL.md -printf '%h\n' | xargs -r -n1 basename | sort)"
if [ "$canonical_names" != "$mirror_names" ]; then
  while IFS= read -r delta; do
    case "$delta" in
      $'\t'*) err "mirror-only skill: ${delta#$'\t'}";;
      *)       err "canonical skill missing from mirror: $delta";;
    esac
  done < <(comm -3 <(printf '%s\n' "$canonical_names") \
                   <(printf '%s\n' "$mirror_names"))
fi
while IFS= read -r skill; do
  name="$(basename "$(dirname "$skill")")"
  mirror="$plugin_root/skills/$name"
  [ -d "$mirror" ] || { err "missing mirrored skill for $name at $mirror"; continue; }
  [ -f "$mirror/SKILL.md" ] || err "mirrored skill for $name is missing SKILL.md"
  diff -qr "$(dirname "$skill")" "$mirror" >/dev/null || err "mirrored skill differs from canonical skill: $name"
done < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

echo "• Codex mirrored reference paths"
if ! bash scripts/sh/validate-skill-reference-paths.sh "$plugin_root/skills"; then
  fail=1
fi

# The plugin manifest ships the skill CATALOGUE; it has no session-start field,
# so on Codex the entry skill arrives through a SessionStart hook instead.
# Compaction is another SessionStart invocation with source=compact, and the
# injector deliberately skips it: loaded context survives compaction, so
# re-injection is redundant cost. PostCompact stays unregistered — its output
# cannot carry additional context, and compact re-injection is retired anyway.
#
# The hooks ship INSIDE the plugin, because the plugin is installed standalone:
# a hooks file at the repository root is outside the plugin root and Codex never
# loads it. Manifest hook paths resolve relative to the plugin root and must stay
# inside it, so everything the hook touches is mirrored in by
# scripts/sh/sync-codex-plugin-skills.sh.
echo "• Codex hook config (router only)"
codex_hook="$plugin_root/hooks/hooks.json"
if [ ! -f "$codex_hook" ]; then
  err "missing $codex_hook (an installed plugin would inject no router)"
else
  grep -q '"SessionStart"' "$codex_hook" || err "$codex_hook: no SessionStart hook (router would not load)"
  jq -e '.hooks | keys == ["SessionStart"]' "$codex_hook" >/dev/null 2>&1 ||
    err "$codex_hook: SessionStart must be the sole hook event"
  grep -q 'session-start\.sh' "$codex_hook" || err "$codex_hook: does not invoke session-start.sh"
  grep -q 'PLUGIN_ROOT' "$codex_hook" \
    || err "$codex_hook: resolves no plugin root — the command must not depend on the session cwd"
fi
if [ -f "$manifest" ]; then
  hooks_field="$(jq -r '.hooks // empty' "$manifest" 2>/dev/null)"
  [ -n "$hooks_field" ] || err "$manifest declares no hooks entry (bundled hooks would not be loaded)"
fi

# A hook is inert unless the injector it runs is inside the package, and the
# mirror is generated — so a stale copy is the realistic failure, not a divergent
# hand edit.
echo "• Codex plugin ships its hook scripts"
[ -x scripts/sh/session-start.sh ] || err "scripts/sh/session-start.sh is not executable"
mirrored="$plugin_root/scripts/sh/session-start.sh"
if [ ! -x "$mirrored" ]; then
  err "missing executable $mirrored (run scripts/sh/sync-codex-plugin-skills.sh)"
elif ! diff -q scripts/sh/session-start.sh "$mirrored" >/dev/null; then
  err "$mirrored is stale — re-run scripts/sh/sync-codex-plugin-skills.sh"
fi
for guard in implementation-guard completion-guard; do
  [ ! -e "$plugin_root/scripts/sh/$guard.sh" ] ||
    err "$plugin_root/scripts/sh/$guard.sh is unused and must not ship"
done
[ -f "$plugin_root/skills/using-sdlc-skills/SKILL.md" ] \
  || err "$plugin_root/skills/using-sdlc-skills/SKILL.md missing — the injector would find no router"

echo "• manifest versions agree"
codex_v=""
claude_v=""
if [ -f "$manifest" ]; then
  codex_v="$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$manifest" | sed -E 's/.*"([^"]+)"$/\1/')"
fi
if [ -f ".claude-plugin/plugin.json" ]; then
  claude_v="$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' .claude-plugin/plugin.json | sed -E 's/.*"([^"]+)"$/\1/')"
fi
[ -n "$codex_v" ] || err "Codex manifest has no version"
[ -n "$claude_v" ] || err "Claude manifest has no version"
[ -n "$codex_v" ] && [ -n "$claude_v" ] && [ "$codex_v" != "$claude_v" ] && err "Codex version $codex_v != Claude version $claude_v"

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✓ Codex plugin adapter passes structural validation"
else
  echo "✗ Codex plugin adapter violations found"
fi
exit "$fail"
