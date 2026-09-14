#!/usr/bin/env bash
# Claude Code adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.
#
# This file holds only what is true of the `claude` CLI's install: how skills
# are loaded and what the harness reports it resolved.

source_claude_home="${CLAUDE_CONFIG_DIR:-${HOME:-}/.claude}"

adapter_check() {
  command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; return 3; }
}

# Claude Code loads a plugin tree directly, so `--plugin-dir` is the whole
# install.
#
# The isolated CLAUDE_CONFIG_DIR is a separate job: `~/.claude/plugins/` is read
# regardless of `--plugin-dir`, so on an operator with sdlc-skills installed the
# installed copy would answer for the tree under test. Credentials are copied in
# because the CLI has to authenticate; `settings.json` deliberately is NOT,
# because it carries the SessionStart hook that injects the router. An operator
# authenticating by environment variable needs no file, and the copy is skipped
# without complaint.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  [ -f "$source_claude_home/.credentials.json" ] &&
    cp "$source_claude_home/.credentials.json" "$harness_home/.credentials.json"
  plugin_dir="$1"
  return 0
}

# DISCOVERY: ask Claude Code to resolve the plugin exactly as a session would
# and return the skill names from its component inventory. A filesystem count
# cannot prove that the manifest entries were accepted by the harness.
adapter_component_inventory() { # $1 plugin source
  env CLAUDE_CONFIG_DIR="$harness_home" claude --plugin-dir "$1" plugin details sdlc-skills 2>>"$errlog" |
    awk '/^  Skills \([0-9]+\)/ {
      sub(/^  Skills \([0-9]+\)[[:space:]]+/, "")
      gsub(/,[[:space:]]*/, "\n")
      print
    }'
}
