#!/usr/bin/env bash
# Open the ledger a subagent-driven run records its dispatches and rulings in,
# or check that it still binds to the plan it was opened against.
#
# Writes only the ledger file. It never touches the plan.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/sdd-workspace.sh --plan DIR [OPTIONS]

Open the ledger a subagent-driven run records its dispatches, rulings, and task
states in, or check that it still binds to the plan it was opened against.

Line 1 carries the identity of the plan index. That line is what a session
resuming after a compaction reads first: if the identity no longer matches, the
run has been following a plan that was amended underneath it, and the rows below
describe a plan that no longer exists.

Options:
  --plan DIR     the plan directory; its index is DIR/00-index.md
  --ledger FILE  use this path instead of DIR/sdd-ledger.md
  --check        compare identities and write nothing
  --help         show this message

Opening is idempotent. An existing ledger is left exactly as it is, so resuming
a run never truncates what an earlier session recorded.

Exit codes:
  0  the ledger is present and bound to this plan
  1  the ledger is missing, or its identity is not the plan's (drift)
  2  bad arguments, no plan index, or the ledger cannot be written
EOF
}

plan=""; ledger=""; check=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --plan)   plan="${2-}"; [ -n "$plan" ] || { echo "--plan needs a directory" >&2; exit 2; }; shift 2;;
    --ledger) ledger="${2-}"; [ -n "$ledger" ] || { echo "--ledger needs a path" >&2; exit 2; }; shift 2;;
    --check)  check=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "unknown argument: $1 (see --help)" >&2; exit 2;;
  esac
done

[ -n "$plan" ] || { echo "--plan is required (see --help)" >&2; exit 2; }
index="$plan/00-index.md"
[ -f "$index" ] || { echo "no plan index at $index" >&2; exit 2; }

# The identity is the plan index's content, hashed the way this library hashes an
# issued artifact. --stdin keeps it working on a plan outside the current repo.
identity="$(git hash-object --stdin < "$index" 2>/dev/null | cut -c1-7)"
[ -n "$identity" ] || { echo "could not compute the identity of $index" >&2; exit 2; }

[ -n "$ledger" ] || ledger="$plan/sdd-ledger.md"

if [ "$check" = 1 ]; then
  [ -f "$ledger" ] || { echo "no ledger at $ledger" >&2; exit 1; }
  case "$(head -1 "$ledger")" in
    *"$identity"*) exit 0;;
    *) echo "ledger $ledger is bound to another revision of the plan; the plan is now $identity" >&2; exit 1;;
  esac
fi

if [ -f "$ledger" ]; then
  case "$(head -1 "$ledger")" in
    *"$identity"*) printf '%s\n' "$ledger"; exit 0;;
    *) echo "ledger $ledger is bound to another revision of the plan; the plan is now $identity" >&2
       printf '%s\n' "$ledger"; exit 1;;
  esac
fi

dir="$(dirname "$ledger")"
mkdir -p "$dir" 2>/dev/null || { echo "cannot create $dir" >&2; exit 2; }
{
  printf '# Subagent-driven run — plan %s, identity %s\n' "$(basename "$plan")" "$identity"
  printf '\n'
  printf 'Append only. One row per dispatch, ruling, and task state. Rulings carry\n'
  printf 'their reason, so the next brief can inherit them and the finish message can\n'
  printf 'list them.\n'
  printf '\n'
  printf '| When | Kind | Task | Detail |\n'
  printf '| --- | --- | --- | --- |\n'
} > "$ledger" || { echo "cannot write $ledger" >&2; exit 2; }
printf '%s\n' "$ledger"
exit 0
