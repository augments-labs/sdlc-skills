#!/usr/bin/env bash
# Rebuild the Codex plugin package from canonical sources.
#
# The plugin is installed standalone — copied out of this repository into Codex's
# plugin cache — so anything its manifest or hooks reference must live inside the
# plugin root. That is the skills (flattened, because the manifest points at one
# directory) AND the session-start injector its hooks run.

set -euo pipefail
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/sync-codex-plugin-skills.sh — rebuild the Codex plugin from canonical sources.

Takes no arguments. Flattens skills/<phase>/<name>/ into the plugin root the
Codex manifest points at, and copies the hook scripts its lifecycle events run.
Re-run it after ANY edit under skills/, including scripts/ and assets/ — the
mirror is a copy, not a link, and a stale one ships silently.

  --help    this text

Destructive by design: it removes the mirrored skill directories before
rebuilding them. Never hand-edit the mirror.

Exit codes: 0 mirror rebuilt · non-zero a copy step failed
EOF
    exit 0;;
esac

root="plugins/sdlc-skills"
out="$root/skills"
mkdir -p "$out"

find "$out" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

while IFS= read -r skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  dest="$out/$name"
  mkdir -p "$dest"
  cp -a "$src/." "$dest/"
done < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

# Hooks are inert without their scripts beside them. session-start.sh resolves
# the router from the flat mirror and needs no rewriting.
mkdir -p "$root/scripts/sh"
rm -f "$root/scripts/sh/implementation-guard.sh" "$root/scripts/sh/completion-guard.sh"
cp -a scripts/sh/session-start.sh "$root/scripts/sh/session-start.sh"
chmod +x "$root/scripts/sh/session-start.sh"
