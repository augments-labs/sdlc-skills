#!/usr/bin/env bash
# Offline test for the diagnosing-a-session trace viewer: the page is a static
# asset that renders an agent-written trace, so everything that keeps
# transcript-derived text inert has to hold in the page itself.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

usage() {
  cat <<'USAGE'
tests/run-trace-viewer.sh — is the trace viewer page safe to feed untrusted text?

  --help    this text

Exit codes: 0 every check passed · N the number of failed checks
            2 a required tool (python3, curl, jq) is missing
USAGE
}
case "${1-}" in -h|--help) usage; exit 0;; esac
for t in python3 curl jq; do command -v "$t" >/dev/null || { echo "needs $t" >&2; exit 2; }; done

fails=0
ok() { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=$((fails + 1)); }

D=skills/maintenance/diagnosing-a-session
page="$D/assets/trace-viewer.html"
ref="$D/references/trace-format.md"

echo "--- the page"
[ -f "$page" ] && ok "the viewer page ships" || { bad "the viewer page ships ($page)"; echo; echo "✗ trace viewer violations found"; exit "$fails"; }

# Transcript-derived text reaches the DOM as text only. Each of these turns a
# string into markup or code.
for sink in 'innerHTML' 'outerHTML' 'insertAdjacentHTML' 'document.write' 'eval(' 'new Function' 'srcdoc' 'javascript:'; do
  if grep -qF "$sink" "$page"; then bad "page never uses $sink"; else ok "page never uses $sink"; fi
done
grep -q 'textContent' "$page" && ok "page writes text through textContent" || bad "page writes text through textContent"

# Text enters through one function, and that function masks what looks like a
# credential. A second writer of trace text would bypass both guarantees.
grep -q 'n.textContent = mask(text)' "$page" && ok "the text writer masks credential-shaped values" || bad "the text writer masks credential-shaped values"
if grep -E 'textContent = ' "$page" | grep -E 'str\(|trace|\.(title|summary|quote|fragment|input|result)' | grep -vq 'mask('; then
  bad "no trace value is written around the mask"; else ok "no trace value is written around the mask"; fi
if grep -E 'Storage\.setItem|document\.cookie|indexedDB' "$page" | grep -vq "setItem('session-trace-theme', name)"; then bad "the page stores no trace content in the browser"; else ok "the page stores no trace content in the browser"; fi

csp="$(grep -o '<meta http-equiv="Content-Security-Policy"[^>]*>' "$page")"
[ -n "$csp" ] && ok "page declares a content security policy" || bad "page declares a content security policy"
case "$csp" in *"default-src 'none'"*) ok "policy denies by default";; *) bad "policy denies by default";; esac
case "$csp" in *"connect-src 'self'"*) ok "policy limits fetches to the preview origin";; *) bad "policy limits fetches to the preview origin";; esac
case "$csp" in *http:*|*https:*|*'*'*) bad "policy names no remote origin";; *) ok "policy names no remote origin";; esac

# Self-contained: no remote script, stylesheet, font, or image.
if grep -qE '(src|href)="(https?:)?//' "$page"; then bad "page loads nothing remote"; else ok "page loads nothing remote"; fi
grep -q "fetch('trace.json'" "$page" && ok "page reads trace.json beside it" || bad "page reads trace.json beside it"
# The page is copied verbatim, never filled: a slot would mean the agent edits markup.
if grep -q '{{' "$page"; then bad "page has no fill-in slot"; else ok "page has no fill-in slot"; fi

echo "--- the documented format"
[ -f "$ref" ] && ok "the trace format is documented" || bad "the trace format is documented ($ref)"
if [ -f "$ref" ]; then
  example="$(awk '/^```json/{f=1;next} /^```/{if(f){exit}} f' "$ref")"
  if printf '%s' "$example" | jq -e '.schema == "session-trace/1" and (.events|type=="array") and (.findings|type=="array")' >/dev/null 2>&1; then
    ok "the documented example is valid JSON with the schema fields"
  else bad "the documented example is valid JSON with the schema fields"; fi
  # A documented field the page never reads is information the user never
  # sees: every field named in the format's tables is one the page renders.
  missing=""
  for f in $(grep -E '^\| `' "$ref" | cut -d'|' -f2 | grep -oE '`[a-z_]+`' | tr -d '`' | sort -u) \
           $(sed -n '/^`stats` counts/,/^$/p' "$ref" | grep -oE '`[a-z_]+`' | tr -d '`' | grep -v '^stats$'); do
    grep -qE "\.$f\b" "$page" || missing="$missing $f"
  done
  [ -z "$missing" ] && ok "the page renders every documented field" || bad "the page renders every documented field (unread:$missing)"
fi

echo "--- served together"
fixture="$(mktemp -d)"; trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/trace"; cp "$page" "$fixture/trace/index.html"
[ -f "$ref" ] && printf '%s' "${example-}" > "$fixture/trace/trace.json"
line="$(bash "$D/scripts/start-server.sh" --root "$fixture/trace" --entry index.html --idle-timeout-minutes 5 2>/dev/null)"
if printf '%s' "$line" | jq -e '.url and .pid' >/dev/null 2>&1; then
  url="$(printf '%s' "$line" | jq -r .url)"; pid="$(printf '%s' "$line" | jq -r .pid)"
  jar="$fixture/jar"
  code="$(curl -s -c "$jar" -o /dev/null -w '%{http_code}' "$url")"
  [ "$code" = 200 ] && ok "the page is served with its key" || bad "the page is served with its key (got $code)"
  origin="$(printf '%s' "$url" | sed -E 's#(https?://[^/]+).*#\1#')"
  ctype="$(curl -s -b "$jar" -o "$fixture/got.json" -w '%{content_type}' "$origin/trace.json")"
  case "$ctype" in application/json*) ok "the trace is served as JSON";; *) bad "the trace is served as JSON (got $ctype)";; esac
  jq -e . "$fixture/got.json" >/dev/null 2>&1 && ok "the served trace parses" || bad "the served trace parses"
  bash "$D/scripts/stop-server.sh" "$pid" >/dev/null 2>&1
else bad "the skill's own start-server.sh starts the preview"; fi

echo
if [ "$fails" -eq 0 ]; then echo "✓ trace viewer passes"; else echo "✗ trace viewer violations found"; fi
exit "$fails"
