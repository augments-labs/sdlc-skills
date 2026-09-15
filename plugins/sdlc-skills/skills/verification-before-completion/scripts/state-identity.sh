#!/usr/bin/env bash
# Capture the exact state a piece of evidence is bound to, as JSON on stdout.
#
# Read-only for repository files, refs, and the index: it never fetches, commits,
# or changes them. Git may refresh the timestamps of objects it already holds.
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
  --compare VALUE    Compare the current state against VALUE: the
                     `source.digest` from an earlier run, or with --committed
                     a full revision. Exit 1 on drift.
  --committed        Require a commit that holds the whole state: a born HEAD
                     and no staged, unstaged, or untracked non-ignored path.
                     Otherwise exit 5. A partial commit leaves the digest
                     unchanged, so only this flag proves a commit holds it.
                     Dirt inside a submodule counts once its commit moves.
  --quiet            Print only the source digest, or with --committed HEAD's
                     full revision, one line, no JSON.
  --help             Show this message.

Output:
  JSON on stdout, diagnostics on stderr.

  source.digest covers the content the working tree presents (tracked and
  untracked, non-ignored paths, as git would record them) plus any staged copy
  that matches neither HEAD nor the working tree. HEAD is not part of it:
  staging or committing exactly the captured content keeps the digest. It does
  NOT change when only the time or the environment changes. Changes inside a
  submodule count once its checked-out commit moves. Paths under
  .sdlc-skills/evidence/ are left out of the digest, the counts, and
  --committed, so a record written there never moves the candidate.

Exit codes:
  0  state captured, or --compare matched
  1  --compare found drift: the evidence does not describe this state
  2  not a git repository, or bad arguments
  3  a required tool is missing
  4  a git step failed: no digest or committed identity, so no evidence binds
  5  --committed found uncommitted content: the commit does not hold the captured state

Examples:
  before=$(bash scripts/state-identity.sh --quiet)
  # ... run the gate ...
  bash scripts/state-identity.sh --compare "$before" || echo "source moved; rerun"
EOF
}

compare=""; quiet=0; committed=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --compare) compare="${2:-}"; [ -n "$compare" ] || { echo "Error: --compare needs a value." >&2; exit 2; }; shift 2;;
    --quiet)   quiet=1; shift;;
    --committed) committed=1; shift;;
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
# Records under .sdlc-skills/evidence/ describe a candidate and never belong to
# it, so the digest and the uncommitted listings leave that directory out.
evidence_out=':(exclude).sdlc-skills/evidence'

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

# The content digest: what the working tree presents, as git would record it,
# plus every staged copy that matches neither HEAD nor the working tree. HEAD is
# not part of it, so staging or committing exactly this content keeps it.
# Neither is .sdlc-skills/evidence/: a record written there keeps it too.
#
# Git itself records the working tree into a throwaway index and object
# directory under mktemp, reading the repository's objects as alternates, so
# paths with tabs or newlines, submodules, symlinks, modes, and clean filters
# are handled as a commit would handle them. The copy keeps the index's mtime,
# so git still re-reads a racily clean file. Split index and hooks are off, so
# no hook runs and no repository file is added or changed; git may only refresh
# the timestamps of objects it already holds. Any git step that fails makes the
# function fail: it never prints a digest for a partial record.
content_digest() {
  local cd_tmp cd_objects cd_index cd_head cd_tw cd_t2 cd_hdr cd_path cd_newmode cd_newsha cd_status
  cd_tmp="$(mktemp -d 2>/dev/null)" || return 1
  cd_objects="$(cd "$(git rev-parse --git-path objects 2>/dev/null)" 2>/dev/null && pwd -P)" || { rm -rf "$cd_tmp"; return 1; }
  cd_index="$(git rev-parse --git-path index 2>/dev/null)"
  mkdir -p "$cd_tmp/objects"
  if [ -f "$cd_index" ]; then cp -p "$cd_index" "$cd_tmp/wt.index" || { rm -rf "$cd_tmp"; return 1; }; fi
  cd_git() { # $1 index file; the rest is a git command
    local idx="$1"; shift
    GIT_INDEX_FILE="$idx" GIT_OBJECT_DIRECTORY="$cd_tmp/objects" GIT_ALTERNATE_OBJECT_DIRECTORIES="$cd_objects" \
      git --no-optional-locks -c core.fsmonitor=false -c core.splitIndex=false -c core.hooksPath=/dev/null "$@"
  }
  # What the working tree presents, recorded as git would record it.
  cd_git "$cd_tmp/wt.index" add -A -- . "$evidence_out" >/dev/null 2>&1 &&
    cd_git "$cd_tmp/wt.index" rm -r -q -f --cached --ignore-unmatch -- .sdlc-skills/evidence >/dev/null 2>&1 &&
    cd_tw="$(cd_git "$cd_tmp/wt.index" write-tree 2>/dev/null)" && [ -n "$cd_tw" ] ||
    { rm -rf "$cd_tmp"; return 1; }
  # Overlay every staged copy that differs from HEAD; the result differs from
  # the working-tree tree only where a staged copy matches neither.
  if [ -f "$cd_tmp/wt.index" ]; then cp -p "$cd_tmp/wt.index" "$cd_tmp/t2.index" || { rm -rf "$cd_tmp"; return 1; }; fi
  cd_head="$(git rev-parse --verify -q 'HEAD^{tree}' 2>/dev/null)" || cd_head=4b825dc642cb6eb9a060e54bf8d69288fbee4904
  git --no-optional-locks diff-index --cached --raw -z --no-renames --ita-invisible-in-index --ignore-submodules=none "$cd_head" -- . "$evidence_out" 2>/dev/null |
    while IFS= read -r -d '' cd_hdr && IFS= read -r -d '' cd_path; do
      set -- $cd_hdr
      cd_newmode="$2"; cd_newsha="$4"; cd_status="$5"
      case "$cd_status" in M|A|T) ;; *) continue;; esac
      case "$cd_newsha" in *[!0]*) ;; *) continue;; esac
      printf '%s %s 0\t%s\0' "$cd_newmode" "$cd_newsha" "$cd_path"
    done | cd_git "$cd_tmp/t2.index" update-index -z --index-info >/dev/null 2>&1 &&
    cd_t2="$(cd_git "$cd_tmp/t2.index" write-tree 2>/dev/null)" && [ -n "$cd_t2" ] ||
    { rm -rf "$cd_tmp"; return 1; }
  git --no-optional-locks ls-files -u -z -- . "$evidence_out" >"$cd_tmp/unmerged" 2>/dev/null || { rm -rf "$cd_tmp"; return 1; }
  { printf '%s\n%s\n' "$cd_tw" "$cd_t2"; cat "$cd_tmp/unmerged"; } | sha || { rm -rf "$cd_tmp"; return 1; }
  rm -rf "$cd_tmp"
}

