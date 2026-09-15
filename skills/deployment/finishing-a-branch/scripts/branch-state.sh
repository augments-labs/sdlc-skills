#!/usr/bin/env bash
# Bind the local integration state of a candidate branch, as JSON on stdout.
#
# Read-only for repository files, refs, and the index: it never fetches, commits,
# or changes them. Git may refresh the timestamps of objects it already holds.
#
# It exists because the menu and the discard block in SKILL.md interpolate
# facts — unique commits, uncommitted inventory, worktree ownership, whether
# history is published, whether a discard is recoverable — that an agent
# otherwise re-derives with ad-hoc git commands on every run. A miscount there
# is not a cosmetic error: it prints a destructive confirmation that understates
# what the user is about to lose.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/branch-state.sh [OPTIONS]

Report the local git integration state of the current candidate as JSON.
Read-only for repository files, refs, and the index. Run it from inside the
repository whose branch is being finished.

Options:
  --base REF     Compare against REF instead of the detected base.
  --limit N      Cap each file/commit list at N entries (default: 50).
                 Counts are exact when known; only the listings are capped.
  --full         No cap on listings. May produce large output.
  --help         Show this message.

Output:
  JSON on stdout, diagnostics on stderr. Every list is accompanied by an
  exact count, so a truncated listing never understates the real total. A
  count the script cannot compute is null, never 0.

  Key fields:
    base.resolved        false when the base is ambiguous, or would be the branch's
                         own upstream (feature → origin/feature) — integration stops
    head.detached        true when there is no branch to push
    candidate.id         digest over root, branch, HEAD, base, base sha, dirty.digest,
                         the ignored listing, published, and the unpushed commit
                         count; the discard token, and it changes with any of them.
                         null, with exit 4, when git hides an edit
    candidate.commit_count, candidate.unpushed_commit_count, candidate.commits
                         null when base.resolved is false
    candidate.published  true when HEAD or any candidate commit is on a remote
                         ref; null when base.resolved is false, remote refs
                         exist, and HEAD is on none. true or null: rewriting
                         needs separate direct permission. Read from local
                         remote-tracking refs: a stale or single-branch clone
                         can report false for pushed commits
    dirty.*_count        staged / unstaged / untracked / ignored, counted separately.
                         An assume-unchanged or skip-worktree path whose edits
                         git hides counts as unstaged
    dirty.digest         state-identity.sh's source.digest, or null when git hides
                         an edit. It, the counts, and dirty.clean leave
                         .sdlc-skills/evidence/ out
    dirty.ignored        ignored entries as git lists them (git ls-files --others
                         --ignored --exclude-standard --directory), plus every
                         file under .sdlc-skills/evidence/ that git does not
                         ignore, capped like the other listings. A directory
                         whose content is all ignored is one entry, and a change
                         inside it leaves candidate.id unchanged. Removing their
                         worktree destroys them
    recoverability       what a discard would and would not be able to undo;
                         ignored_would_be_lost is true when any ignored path
                         exists; commits_recoverable_from_remote is true only when
                         HEAD, and so every candidate commit, is on a remote ref

Not covered: remote/PR state. That needs a forge API, which this script
deliberately does not reach for. Bind PR state separately. Nor is content
inside a submodule: git refuses to remove a worktree holding one without --force.

Exit codes:
  0  state reported
  2  not a git repository, or bad arguments
  3  a required tool is missing
  4  git could not record or list the working tree, so candidate.id cannot
     be computed and nothing prints; or git hides an edit (an assume-unchanged
     entry, a skip-worktree entry whose path exists or, outside a sparse
     checkout, is gone, or an embedded repository), so the JSON prints with
     dirty.clean false and dirty.digest and candidate.id null, and stderr
     names each path

Examples:
  bash scripts/branch-state.sh
  bash scripts/branch-state.sh --base origin/main
  bash scripts/branch-state.sh --full
EOF
}

