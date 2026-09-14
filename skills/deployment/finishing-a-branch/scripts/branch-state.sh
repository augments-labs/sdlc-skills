#!/usr/bin/env bash
# Bind the local integration state of a candidate branch, as JSON on stdout.
#
# Read-only: this script never writes, fetches, or mutates anything.
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
Read-only — never writes, fetches, or mutates. Run it from inside the
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
    base.resolved        false when the base is ambiguous — integration stops
    head.detached        true when there is no branch to push
    candidate.id         digest over root, branch, HEAD, base, dirty.digest,
                         published, and the unpushed commit count;
                         the discard token, and it changes with any of them
    candidate.commit_count, candidate.unpushed_commit_count, candidate.commits
                         null when base.resolved is false
    candidate.published  true when commits already exist on a remote ref;
                         rewriting them needs separate direct permission
    dirty.*_count        staged / unstaged / untracked, counted separately
    recoverability       what a discard would and would not be able to undo

Not covered: remote/PR state. That needs a forge API, which this script
deliberately does not reach for. Bind PR state separately.

Exit codes:
  0  state reported
  2  not a git repository, or bad arguments
  3  a required tool is missing

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
jbool() { [ "${1:-}" = 1 ] && printf 'true' || printf 'false'; }
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

# --- repository and worktree --------------------------------------------------
root="$(git rev-parse --show-toplevel 2>/dev/null)"
# Every listing below must cover the WHOLE candidate and print repo-relative
# paths. `git ls-files --others` is scoped to the current directory, so running
# from a subdirectory silently reports a subset — which would understate what a
# discard destroys. Move to the root before inspecting anything.
[ -n "$root" ] && cd "$root" || { echo "Error: could not resolve the repository root." >&2; exit 2; }
git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null)"
common_dir="$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)"
# A linked worktree has its own git-dir but shares the common dir. Removing one
# is a different, and differently owned, operation from deleting a branch.
linked=0; [ -n "$common_dir" ] && [ "$git_dir" != "$common_dir" ] && linked=1
bare=0; [ "$(git rev-parse --is-bare-repository 2>/dev/null)" = true ] && bare=1
worktrees="$(git worktree list --porcelain 2>/dev/null | grep -c '^worktree ' || true)"

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
    base="$upstream"; base_source="upstream tracking ref"
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
staged="$(git diff --cached --name-only 2>/dev/null)"
unstaged="$(git diff --name-only 2>/dev/null)"
untracked="$(git ls-files --others --exclude-standard 2>/dev/null)"
staged_n="$(printf '%s\n' "$staged" | count_lines)"
unstaged_n="$(printf '%s\n' "$unstaged" | count_lines)"
untracked_n="$(printf '%s\n' "$untracked" | count_lines)"
clean=0; [ "$staged_n" = 0 ] && [ "$unstaged_n" = 0 ] && [ "$untracked_n" = 0 ] && clean=1

# Working-tree digest: HEAD tree + full diff against HEAD + untracked content
# and names. Two runs agree only if the source actually matches, which is what
# binds evidence to a candidate.
digest="$( { git rev-parse 'HEAD^{tree}' 2>/dev/null
             git diff HEAD --binary 2>/dev/null
             git status --porcelain -uall 2>/dev/null
             git ls-files --others --exclude-standard -z 2>/dev/null \
               | xargs -0 -r git hash-object 2>/dev/null
           } | sha )"

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

# Published: are the candidate's commits already on a remote-tracking ref?
# This is what makes a rewrite unsafe, and it is not the same question as
# "does the branch have an upstream".
published=0
if [ -n "$head_sha" ]; then
  if [ -n "$(git branch -r --contains HEAD 2>/dev/null | head -1)" ]; then published=1; fi
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

# The discard token: any change to what a discard would destroy changes it.
cand_id="$(printf '%s\n' "$root" "$branch" "$head_sha" "$base" "$base_sha" "$digest" "$published" "$unpushed_n" | sha)"

stashes="$(git stash list 2>/dev/null | count_lines)"

# --- recoverability -----------------------------------------------------------
# Untracked content is never recoverable by git; committed-and-pushed work
# always is; committed-but-unpushed work is reflog-only and time-limited.
untracked_lost=0; [ "$untracked_n" -gt 0 ] && untracked_lost=1
uncommitted_lost=0; { [ "$staged_n" -gt 0 ] || [ "$unstaged_n" -gt 0 ]; } && uncommitted_lost=1

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
printf '    "staged_count": %s, "unstaged_count": %s, "untracked_count": %s,\n' \
  "$staged_n" "$unstaged_n" "$untracked_n"
printf '    "staged": %s,\n'    "$(printf '%s\n' "$staged"    | jarray)"
printf '    "unstaged": %s,\n'  "$(printf '%s\n' "$unstaged"  | jarray)"
printf '    "untracked": %s\n'  "$(printf '%s\n' "$untracked" | jarray)"
printf '  },\n'
printf '  "candidate": {\n'
printf '    "id": %s,\n' "$(jstr "$cand_id")"
printf '    "commit_count": %s, "published": %s, "unpushed_commit_count": %s,\n' \
  "$commits_n" "$(jbool $published)" "$unpushed_n"
printf '    "commits": %s\n' "$commits_json"
printf '  },\n'
printf '  "recoverability": {\n'
printf '    "stash_entries": %s,\n' "${stashes:-0}"
printf '    "untracked_would_be_lost": %s,\n' "$(jbool $untracked_lost)"
printf '    "uncommitted_would_be_lost": %s,\n' "$(jbool $uncommitted_lost)"
printf '    "commits_recoverable_from_remote": %s\n' "$(jbool $published)"
printf '  },\n'
printf '  "listing_limit": %s\n' "$limit"
printf '}\n'

[ "$limit" -gt 0 ] && {
  for pair in "staged:$staged_n" "unstaged:$unstaged_n" "untracked:$untracked_n" "commits:$commits_n"; do
    case "${pair##*:}" in ''|*[!0-9]*) continue;; esac
    [ "${pair##*:}" -gt "$limit" ] && \
      echo "note: ${pair%%:*} listing truncated to $limit of ${pair##*:}; the count is exact. Use --full for all." >&2
  done
}
exit 0
