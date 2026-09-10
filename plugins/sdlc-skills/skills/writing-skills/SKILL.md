---
name: writing-skills
description: "Use when creating or editing a skill in this library — its format, its sibling files, and how to prove it works. Fires on add a skill for X and this skill isn't triggering, even if nobody says authoring. Skip using a skill."
---

# Writing Skills

Skills are tools, not pipelines. Each one loads into context every time it fires, so every line costs tokens on every use. Write the minimum that changes behavior; push the rest to sibling files.

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

1. **Frontmatter**: `name` (kebab-case, matches the directory) and `description` (capability + "Use when…" trigger, ≤1024 chars, third person, **never** a workflow summary).
2. **Body under 500 lines and 5000 tokens** — the ceilings every compliant agent
   assumes. Aim well under: most capability skills land near 80–120 lines, and a
   body past ~200 should have to justify itself. Intent + procedure only; cut
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
   to `scripts/`. `SKILL.md` names each file and says *when* to open it; it never
   inlines them.
4. **Complexity gate up top.** State when to *skip* the skill. Ceremony must scale down with task size.
5. **Lint-clean markdown.** Fill-in placeholders use `{{double-curly}}` — `<angle>` brackets render as HTML and trip linters. Fence code blocks with a language. Blank lines around lists.
6. **Instructions, not facts.** An agent can obey an instruction; it cannot obey
   a fact. Write the body as `## Step N:` sections of numbered one-line acts.
   Put each outcome on its own line as `condition → act`. Mark every handoff with a bold
   `REQUIRED SUB-SKILL:` naming the skill to invoke, at the step where the flow
   reaches it, and say what this skill never does itself. Put the exact text of a question
   to the user, and the right-versus-wrong shape of an output, in a fenced
   block; put a command in a `bash` block only where running it is the act.
   Cut every line that fails "would the agent get this wrong without it?".

## Discipline skills are the exception

A few skills exist to hold an agent to a discipline it is tempted to skip under
pressure—for example routing, TDD, YAGNI, verifying completion, systematic
debugging, and receiving review. For these only:

- Keep the **rationalization table** (each tempting excuse → its rebuttal) and **red-flag list** in the *body*, never a sibling — a tempted agent won't choose to load a sibling file, and the counter must be in context when the temptation hits. You cannot lazy-load willpower.
- They run longer than a capability skill, and that is expected. Each extra line still has to earn its place by passing a pressure test (`references/testing.md`), not by sounding good.
- Everything else (capability, template, reference, meta) has no temptation to counter — keep it lean.

## Step 1: Decide it is a skill

1. Write one only if an agent reliably gets this wrong without guidance.
   Plain prompt text or a one-off → do not.
2. An exact fragile sequence → a tested script, not prose.
3. Split activities only when each is independently invokable. Otherwise one
   cohesive skill.

## Step 2: Write it

1. Choose the phase folder (`planning`…`maintenance`) or `common/`. Create
   `skills/<phase>/<name>/` from `assets/skill-template.md`.
2. Write `description` as a trigger. Test it: does it say **when**, not
   **how**? Lists steps → rewrite.
3. Write the body: **When to use** (incl. Skip), `## Step N:` sections of
   one-line acts (format rule 6), **Common mistakes**.
4. Move anything heavy to a sibling: `assets/` if the agent fills it in,
   `references/` if the agent reads it.
5. Verify the shape (below). Then prove the behavior at the failure surface:
   trigger, artifact or side effect, or pressured discipline. Read
   `references/testing.md`. An agent explaining the rule is not evidence that
   it follows it.

## Available scripts

- **`scripts/check-skill.sh`** — checks one skill directory against the Agent
  Skills standard: frontmatter, `name` charset and length, `description` limit,
  body ceilings, reference resolution, and whether bundled scripts answer
  `--help`. Read-only, and portable to any skill directory, including outside
  this repository. Run it in *Verify before done*; `--help` lists the checks and
  exit codes.

## Verify before done

- Run the conformance check and read what it returns:

  ```bash
  bash scripts/check-skill.sh path/to/skill
  ```

  Exit 0 conforms; exit 1 lists what fails. It replaces hand-counting lines and
  eyeballing paths — both of which this library got wrong before it existed.
- Markdown lints clean · description states triggers, not a summary.
- A skill library will usually add house rules on top — no external references,
  no vendor model names, manifest registration. Run its gate too; conforming to
  the standard is necessary, not sufficient.
- The targeted before/after proof observes behavior, reports every run, and does
  not turn unchanged skills into a costly coverage exercise.

## Common mistakes

- A body that reads like documentation — it reloads into context every invocation.
- A description that summarizes the workflow → the model follows the summary and skips the skill body.
- Inlining templates/examples that belong in sibling files.
- No complexity gate → ceremony on trivial tasks (the #1 complaint about heavy skill libraries).
- Shipping a skill you never watched fail without — you don't know it prevents the right failure.

See `references/reference.md` for examples and reasoning, and `references/testing.md` for proving a skill actually changes behavior.
