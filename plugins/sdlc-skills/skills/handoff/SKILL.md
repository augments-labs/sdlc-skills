---
name: handoff
description: "Use when a session is ending or work is passing to a fresh session or another agent, so the next one resumes without re-deriving the goal, the state, the decisions, and the next step. Fires on I'm heading out, wrapping up for the day, context is getting full, and someone else is taking this over, even if nobody says handoff. Skip a finished, self-contained task that needs no continuation."
---

# Handoff

Write the state the next session resumes from — not a summary of the
conversation — and write it only where the user or a standing instruction
says it may go.

## When to use

- A conversation is ending mid-work, or work is passing to a fresh session or a different agent.
- **Skip** when the task is finished and self-contained — there's nothing to resume.

## Step 1: Settle the destination

1. An instruction or standing authority names it → write there. Do not ask.
2. Otherwise ask one question and end the turn:

   ```text
   Where should the handoff go?

   1. The durable handoff store — readable by {{who}}
   2. A path you name
   3. This reply only — nothing written

   Recommendation: {{least-disclosing option that reaches the recipient}} — {{one sentence}}.
   ```

3. "Wherever is easiest", approval of the content, silence → no destination.
   Re-ask.
4. Scratch path outside the workspace → fill `Storage controls`: data class,
   readers, lifetime, exact cleanup target and owner, cleanup pending or not.
   Write nothing into the repository.

## Step 2: Fill `assets/handoff-template.md`

1. Fill every section: identity, goal, state identity, decisions and
   authority, evidence, gotchas and permissions, resume first action,
   suggested skills, references.
2. `Handoff identity` → name the predecessor record and append. Several
   terminal successors, or content identity does not verify → stop and
   resolve the lineage.
3. `Decisions and authority` → for each decision, the direct answer or the
   standing default that authorized it. Every open decision listed as open.
   Never write an assumption as approval.
4. `Evidence` → for each gate: command, where it ran, tree, when, result.
   Stale or never run → say so. Leave no weak result out.
5. `Suggested skills` → candidates only. Not proof of invocation, not a
   sequence.
6. `References` → paths or URLs to specs, plans, ADRs, issues, commits. Copy
   nothing in.
7. `Resume first action` → one concrete step the next session verifies
   before executing.
8. Before writing, remove every key, token, password, and piece of personal
   data.

## Common mistakes

- A summary of the conversation instead of the state to resume from.
- Duplicating a plan or spec that already exists — link it.
- Omitting the one concrete next step, leaving the next session to guess.
- Treating the handoff as a durable project-lessons store; it transfers
  current state once.

`assets/handoff-template.md` also carries a worked bad-versus-good example and
what to leave out.
