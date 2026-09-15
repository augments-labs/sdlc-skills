#!/usr/bin/env bash
# Stop a serve.py preview by PID. Refuses to signal a process that is not the
# preview this directory's serve.py runs: a recorded PID can be reused by an
# innocent process between the preview's death and a late stop, and another
# directory's serve.py is not this preview.
set -uo pipefail

case "${1-}" in
  -h|--help)
    cat <<'EOF'
stop-server.sh — stop a governed localhost preview.

  stop-server.sh PID    stop the serve.py process with this PID
  --help                this text

Exit codes: 0 stopped, or already gone · 1 PID is not this directory's
serve.py preview (refused) · 2 bad arguments
EOF
    exit 0;;
esac

pid="${1-}"
case "$pid" in ''|*[!0-9]*) echo '{"error": "needs a numeric PID"}' >&2; exit 2;; esac

if ! kill -0 "$pid" 2>/dev/null; then
  echo "{\"type\": \"server-stopped\", \"pid\": $pid, \"note\": \"already gone\"}"
  exit 0
fi

# start-server.sh launches python3 "$SCRIPT_DIR/serve.py", so a preview's
# command line holds that absolute path as a whole argument.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cmd="$(ps -ww -p "$pid" -o command= 2>/dev/null)"
case " $cmd " in
  *" $SCRIPT_DIR/serve.py "*) ;;
  *) echo "{\"error\": \"PID $pid is not this directory's serve.py preview — refusing to kill it\"}" >&2; exit 1;;
esac

kill "$pid" 2>/dev/null
for _ in $(seq 1 50); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
if kill -0 "$pid" 2>/dev/null; then
  echo "{\"error\": \"PID $pid did not exit after SIGTERM\"}" >&2
  exit 1
fi
echo "{\"type\": \"server-stopped\", \"pid\": $pid}"
exit 0
