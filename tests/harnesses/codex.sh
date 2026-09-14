#!/usr/bin/env bash
# Codex CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.

source_codex_home="${CODEX_HOME:-${HOME:-}/.codex}"

adapter_check() {
  command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; return 3; }
}

# Isolated CODEX_HOME with this checkout installed from a local marketplace —
# the same path `codex plugin add` takes for a real user.
adapter_install() { # $1 plugin source ("" = install nothing)
  harness_home="$(mktemp -d)"
  local f
  for f in auth.json config.toml models_cache.json; do
    [ -f "$source_codex_home/$f" ] && cp "$source_codex_home/$f" "$harness_home/$f"
  done
  # A copied config.toml can already register `augments-labs-dev` against the real
  # repo, which collides when the source under test differs. Removed in the
  # ISOLATED home only — the user's own CODEX_HOME is never touched. With an empty
  # source this is the whole job: an isolated home with credentials and no plugin.
  env CODEX_HOME="$harness_home" codex plugin remove sdlc-skills >/dev/null 2>&1
  env CODEX_HOME="$harness_home" codex plugin marketplace remove augments-labs-dev >/dev/null 2>&1
  [ -n "$1" ] || return 0
  env CODEX_HOME="$harness_home" codex plugin marketplace add "$1" --json >/dev/null 2>>"$errlog" || {
    echo "marketplace add failed (see $errlog)" >&2; return 3; }
  env CODEX_HOME="$harness_home" codex plugin add sdlc-skills@augments-labs-dev --json >/dev/null 2>>"$errlog" || {
    echo "plugin add failed (see $errlog)" >&2; return 3; }
}
