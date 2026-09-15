#!/usr/bin/env python3
"""Governed localhost preview for skill-emitted pages.

Serves one directory over HTTP on 127.0.0.1 with a per-session key, an
owner-process watchdog, and an idle timeout, so a preview never outlives
the session that asked for it. Python 3 standard library only.

The printed URL carries a one-time ?key=; the first authorized load
plants an HttpOnly cookie, after which plain URLs keep working in that
browser. Any other local process gets 403.

Start it backgrounded and read the one-line JSON startup record:

    nohup python3 serve.py --root .sdlc-skills > /tmp/serve.log 2>&1 &

Stop it with the kill command from that record, or let the watchdog or
idle timeout end it. Options: --help
"""

import argparse
import hmac
import http.server
import json
import os
import secrets
import signal
import subprocess
import sys
import threading
import time
import urllib.parse
import webbrowser

MIME = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css",
    ".js": "text/javascript",
    ".json": "application/json",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".gif": "image/gif",
    ".svg": "image/svg+xml",
    ".webp": "image/webp",
    ".ico": "image/x-icon",
    ".woff2": "font/woff2",
    ".txt": "text/plain; charset=utf-8",
    ".md": "text/markdown; charset=utf-8",
}

FORBIDDEN = (
    "<!DOCTYPE html><html><head><meta charset='utf-8'>"
    "<title>Session key required</title></head><body>"
    "<h1>Session key required</h1><p>Open the full URL your agent gave you, "
    "including the <code>?key=…</code> part. It plants a cookie; plain URLs "
    "work afterwards in that browser.</p></body></html>"
)


def resolve_owner_pid():
    """The harness is this process's grandparent: the agent's shell runs us,
    and the shell dies when its command returns. Resolve while it is alive.
    Returns None where ps is unavailable — the idle timeout is then the only
    shutdown trigger."""
    try:
        parent = os.getppid()
        out = subprocess.run(
            ["ps", "-o", "ppid=", "-p", str(parent)],
            capture_output=True, text=True, timeout=5,
        )
        pid = int(out.stdout.strip())
        return pid if pid > 1 else None
    except (OSError, ValueError, subprocess.SubprocessError):
        return None


def owner_alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False
    except (PermissionError, OSError):
        return True  # exists but not ours to signal — treat as alive


class PreviewServer(http.server.ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, host, port, root, entry, token, idle_s, owner_pid):
        self.root = root
        self.token = token
        self.idle_s = idle_s
        self.owner_pid = owner_pid
        self.last_activity = time.monotonic()
        self.cookie_name = "serve-key-%d" % port
        self.url = "http://%s:%d/%s?key=%s" % (host, port, entry, token)
        self.shutdown_reason = "unknown"
        super().__init__((host, port), PreviewHandler)


class PreviewHandler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):  # quiet: the agent reads JSON records
        pass

    def key_matches(self):
        query = urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
        key = query.get("key", [""])[0]
        return bool(key) and hmac.compare_digest(key, self.server.token)

    def authorized(self):
        if self.key_matches():
            return True
        cookie = self.headers.get("Cookie", "")
        for part in cookie.split(";"):
            name, _, value = part.strip().partition("=")
            if name == self.server.cookie_name and value:
                return hmac.compare_digest(value, self.server.token)
        return False

    def send_headers(self, status, content_type, length):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(length))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("X-Content-Type-Options", "nosniff")
        # SAMEORIGIN, not DENY: the viewer page iframes sibling visuals and
        # both are served from this one origin.
        self.send_header("X-Frame-Options", "SAMEORIGIN")
        self.send_header("Content-Security-Policy", "frame-ancestors 'self'")
        # Plant the session cookie only for a request that carried the valid
        # key. A refusal or any other keyless response never hands it out.
        if self.key_matches():
            self.send_header(
                "Set-Cookie",
                "%s=%s; HttpOnly; SameSite=Strict; Path=/"
                % (self.server.cookie_name, self.server.token),
            )
        self.end_headers()

    def refuse(self):
        body = FORBIDDEN.encode()
        self.send_headers(403, "text/html; charset=utf-8", len(body))
        if self.command != "HEAD":
            self.wfile.write(body)

    def resolve(self, raw_path):
        """Map a request path to a file under root, or None. Rejects
        traversal, dotfile segments, and symlink escapes."""
        path = urllib.parse.unquote(urllib.parse.urlsplit(raw_path).path)
        segments = [s for s in path.split("/") if s and s != "."]
        if any(s == ".." or s.startswith(".") for s in segments):
            return None
        candidate = os.path.join(self.server.root, *segments)
        if os.path.isdir(candidate):
            candidate = os.path.join(candidate, "index.html")
        try:
            real = os.path.realpath(candidate)
            root_real = os.path.realpath(self.server.root)
        except OSError:
            return None
        if real != root_real and not real.startswith(root_real + os.sep):
            return None
        if not os.path.isfile(real):
            return None
        return real

    def do_GET(self):
        self.handle_request()

    def do_HEAD(self):
        self.handle_request()

    def handle_request(self):
        if not self.authorized():
            self.refuse()
            return
        self.server.last_activity = time.monotonic()
        real = self.resolve(self.path)
        if real is None:
            body = b"Not found"
            self.send_headers(404, "text/plain; charset=utf-8", len(body))
            if self.command != "HEAD":
                self.wfile.write(body)
            return
        try:
            with open(real, "rb") as f:
                body = f.read()
        except OSError:
            body = b"Not found"
            self.send_headers(404, "text/plain; charset=utf-8", len(body))
            if self.command != "HEAD":
                self.wfile.write(body)
            return
        ext = os.path.splitext(real)[1].lower()
        self.send_headers(200, MIME.get(ext, "application/octet-stream"), len(body))
        if self.command != "HEAD":
            self.wfile.write(body)


