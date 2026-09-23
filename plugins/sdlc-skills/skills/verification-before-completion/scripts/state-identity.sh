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
  --path DIR         Operate on DIR instead of the current directory: enter it
                     first, exactly as if it were the working directory.
  --compare VALUE    Compare the current state against VALUE: the
                     `source.digest` from an earlier run, or with --committed
                     a full revision. Exit 1 on drift.
  --committed        Require a commit that holds the whole state: a born HEAD
                     and no staged, unstaged, or untracked non-ignored path.
                     Otherwise exit 5. A partial commit leaves the digest
                     unchanged, so only this flag proves a commit holds it.
                     Uncommitted content inside a submodule exits 4. Outside
                     any repository no commit can ever hold the state: exit 5.
  --quiet            Print only the source digest, or with --committed HEAD's
                     full revision, one line, no JSON.
  --help             Show this message.

Output:
  JSON on stdout, diagnostics on stderr.

  Inside a git repository: source.digest covers the content the working tree
  presents (tracked and untracked, non-ignored paths, as git would record
  them) plus any staged copy that matches neither HEAD nor the working tree.
  HEAD is not part of it: staging or committing exactly the captured content
  keeps the digest. It does NOT change when only the time or the environment
  changes. Changes inside a submodule count once its checked-out commit
  moves; until they are committed there, no digest reads them and every mode
  exits 4. Paths under .sdlc-skills/evidence/ are left out of the digest, the
  counts, and --committed, so a record written there never moves the
  candidate.
  An edit git hides is content no digest can read: an assume-unchanged entry;
  a skip-worktree entry whose path exists, or is gone outside a sparse
  checkout; a directory holding its own repository, untracked or in place
  of a tracked file (an embedded repository); or a submodule holding
  uncommitted content. While one exists, every mode exits 4 and names each
  path on stderr.

  Outside any git repository (the current directory, or --path DIR, names one
  that is not): source.digest covers every regular file and symbolic link
  under it instead — sorted relative paths and content, each hashed with
  `git hash-object --stdin`, which needs no repository — again leaving out
  .sdlc-skills/evidence/. Records are NUL-delimited before hashing, so no
  path can forge a record boundary and collide two different directory
  states. A symbolic link counts by its own target text, not by what it
  points at, and is never followed; a dangling link is still recorded. The
  JSON carries "repository": "none" and no HEAD fields (no head, branch,
  clean, or uncommitted counts: there is no index to read them from).
  --compare works the same way; --committed always exits 5, since no commit
  can ever hold a state with no repository behind it. A nested
  embedded git repository below this directory (a `.git` directory or file
  under a subdirectory) is refused instead of hashed: exit 4, naming each
  path, the same outcome the in-repository mode gives an embedded repository.

Exit codes:
  0  state captured, or --compare matched
  1  --compare found drift: the evidence does not describe this state
  2  bad arguments (an unknown option, a missing --compare value, a --path
     that is not a directory) or, inside a repository, an unresolvable root
  3  a required tool is missing
  4  a git step failed, or git hides an edit (assume-unchanged, skip-worktree,
     embedded repository, uncommitted submodule content): no digest or
     committed identity, so no evidence binds
  5  --committed found uncommitted content, or ran outside any repository:
     the commit does not hold the captured state

Examples:
  before=$(bash scripts/state-identity.sh --quiet)
  # ... run the gate ...
  bash scripts/state-identity.sh --compare "$before" || echo "source moved; rerun"
  bash scripts/state-identity.sh --path /path/to/deliverable --quiet
EOF
}

compare=""; quiet=0; committed=0; path_arg=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --path) path_arg="${2:-}"; [ -n "$path_arg" ] || { echo "Error: --path needs a value." >&2; exit 2; }; shift 2;;
    --compare) compare="${2:-}"; [ -n "$compare" ] || { echo "Error: --compare needs a value." >&2; exit 2; }; shift 2;;
    --quiet)   quiet=1; shift;;
    --committed) committed=1; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Error: unknown argument \"$1\". Run with --help for usage." >&2; exit 2;;
  esac
done

command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }

if [ -n "$path_arg" ]; then
  [ -d "$path_arg" ] || { echo "Error: --path \"$path_arg\" is not a directory." >&2; exit 2; }
  cd "$path_arg" || { echo "Error: could not enter --path \"$path_arg\"." >&2; exit 2; }
