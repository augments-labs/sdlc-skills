#!/usr/bin/env bash
# Install every canonical skill into Muse Code's user scope, one at a time.
#
# Muse 1.3.0 ships no plugin router: `muse plugins` answers "plugins are not
# available in this build", so `.muse-plugin/plugin.json` cannot be installed
# or validated there and the SessionStart hook it declares never runs. What
# that build does expose is `muse skills install <dir> --scope user`, which
# takes exactly ONE skill directory — a tree makes it fail with "skill package
# must contain SKILL.md" — and copies it under the Muse config directory's
# `skills/`. So the portable route is this loop: one install call per
# canonical skill directory.
#
# This buys DISCOVERY, not routing. No hook runs, so nothing injects the
# `using-sdlc-skills` body at session start; the router is listed like any
# other skill and has to be invoked. A build that ships plugin support would
# install the native manifest and its hook instead; none has been observed, so
# that route is inferred, not measured.
#
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

usage() {
  cat <<'EOF'
scripts/sh/install-muse-skills.sh — install the canonical skills into Muse Code.

Runs `muse skills install <dir> --scope user --force` once per skill directory
under skills/<phase>/<name>/. Re-running is safe: --force overwrites an already
installed copy rather than failing on it.

  --remove   uninstall the same skills instead of installing them
  --help     this text

Discovery only: this build runs no plugin hook, so the router skill is listed
but never injected — invoke `using-sdlc-skills` yourself at the start of a
session.

Exit codes: 0 every skill installed (or removed) · 1 at least one call failed
            2 not run from the repo, no skill directories under skills/, or an unknown argument
            3 no `muse` on PATH
EOF
}

remove=""
[ $# -le 1 ] || { echo "at most one argument (see --help)" >&2; exit 2; }
case "${1-}" in
  -h|--help) usage; exit 0 ;;
  --remove) remove=1 ;;
  "") ;;
  *) echo "unknown argument: $1 (see --help)" >&2; exit 2 ;;
esac

command -v muse >/dev/null 2>&1 || { echo "no \`muse\` CLI on PATH" >&2; exit 3; }

mapfile -t dirs < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md -exec dirname {} \; | sort)
[ "${#dirs[@]}" -gt 0 ] || { echo "no skills found under skills/" >&2; exit 2; }

done_count=0
fail=0
out=""
for dir in "${dirs[@]}"; do
  name="$(basename "$dir")"
  if [ -n "$remove" ]; then
    # `muse skills uninstall` exits 1 on a skill that is not installed, which
    # is the state a second --remove run — or a run after a partial install —
    # is in. Its own `skill-not-installed` code is what separates "already
    # gone" from a real failure, so removal stays idempotent without swallowing
    # the errors that matter.
    out="$(muse skills uninstall "$name" --json 2>&1)"
    if [ $? -eq 0 ] || grep -q 'skill-not-installed' <<<"$out"; then
      done_count=$((done_count + 1))
    else
      echo "  FAIL  muse skills uninstall $name" >&2
      printf '%s\n' "$out" | sed 's/^/        /' >&2
      fail=1
    fi
  else
    out="$(muse skills install "$dir" --scope user --force --json 2>&1)"
    if [ $? -eq 0 ]; then
      done_count=$((done_count + 1))
    else
      echo "  FAIL  muse skills install $dir" >&2
      printf '%s\n' "$out" | sed 's/^/        /' >&2
      fail=1
    fi
  fi
done

if [ -n "$remove" ]; then
  echo "removed $done_count of ${#dirs[@]} skills from Muse user scope"
else
  echo "installed $done_count of ${#dirs[@]} skills into Muse user scope"
  echo "no hook runs on this build — invoke \`using-sdlc-skills\` to start a session"
fi
exit "$fail"
