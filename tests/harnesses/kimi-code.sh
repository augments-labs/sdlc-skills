#!/usr/bin/env bash
# Kimi Code CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly. The live half lives with the live runners in the evals lab.

source_kimi_home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"

adapter_check() {
  command -v kimi >/dev/null 2>&1 || { echo "no \`kimi\` CLI on PATH" >&2; return 3; }
}

# Isolated home with this checkout as a managed plugin — the layout
# `kimi /plugins install` produces (plugins/managed/sdlc-skills + installed.json).
adapter_install() { # $1 plugin source ("" = install nothing)
  harness_home="$(mktemp -d)"
  local f d
  for f in config.toml device_id; do
    [ -f "$source_kimi_home/$f" ] && cp "$source_kimi_home/$f" "$harness_home/$f"
  done
  for d in credentials oauth; do
    [ -d "$source_kimi_home/$d" ] && cp -r "$source_kimi_home/$d" "$harness_home/$d"
  done
  # Empty source: an isolated home with credentials and no plugins/ tree at all.
  [ -n "$1" ] || return 0
  local managed="$harness_home/plugins/managed/sdlc-skills"
  mkdir -p "$managed"
  ( cd "$1" && tar --exclude=.git --exclude=.sdlc-skills -cf - . ) | tar -xf - -C "$managed"
  [ -f "$managed/.kimi-plugin/plugin.json" ] || {
    echo "no .kimi-plugin/plugin.json in $1 — does that ref carry the Kimi adapter?" >&2
    return 2; }
  local skills; skills="$(find "$managed/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  jq -n --arg root "$managed" \
        --arg manifest_path "$managed/.kimi-plugin/plugin.json" \
        --arg original "$1" \
        --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson skills "$skills" \
        --slurpfile manifest "$managed/.kimi-plugin/plugin.json" \
    '{version: 1, plugins: [{
       id: "sdlc-skills", root: $root, source: "local-path", enabled: true,
       state: "ok", installedAt: $now, updatedAt: $now, originalSource: $original,
       skillCount: $skills, manifest: $manifest[0],
       manifestKind: "kimi-plugin-dir", manifestPath: $manifest_path,
       diagnostics: [], skillInstructions: $manifest[0].skillInstructions
     }]}' > "$harness_home/plugins/installed.json" || return 2
}
