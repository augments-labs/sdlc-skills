#!/usr/bin/env bash
# Devin CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.
#
# Devin installs plugins/sdlc-skills/, the Codex plugin directory, not the
# checkout root: it loads skills one level deep, which the flat mirror there
# satisfies, and it would inject a root AGENTS.md into every session.

source_devin_data="${XDG_DATA_HOME:-${HOME:-}/.local/share}/devin"

adapter_check() {
  command -v devin >/dev/null 2>&1 || { echo "no \`devin\` CLI on PATH" >&2; return 3; }
}

# Isolated HOME with `devin plugins install --local`, which links the folder in
# place and, unlike a remote install, never writes the account's cloud plugin
# manifest. Plugin management refuses to run signed out even for a local
# folder, so the credentials file is copied in. HOME is isolated rather than
# Devin's own directories alone because Devin also reads `~/.claude/` hooks and
# skills, which would answer for the tree under test.
#
# The environment is kept, not cleared with `env -i`: measured on 3000.11.3,
# the install checks the organisation's plugin policy over the network and a
# cleared environment times that request out.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  plugin_dir="$1/plugins/sdlc-skills"
  mkdir -p "$harness_home/.local/share/devin"
  [ -f "$source_devin_data/credentials.toml" ] &&
    cp "$source_devin_data/credentials.toml" "$harness_home/.local/share/devin/"
  (cd "$harness_home" && env -u XDG_DATA_HOME -u XDG_CONFIG_HOME -u XDG_CACHE_HOME HOME="$harness_home" \
    devin plugins install --local "$plugin_dir" -y </dev/null) >>"$errlog" 2>&1 || {
    echo "devin plugins install failed (see $errlog)" >&2; return 1; }
}

# DISCOVERY: `devin plugins info` reports what Devin itself resolved from the
# manifest. Each skill is listed as `/sdlc-skills:<name> - <description>`, and
# the hook section names the SessionStart command, so a plugin that loads its
# skills but not its router is caught here too.
adapter_component_inventory() { # $1 plugin dir
  local out
  out="$(cd "$harness_home" && env -u XDG_DATA_HOME -u XDG_CONFIG_HOME -u XDG_CACHE_HOME HOME="$harness_home" \
    devin plugins info sdlc-skills </dev/null 2>>"$errlog")" || {
    echo "devin plugins info failed (see $errlog)" >&2; return 1; }
  if ! printf '%s\n' "$out" | grep -q 'on session_start'; then
    echo "devin plugins info lists no session_start hook — the router would not load" >>"$errlog"
    return 1
  fi
  printf '%s\n' "$out" | sed -nE 's|^[[:space:]]*/sdlc-skills:([a-z0-9-]+) - .*|\1|p'
}
