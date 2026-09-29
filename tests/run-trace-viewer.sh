#!/usr/bin/env bash
# Offline test for the diagnosing-a-session trace viewer: the page is a static
# asset that renders an agent-written trace, so everything that keeps
# transcript-derived text inert has to hold in the page itself.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

usage() {
  cat <<'USAGE'
tests/run-trace-viewer.sh — is the trace viewer page safe to feed untrusted text, and does it play?

  --help    this text

Three layers. The source checks need python3, curl and jq. The mask and
syntax checks also need node. The behaviour checks also need a headless
Chrome or Chromium. A missing node or browser skips its layer and says so;
with CI set in the environment a skipped layer is a failure.

Exit codes: 0 every check that ran passed · N the number of failed checks
            2 a required tool (python3, curl, jq) is missing
USAGE
}
case "${1-}" in -h|--help) usage; exit 0;; esac
for t in python3 curl jq; do command -v "$t" >/dev/null || { echo "needs $t" >&2; exit 2; }; done

fails=0
ok() { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=$((fails + 1)); }
skip() { if [ -n "${CI-}" ]; then bad "$1 (not available, and CI is set)"; else echo "  skip  $1"; fi; }

D=skills/maintenance/diagnosing-a-session
page="$D/assets/trace-viewer.html"
ref="$D/references/trace-format.md"
fixture="$(mktemp -d)"
pid=""
cleanup() { [ -n "$pid" ] && bash "$D/scripts/stop-server.sh" "$pid" >/dev/null 2>&1; rm -rf "$fixture"; }
trap cleanup EXIT

echo "--- the page source"
[ -f "$page" ] && ok "the viewer page ships" || { bad "the viewer page ships ($page)"; echo; echo "✗ trace viewer violations found"; exit "$fails"; }

# Transcript-derived text reaches the DOM as text only. Each of these turns a
# string into markup or code, or writes text around the one masked writer.
for sink in 'innerHTML' 'outerHTML' 'insertAdjacentHTML' 'document.write' 'eval(' 'new Function' 'srcdoc' 'javascript:' \
            'createContextualFragment' 'DOMParser' 'createTextNode' 'innerText' "setAttribute('on" 'setAttribute("on' "['inner" '["inner' \
            'new Image' 'sendBeacon' 'XMLHttpRequest' 'WebSocket' 'EventSource' 'window.open' 'importScripts'; do
  if grep -qF -- "$sink" "$page"; then bad "page never uses $sink"; else ok "page never uses $sink"; fi
done
[ "$(grep -c 'fetch(' "$page")" = 1 ] && grep -q "fetch('trace.json'" "$page" && ok "the page fetches trace.json and nothing else" || bad "the page fetches trace.json and nothing else"

# Every assignment of text either goes through mask() or writes a value the
# page computed itself: a label, a count, a clock time.
unmasked="$(grep -nE '\.(textContent|title)[[:space:]]*=[^=]' "$page" | grep -v 'mask(' |
  grep -vE "=[[:space:]]*(text|name === 'light'|n \? plural|p < 0 \? 'overview'|a \? clock|z \? clock|\(shown === |'[A-Za-z ]*'|state\.playing \?)" || true)"
[ -z "$unmasked" ] && ok "no text is written around the mask" || bad "no text is written around the mask: $unmasked"