fi

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

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  # Non-repository mode: no git repository governs this directory (the
  # current directory, or --path DIR), so there is no HEAD, index, or commit
  # — only the files themselves. The digest is the sorted set of relative
  # paths, each hashed with `git hash-object --stdin`, the one git command
  # that computes a content hash without needing a repository to hold it.
  if [ "$committed" = 1 ]; then
    echo "Error: outside any repository, so no commit can hold this state." >&2
    exit 5
  fi

  # A directory that is itself a git work tree, nested below this one, is an
  # embedded repository: its .git/ internals are not this directory's content,
  # and hashing them as plain files would fold another repository's private
  # state into the digest. The in-repository path refuses these too
  # (hidden_paths(), below); match that outcome here instead of silently
  # reading inside it. Left out of consideration: anything under
  # .sdlc-skills/evidence/, and the root's own .git (unreachable here, since
  # git would already have taken the in-repository path above).
  nr_embedded="$(find . -path './.sdlc-skills/evidence' -prune -o -name '.git' \( -type d -o -type f \) -print 2>/dev/null |
    LC_ALL=C grep -v '^\./\.git$' | LC_ALL=C sort)"
  if [ -n "$nr_embedded" ]; then
    echo "Error: an embedded git repository exists below this directory, so its content cannot be digested as plain files:" >&2
    printf '%s\n' "$nr_embedded" | sed 's#^\./##' | while IFS= read -r nr_p; do printf '  embedded repository: %s\n' "$nr_p" >&2; done
    exit 4
  fi

  # Each record is type, hash, then path — three NUL-terminated fields — so a
  # path can hold any byte except NUL and '/', and no field can forge a
  # record boundary the way a tab/newline-delimited manifest could (F-1). A
  # regular file ('f') is hashed by its content; a symbolic link ('l') is
  # hashed by its own target text (`readlink`, never the file it resolves
  # to), so a file and a same-content symlink at the same path differ, and
  # retargeting or a dangling target still moves the digest. Links are never
  # followed (no -L): find treats a symlink to a directory as a leaf, the
  # same as any other symlink, not something to descend into.
  nr_manifest="$(mktemp)" || { echo "Error: could not create a temporary file." >&2; exit 4; }
  nr_fail=0
  while IFS= read -r -d '' nr_f; do
    if [ -L "$nr_f" ]; then
      nr_type=l
      nr_target="$(readlink "$nr_f" 2>/dev/null)" && [ -n "$nr_target" ] || { nr_fail=1; break; }
      nr_h="$(printf '%s' "$nr_target" | git hash-object --stdin 2>/dev/null)" && [ -n "$nr_h" ] || { nr_fail=1; break; }
    else
      nr_type=f
      nr_h="$(git hash-object --stdin < "$nr_f" 2>/dev/null)" && [ -n "$nr_h" ] || { nr_fail=1; break; }
    fi
    printf '%s\0%s\0%s\0' "$nr_type" "$nr_h" "${nr_f#./}" >>"$nr_manifest"
  done < <(find . -type d -path './.sdlc-skills/evidence' -prune -o \( -type f -o -type l \) -print0 2>/dev/null | LC_ALL=C sort -z)
  if [ "$nr_fail" = 1 ]; then
    rm -f "$nr_manifest"
    echo "Error: git could not hash a file or symbolic link under $PWD; there is no digest to bind evidence to." >&2
    exit 4
  fi
  digest="$(sha <"$nr_manifest")"
  rm -f "$nr_manifest"
  [ -n "$digest" ] || { echo "Error: could not compute a digest for $PWD." >&2; exit 4; }

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

  printf '{\n'
  printf '  "schema": "state-identity/1",\n'
  printf '  "source": {\n'
  printf '    "digest": %s,\n' "$(jnull "$digest")"
  printf '    "repository": "none",\n'
  printf '    "workspace": %s\n' "$(jnull "$PWD")"
  printf '  },\n'
  printf '  "environment": {\n'
  printf '    "cwd": %s,\n' "$(jnull "$PWD")"
  printf '    "platform": %s,\n' "$(jnull "$(uname -srm 2>/dev/null)")"
  printf '    "captured_at": %s\n' "$(jnull "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)")"
  printf '  }\n'
  printf '}\n'
  exit 0
fi

root="$(git rev-parse --show-toplevel 2>/dev/null)"
# Scope every listing to the whole workspace, not the current directory.
[ -n "$root" ] && cd "$root" || { echo "Error: could not resolve the repository root." >&2; exit 2; }
# Records under .sdlc-skills/evidence/ describe a candidate and never belong to
# it, so the digest and the uncommitted listings leave that directory out. The
# pathspec means what it says whatever pathspec settings the caller exported.
evidence_out=':(exclude).sdlc-skills/evidence'
unset GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS

