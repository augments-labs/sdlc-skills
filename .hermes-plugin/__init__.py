"""Hermes Agent adapter for SDLC skills.

Two jobs. Discovery: register every canonical skills/<phase>/<name>/SKILL.md
as a plugin skill, so Hermes lists it as sdlc-skills:<name> in skills_list and
the system prompt's skill index. Routing: contribute the using-sdlc-skills
router to the system prompt as plugin prompt sections.

Sections, not a hook: Hermes renders plugin sections once per session and
again after every context compression, which is exactly the epoch cadence the
router needs — a pre_llm_call hook would run on every turn instead. Hermes caps
one section at 4,000 characters, below the router's length, so the router is
split at its own headings into as many sections as it takes; they render in id
order, so the agent reads it in sequence.

The router is READ from the canonical skill at runtime, never copied here, so
editing the skill cannot silently stop shipping.
"""

from pathlib import Path

NAMESPACE = "sdlc-skills"
ROUTER = Path("common") / "using-sdlc-skills" / "SKILL.md"
# Hermes skips, whole, any section longer than this.
SECTION_MAX_CHARS = 4000


def _skills_root():
    root = Path(__file__).resolve().parent.parent / "skills"
    # Fail loudly: a silent empty registration stops routing and nothing
    # observes it.
    if not (root / ROUTER).is_file():
        raise FileNotFoundError(f"sdlc-skills: no router at {root / ROUTER}")
    return root


def _split_frontmatter(text):
    """Return (frontmatter lines, body). Only a leading --- block is frontmatter."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return [], text
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            return lines[1:index], "\n".join(lines[index + 1:])
    return [], text


def _description(frontmatter):
    """Read a one-line or folded `description:` value without a YAML parser."""
    for index, line in enumerate(frontmatter):
        if not line.startswith("description:"):
            continue
        value = line[len("description:"):].strip()
        if value in ("|", ">", "|-", ">-", ""):
            parts = []
            for follow in frontmatter[index + 1:]:
                if follow and not follow[0].isspace():
                    break
                parts.append(follow.strip())
            value = " ".join(part for part in parts if part)
        return value.strip().strip("'\"")
    return ""


def skill_files(root):
    return sorted(root.rglob("SKILL.md"))


def router_context(root):
    _, body = _split_frontmatter((root / ROUTER).read_text(encoding="utf-8"))
    body = body.strip()
    if not body:
        raise ValueError(f"sdlc-skills: router body is empty ({root / ROUTER})")
    return f"""<EXTREMELY_IMPORTANT>
# SDLC skills

The full `using-sdlc-skills` entry skill follows. It is ALREADY LOADED — apply
it directly and do not spend a tool call re-invoking it. Every skill in the
catalogue is listed with its trigger in your skill index as
`{NAMESPACE}:<name>`; invoke a skill by calling
`skill_view(name="{NAMESPACE}:<name>")`, since reading a skill file is not
invoking it. Each loaded skill's own preconditions, skips, and handoffs are
the routing authority — follow them.

Apply this before any answer or action, including questions and exploration,
and before any tool that begins the work.

{body}
</EXTREMELY_IMPORTANT>"""


def router_sections(root, limit=SECTION_MAX_CHARS):
    """Split the router context at its `## ` headings into parts of at most limit chars."""
    parts, current = [], ""
    for block in router_context(root).split("\n## "):
        piece = block if not current and not parts else "## " + block
        candidate = f"{current}\n{piece}" if current else piece
        if len(candidate.strip()) <= limit:
            current = candidate
            continue
        if not current or len(piece.strip()) > limit:
            raise ValueError(f"sdlc-skills: a router part exceeds {limit} chars; split it at a heading")
        parts.append(current.strip())
        current = piece
    parts.append(current.strip())
    return parts


def register(ctx):
    root = _skills_root()
    for skill_md in skill_files(root):
        frontmatter, _ = _split_frontmatter(skill_md.read_text(encoding="utf-8"))
        ctx.register_skill(skill_md.parent.name, skill_md, description=_description(frontmatter))

    # Each section reads the router when it renders, once per session and after
    # compression, so an edit reaches the next session without reinstalling.
    # The number of sections is fixed here, when Hermes loads the plugin: an
    # edit that changes it takes effect after Hermes restarts.
    count = len(router_sections(root))
    for index in range(count):
        ctx.register_system_prompt_section(
            f"{NAMESPACE}.router-{index + 1:02d}",  # zero-padded: Hermes sorts by id
            lambda _info, index=index: router_sections(root)[index],
        )
