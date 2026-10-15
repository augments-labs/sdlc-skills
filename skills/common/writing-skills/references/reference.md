# Writing Skills — Reference

## Where detail belongs

Keep what changes action and load supporting detail when needed. Reusing a
current body is not another load; token claims must describe actual text and
execution.

Shortening a rationalization table or red-flag list requires relevant
behavioral evidence; a description score cannot establish that its body still
holds under pressure.

## Descriptions: trigger, not summary

Catalogue names and descriptions guide initial selection. Explicit user requests
and loaded handoffs can also cause invocation. Two description failure modes:

- **Too vague.** The skill never fires when it should.
- **A workflow summary.** The model reads the summary, assumes it knows the procedure, and skips the skill body. Incomplete execution.

### Good (trigger conditions)

- `Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes.`
- `Use when you have an alignment brief or a clear multi-step task and need an executable plan before implementing. Skip for single-step work.`

### Bad

- `Reproduces the bug, forms a hypothesis, instruments the code, fixes it, then writes a regression test.` — summarizes the workflow; the model follows it from memory and never opens the skill.
- `A skill for debugging.` — too vague to trigger reliably.

## How much to write

Match instruction density to how constrained the task is:

- For **one correct sequence** (a fragile path), bundle a tested script; prose drifts.
- For **a preferred pattern**, give pseudocode or a worked shape, but allow variation.
- For **open-ended or exploratory** work, state the objective, a useful
  method, and when to stop; allow judgment where several approaches satisfy them.

## Prose hygiene

- **One term per concept.** Choose "extract" and don't also write "pull"/"get"/"retrieve" — the model may treat each synonym as a distinct operation.
- **Match control to the consequence.** State required actions directly. Use
  emphasis at a fragile boundary or tempting omission; let flexible methods
  vary within the accepted scope. Do not turn ordinary advice into a hard stop.

## Naming

- Directory name == frontmatter `name`, kebab-case.
- Gerund or verb-first, naming the activity: `writing-plans`, `debugging`.
- No vague words such as helper, utils, or tools, and no pronoun or particle
  suffix such as `-it`, `-me`, or `-out`.
- The invoked name is `sdlc-skills:<name>` regardless of which phase folder holds it — the folder is organization for humans, not part of the address.

The gerund, vague-word, and suffix rules apply when a name is chosen: a new
skill, or a rename planned as its own change. Editing a skill never renames
it, so a shipped name that predates them stays until that rename.
