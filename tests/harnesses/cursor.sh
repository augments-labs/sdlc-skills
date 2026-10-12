#!/usr/bin/env bash
# Cursor CLI (`cursor-agent`) adapter. Sourced by tests/run-plugin-smoke.sh —
# never executed directly.
#
# Cursor installs the checkout root. With no .cursor-plugin/plugin.json it reads
# .claude-plugin/plugin.json, so the Claude skills list and hooks/hooks.json are
# what it loads; it exports CURSOR_PLUGIN_ROOT to that hook, which selects the
# snake_case output Cursor reads.

adapter_check() {
  command -v cursor-agent >/dev/null 2>&1 || { echo "no \`cursor-agent\` CLI on PATH" >&2; return 3; }
}

# Isolated HOME with the tree placed where a user's clone goes:
# `~/.cursor/plugins/local/<name>/`, which Cursor loads at session start.
# Measured on 2026.10.01: a symlink there is rejected when its target lies
# outside that directory, so the tree is copied, not linked. The copy takes the
# files git would clone plus untracked ones, so the working tree under test is
# what lands. Cursor can add a marketplace or load a folder for one session, but
# has no command that installs a single plugin, and lists plugins only inside
# a model session, so the copy is the install and there is no inventory.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  local dest="$harness_home/.cursor/plugins/local/sdlc-skills"
  mkdir -p "$dest"
  git -C "$1" ls-files -z --cached --others --exclude-standard 2>>"$errlog" |
    tar -C "$1" --null --ignore-failed-read -T - -cf - 2>>"$errlog" |
    tar -C "$dest" -xf - 2>>"$errlog" || {
    echo "copying the checkout into $dest failed (see $errlog)" >&2; return 1; }
}
