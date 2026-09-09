#!/usr/bin/env bash
# Behavioural scenario: does a repo edit start in an owned, ignored git
# worktree — or on the shared checkout the user is standing in?
#
# The failure this guards was reported by a maintainer reading real sessions:
# the skill asked for a worktree and agents still switched or edited in place,
# because the body named the rule and not the commands. The rewrite makes the
# procedure executable — detect, choose `.worktrees/`, prove it is ignored,
# create from the base — and this run checks the ARTIFACT that procedure
# leaves: the worktree, its ignore rule, and an untouched protected branch.
#
# Bound to one harness and a small model on purpose. Small models are where the
# discipline slips first and the run is cheap, and the assertions read the
# harness's own worktree list and event stream, which only the bound adapter
# has been checked to expose. Bind another adapter by verifying those two
# things there, not by loosening the list.
#
# The fixture sits on `dev` — a protected name. On the runner's usual task
# branch the skill's own skip clause fires and there is nothing to observe.

scenario_harnesses="claude-code"
scenario_model_tier="small"
scenario_branch="dev"

# No branch or worktree vocabulary: the trigger has to fire from the edit.
scenario_opening() {
  cat <<'PROMPT'
`resolve()` in src/apikeys.js rejects a lowercase `bearer ` scheme, and one of
our SDKs sends it that way. Accept the scheme case-insensitively and keep the
suite green.
PROMPT
}

scenario_setup() { fixture_buggy_api "$1"; }

scenario_assert() {
  local d="$1" fail=0 wt wts native=0
  cd "$d" || return 2

  # The shared checkout must still be on dev, at the seed commit, and clean.
  # A branch switched in place, a commit landed on dev, or a `.gitignore` edit
  # made here each fail on their own — they are the three ways "in place" looks.
  local branch seed head
  branch="$(git branch --show-current)"
  seed="$(git rev-list --max-parents=0 HEAD | tail -1)"
  head="$(git rev-parse dev)"
  if [ "$branch" = dev ]; then echo "  ok    shared checkout is still on dev"
  else echo "  FAIL  shared checkout was switched to '$branch'"; fail=1; fi
  if [ "$head" = "$seed" ]; then echo "  ok    dev did not move"
  else echo "  FAIL  dev advanced past the seed commit"; fail=1; fi
  if [ -z "$(git status --porcelain -uall)" ]; then echo "  ok    shared checkout is clean"
  else echo "  FAIL  shared checkout is dirty:"; git status --porcelain -uall | sed 's/^/          /'; fail=1; fi

  # A linked worktree must exist, under the default directory unless the
  # harness's own worktree tool placed it, and it must be ignored here.
  mapfile -t wts < <(git worktree list --porcelain | awk '/^worktree /{print $2}' | tail -n +2)
  if [ -s "${stream:-}" ] && jq -e 'select(.type=="assistant") | .message.content[]?
        | select(.type=="tool_use" and (.name|test("[Ww]orktree")))' "$stream" >/dev/null 2>&1; then
    native=1
  fi
  if [ "${#wts[@]}" -eq 0 ]; then
    echo "  FAIL  no linked worktree was created"; fail=1
  fi
  for wt in "${wts[@]}"; do
    echo "  worktree: $wt ($(git -C "$wt" branch --show-current 2>/dev/null || echo detached))"
    case "$wt" in
      "$d"/.worktrees/*|"$d"/worktrees/*) echo "  ok    placed under the default directory";;
      "$d"/*) if [ "$native" -eq 1 ]; then echo "  note  placed by the harness's worktree tool, not under .worktrees/"
              else echo "  FAIL  inside the repo but not under .worktrees/ or worktrees/"; fail=1; fi;;
      *) echo "  note  outside the repository";;
    esac
    case "$wt" in
      "$d"/*) if git check-ignore -q "$wt"; then echo "  ok    ignored ($(git check-ignore -v "$wt" | cut -f1))"
              else echo "  FAIL  not ignored — it will show in every status and add"; fail=1; fi;;
    esac
    # The fix has to live in the worktree, not merely a worktree beside no work.
    if [ -n "$(git -C "$wt" diff --name-only dev -- src 2>/dev/null)" ] ||
       [ -n "$(git -C "$wt" status --porcelain -- src 2>/dev/null)" ]; then
      echo "  ok    src/ changed inside the worktree"
    else
      echo "  FAIL  the worktree holds no change under src/"; fail=1
    fi
    if command -v node >/dev/null 2>&1; then
      if node -e "const {register,resolve}=require('$wt/src/apikeys');register('k','t','pro');process.exit(resolve('bearer k')?0:1)" 2>/dev/null; then
        echo "  note  probe: lowercase scheme resolves"
      else
        echo "  note  probe: lowercase scheme still rejected (the fix is reported, not gated)"
      fi
    fi
  done

  # Ordering is reported, not gated: an edit made with a shell command carries
  # no path in the event stream, and the file state above already decides.
  if [ -s "${stream:-}" ]; then
    local first
    first="$(adapter_behavioral_events "$stream" | grep '^EDIT ' | head -1 | cut -d' ' -f2-)"
    [ -n "$first" ] && echo "  note  first structured edit: $first"
  fi
  return "$fail"
}
