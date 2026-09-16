---
name: writing-skills
description: "Writes and edits the skills in this library: the SKILL.md format, descriptions, Gotchas, support files, and the proof that a skill changes what an agent does. Use when adding a skill, changing or fixing one, or when a skill is not triggering. Skip using a skill."
---

# Writing Skills

Write the minimum guidance that changes behavior. Reuse a current body already
in context and load supporting material only when needed.

## When to use

- Creating or editing a skill under `skills/<phase>/<name>/`.
- **Skip** when you're *using* a skill — this is only for authoring.

## Skill types

Match the form to the need. Read `references/reference.md` when unsure how much detail a form needs:

- **Instruction** — a prose procedure. Most skills.
- **Template** — ships a `{{placeholder}}` file the agent copies when it produces that document.
- **Script** — bundles a tested, deterministic script when prose would be error-prone.
- **Reference** — a doc loaded on demand for lookup; large is fine, it isn't always-loaded.

## The format (non-negotiable)

1. **Frontmatter**: `name` (kebab-case, matches the directory) and `description`.
   The [Agent Skills specification](https://agentskills.io/specification) lists
   every field. The description says what the skill does and when to use it, in
   the user's words, with the keywords an agent matches a task on — 1 to 1,024
   characters, no word cap, no `Fires on` list, no summary of the steps. Quote
   it. A description that still carries a `Fires on` list predates this rule;
   rewrite it to this shape when you edit that skill.
2. **House limits: at most 500 body lines and under 5000 estimated tokens.**
   These enforce the concise-body recommendations. Most capability skills land
   near 80–120 lines; a body past ~200 should justify itself. Intent + procedure only; cut
   marketing ("why this matters") and long worked examples.

   Aim under the target by **removing content**, never by compressing prose.
   Dropping articles and verbs until a sentence reads as a noun stack — `Bind
   exact source/contracts/external inputs and a stable-ID surface` — buys line
   count and costs comprehension: an agent that must decompress an instruction
   before acting is likelier to act on the wrong reading. If a body needs 140
   clear lines, take them.
3. **Progressive disclosure**, split by what the agent does with the file. A file
   it fills in and emits — a document template — goes to `assets/`. A file it
   reads to decide or check — a rubric, a checklist, a reviewer brief, a worked
   example, a lookup table — goes to `references/`. Bundled executable code goes
   to `scripts/`. `SKILL.md` names each file and says *when* to open it.
   Keep short questions or response examples inline when their exact shape
   matters at that step.
4. **Scope and scale-down up top.** State applicability and any skip conditions.
   A mandatory gate may have no skip; define its smallest useful check instead.
5. **Lint-clean markdown.** Fill-in placeholders use `{{double-curly}}` — `<angle>` brackets render as HTML and trip linters. Fence code blocks with a language. Blank lines around lists.
6. **Instructions, not facts.** An agent can obey an instruction; it cannot obey
   a fact. Use `## Step N:` sections with numbered actions and readable conditions.
   Put each outcome on its own line as `condition → act`. Mark every handoff with a bold
   `REQUIRED SUB-SKILL:` naming the skill to invoke, at the step where the flow
   reaches it, and say what this skill never does itself.

   Put the exact text of a question to the user, and the right-versus-wrong
   shape of an output, in a fenced block; put a command in a `bash` block only
   where running it is the act. The body asks a fenced question through the
   harness's user-input action when one exists and prints it as text otherwise;
   it never assumes the action exists, and rendering a question collects an
   answer — it never infers one.

   Every retry names its owner, observable progress, finite attempt/resource
   boundary, and unresolved outcome. Before retrying, apply an evidence-supported
   correction or obtain new discriminating evidence; naming a possible fix is
   not applying it. Preserve history across revisions and return to a pending
   caller instead of invoking it recursively.
7. **Cut by judgement, not word caps.** Ask of every section:
   "would the agent get this wrong without this?" No → cut it. Unsure → run a
   throwaway probe; read `references/testing.md` before writing it up. Never cut
   a hard stop or a destructive-action guard.
8. **Prescribe exactly only where the operation is fragile** — git mutations,
   dispatch, evidence binding, destructive actions. Everywhere else state the
   goal and its reason in one sentence. Give one default and one escape hatch;
   keep a menu only for a decision that belongs to the user.
9. **Gotchas over rules.** Every body carries `## Gotchas`: facts the agent gets
   wrong when untold, each naming the failure it prevents and citing only the
   probe or scenario that reproduces it. Name every support file with its load
   condition, as in `Read references/{{file}} when {{condition}}`, and keep the
   body understandable without it.

## Discipline skills are the exception

A few skills exist to hold an agent to a discipline it is tempted to skip under
pressure—for example routing, TDD, YAGNI, verifying completion, systematic
debugging, and receiving review. For these only:

- Keep the **rationalization table** (each tempting excuse → its rebuttal) and **red-flag list** in the *body*, never a sibling — a tempted agent won't choose to load a sibling file, and the counter must be in context when the temptation hits. You cannot lazy-load willpower. Keep only the rows an agent actually falls for.
- They run longer than a capability skill, and that is expected. Each extra line still has to earn its place by passing a pressure test, not by sounding good; read `references/testing.md` before claiming one passed.
- Everything else (capability, template, reference, meta) has no temptation to counter — keep it lean.
- `containing-an-incident` is this library's exemplar of the form: read its
  body when writing or editing one. Hard stops, a rationalization table, and
  `## Gotchas` all sit in the always-loaded body, inside the limits above.

## Step 1: Decide it is a skill

1. Identify the recurring task and the observed failure, contract gap, or
   reusable reference it addresses. Plain prompt text or a one-off → do not.
   Passing samples limit a behavior claim; they do not erase reported failures.
2. Start from real expertise: extract the procedure from a task done by hand,
   or synthesize it from project artifacts — runbooks, review comments, fixes.
   Before editing a heavily used skill, run it on three real tasks, read the
   transcripts, and cut or clarify the steps agents wasted first.
3. An exact fragile sequence → a tested script, not prose.
4. Split activities only when each is independently invokable. Otherwise one
   cohesive skill.

## Step 2: Write it

1. Choose the phase folder (`planning`…`maintenance`) or `common/`. Create
   `skills/<phase>/<name>/`, copying `assets/skill-template.md` when you start
   the file.
2. Write `description` as a trigger. Test it: does it say **when**, not
   **how**? Lists steps → rewrite.
3. Write the body: **When to use** (incl. Skip), `## Step N:` sections of
   actions (format rule 6), `## Gotchas` (format rule 9), and **Common
   mistakes** for the mistakes the steps do not already forbid.
   Favor procedures over declarations: the steps an agent performs, not a
   description of the outcome it should reach.
4. Move anything heavy to a sibling (format rule 3).
5. Verify the shape (below). Then prove the behavior at the failure surface:
   trigger, artifact or side effect, or pressured discipline. Read
   `references/testing.md` before choosing the proof. An agent explaining the
   rule is not evidence that it follows it.

## Available scripts

- **`scripts/check-skill.sh`** — checks a skill directory with the library's
  format and policy profile: required fields, names, sizes, selected paths,
  presentation, bundled script help, and the policy checks (`## Gotchas`, load
  conditions, description YAML, frontmatter fields, compatibility length) —
  warnings by default,
  failures with `--strict`. Its field extraction is not a complete
  YAML parser and does not validate all optional metadata. It executes candidate
  scripts with `--help`; inspect untrusted scripts or isolate them first.

## Verify before done

- Run the skill check, fix what it reports, and run it again until it passes:

  ```bash
  bash scripts/check-skill.sh --strict path/to/skill
  ```

  Exit 0 passes this checker's profile; exit 1 lists failures. Review any format
  or metadata the checker does not cover before claiming standard conformance.
- Markdown lints clean · description states triggers, not a summary.
- A skill library will usually add house rules on top — no external references,
  no vendor model names, manifest registration. Run its gate too; conforming to
  the standard is necessary, not sufficient.
- The targeted before/after proof observes behavior, reports every run, and does
  not turn unchanged skills into a costly coverage exercise.

## Gotchas

- An unquoted `description` containing `: `, or starting with a YAML indicator
  such as `*`, `&`, `[`, `{`, or `#`, is invalid YAML, and a strict parser drops
  the skill without an error. Quote it; `check-skill.sh` reports
  `description-yaml`.
- A support file named without a load condition gets loaded on every run or on
  none; `check-skill.sh` reports `reference-load-condition`.
- A support file that names another support file gets read partially, so the
  third file is missed; `check-skill.sh` warns `reference-depth`.