# The digest that decides whether evidence still applies.
digest="$(content_digest)" || {
  echo "Error: git could not record the working tree (try \`git add -A --dry-run\`); there is no digest to bind evidence to." >&2; exit 4; }

# --committed: the commit must hold the whole state, or no committed identity
# exists. A partial commit leaves reviewed content uncommitted while the digest
# above still matches, so digest equality alone never proves a commit holds it.
head_full=""
if [ "$committed" = 1 ]; then
  head_full="$(git rev-parse --verify -q 'HEAD^{commit}' 2>/dev/null)"; rc=$?
  [ "$rc" -le 1 ] || { echo "Error: git could not resolve HEAD; no identity." >&2; exit 4; }
  uncommitted=0
  if [ -z "$head_full" ]; then uncommitted=1
  else
    git --no-optional-locks diff --cached --quiet --ignore-submodules=dirty -- . "$evidence_out" 2>/dev/null; rc=$?
    [ "$rc" -le 1 ] || { echo "Error: git could not compare the index with HEAD; no identity." >&2; exit 4; }
    [ "$rc" -eq 1 ] && uncommitted=1
    git --no-optional-locks diff --quiet --ignore-submodules=dirty -- . "$evidence_out" 2>/dev/null; rc=$?
    [ "$rc" -le 1 ] || { echo "Error: git could not compare the working tree with the index; no identity." >&2; exit 4; }
    [ "$rc" -eq 1 ] && uncommitted=1
    untracked="$(git --no-optional-locks ls-files --others --exclude-standard -- . "$evidence_out" 2>/dev/null)" || {
      echo "Error: git could not list untracked paths; no identity." >&2; exit 4; }
    [ -n "$untracked" ] && uncommitted=1
  fi
  [ "$uncommitted" = 0 ] || { echo "uncommitted content: the commit does not hold the captured state" >&2; exit 5; }
fi

if [ -n "$compare" ]; then
  identity="${head_full:-$digest}"
  if [ "$digest" = "$compare" ] || { [ -n "$head_full" ] && [ "$head_full" = "$compare" ]; }; then
    echo "$identity"
    echo "match: source unchanged; evidence taken on $compare still describes this state." >&2
    exit 0
  fi
  echo "$identity"
  echo "DRIFT: source digest is $digest${head_full:+ at HEAD $head_full} but the evidence was taken on $compare." >&2
  echo "       That evidence describes a state that no longer exists. Rerun the gate." >&2
  exit 1
fi

[ "$quiet" = 1 ] && { echo "${head_full:-$digest}"; exit 0; }

head_sha="$(git rev-parse HEAD 2>/dev/null)" || head_sha=""
branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch=""
count() { # the line count of a git listing outside evidence/; fails when git does
  local out; out="$(git --no-optional-locks "$@" -- . "$evidence_out" 2>/dev/null)" || return 1
  printf '%s\n' "$out" | grep -c . || true
}
staged_n="$(count diff --cached --name-only)" && unstaged_n="$(count diff --name-only)" &&
  untracked_n="$(count ls-files --others --exclude-standard)" || {
  echo "Error: git could not list uncommitted paths; no identity." >&2; exit 4; }
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