def watchdog(server):
    while True:
        time.sleep(30)
        if server.owner_pid is not None and not owner_alive(server.owner_pid):
            server.shutdown_reason = "owner process exited"
            server.shutdown()
            return
        if time.monotonic() - server.last_activity > server.idle_s:
            server.shutdown_reason = "idle timeout"
            server.shutdown()
            return


def main():
    parser = argparse.ArgumentParser(
        description="Serve one directory on 127.0.0.1 with a per-session key, "
                    "an owner watchdog, and an idle timeout. Prints a one-line "
                    "JSON startup record with the URL to hand to the user.",
        epilog="Exit codes: 0 served until stopped (kill, watchdog, or idle "
               "timeout) · 1 bad arguments, missing root directory, or no "
               "free high port.",
    )
    parser.add_argument("--root", required=True,
                        help="directory to serve; nothing outside it is reachable")
    parser.add_argument("--entry", default=None,
                        help="path the printed URL points at, relative to root "
                             "(default: index.html when it exists, else /)")
    parser.add_argument("--host", default="127.0.0.1",
                        help="interface to bind (default 127.0.0.1; 0.0.0.0 only "
                             "for remote/container use, on explicit user request)")
    parser.add_argument("--idle-timeout-minutes", type=int, default=240,
                        help="shut down after this many minutes without an "
                             "authorized request (default 240)")
    parser.add_argument("--no-owner-watchdog", action="store_true",
                        help="disable the owner-process watchdog; the idle "
                             "timeout remains the shutdown trigger")
    parser.add_argument("--owner-pid", type=int, default=None,
                        help="process whose death stops the server. start-server.sh "
                             "passes this, resolved before backgrounding; run "
                             "directly, the calling harness is resolved instead")
    parser.add_argument("--open", action="store_true",
                        help="open the URL in the user's browser once started "
                             "(only after the user asked for the preview)")
    args = parser.parse_args()

    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        print(json.dumps({"error": "no such directory: %s" % args.root}))
        return 1
    if args.idle_timeout_minutes < 1:
        print(json.dumps({"error": "--idle-timeout-minutes must be >= 1"}))
        return 1

    if args.entry is not None:
        entry = args.entry.lstrip("/")
    elif os.path.isfile(os.path.join(root, "index.html")):
        entry = "index.html"
    else:
        entry = ""

    if args.no_owner_watchdog:
        owner_pid = None
    elif args.owner_pid is not None:
        owner_pid = args.owner_pid
    else:
        owner_pid = resolve_owner_pid()
    token = secrets.token_hex(32)

    server = None
    for _ in range(5):
        port = 49152 + secrets.randbelow(16383)
        try:
            server = PreviewServer(args.host, port, root, entry, token,
                                   args.idle_timeout_minutes * 60, owner_pid)
            break
        except OSError:
            continue
    if server is None:
        print(json.dumps({"error": "no free high port after 5 attempts"}))
        return 1

    record = {
        "type": "server-started",
        "url": server.url,
        "root": root,
        "pid": os.getpid(),
        "idle_timeout_minutes": args.idle_timeout_minutes,
        "owner_watchdog": owner_pid is not None,
        "stop": "kill %d" % os.getpid(),
    }
    print(json.dumps(record), flush=True)

    # shutdown() deadlocks when called from the serve thread, which is where a
    # signal handler runs — hand it to a fresh thread so `kill` exits cleanly.
    def _sigterm(_signum, _frame):
        server.shutdown_reason = "stopped (SIGTERM)"
        threading.Thread(target=server.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, _sigterm)

    if args.open:
        threading.Timer(0.3, lambda: webbrowser.open(server.url)).start()

    watcher = threading.Thread(target=watchdog, args=(server,), daemon=True)
    watcher.start()
    try:
        server.serve_forever()
    finally:
        server.server_close()
        print(json.dumps({"type": "server-stopped",
                          "reason": server.shutdown_reason}), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