base_override=""; limit=50
while [ "$#" -gt 0 ]; do
  case "$1" in
    --base)  base_override="${2:-}"; [ -n "$base_override" ] || { echo "Error: --base needs a ref." >&2; exit 2; }; shift 2;;
    --limit) limit="${2:-}"; case "$limit" in ''|*[!0-9]*) echo "Error: --limit must be a non-negative integer. Received: \"${2:-}\"" >&2; exit 2;; esac; shift 2;;
    --full)  limit=0; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Error: unknown argument \"$1\". Run with --help for usage." >&2; exit 2;;
  esac
done

command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }
git rev-parse --git-dir >/dev/null 2>&1 || {
  echo "Error: not inside a git repository. Run this from the candidate's working tree." >&2; exit 2; }

# Digest helper — sha256sum on GNU, shasum on BSD/macOS.
if command -v sha256sum >/dev/null 2>&1; then sha() { sha256sum | cut -c1-16; }
elif command -v shasum  >/dev/null 2>&1; then sha() { shasum -a 256 | cut -c1-16; }
else sha() { cksum | tr -d ' ' | cut -c1-16; }
fi

# --- JSON emitters ------------------------------------------------------------
# Hand-rolled because this library ships zero dependencies; jq is not assumed.
jstr() { # escape one string as a JSON scalar
  local s="${1-}"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"
  s="${s//	/\\t}"
  s="${s//$'\r'/\\r}"; s="${s//$'\n'/\\n}"
  printf '"%s"' "$s"
}
jbool() { case "${1:-}" in 1) printf 'true';; null) printf 'null';; *) printf 'false';; esac; }
jnull() { [ -n "${1-}" ] && jstr "$1" || printf 'null'; }

# Emit a JSON array from newline-delimited stdin, honouring $limit.
jarray() {
  local first=1 n=0 line
  printf '['
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    n=$((n + 1))
    if [ "$limit" -gt 0 ] && [ "$n" -gt "$limit" ]; then continue; fi
    [ "$first" = 1 ] || printf ', '
    first=0
    jstr "$line"
  done
  printf ']'
}

count_lines() { grep -c . 2>/dev/null || true; }

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
  local hp_index hp_others hp_types hp_sparse hp_line hp_path hp_raw
  hp_git() { git --no-optional-locks -c core.quotePath=true -c core.fsmonitor=false "$@"; }
  hp_index="$(hp_git ls-files -v -- . "$evidence_out" 2>/dev/null)" &&
    hp_others="$(hp_git ls-files --others --exclude-standard -- . "$evidence_out" 2>/dev/null)" &&
    hp_types="$(hp_git diff --ignore-submodules=dirty --name-only --diff-filter=AT -- . "$evidence_out" 2>/dev/null)" ||
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
  return 0
}

# --- repository and worktree --------------------------------------------------
root="$(git rev-parse --show-toplevel 2>/dev/null)"
# Every listing below must cover the WHOLE candidate and print repo-relative
# paths. `git --no-optional-locks ls-files --others` is scoped to the current directory, so running
# from a subdirectory silently reports a subset — which would understate what a
# discard destroys. Move to the root before inspecting anything.
[ -n "$root" ] && cd "$root" || { echo "Error: could not resolve the repository root." >&2; exit 2; }
# Records under .sdlc-skills/evidence/ describe a candidate and never belong to
# it, so the digest and the uncommitted listings leave that directory out. The
# pathspec means what it says whatever pathspec settings the caller exported.
evidence_out=':(exclude).sdlc-skills/evidence'
unset GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS
git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null)"
common_dir="$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)"
# A linked worktree has its own git-dir but shares the common dir. Removing one
# is a different, and differently owned, operation from deleting a branch.
linked=0; [ -n "$common_dir" ] && [ "$git_dir" != "$common_dir" ] && linked=1
bare=0; [ "$(git rev-parse --is-bare-repository 2>/dev/null)" = true ] && bare=1
worktrees="$(git --no-optional-locks worktree list --porcelain 2>/dev/null | grep -c '^worktree ' || true)"

# --- HEAD ---------------------------------------------------------------------
detached=0
branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" || true
[ -n "$branch" ] || detached=1
head_sha="$(git rev-parse HEAD 2>/dev/null)" || head_sha=""
head_short="$(git rev-parse --short HEAD 2>/dev/null)" || head_short=""
unborn=0; [ -n "$head_sha" ] || unborn=1

upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)" || upstream=""

# --- base resolution ----------------------------------------------------------
# Order: explicit flag, then the remote's own default branch, then upstream's
# remote. Guessing "main" is exactly the failure this replaces, so an
# unresolvable base is reported as unresolved rather than assumed.
base=""; base_source=""
if [ -n "$base_override" ]; then
  base="$base_override"; base_source="--base flag"
else
  remote_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" || remote_head=""
  if [ -n "$remote_head" ]; then
    base="$remote_head"; base_source="origin/HEAD"
  elif [ -n "$upstream" ]; then
    # A branch's own upstream (feature → origin/feature) holds its own pushed
    # commits, not its base: counting base..HEAD against it reads pushed history
    # as unpublished. Only an upstream naming another branch is a base.
    upstream_merge="$(git config --get "branch.$branch.merge" 2>/dev/null)" || upstream_merge=""
    if [ -n "$branch" ] && [ "${upstream_merge#refs/heads/}" = "$branch" ]; then
      base_source="upstream tracking ref (the branch's own upstream)"
    else
      base="$upstream"; base_source="upstream tracking ref"
    fi
  fi
fi
base_sha=""; base_resolved=0
if [ -n "$base" ] && base_sha="$(git rev-parse --verify "$base^{commit}" 2>/dev/null)"; then
  base_resolved=1
else
  [ -n "$base" ] && base_source="$base_source (unresolvable)"
  base_sha=""
fi
same_as_base=0
[ "$base_resolved" = 1 ] && [ -n "$head_sha" ] && [ "$base_sha" = "$head_sha" ] && same_as_base=1

merge_base=""
[ "$base_resolved" = 1 ] && [ -n "$head_sha" ] && \
  merge_base="$(git merge-base HEAD "$base_sha" 2>/dev/null)" || true

ahead=""; behind=""
if [ -n "$upstream" ]; then
  counts="$(git rev-list --left-right --count "HEAD...$upstream" 2>/dev/null)" || counts=""
  if [ -n "$counts" ]; then ahead="${counts%%	*}"; behind="${counts##*	}"; fi
fi

# --- working tree -------------------------------------------------------------
# A listing git cannot produce stops the script: an empty one would read as clean.
# Evidence records leave the three listings, but a discard destroys the ones git
# does not ignore, so they join the ignored listing below. --ignore-submodules=untracked
# is git's default, stated so that no ignore setting hides a submodule change.
staged="$(git --no-optional-locks diff --cached --ignore-submodules=untracked --name-only -- . "$evidence_out" 2>/dev/null)" &&
  unstaged="$(git --no-optional-locks diff --ignore-submodules=untracked --name-only -- . "$evidence_out" 2>/dev/null)" &&
  untracked="$(git --no-optional-locks ls-files --others --exclude-standard -- . "$evidence_out" 2>/dev/null)" &&
  evidence="$( { git --no-optional-locks diff --cached --name-only -- .sdlc-skills/evidence &&
    git --no-optional-locks ls-files --others --modified --exclude-standard -- .sdlc-skills/evidence; } 2>/dev/null | LC_ALL=C sort -u)" || {
  echo "Error: git could not list uncommitted paths; candidate.id cannot be computed." >&2; exit 4; }
# Ignored content never shows as untracked, yet a discard or a worktree removal
# destroys it: local secrets, build output, uncommitted evidence records.
ignored="$(git --no-optional-locks ls-files --others --ignored --exclude-standard --directory 2>/dev/null)" || {
  echo "Error: git could not list ignored paths; candidate.id cannot be computed." >&2; exit 4; }
[ -z "$evidence" ] || ignored="$(printf '%s\n' "$evidence" "$ignored" | grep -v '^$')"
staged_n="$(printf '%s\n' "$staged" | count_lines)"
unstaged_n="$(printf '%s\n' "$unstaged" | count_lines)"
untracked_n="$(printf '%s\n' "$untracked" | count_lines)"
ignored_n="$(printf '%s\n' "$ignored" | count_lines)"
clean=0; [ "$staged_n" = 0 ] && [ "$unstaged_n" = 0 ] && [ "$untracked_n" = 0 ] && clean=1
# An edit git hides reaches none of the listings above, yet a discard destroys
# it. Its path counts as unstaged (an embedded repository is already listed),
# the state is not clean, and no digest or discard token is computed below.
hidden="$(hidden_paths)" || {
  echo "Error: git could not list the paths whose edits it hides; candidate.id cannot be computed." >&2; exit 4; }
