#!/usr/bin/env bash
# Offline test for the Hermes Agent plugin adapter.
#
# What this guards: register() must register every canonical skill under its
# bare name with a non-empty description, and must contribute the canonical
# router body as system-prompt sections — rendered by Hermes once per session
# and after compression, never per turn — each within Hermes' per-section cap,
# in an order that reads the router in sequence. Mirrors
# tests/run-pi-extension.sh, through the plugin's own register() with a stub
# context, since Hermes calls Python, not scripts.
#
# Deterministic on purpose: registration and section logic get a unit check.
# Whether the injected router changes behaviour on a live Hermes session is
# not claimed here.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'HELP'
tests/run-hermes-plugin.sh — offline unit check for the Hermes adapter.

Takes no arguments; loads .hermes-plugin/__init__.py in Python with a stub
context whose register_* methods record their calls, and checks skill
registration and the router's system-prompt sections.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
            3 python3 is unavailable
HELP
    exit 0;;
esac

PLUGIN=.hermes-plugin/__init__.py
ROUTER=skills/common/using-sdlc-skills/SKILL.md
fails=0
ok()   { echo "  ok    $1"; }
bad()  { echo "  FAIL  $1"; fails=1; }

command -v python3 >/dev/null 2>&1 || { echo "needs \`python3\`" >&2; exit 3; }
[ -f "$PLUGIN" ] || { bad "missing $PLUGIN (nothing registers the skills or injects the router)"; echo "---"; echo "hermes plugin offline tests: FAIL"; exit 1; }
[ -f "$ROUTER" ] || { bad "missing canonical router $ROUTER"; echo "---"; echo "hermes plugin offline tests: FAIL"; exit 1; }

# The canonical side, computed in shell so the check does not share the
# plugin's parsing: skill names from the tree, router body with only the
# leading frontmatter stripped (as scripts/sh/session-start.sh strips it).
canonical_names="$(find skills -name SKILL.md -printf '%h\n' | sed 's|.*/||' | sort)"
router_body="$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$ROUTER")"

# Drive the plugin's real register() and router sections with a stub context; report one
# line per check as `ok <label>` or `bad <label> (<detail>)`.
results="$(CANONICAL_NAMES="$canonical_names" ROUTER_BODY="$router_body" python3 -I -B - "$PLUGIN" <<'PY'
import importlib.util, os, re, sys
from pathlib import Path

def report(passed, label, detail=""):
    print(("ok " if passed else "bad ") + label + (f" ({detail})" if detail and not passed else ""))

try:
    spec = importlib.util.spec_from_file_location("sdlc_skills_hermes", sys.argv[1])
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    class Ctx:
        def __init__(self):
            self.skills, self.hooks, self.sections = [], {}, []
        def register_skill(self, name, path, description=""):
            self.skills.append((name, Path(path), description))
        def register_hook(self, event, callback):
            self.hooks.setdefault(event, []).append(callback)
        def register_system_prompt_section(self, id, content, **_):
            self.sections.append((id, content))

    ctx = Ctx()
    module.register(ctx)

    canonical = sorted(os.environ["CANONICAL_NAMES"].split())
    names = sorted(name for name, _, _ in ctx.skills)
    missing = sorted(set(canonical) - set(names))
    extra = sorted(set(names) - set(canonical))
    report(names == canonical, f"registers exactly the {len(canonical)} canonical skills",
           f"missing={missing} extra={extra} duplicates={len(names) - len(set(names))}")
    # Hermes refuses a name with ':' or outside [A-Za-z0-9_-] (it qualifies it as sdlc-skills:<name>).
    invalid = [n for n in names if not re.fullmatch(r"[A-Za-z0-9_-]+", n)]
    report(not invalid, "every skill name is one Hermes accepts", ",".join(invalid))
    unreal = [n for n, p, _ in ctx.skills if p.name != "SKILL.md" or p.parent.name != n or not p.is_file()]
    report(not unreal, "every registered path is that skill's own SKILL.md", ",".join(unreal))
    blank = [n for n, _, d in ctx.skills if not d.strip()]
    report(not blank, "every skill carries its frontmatter description", ",".join(blank))

    # The repo binds no per-turn hook: the router rides the system prompt instead.
    report(not ctx.hooks, "registers no hook (nothing runs per turn)", ",".join(sorted(ctx.hooks)))

    info = {"session_id": "s", "model": "m", "provider": "p", "platform": "cli", "profile_name": "default", "cwd": "."}
    ids = [i for i, _ in ctx.sections]
    report(bool(ids) and all(re.fullmatch(r"sdlc-skills\.router-[0-9]+", i) for i in ids),
           "registers router sections under the sdlc-skills namespace", ",".join(ids))
    # Hermes renders sections sorted by id, so the order the router reads in is the sorted-id order.
    ordered = [text for _, text in sorted(ctx.sections, key=lambda s: s[0])]
    ordered = [text(info) if callable(text) else text for text in ordered]
    report([i for i, _ in sorted(ctx.sections)] == ids, "section ids sort in reading order", ",".join(ids))
    # Hermes skips, whole, a section over 4,000 characters, and all plugins share 8,000.
    sizes = [len(text.strip()) for text in ordered]
    report(sizes and max(sizes) <= 4000, "every section fits Hermes' per-section cap", str(sizes))
    # The shared budget counts each section as Hermes frames it in the prompt: a
    # heading and a length comment above the text, a blank line between
    # sections, and one start and one end marker around them all.
    framed = len("<!-- hermes-plugin-sections:start -->") + len("<!-- hermes-plugin-sections:end -->") + 2
    framed += sum(len(f"## Plugin Context: {i}\n<!-- hermes-plugin-section-chars:{n} -->\n\n") + n
                  for i, n in zip(sorted(ids), sizes)) + 2 * (len(sizes) - 1)
    report(framed <= 8000, "the framed sections fit the budget all plugins share", str(framed))
    joined = "\n".join(ordered)
    body = os.environ["ROUTER_BODY"].strip()
    blocks = [b.strip() for b in ("\n" + body).split("\n## ") if b.strip()]
    lost = [b.splitlines()[0][:40] for b in blocks if b not in joined]
    report(bool(blocks) and not lost, "the sections carry the canonical router body verbatim", ",".join(lost))
    report("ALREADY LOADED" in ordered[0] if ordered else False, "the first section says the router is already loaded")
    report('skill_view(name="sdlc-skills:' in joined, "the sections name Hermes' skill-loading call")
except Exception as exc:
    report(False, "plugin loads and registers", f"{type(exc).__name__}: {exc}")
PY
)"

while IFS= read -r line; do
  case "$line" in
    ok\ *)  ok "${line#ok }";;
    bad\ *) bad "${line#bad }";;
  esac
done <<<"$results"

echo "---"
if [ "$fails" -eq 0 ]; then echo "hermes plugin offline tests: PASS"; else echo "hermes plugin offline tests: FAIL"; exit 1; fi
