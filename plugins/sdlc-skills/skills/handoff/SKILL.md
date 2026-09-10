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

## Procedure

1. **Settle the destination before writing a word.** Where an instruction or
   standing authority already names it, write there and do not ask. Otherwise
   ask one conversational question offering: the durable handoff store, naming
   who can read it; a path the user names; or this reply only, with no write.
   Recommend the least-disclosing option that still reaches the recipient,
   with one sentence of reasoning, then stop. Treat "wherever is easiest",
   approval of the content, and silence as no destination.

2. **For a scratch path outside the workspace, fill `Storage controls`** in
   the template: data class, who may read it, how long it lives, the exact
   cleanup target and owner, and whether cleanup is pending. Write nothing
   into the repository.

3. **Fill every section of `assets/handoff-template.md`:** identity, goal,
   state identity, decisions and authority, evidence, gotchas and
   permissions, resume first action, suggested skills, references.

4. **In `Handoff identity`, name the predecessor record** and append; never
   overwrite the source. When several terminal successors exist, or the
   content identity does not verify, stop and resolve the lineage instead of
   picking one.

5. **In `Decisions and authority`, write for each decision the direct answer
   or the standing default that authorized it,** and list every still-open
   decision as open. Never upgrade an assumption into approval.

6. **In `Evidence`, write for each gate the command, where it ran, the tree
   it ran against, when, and the result,** and say plainly when a result is
   stale or was never run. Never leave a weak result out.

7. **In `Suggested skills`, list candidates only.** They are not proof that
   anything was invoked and not a fixed sequence.

8. **In `References`, point at existing specs, plans, ADRs, issues, and
   commits by path or URL;** do not copy their content in.

9. **Before writing, remove every key, token, password, and piece of personal
   data.**

10. **Write `Resume first action` as one concrete step** the next session
    verifies before executing — identity, status, approvals, and
    time-sensitive external state may have moved.

## Common mistakes

- A summary of the conversation instead of the state to resume from.
- Duplicating a plan or spec that already exists — link it.
- Omitting the one concrete next step, leaving the next session to guess.
- Treating the handoff as a durable project-lessons store; it transfers
  current state once.

`assets/handoff-template.md` also carries a worked bad-versus-good example and
what to leave out.