want="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; connect-src 'self'; base-uri 'none'; form-action 'none'"
got="$(grep -o '<meta http-equiv="Content-Security-Policy" content="[^"]*"' "$page" | sed 's/.*content="//; s/"$//')"
[ "$got" = "$want" ] && ok "the content security policy is exactly the expected one" || bad "the content security policy is exactly the expected one (got: $got)"

if grep -qiE "(src|href)[[:space:]]*=[[:space:]]*[\"']?(https?:)?//" "$page"; then bad "page loads nothing remote"; else ok "page loads nothing remote"; fi
if grep -q '{{' "$page"; then bad "page has no fill-in slot"; else ok "page has no fill-in slot"; fi
if grep -E 'Storage\.setItem|Storage\[|document\.cookie|indexedDB' "$page" | grep -vq "setItem('session-trace-theme', name)"; then
  bad "the page stores no trace content in the browser"; else ok "the page stores no trace content in the browser"; fi

echo "--- the documented format"
[ -f "$ref" ] && ok "the trace format is documented" || bad "the trace format is documented ($ref)"
example=""
if [ -f "$ref" ]; then
  example="$(awk '/^```json/{f=1;next} /^```/{if(f){exit}} f' "$ref")"
  if printf '%s' "$example" | jq -e '.schema == "session-trace/1" and (.events|type=="array") and (.findings|type=="array")' >/dev/null 2>&1; then
    ok "the documented example is valid JSON with the schema fields"
  else bad "the documented example is valid JSON with the schema fields"; fi
  # A documented field the page never reads is information the user never
  # sees: every field named in the format's tables is one the page reads.
  missing=""
  for f in $(grep -E '^\| `' "$ref" | cut -d'|' -f2 | grep -oE '`[a-z_]+`' | tr -d '`' | sort -u) \
           $(sed -n '/^`stats` counts/,/^$/p' "$ref" | grep -oE '`[a-z_]+`' | tr -d '`' | grep -v '^stats$'); do
    grep -qE "\.$f\b" "$page" || missing="$missing $f"
  done
  [ -z "$missing" ] && ok "the page reads every documented field" || bad "the page reads every documented field (unread:$missing)"
fi

echo "--- the script and the mask"
if command -v node >/dev/null; then
  awk '/^<script>$/{f=1;next} /^<\/script>$/{f=0} f' "$page" > "$fixture/page.js"
  node --check "$fixture/page.js" 2>"$fixture/syntax.log" && ok "the page script parses" || bad "the page script parses: $(head -3 "$fixture/syntax.log")"
  { echo "var LIMIT = 20000;"; awk '/\/\* mask:start \*\//{f=1;next} /\/\* mask:end \*\//{f=0} f' "$page"; cat <<'JS'
var hide = [
  'ghp_' + 'A1b2C3d4E5f6G7h8I9j0K1l2M3n4', 'sk-' + 'test1234567890abcdefXYZ', 'AKIA' + 'ABCDEFGHIJKLMNOP',
  'password=hunter2', 'password: "s3cret!"', 'pwd=abc123', 'passphrase: correct-horse-9', 'api key: abcd1234efgh',
  'Authorization: Bearer abcdefghijklmnop123456', 'Authorization: Basic dXNlcjpwYXNzd29yZA==', 'Cookie: sid=9f8e7d6c5b4a',
  'postgres://admin:' + 's3cret@w0rd@db.internal/app', 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abcdefghijk',
  'npm_' + 'abcdefghijklmnopqrstuvwxyz0123456789', 'http://127.0.0.1:1/index.html?key=' + 'f9913b10d53b121873aa28ef80ed144e',
  '-----BEGIN RSA PRIVATE KEY-----\nMIIEow\n-----END RSA PRIVATE KEY-----'
];
var secretPart = [/A1b2C3d4/, /test1234567890/, /ABCDEFGHIJKLMNOP/, /hunter2/, /s3cret!/, /abc123/, /correct-horse/, /abcd1234efgh/,
  /abcdefghijklmnop123456/, /dXNlcjpwYXNz/, /9f8e7d6c/, /s3cret@w0rd/, /eyJzdWIi/, /abcdefghijklmnopqrstuvwxyz0123456789/, /f9913b10d53b/, /MIIEow/];
var keep = [
  'skipped password authentication checks', 'Ran token verification before the push', 'wrote skills/auth/authorization-middleware.ts',
  '/home/me/project/secret/configuration.yaml', 'src/auth/session-handler.ts', 'skills/security/secret-scanning/SKILL.md',
  'authentication_failed', 'tokenization_strategy', 'passenger_manifest.json', 'pass --no-verify-hooks', 'api_key_rotation_policy',
  'compass directions-and-more-things', 'commit 4b825dc642cb6eb9a060e54bf8d69288fbee4904', 'git push -u origin fix/login',
  'The token: none was set', 'b92ab436-8bc9-4f1a-93c7-dd8cd8833e6f.jsonl:3121', 'Loads requesting-code-review, for the first time'
];
var failed = 0;
hide.forEach(function (v, i) { var m = mask('ran with ' + v + ' today'); if (secretPart[i].test(m) || m.indexOf('[masked]') < 0) { failed++; console.log('shown: ' + JSON.stringify(v.slice(0, 18)) + ' -> ' + JSON.stringify(m.slice(0, 60))); } });
keep.forEach(function (v) { if (mask(v) !== v) { failed++; console.log('hidden: ' + JSON.stringify(v) + ' -> ' + JSON.stringify(mask(v))); } });
['auth' + new Array(100001).join(' '), new Array(30000).join('token ') + new Array(50000).join(' '), new Array(50000).join('a.') , 'x://' + new Array(100000).join('a:')].forEach(function (v, i) {
  var t = Date.now(); mask(v); var ms = Date.now() - t;
  if (ms > 1000) { failed++; console.log('slow: hostile input ' + i + ' took ' + ms + ' ms'); }
});
if (mask(new Array(50000).join('x')).length > 20200) { failed++; console.log('long: an overlong value is not cut'); }
process.exit(failed ? 1 : 0);
JS
  } > "$fixture/mask.js"
  out="$(node "$fixture/mask.js" 2>&1)" && ok "the mask hides credential shapes, keeps ordinary text, and stays fast" || bad "the mask hides credential shapes, keeps ordinary text, and stays fast: $out"
else
  skip "the page script parses, and the mask behaves (needs node)"
fi

echo "--- served together"
mkdir -p "$fixture/plain" "$fixture/hostile" "$fixture/loop" "$fixture/broken"
for d in plain hostile loop broken; do cp "$page" "$fixture/$d/index.html"; done
printf '%s' "$example" > "$fixture/plain/trace.json"
python3 - "$fixture" <<'PY'
import json, sys
root = sys.argv[1]
payload = "<img src=x onerror=alert(1)><script>document.title='PWNED'</script>"
cred = "ghp_" + "A1b2C3d4E5f6G7h8I9j0K1l2M3n4"
ev = [dict(id="e%d" % i, line=i + 1, time="2026-01-01T00:0%d:00Z" % i, kind="prompt" if i == 0 else payload, status=payload,
           thread="main", title="T%d %s %s" % (i, payload, cred), summary=payload + cred, quote=(payload + cred) if i == 0 else None,
           fragment=cred, input=payload, result=cred, files=[payload, {"x": 1}], related=[None, {"event": "e0", "relation": payload}])
      for i in range(4)]
json.dump(dict(schema="session-trace/1", headline=payload + cred, session=dict(which=payload, transcript="/x/" + cred + ".jsonl", symptom=cred, expected=payload),
               stats="nope", events=ev + [None, 7, "text"],
               findings=[None, dict(id=payload, dimension=payload, statement=cred, shows=payload, consequence=cred,
                                    evidence=[None, dict(line=1, fragment=cred)], steps=[dict(event="e0", note=cred), dict(event="e2", note=payload), None])],
               dimensions=[None, dict(name=payload, searched_with=cred, result=payload)], unavailable=[cred, None], notes=[payload], next_action=cred),
          open(root + "/hostile/trace.json", "w"))
ev = [dict(id="e%d" % i, line=i + 1, time="2026-01-01T00:0%d:00Z" % i, kind="tool", title="step %d" % i) for i in range(4)]
ev.append(dict(id="e1", line=9, kind="tool", title="a second event with the id e1"))
json.dump(dict(schema="session-trace/1", headline="loop", session=dict(which="loop"), events=ev,
               findings=[dict(id="1", dimension="Ordering", statement="repeats", evidence=[dict(line=1)],
                              steps=[dict(event="e1"), dict(event="e2"), dict(event="e1"), dict(event="e3")])]),
          open(root + "/loop/trace.json", "w"))
open(root + "/broken/trace.json", "w").write('{"schema": "session-trace/1", "events": [')
PY
line="$(bash "$D/scripts/start-server.sh" --root "$fixture" --entry plain/index.html --idle-timeout-minutes 5 2>/dev/null)"
if printf '%s' "$line" | jq -e '.url and .pid' >/dev/null 2>&1; then
  url="$(printf '%s' "$line" | jq -r .url)"; pid="$(printf '%s' "$line" | jq -r .pid)"
  origin="$(printf '%s' "$url" | sed -E 's#(https?://[^/]+).*#\1#')"; key="${url#*\?}"
  jar="$fixture/jar"
  code="$(curl -s -c "$jar" -o /dev/null -w '%{http_code}' "$url")"
  [ "$code" = 200 ] && ok "the page is served with its key" || bad "the page is served with its key (got $code)"
  ctype="$(curl -s -b "$jar" -o "$fixture/got.json" -w '%{content_type}' "$origin/plain/trace.json")"
  case "$ctype" in application/json*) ok "the trace is served as JSON";; *) bad "the trace is served as JSON (got $ctype)";; esac
  jq -e . "$fixture/got.json" >/dev/null 2>&1 && ok "the served trace parses" || bad "the served trace parses"
  code="$(curl -s -o /dev/null -w '%{http_code}' "$origin/plain/trace.json")"
  [ "$code" = 403 ] && ok "the trace is refused without the key" || bad "the trace is refused without the key (got $code)"

  echo "--- behaviour in a browser"
  chrome=""
  for c in google-chrome google-chrome-stable chromium chromium-browser; do command -v "$c" >/dev/null && { chrome="$c"; break; }; done
  if [ -n "$chrome" ]; then
    dom() { # $1 directory, $2 hash, $3 virtual milliseconds
      timeout 120 "$chrome" --headless=new --disable-gpu --no-sandbox --user-data-dir="$fixture/profile" \
        --virtual-time-budget="$3" --dump-dom "$origin/$1/index.html?$key$2" 2>/dev/null
    }
    has() { grep -qE -- "$2" <<<"$1"; }
    d="$(dom plain '' 3000)"
    has "$d" 'id="detail"' && has "$d" 'The agent pushed before the review' && ok "the documented example renders its headline" || bad "the documented example renders its headline"
    has "$d" '<svg class="g"' && ok "the transport icons are drawn" || bad "the transport icons are drawn"
    d="$(dom plain '#finding=1&play=1' 1500)"
    has "$d" 'aria-label="Pause"' && has "$d" 'step 1 of 2' && ok "a replay starts at step 1 and shows Pause" || bad "a replay starts at step 1 and shows Pause"
    d="$(dom plain '#finding=1&play=1' 12000)"
    has "$d" 'aria-label="Play"' && has "$d" 'step 2 of 2' && ok "a replay reaches the last step and stops" || bad "a replay reaches the last step and stops"
    has "$d" 'Why this step matters' && ok "a step shows why it matters" || bad "a step shows why it matters"
    d="$(dom loop '#finding=1&play=1' 30000)"
    has "$d" 'aria-label="Play"' && has "$d" 'step 4 of 4' && ok "a finding that repeats an event still ends" || bad "a finding that repeats an event still ends"
    has "$d" 'used more than once' || d2="$(dom loop '' 3000)"
    has "${d2-$d}" 'used more than once' && ok "a repeated event id is reported on the page" || bad "a repeated event id is reported on the page"
    d="$(dom plain '#event=%E0%A4%A&finding=%' 3000)"
    has "$d" 'The agent pushed before the review' && ok "a malformed link still shows the overview" || bad "a malformed link still shows the overview"
    d="$(dom broken '' 3000)"
    has "$d" '<main[^>]*><p class="fail">trace.json is not valid JSON' && ok "a trace that does not parse is reported as such" || bad "a trace that does not parse is reported as such"
    mkdir -p "$fixture/none"; cp "$page" "$fixture/none/index.html"
    d="$(dom none '' 3000)"
    has "$d" '<main[^>]*><p class="fail">trace.json could not be read' && ok "a missing trace is reported as such" || bad "a missing trace is reported as such"
    leaks=0
    for h in '' '#finding=2' '#finding=2&step=1' '#event=1' '#event=3' '#event=2&tab=flow'; do
      d="$(dom hostile "$h" 3000)"
      has "$d" 'id="detail"' || { bad "the hostile trace renders at '$h'"; continue; }
      has "$d" '<img|<script>document|<title>[^<]*PWNED| onerror="' && { bad "hostile text stays text at '$h'"; leaks=1; }
      has "$d" 'A1b2C3d4E5f6' && { bad "a credential-shaped value is masked at '$h'"; leaks=1; }
      grep -qE 'img|onerror|script' <<<"$(grep -oE 'class="[^"]*"' <<<"$d")" && { bad "no class name comes from the trace at '$h'"; leaks=1; }
    done
    [ "$leaks" = 0 ] && ok "hostile text stays text, and credential shapes are masked, in six states"
    d="$(dom hostile '#finding=2&step=1' 3000)"
    has "$d" '\[masked\]' && ok "the mask leaves its mark where it hid something" || bad "the mask leaves its mark where it hid something"
  else
    skip "behaviour in a browser (needs a headless Chrome or Chromium)"
  fi
else bad "the skill's own start-server.sh starts the preview"; fi

echo
if [ "$fails" -eq 0 ]; then echo "✓ trace viewer passes"; else echo "✗ trace viewer violations found"; fi
exit "$fails"
