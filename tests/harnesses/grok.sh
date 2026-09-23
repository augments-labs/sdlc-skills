#!/usr/bin/env bash
# Grok Build CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.

adapter_check() {
  command -v grok >/dev/null 2>&1 || { echo "no \`grok\` CLI on PATH" >&2; return 3; }
}

# Isolated home, installed the way `grok plugin install <path> --trust`
# installs it for a real user: offline and without login, since a local-path
# source is copied on the filesystem without touching the network.
#
# HOME is overridden alongside GROK_HOME, not GROK_HOME alone: Grok cross-reads
# a real `~/.claude/plugins/marketplaces/` for Claude-compatible plugins
# regardless of GROK_HOME, so on an operator who already has sdlc-skills
# installed for Claude Code, GROK_HOME isolation alone would let that install
# answer for the tree under test — and would read the operator's real home,
# which this adapter must not do.
#
# `grok plugin install` COPIES the source recursively into a per-install
# directory under the throwaway home rather than loading the checkout in
# place, so `plugin_dir` is recorded as the checkout for `cd` purposes only —
# it is never where the installed skills end up on disk.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  plugin_dir="$1"
  env -i PATH="$PATH" HOME="$harness_home" GROK_HOME="$harness_home" \
    grok plugin install "$1" --trust >>"$errlog" 2>&1 || {
    echo "grok plugin install failed (see $errlog)" >&2; return 1; }

  # RULES-FILE PROBE: no hook on 1.0.40 reaches the prompt (see
  # docs/harness-support.md), so the one channel that nudges the router is a
  # rules file Grok scans regardless of folder trust. Write the same one-line
  # nudge a real install needs, then read it straight back through `grok
  # inspect --json`'s own `projectInstructions` array in this same isolated
  # home — measured: a file placed here comes back with `scope: global` and a
  # `path` naming it, so the smoke proves the nudge is actually discoverable
  # instead of only documented. No model turn.
  local out instructions
  mkdir -p "$harness_home/rules"
  printf 'Invoke the `using-sdlc-skills` skill before acting.\n' \
    >"$harness_home/rules/using-sdlc-skills.md"
  out="$(cd "$plugin_dir" && env -i PATH="$PATH" HOME="$harness_home" GROK_HOME="$harness_home" \
    grok inspect --json 2>>"$errlog")" || {
    echo "grok inspect failed (see $errlog)" >&2; return 1; }
  instructions="$(jq -c '.projectInstructions' <<<"$out" 2>>"$errlog")" || {
    echo "grok inspect output did not parse (see $errlog)" >&2; return 1; }
  if jq -e '.[] | select(.path | endswith("rules/using-sdlc-skills.md"))' \
    <<<"$instructions" >/dev/null 2>>"$errlog"; then
    echo "  ok    rules-file nudge listed by grok inspect (offline)"
  else
    echo "$instructions" >>"$errlog"
    echo "grok inspect did not list the rules-file nudge (see $errlog)" >&2
    return 1
  fi
}

# DISCOVERY: ask Grok what it resolves for this directory and report the
# names of the skills it attributes to this plugin. The install above copies
# the source rather than loading it in place, so the copy's path is not known
# in advance — `source.plugin_name` in Grok's own `inspect --json` output is
# the stable handle, tying each skill back to the one plugin this adapter
# installed in this isolated home.
adapter_component_inventory() { # $1 plugin source (checkout, for cwd only)
  local out names total found shapes
  out="$(cd "$1" && env -i PATH="$PATH" HOME="$harness_home" GROK_HOME="$harness_home" \
    grok inspect --json 2>>"$errlog")" || {
    echo "grok inspect failed (see $errlog)" >&2; return 1; }
  names="$(jq -r '.skills[] | select(.source.type=="plugin" and .source.plugin_name=="sdlc-skills") | .name' \
    <<<"$out" 2>>"$errlog")" || {
    echo "grok inspect output did not parse (see $errlog)" >&2; return 1; }

  # SHAPE GUARD: a total-zero inventory is a real install failure the
  # runner's own comparison already catches. A NON-zero total with zero
  # matches is different — `grok inspect` saw skills but none had the
  # `.source.type`/`.source.plugin_name` shape the filter assumes, which
  # silently degraded to "0 matched, exit 0" before this guard (see
  # .sdlc-skills/evidence/2026-09-22-t009-grok-build/silent-failures-report.md
  # F2). Name the shape it actually saw instead of leaving that
  # indistinguishable from a total install breakage.
  total="$(jq -r '.skills | length' <<<"$out" 2>>"$errlog")"
  found="$(printf '%s\n' "$names" | grep -c .)"
  if [ "$total" -gt 0 ] && [ "$found" -eq 0 ]; then
    shapes="$(jq -c '[.skills[].source] | unique' <<<"$out" 2>>"$errlog")"
    echo "grok inspect returned $total skills but none matched plugin sdlc-skills; .skills[].source shapes seen: $shapes" >>"$errlog"
    echo "grok inspect listed skills but none matched plugin sdlc-skills (see $errlog)" >&2
    return 1
  fi

  printf '%s\n' "$names"
}
