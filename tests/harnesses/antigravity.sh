#!/usr/bin/env bash
# Antigravity CLI (`agy`) adapter. Sourced by tests/run-plugin-smoke.sh — never
# executed directly.
#
# Antigravity installs plugins/sdlc-skills/, the Codex plugin directory, not the
# checkout root: it loads skills one level deep, which the flat mirror there
# satisfies, and the root's AGENTS.md and GEMINI.md would load as rules.

adapter_check() {
  command -v agy >/dev/null 2>&1 || { echo "no \`agy\` CLI on PATH" >&2; return 3; }
}

# Isolated HOME, because `agy plugin install` writes into `~/.gemini/config/`.
# Measured on 1.3.3: a local install needs no sign-in and no network, and it
# copies the directory, so the tree under test is the installed copy, not the
# checkout.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  (cd "$harness_home" && HOME="$harness_home" agy plugin install "$1/plugins/sdlc-skills" </dev/null) \
    >>"$errlog" 2>&1 || { echo "agy plugin install failed (see $errlog)" >&2; return 1; }
}

# DISCOVERY: `agy plugin validate` reports how many skills Antigravity itself
# processed from the installed copy, but not their names. The names are read
# from that copy and accepted only when the two counts agree, so a skill that
# landed on disk but that Antigravity would not load fails here. The rules file
# that carries the router nudge must have been copied too. The count line reads
# `skills : N processed` on 1.3.x and `skills N · agents 0 · ...` on 1.4.x; both
# shapes are accepted.
adapter_component_inventory() { # $1 plugin dir (unset: the install is a copy)
  local installed="$harness_home/.gemini/config/plugins/sdlc-skills" processed names
  [ -f "$installed/rules/AGENTS.md" ] || {
    echo "no rules/AGENTS.md in the installed plugin — the router nudge would not load" >>"$errlog"; return 1; }
  processed="$(agy plugin validate "$installed" </dev/null 2>>"$errlog" |
    sed 's/\x1b\[[0-9;]*m//g' | sed -nE 's/.*skills[[:space:]]*:?[[:space:]]*([0-9]+)([[:space:]]+processed|[[:space:]]+·|[[:space:]]*$).*/\1/p' | head -n 1)"
  names="$(find "$installed/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' 2>/dev/null |
    sed 's|.*/||' | sort -u)"
  if [ "${processed:-0}" -ne "$(printf '%s\n' "$names" | grep -c .)" ]; then
    echo "agy plugin validate processed ${processed:-no} skills; the installed copy holds $(printf '%s\n' "$names" | grep -c .)" >>"$errlog"
    return 1
  fi
  printf '%s\n' "$names"
}
