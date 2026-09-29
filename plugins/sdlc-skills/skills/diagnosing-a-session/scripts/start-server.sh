#!/usr/bin/env bash
# Start the governed localhost preview (serve.py) in the background and print
# its one-line JSON startup record. The URL in that record is the one to hand
# to the user: it carries a one-time ?key= that plants a cookie, after which
# plain URLs work in that browser. A request with neither gets 403. Browsers
# scope cookies by host, not port: any other listener on this host that the
# browser visits while the preview runs receives the cookie.
#
# Why a wrapper instead of running serve.py directly: the owner PID must be
# resolved BEFORE backgrounding — once this shell exits, the server re-parents
# and can no longer tell the harness from init — and the nohup + readiness-wait
# sequence is too fragile to improvise per invocation.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<'EOF'
start-server.sh — start the governed localhost preview.

  --root DIR                directory to serve (required); nothing outside it is reachable
  --entry PATH              path the printed URL points at, relative to root
                            (default: index.html when it exists, else /)
  --host HOST               interface to bind (default 127.0.0.1; 0.0.0.0 only
                            for remote/container use, on explicit user request)
  --idle-timeout-minutes N  shut down after N idle minutes (default 240)
  --no-owner-watchdog       disable the owner-process watchdog
  --open                    open the URL in the user's browser (only after the
                            user asked for the preview)
  --help                    this text

Stdout: serve.py's one-line JSON startup record (url, pid, stop). Stderr: the
server log path. Exit codes: 0 started · 1 bad arguments · 2 server failed to
start (no python3, bad root, no free port, or died on launch)
EOF
}

passthrough=() ; root_seen=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root) passthrough+=(--root "$2"); root_seen=1; shift 2;;
    --entry|--host|--idle-timeout-minutes) passthrough+=("$1" "$2"); shift 2;;
    --open|--no-owner-watchdog) passthrough+=("$1"); shift;;
    -h|--help) usage; exit 0;;
    *) echo "{\"error\": \"unknown argument: $1\"}"; exit 1;;
  esac
done
[ -n "$root_seen" ] || { echo '{"error": "needs --root DIR"}'; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo '{"error": "needs python3"}'; exit 2; }

# The harness is this script's grandparent: the agent's shell runs us, and
# that shell dies when its command returns. Resolve while it is alive.
owner_pid="$(ps -o ppid= -p "$PPID" 2>/dev/null | tr -d ' ')"
case "$owner_pid" in ''|*[!0-9]*) owner_pid="" ;; esac
[ "$owner_pid" = "1" ] && owner_pid=""
[ -n "$owner_pid" ] && passthrough+=(--owner-pid "$owner_pid")

log="$(mktemp /tmp/serve-preview.XXXXXX.log)"
nohup python3 "$SCRIPT_DIR/serve.py" "${passthrough[@]}" >"$log" 2>&1 &
server_pid=$!

for _ in $(seq 1 50); do
  line="$(grep -m1 'server-started' "$log" 2>/dev/null)" && break
  grep -m1 '"error"' "$log" 2>/dev/null && break
  kill -0 "$server_pid" 2>/dev/null || break
  sleep 0.1
done

if [ -z "${line:-}" ]; then
  kill "$server_pid" 2>/dev/null
  detail="$(grep -m1 '"error"' "$log" 2>/dev/null)"
  echo "${detail:-{\"error\": \"server failed to start within 5 seconds\"}}"
  echo "log: $log" >&2
  exit 2
fi

echo "$line"
echo "log: $log" >&2
exit 0
