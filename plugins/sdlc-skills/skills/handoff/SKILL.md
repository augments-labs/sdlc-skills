---
name: handoff
description: "Writes a handoff so a fresh session or another agent can continue unfinished work. Use when a session is ending mid-work, the context is getting full, the user is heading out, or someone else is taking over. Skip finished tasks and bounded worker assignments whose coordinator stays responsible."
---

# Handoff

Write the state the next session resumes from, not a summary of the
conversation, and write it only where the user or a standing instruction
says it may go.

## When to use

- A conversation is ending mid-work, or responsibility for continuing it passes
  to a fresh session or a different agent.
- **Skip** when the task is finished and self-contained — there's nothing to resume.
- **Skip** bounded worker assignments while the coordinator retains the task;
  those use the dispatch packet and return contract instead.

## Step 1: Settle the destination

1. If an instruction or a standing authority names the destination, write
   there. Do not ask.
2. Otherwise ask one question and end the turn:

   ```text
   Where should the handoff go?

   1. .sdlc-skills/handoffs/ in this project — readable by anyone who can read this checkout; committed only when the reader works from another checkout and the content is safe to share, and then readable by everyone with repository access
   2. A path you name
   3. This reply only — nothing written

   Recommendation: {{least-disclosing option that reaches the recipient}} — {{one sentence}}.
   ```

3. "Wherever is easiest", approval of the content, or silence names no
   destination. Ask again.
4. For a scratch path outside the workspace, fill `Storage controls`: data
   class, readers, lifetime, exact cleanup target and owner, and whether
   cleanup is still pending. Write nothing into the repository.

## Step 2: Fill `assets/handoff-template.md` before writing

Read `references/handoff-example.md` when the first draft is written and needs comparing against a filled example.

1. Fill every section: identity, goal, state identity, decisions and
   authority, evidence, gotchas and permissions, resume first action,
   suggested skills, references.
2. In `Handoff identity`, name the predecessor record and add this note after
   it as its successor. If more than one successor already ends the
   predecessor's lineage, or the predecessor file's record (the ledger) holds
   no hash for it, or one the file no longer matches, stop and resolve the
   lineage.
3. In `Decisions and authority`, give for each decision the direct answer or
   the standing default that authorized it. List every open decision as open.
   Never write an assumption as approval.
4. In `Evidence`, give for each check: the command, where it ran, the tree,
   when, and the result. If a result is stale or the check never ran, say so.
   Leave no weak result out.
5. `Suggested skills` lists possibilities only. It is not proof that any was
   invoked, and not a sequence to follow.
6. `References` holds paths or URLs to specs, plans, ADRs, issues, commits.
   Copy nothing in.
7. `Resume first action` is one concrete step, which the next session
   verifies before executing it.
8. Before writing, remove every key, token, password, and piece of personal
   data.
9. After writing a note to a file, record the first 7 characters of
   `git hash-object` of that file in its record (the ledger: add to it, never
   rewrite it; it sits outside the note, at the note's path with `.ledger.md`
   in place of `.md`), never in the note.

## Gotchas

- Session state can hold credentials, customer data, or unreviewed findings. A
  store the session invents discloses it to readers nobody chose.
- A hash written inside the note changes the bytes it names, so the note
  never matches it and every later handoff stops on its lineage.

## Common mistakes

- Treating the handoff as a durable project-lessons store; it transfers
  current state once.