if [ -n "$hidden" ]; then
  flagged="$(printf '%s\n' "$hidden" | awk -F'\t' '$1 != "embedded repository" { print $2 }')"
  if [ -n "$flagged" ]; then
    unstaged="$(printf '%s\n' "$unstaged" "$flagged" | LC_ALL=C grep -v '^$')"
    unstaged_n="$(printf '%s\n' "$unstaged" | LC_ALL=C grep -c .)"
  fi
  clean=0
fi

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

# The same digest state-identity.sh prints as source.digest: two runs agree only
# if the content matches, which is what binds evidence to a candidate. None is
# computed while git hides an edit.
digest=""
[ -n "$hidden" ] || digest="$(content_digest)" || {
  echo "Error: git could not record the working tree (try \`git add -A --dry-run\`); candidate.id cannot be computed." >&2; exit 4; }

# --- candidate commits --------------------------------------------------------
# With no resolved base there is nothing to count against: report null, never
# 0, so a discard block cannot present "no unique commits" it never computed.
commits=""; commits_n=null; commits_json=null
if [ "$base_resolved" = 1 ]; then
  commits_n=0; commits_json='[]'
  if [ -n "$head_sha" ]; then
    commits="$(git log --format='%h %s' "$base_sha..HEAD" 2>/dev/null)"
    commits_n="$(printf '%s\n' "$commits" | count_lines)"
    commits_json="$(printf '%s\n' "$commits" | jarray)"
  fi
fi

# Commits unique to this candidate and on NO remote ref — the ones a discard
# would actually destroy.
unpushed_n=null
if [ "$base_resolved" = 1 ]; then
  unpushed_n=0
  if [ "$commits_n" -gt 0 ]; then
    unpushed_n="$(git rev-list "$base_sha..HEAD" --not --remotes 2>/dev/null | count_lines)"
  fi
fi

# Published: is ANY candidate commit already on a remote-tracking ref? One is
# enough to make a rewrite unsafe, and it is not the same question as "does the
# branch have an upstream". The tip alone cannot answer it: after a push and a
# local commit, the tip is on no remote ref while the commits below it are.
# With no resolved base the candidate's commits are unknown, so a tip on no
# remote ref reports null while any remote-tracking ref exists.
# A tip on a remote ref carries every candidate commit with it; that is the only
# case in which recovery from the remote is claimed.
head_on_remote=0; published=0
if [ -n "$head_sha" ]; then
  [ -n "$(git --no-optional-locks branch -r --contains HEAD 2>/dev/null | head -1)" ] && head_on_remote=1
  if [ "$head_on_remote" = 1 ]; then
    published=1
  elif [ "$base_resolved" = 1 ]; then
    [ "$unpushed_n" -lt "$commits_n" ] && published=1
  elif [ -n "$(git --no-optional-locks for-each-ref --count=1 refs/remotes 2>/dev/null)" ]; then
    published=null
  fi
fi

# The discard token: any change to what a discard would destroy changes it. None
# binds content git hides.
cand_id=""
[ -n "$hidden" ] || cand_id="$(printf '%s\n' "$root" "$branch" "$head_sha" "$base" "$base_sha" "$digest" "$ignored" "$published" "$unpushed_n" | sha)"

stashes="$(git --no-optional-locks stash list 2>/dev/null | count_lines)"

# --- recoverability -----------------------------------------------------------
# Untracked content is never recoverable by git; committed-and-pushed work
# always is; committed-but-unpushed work is reflog-only and time-limited.
untracked_lost=0; [ "$untracked_n" -gt 0 ] && untracked_lost=1
ignored_lost=0; [ "$ignored_n" -gt 0 ] && ignored_lost=1
uncommitted_lost=0; { [ "$staged_n" -gt 0 ] || [ "$unstaged_n" -gt 0 ]; } && uncommitted_lost=1
[ -z "$hidden" ] || uncommitted_lost=1

