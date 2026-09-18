#!/usr/bin/env bash
# OpenCode CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.
#
# This file holds only what is true of the `opencode` CLI's install: how the
# plugin is loaded and what the harness reports it resolved.

adapter_check() {
  command -v opencode >/dev/null 2>&1 || { echo "no \`opencode\` CLI on PATH" >&2; return 3; }
}

# OpenCode loads a plugin file directly, so the checkout is the whole install:
# the plugin resolves its skills from its own location. The isolated config
# home carries only the plugin entry — no credentials, because skill discovery
# (`debug skill`) is offline.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  mkdir -p "$harness_home/xdg/opencode"
  printf '{"$schema":"https://opencode.ai/config.json","plugin":["%s/.opencode/plugins/sdlc-skills.js"]}' \
    "$1" > "$harness_home/xdg/opencode/opencode.json"
  plugin_dir="$1"
  return 0
}

# DISCOVERY: ask OpenCode to resolve the skills exactly as a session would and
# return the skill names from its own listing. A filesystem count cannot prove
# that the registered path was accepted by the harness.
#
# Two harness quirks live here. `debug skill` truncates piped stdout at 64 KiB,
# so the output is staged through a file first — a pipe sees only the first
# few skills. And the listing covers every visible skill including built-ins,
# so only entries located under the installed plugin source are reported.
adapter_component_inventory() { # $1 plugin source
  local out="$harness_home/skills.json"
  env -i PATH="$PATH" HOME="$harness_home" XDG_CONFIG_HOME="$harness_home/xdg" \
    opencode debug skill >"$out" 2>>"$errlog" || {
    echo "debug skill failed (see $errlog)" >&2; return 1; }
  jq -r --arg root "$1" \
    '.[] | select(.location | startswith($root)) | .name' "$out" 2>>"$errlog" || {
    echo "debug skill output did not parse (see $errlog)" >&2; return 1; }
}
