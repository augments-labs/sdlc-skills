---
name: writing-skills
description: "Use when creating or editing a skill in this library — its format, its sibling files, and how to prove it works. Fires on add a skill for X and this skill isn't triggering. Skip using a skill."
---

# Writing Skills

Write the minimum guidance that changes behavior. Reuse a current body already
in context and load supporting material only when needed.

## When to use

- Creating or editing a skill under `skills/<phase>/<name>/`.
- **Skip** when you're *using* a skill — this is only for authoring.

## Skill types

Match the form to the need (see `references/reference.md` for how much detail each needs):

- **Instruction** — a prose procedure. Most skills.
- **Template** — ships a `{{placeholder}}` file to copy (like `assets/skill-template.md`).
- **Script** — bundles a tested, deterministic script when prose would be error-prone.
- **Reference** — a doc loaded on demand for lookup; large is fine, it isn't always-loaded.

## The format (non-negotiable)

1. **Frontmatter**: `name` (kebab-case, matches the directory) and `description`
   (nonempty, ≤1024 characters). Use plain applicability triggers in the house
   `Use when…` style; do not summarize the internal workflow.
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
   reaches it, and say what this skill never does itself. Put the exact text of a question
   to the user, and the right-versus-wrong shape of an output, in a fenced
   block; put a command in a `bash` block only where running it is the act.
   Every retry names its owner, observable progress, finite attempt/resource
   boundary, and unresolved outcome. Before retrying, apply an evidence-supported
   correction or obtain new discriminating evidence; naming a possible fix is
   not applying it. Preserve history across revisions and return to a pending
   caller instead of invoking it recursively.
   Cut every line that fails "would the agent get this wrong without it?".

## Discipline skills are the exception

A few skills exist to hold an agent to a discipline it is tempted to skip under
pressure—for example routing, TDD, YAGNI, verifying completion, systematic
debugging, and receiving review. For these only:

- Keep the **rationalization table** (each tempting excuse → its rebuttal) and **red-flag list** in the *body*, never a sibling — a tempted agent won't choose to load a sibling file, and the counter must be in context when the temptation hits. You cannot lazy-load willpower.
- They run longer than a capability skill, and that is expected. Each extra line still has to earn its place by passing a pressure test (`references/testing.md`), not by sounding good.
- Everything else (capability, template, reference, meta) has no temptation to counter — keep it lean.

## Step 1: Decide it is a skill

1. Identify the recurring task and the observed failure, contract gap, or
   reusable reference it addresses. Plain prompt text or a one-off → do not.
   Passing samples limit a behavior claim; they do not erase reported failures.
2. An exact fragile sequence → a tested script, not prose.
3. Split activities only when each is independently invokable. Otherwise one
   cohesive skill.

## Step 2: Write it

1. Choose the phase folder (`planning`…`maintenance`) or `common/`. Create
   `skills/<phase>/<name>/` from `assets/skill-template.md`.
2. Write `description` as a trigger. Test it: does it say **when**, not
   **how**? Lists steps → rewrite.
3. Write the body: **When to use** (incl. Skip), `## Step N:` sections of
   actions (format rule 6), **Common mistakes**.
4. Move anything heavy to a sibling: `assets/` if the agent fills it in,
   `references/` if the agent reads it.
5. Verify the shape (below). Then prove the behavior at the failure surface:
   trigger, artifact or side effect, or pressured discipline. Read
   `references/testing.md`. An agent explaining the rule is not evidence that
   it follows it.

## Available scripts

- **`scripts/check-skill.sh`** — checks a skill directory with the library's
  format and policy profile: required fields, names, sizes, selected paths,
  presentation, and bundled script help. Its field extraction is not a complete
  YAML parser and does not validate all optional metadata. It executes candidate
  scripts with `--help`; inspect untrusted scripts or isolate them first.

## Verify before done

- Run the skill check and read what it returns:

  ```bash
  bash scripts/check-skill.sh path/to/skill
  ```

  Exit 0 passes this checker's profile; exit 1 lists failures. Review any format
  or metadata the checker does not cover before claiming standard conformance.
- Markdown lints clean · description states triggers, not a summary.
- A skill library will usually add house rules on top — no external references,
  no vendor model names, manifest registration. Run its gate too; conforming to
  the standard is necessary, not sufficient.
- The targeted before/after proof observes behavior, reports every run, and does
  not turn unchanged skills into a costly coverage exercise.

## Common mistakes

- A body that explains background without changing an action.
- A description that summarizes the workflow → the model follows the summary and skips the skill body.
- Inlining templates/examples that belong in sibling files.
- No complexity gate → ceremony on trivial tasks (the #1 complaint about heavy skill libraries).
- Claiming a skill prevents a failure without observing the relevant behavior;
  report unproved claims and inconclusive runs explicitly.

See `references/reference.md` for examples and reasoning, and `references/testing.md` for proving a skill actually changes behavior.