# --- emit ---------------------------------------------------------------------
printf '{\n'
printf '  "schema": "branch-state/1",\n'
printf '  "repo": { "root": %s, "git_dir": %s, "linked_worktree": %s, "bare": %s, "worktrees": %s },\n' \
  "$(jnull "$root")" "$(jnull "$git_dir")" "$(jbool $linked)" "$(jbool $bare)" "${worktrees:-0}"
printf '  "head": { "detached": %s, "unborn": %s, "branch": %s, "sha": %s, "short": %s },\n' \
  "$(jbool $detached)" "$(jbool $unborn)" "$(jnull "$branch")" "$(jnull "$head_sha")" "$(jnull "$head_short")"
printf '  "upstream": { "ref": %s, "ahead": %s, "behind": %s },\n' \
  "$(jnull "$upstream")" "${ahead:-null}" "${behind:-null}"
printf '  "base": { "ref": %s, "sha": %s, "source": %s, "resolved": %s, "merge_base": %s, "head_equals_base": %s },\n' \
  "$(jnull "$base")" "$(jnull "$base_sha")" "$(jnull "$base_source")" \
  "$(jbool $base_resolved)" "$(jnull "$merge_base")" "$(jbool $same_as_base)"
printf '  "dirty": {\n'
printf '    "clean": %s, "digest": %s,\n' "$(jbool $clean)" "$(jnull "$digest")"
printf '    "staged_count": %s, "unstaged_count": %s, "untracked_count": %s, "ignored_count": %s,\n' \
  "$staged_n" "$unstaged_n" "$untracked_n" "$ignored_n"
printf '    "staged": %s,\n'    "$(printf '%s\n' "$staged"    | jarray)"
printf '    "unstaged": %s,\n'  "$(printf '%s\n' "$unstaged"  | jarray)"
printf '    "untracked": %s,\n' "$(printf '%s\n' "$untracked" | jarray)"
printf '    "ignored": %s\n'    "$(printf '%s\n' "$ignored"   | jarray)"
printf '  },\n'
printf '  "candidate": {\n'
printf '    "id": %s,\n' "$(jnull "$cand_id")"
printf '    "commit_count": %s, "published": %s, "unpushed_commit_count": %s,\n' \
  "$commits_n" "$(jbool $published)" "$unpushed_n"
printf '    "commits": %s\n' "$commits_json"
printf '  },\n'
printf '  "recoverability": {\n'
printf '    "stash_entries": %s,\n' "${stashes:-0}"
printf '    "untracked_would_be_lost": %s,\n' "$(jbool $untracked_lost)"
printf '    "ignored_would_be_lost": %s,\n' "$(jbool $ignored_lost)"
printf '    "uncommitted_would_be_lost": %s,\n' "$(jbool $uncommitted_lost)"
printf '    "commits_recoverable_from_remote": %s\n' "$(jbool $head_on_remote)"
printf '  },\n'
printf '  "listing_limit": %s\n' "$limit"
printf '}\n'

[ "$limit" -gt 0 ] && {
  for pair in "staged:$staged_n" "unstaged:$unstaged_n" "untracked:$untracked_n" "ignored:$ignored_n" "commits:$commits_n"; do
    case "${pair##*:}" in ''|*[!0-9]*) continue;; esac
    [ "${pair##*:}" -gt "$limit" ] && \
      echo "note: ${pair%%:*} listing truncated to $limit of ${pair##*:}; the count is exact. Use --full for all." >&2
  done
}
if [ -n "$hidden" ]; then
  echo "Error: git hides edits to these paths, so dirty.digest and candidate.id are null and no discard token binds this state:" >&2
  printf '%s\n' "$hidden" | while IFS=$'\t' read -r kind path; do printf '  %s: %s\n' "$kind" "$path" >&2; done
  echo "  Clear the flag (git update-index --no-assume-unchanged or --no-skip-worktree; with core.ignoreStat set, git sets it again on every add), or commit, ignore, or move the embedded repository, then rerun." >&2
  exit 4
fi
exit 0