# Paths whose edits git hides from its own listings and from the digest, as
# kind<TAB>path lines outside .sdlc-skills/evidence/, quoted as git quotes paths.
# Git never reads the working-tree copy of an assume-unchanged entry (a
# lowercase tag), or of a skip-worktree entry (S) whose path exists or, outside
# a sparse checkout, is gone: only a sparse checkout's absent paths are not
# edits. A directory holding its own repository, untracked or where a tracked or
# intent-to-add entry was (a symlink to one is only a symlink), is one entry git
# never reads inside. Listed with fsmonitor off, as the digest is. Fails only
# when git cannot list.
hidden_paths() {
  local hp_index hp_others hp_types hp_subs hp_sparse hp_line hp_path hp_raw
  hp_git() { git --no-optional-locks -c core.quotePath=true -c core.fsmonitor=false "$@"; }
  hp_index="$(hp_git ls-files -v -- . "$evidence_out" 2>/dev/null)" &&
    hp_others="$(hp_git ls-files --others --exclude-standard -- . "$evidence_out" 2>/dev/null)" &&
    hp_types="$(hp_git diff --ignore-submodules=dirty --name-only --diff-filter=AT -- . "$evidence_out" 2>/dev/null)" &&
    hp_subs="$(hp_git ls-files --stage -- . 2>/dev/null | LC_ALL=C awk '$1 == "160000" { sub(/^[0-7]+ [0-9a-f]+ [0-9]+\t/, ""); print }')" ||
    return 1
  hp_sparse="$(git config --bool core.sparseCheckout 2>/dev/null)"
  printf '%s\n' "$hp_index" | LC_ALL=C grep -E '^([a-z]|S) ' | while IFS= read -r hp_line; do
    hp_path="${hp_line#? }"
    case "$hp_line" in
      S\ *)
        hp_raw="$hp_path"
        case "$hp_raw" in \"*) hp_raw="${hp_raw#\"}"; hp_raw="${hp_raw%\"}"; printf -v hp_raw -- "${hp_raw//%/%%}" ;; esac
        if [ -e "$hp_raw" ] || [ -L "$hp_raw" ] || [ "$hp_sparse" != true ]; then printf 'skip-worktree\t%s\n' "$hp_path"; fi ;;
      *) printf 'assume-unchanged\t%s\n' "$hp_path" ;;
    esac
  done
  printf '%s\n' "$hp_others" | LC_ALL=C grep -E '/"?$' | while IFS= read -r hp_line; do
    printf 'embedded repository\t%s\n' "$hp_line"
  done
  printf '%s\n' "$hp_types" | while IFS= read -r hp_line; do
    [ -n "$hp_line" ] || continue
    hp_raw="$hp_line"
    case "$hp_raw" in \"*) hp_raw="${hp_raw#\"}"; hp_raw="${hp_raw%\"}"; printf -v hp_raw -- "${hp_raw//%/%%}" ;; esac
    if [ ! -L "$hp_raw" ] && [ -d "$hp_raw" ] && [ -e "$hp_raw/.git" ]; then printf 'embedded repository\t%s\n' "$hp_line"; fi
  done
  # A submodule is its own repository: the index records the commit its gitlink
  # names, never the working tree inside it, so uncommitted content there is
  # content no digest reads while the gitlink stays put.
  printf '%s\n' "$hp_subs" | while IFS= read -r hp_line; do
    [ -n "$hp_line" ] || continue
    hp_raw="$hp_line"
    case "$hp_raw" in \"*) hp_raw="${hp_raw#\"}"; hp_raw="${hp_raw%\"}"; printf -v hp_raw -- "${hp_raw//%/%%}" ;; esac
    [ -e "$hp_raw/.git" ] || continue
    [ -n "$(hp_git -C "$hp_raw" status --porcelain --ignore-submodules=none 2>/dev/null)" ] &&
      printf 'uncommitted submodule content\t%s\n' "$hp_line"
  done
  return 0
}

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
  cd_git "$cd_tmp/wt.index" add -A >/dev/null 2>&1 &&
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

# An edit git hides passes every check below unseen, so no mode prints an
# identity while one exists.
hidden="$(hidden_paths)" || {
  echo "Error: git could not list the paths whose edits it hides; no identity." >&2; exit 4; }
if [ -n "$hidden" ]; then
  echo "Error: git hides edits to these paths, so no digest or committed identity can hold them:" >&2
  printf '%s\n' "$hidden" | while IFS=$'\t' read -r kind path; do printf '  %s: %s\n' "$kind" "$path" >&2; done
  echo "  Clear the flag (git update-index --no-assume-unchanged or --no-skip-worktree; with core.ignoreStat set, git sets it again on every add), commit, ignore, or move the embedded repository, or commit the submodule's content and the gitlink naming it, then rerun." >&2
  exit 4
fi

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
# --ignore-submodules=untracked is git's default, stated so that no ignore setting
# hides a submodule change from the counts.
staged_n="$(count diff --cached --ignore-submodules=untracked --name-only)" &&
  unstaged_n="$(count diff --ignore-submodules=untracked --name-only)" &&
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
