#!/usr/bin/env bash
# Points core.hooksPath at the tracked scripts/git-hooks directory, so
# pre-commit runs the CI validators locally on a relevant staged change.
# No third-party tool. --remove restores whatever core.hooksPath held before.
# Flags and exit codes: --help.

set -uo pipefail

# An arbitrary marker distinguishable from any real hooksPath value, recording
# that core.hooksPath was unset before install.
PREV_MARKER='__sdlc-skills-hooks-unset__'
HOOKS_DIR=scripts/git-hooks

usage() {
  cat <<'EOF'
scripts/sh/install-git-hooks.sh — install or remove the local pre-commit hook.

Points core.hooksPath at the tracked scripts/git-hooks directory, whose
pre-commit hook runs the same validators as CI when a staged path can affect
them, and exits fast otherwise. No third-party tool. Run this from the
repository's root.

  --remove  restore core.hooksPath to whatever it held before install (or
            unset it, if it was unset then), and forget the saved value
  --help    this text

Exit codes: 0 installed or removed · 1 could not read or write git config, or
            the tracked hook is missing · 2 not run from this repository's
            root, or an unknown argument
EOF
}

[ $# -le 1 ] || { echo "at most one argument (see --help)" >&2; exit 2; }

mode=install
case "${1-}" in
  -h|--help) usage; exit 0 ;;
  --remove)  mode=remove ;;
  "") ;;
  *) echo "unknown argument: $1 (see --help)" >&2; exit 2 ;;
esac

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 2; }

toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "not run from inside a git working tree" >&2
  exit 2
}
here="$(pwd -P)"
toplevel_resolved="$(cd "$toplevel" 2>/dev/null && pwd -P)"
if [ -z "$toplevel_resolved" ] || [ "$here" != "$toplevel_resolved" ]; then
  echo "run this from the repository root ($toplevel), not $here" >&2
  exit 2
fi

# In a linked worktree .git is a pointer file, not the real git directory, so
# the previous-value record has to live beside the shared git-common-dir — the
# same place core.hooksPath itself is stored — not under a literal ".git/" in
# the working tree.
common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || {
  echo "could not resolve the git directory" >&2
  exit 1
}
case "$common_dir" in
  /*) ;;
  *) common_dir="$toplevel_resolved/$common_dir" ;;
esac
prev_file="$common_dir/sdlc-skills-hooks.previous"

if [ "$mode" = remove ]; then
  if [ -f "$prev_file" ]; then
    prev="$(cat "$prev_file")"
    if [ "$prev" = "$PREV_MARKER" ]; then
      git config --unset core.hooksPath 2>/dev/null
    else
      git config core.hooksPath "$prev" || { echo "could not restore core.hooksPath" >&2; exit 1; }
    fi
    rm -f "$prev_file"
  else
    # No recorded value: only clear it if it is still ours to clear.
    current="$(git config --get core.hooksPath 2>/dev/null || true)"
    if [ "$current" = "$HOOKS_DIR" ]; then
      git config --unset core.hooksPath 2>/dev/null
    fi
  fi
  echo "removed: core.hooksPath restored"
  exit 0
fi

# install
[ -f "$HOOKS_DIR/pre-commit" ] || { echo "missing $HOOKS_DIR/pre-commit" >&2; exit 1; }

if [ ! -f "$prev_file" ]; then
  current="$(git config --get core.hooksPath 2>/dev/null || true)"
  if [ -n "$current" ]; then
    printf '%s' "$current" > "$prev_file" || { echo "could not save the previous core.hooksPath" >&2; exit 1; }
  else
    printf '%s' "$PREV_MARKER" > "$prev_file" || { echo "could not save the previous core.hooksPath" >&2; exit 1; }
  fi
fi

git config core.hooksPath "$HOOKS_DIR" || { echo "could not set core.hooksPath" >&2; exit 1; }
echo "installed: core.hooksPath -> $HOOKS_DIR"
exit 0
