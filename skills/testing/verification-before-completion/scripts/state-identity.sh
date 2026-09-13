#!/usr/bin/env bash
# Capture the exact state a piece of evidence is bound to, as JSON on stdout.
#
# Read-only: this script never writes, fetches, or mutates anything.
#
# Evidence is only valid for the state it was taken on. Recalling that state
# from memory is how a green result gets carried across an edit and reported as
# still passing. Run this immediately before a gate and immediately after, and
# compare the digests: if they differ, the run described a state that no longer
# exists and the claim is pending, not proven.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/state-identity.sh [OPTIONS]

Capture the identity of the state a gate is about to run against — or just ran
against — as JSON. Read-only.

Options:
  --compare DIGEST   Compare the current source digest against DIGEST (the
                     `source.digest` from an earlier run). Exit 1 on drift.
  --quiet            Print only the source digest, one line, no JSON.
  --help             Show this message.

Output:
  JSON on stdout, diagnostics on stderr.

  source.digest covers tracked content, staged and unstaged changes, and
  untracked file names and contents. It deliberately does NOT change when only
  the time or the environment changes, so a matching digest means the source
  really is the same source.

Exit codes:
  0  state captured, or --compare matched
  1  --compare found drift: the evidence does not describe this state
  2  not a git repository, or bad arguments
  3  a required tool is missing

Examples:
  before=$(bash scripts/state-identity.sh --quiet)
  # ... run the gate ...
  bash scripts/state-identity.sh --compare "$before" || echo "source moved; rerun"
EOF
}

compare=""; quiet=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --compare) compare="${2:-}"; [ -n "$compare" ] || { echo "Error: --compare needs a digest." >&2; exit 2; }; shift 2;;
    --quiet)   quiet=1; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Error: unknown argument \"$1\". Run with --help for usage." >&2; exit 2;;
  esac
done

command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }
git rev-parse --git-dir >/dev/null 2>&1 || {
  echo "Error: not inside a git repository. Run this from the workspace the gate runs in." >&2; exit 2; }

root="$(git rev-parse --show-toplevel 2>/dev/null)"
# Scope every listing to the whole workspace, not the current directory.
[ -n "$root" ] && cd "$root" || { echo "Error: could not resolve the repository root." >&2; exit 2; }

if command -v sha256sum >/dev/null 2>&1; then sha() { sha256sum | cut -c1-16; }
elif command -v shasum  >/dev/null 2>&1; then sha() { shasum -a 256 | cut -c1-16; }
else sha() { cksum | tr -d ' ' | cut -c1-16; }
fi

jstr() {
  local s="${1-}"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"
  s="${s//	/\\t}"; s="${s//$'\r'/\\r}"; s="${s//$'\n'/\\n}"
  printf '"%s"' "$s"
}
jnull() { [ -n "${1-}" ] && jstr "$1" || printf 'null'; }
jbool() { [ "${1:-}" = 1 ] && printf 'true' || printf 'false'; }

# The digest that decides whether evidence still applies.
digest="$( { git rev-parse 'HEAD^{tree}' 2>/dev/null
             git diff HEAD --binary 2>/dev/null
             git status --porcelain -uall 2>/dev/null
             git ls-files --others --exclude-standard -z 2>/dev/null \
               | xargs -0 -r git hash-object 2>/dev/null
           } | sha )"

if [ -n "$compare" ]; then
  if [ "$digest" = "$compare" ]; then
    echo "$digest"
    echo "match: source unchanged; evidence taken on $compare still describes this state." >&2
    exit 0
  fi
  echo "$digest"
  echo "DRIFT: source digest is $digest but the evidence was taken on $compare." >&2
  echo "       That evidence describes a state that no longer exists. Rerun the gate." >&2
  exit 1
fi

[ "$quiet" = 1 ] && { echo "$digest"; exit 0; }

head_sha="$(git rev-parse HEAD 2>/dev/null)" || head_sha=""
branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch=""
staged_n="$(git diff --cached --name-only 2>/dev/null | grep -c . || true)"
unstaged_n="$(git diff --name-only 2>/dev/null | grep -c . || true)"
untracked_n="$(git ls-files --others --exclude-standard 2>/dev/null | grep -c . || true)"
clean=0; [ "$staged_n" = 0 ] && [ "$unstaged_n" = 0 ] && [ "$untracked_n" = 0 ] && clean=1

printf '{\n'
printf '  "schema": "state-identity/1",\n'
printf '  "source": {\n'
printf '    "digest": %s,\n' "$(jnull "$digest")"
printf '    "workspace": %s,\n' "$(jnull "$root")"
printf '    "head": %s,\n' "$(jnull "$head_sha")"
printf '    "branch": %s,\n' "$(jnull "$branch")"
printf '    "clean": %s,\n' "$(jbool $clean)"
printf '    "staged_count": %s, "unstaged_count": %s, "untracked_count": %s\n' \
  "$staged_n" "$unstaged_n" "$untracked_n"
printf '  },\n'
printf '  "environment": {\n'
printf '    "cwd": %s,\n' "$(jnull "$PWD")"
printf '    "platform": %s,\n' "$(jnull "$(uname -srm 2>/dev/null)")"
printf '    "captured_at": %s\n' "$(jnull "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)")"
printf '  }\n'
printf '}\n'
exit 0
