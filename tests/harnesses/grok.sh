#!/usr/bin/env bash
# Grok Build CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.

adapter_check() {
  command -v grok >/dev/null 2>&1 || { echo "no \`grok\` CLI on PATH" >&2; return 3; }
}

# Isolated home, installed the way `grok plugin install <path> --trust`
# installs it for a real user: offline and without login, since a local-path
# source clones through git without touching the network.
#
# HOME is overridden alongside GROK_HOME, not GROK_HOME alone: Grok cross-reads
# a real `~/.claude/plugins/marketplaces/` for Claude-compatible plugins
# regardless of GROK_HOME, so on an operator who already has sdlc-skills
# installed for Claude Code, GROK_HOME isolation alone would let that install
# answer for the tree under test — and would read the operator's real home,
# which this adapter must not do.
#
# `grok plugin install` COPIES (git-clones) the source into a per-install
# directory under the throwaway home rather than loading the checkout in
# place, so `plugin_dir` is recorded as the checkout for `cd` purposes only —
# it is never where the installed skills end up on disk.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  plugin_dir="$1"
  env -i PATH="$PATH" HOME="$harness_home" GROK_HOME="$harness_home" \
    grok plugin install "$1" --trust >>"$errlog" 2>&1 || {
    echo "grok plugin install failed (see $errlog)" >&2; return 1; }
}

# DISCOVERY: ask Grok what it resolves for this directory and report the
# names of the skills it attributes to this plugin. The install above copies
# the source rather than loading it in place, so the copy's path is not known
# in advance — `source.plugin_name` in Grok's own `inspect --json` output is
# the stable handle, tying each skill back to the one plugin this adapter
# installed in this isolated home.
adapter_component_inventory() { # $1 plugin source (checkout, for cwd only)
  local out
  out="$(cd "$1" && env -i PATH="$PATH" HOME="$harness_home" GROK_HOME="$harness_home" \
    grok inspect --json 2>>"$errlog")" || {
    echo "grok inspect failed (see $errlog)" >&2; return 1; }
  jq -r '.skills[] | select(.source.type=="plugin" and .source.plugin_name=="sdlc-skills") | .name' \
    <<<"$out" 2>>"$errlog" || {
    echo "grok inspect output did not parse (see $errlog)" >&2; return 1; }
}
