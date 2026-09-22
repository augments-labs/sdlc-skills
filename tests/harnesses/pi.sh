#!/usr/bin/env bash
# pi CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.
#
# `pi install <path>` installs a local-path source BY REFERENCE: measured on
# 0.86.1, a throwaway HOME after install holds only `.pi/agent/settings.json`
# naming the checkout path — nothing is copied, and nothing is written into
# the checkout itself, so .gitignore needs no edit. The skills therefore stay
# exactly where the checkout already has them, discovered recursively under
# the `skills` directory the `pi` key in package.json names — the same
# in-place layout Claude Code and OpenCode load, so `plugin_dir` (not
# `harness_home`) is the tree run-plugin-smoke.sh looks under.

adapter_check() {
  command -v pi >/dev/null 2>&1 || { echo "no \`pi\` CLI on PATH" >&2; return 3; }
}

# Isolated HOME, offline: a local-path source needs no network and no
# credentials, so nothing is copied in before the install runs.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  plugin_dir="$1"
  env -i PATH="$PATH" HOME="$harness_home" pi install "$1" >>"$errlog" 2>&1 || {
    echo "pi install failed (see $errlog)" >&2; return 1; }

  # LIMIT, stated rather than worked around: pi 0.86.1 has no non-interactive
  # skill dump, and `pi -p` runs a model turn, which this offline test must
  # not do. `pi list` is the most this can prove offline — the registered
  # package line is the evidence, and the smoke test names the limit instead
  # of fabricating an inventory.
  local list pkg_line
  list="$(env -i PATH="$PATH" HOME="$harness_home" pi list 2>>"$errlog")" || {
    echo "pi list failed (see $errlog)" >&2; return 1; }
  pkg_line="$(printf '%s\n' "$list" | grep -F "$1" | head -1 | sed 's/^[[:space:]]*//')"
  if [ -n "$pkg_line" ]; then
    echo "  ok    pi list registers the package: $pkg_line"
  else
    echo "  FAIL  pi list does not name the installed package"; return 1
  fi
  echo "  ok    skill inventory unavailable offline — pi 0.86.1 has no non-interactive skill dump"
}
