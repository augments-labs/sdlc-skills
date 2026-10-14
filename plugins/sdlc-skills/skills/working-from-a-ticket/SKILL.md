---
name: working-from-a-ticket
description: "Captures a ticket from an issue tracker as the definition of the work: its text and acceptance criteria as read, and what it leaves unclear, so the plan and the tests bind to a recorded text. Use when the user hands over a ticket, issue, story, or work item as the task, whether pasted, linked, or named by its identifier, and again before ticket-defined work is called done. Skip work the user describes in their own words with no ticket behind it."
---

# Working From a Ticket

A ticket is the user's definition of the work, and it lives outside the
repository, where nothing in the project can bind to it. Capture what it says,
as read and when, so the plan, the tests, and the claim of done bind to one
recorded text instead of a memory of it.

## When to use

- The user hands over a ticket — pasted, linked, or named by its identifier —
  as the task.
- Before ticket-defined work is called done (Step 4).
- **Skip** work the user describes in their own words with no ticket behind
  it; `clarifying-intent` owns what such a request leaves open.
- **Skip** turning the ticket into goals, a scope, or a spec: `define-goals`,
  `scoping`, and `writing-specs` own those. This skill writes no requirement
  of its own and judges no criterion met.

## Step 1: Read the ticket through what you were given

1. If the ticket was pasted, that text is the ticket. Read all of it,
   comments included.
2. If you were given a link or an identifier, read it only through a tool
   the harness already provides for that source and the user is entitled to
   use. Note the tool and the time of the read.
3. If there is no such tool, or the tool fails or returns only part of the
   ticket, stop reading, write down exactly what could not be read, and ask
   once:

   ```text
   I cannot read {{identifier}} from here: {{reason}}.

   1. Paste the ticket, acceptance criteria and comments included
   2. Name a tool or path I may read it through
   3. Continue from what was read so far, recorded as partial

   Recommendation: 1 — the work binds to the text read, so a partial read binds partial work.
   ```

   Ask this and end the turn.
4. Read linked tickets, attachments, and comments that carry criteria or
   constraints the same way. List the rest; do not read them.
5. Never fill a gap from memory, from a similar ticket, or from the title.
   Text that was not read is not in the capture.

## Step 2: Capture it

1. Open `assets/ticket-capture.md` before writing. Fill every section from
   the text as read: source and identifier, the read time and means, the
   ticket verbatim, its acceptance criteria exactly as written, links, what
   could not be read, and what the ticket leaves unclear.
2. Copy each acceptance criterion as written, informal or partial ones
   included:

   ```text
   Right: 2. "Should respond within 2 seconds" (as written; no load stated)
   Wrong: 2. Responds within 2 seconds under normal load
   ```

   If the ticket states none, write `none stated`; the done condition is
   then an unclear point.
3. Search the codebase before listing a point as unclear; never list what the
   code answers. List one line per point the text and the code together do
   not settle: which component, where a boundary sits, a criterion with
   nothing observable to check it by, a comment that contradicts the
   description.

   A ticket's description asks for CSV and PDF export; its last comment
   says "PDF can wait". Both go into the capture verbatim, and the criteria
   stay as written. The latest comment often carries the current ask, but
   "can wait" settles neither what ships nor who decided, so the conflict
   is one `Unclear` line, for `clarifying-intent` under Step 3.1. Dropping
   PDF yourself would settle the scope, which this skill never does.
4. Write the capture to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{slug}}-ticket.md` or the user-set
   path. The slug is the identifier lowercased, with each run of other
   characters replaced by one `-` and the ends trimmed, or a short topic
   slug when there is no identifier; the H1 keeps the identifier as
   written. If the path already exists, add `-{{n}}` before `-ticket`; a
   successor never takes the predecessor's path. No other skill writes that
   name.

   Compute its identity by the artifact layout's captured-ticket rule
   in `using-sdlc-skills` (the first 7 characters of `git hash-object` over
   the whole file), and add one row to its record (the ledger: add to it,
   never rewrite it; its path is the capture's with `.ledger.md` in place of
   `.md`): that identity, the state `captured`, and the source and read time
   as bound evidence. Never edit the capture afterwards; a changed ticket
   gets a successor (Step 4).

## Step 3: Settle what is unclear, then hand on

1. If `Unclear` holds an entry, **REQUIRED SUB-SKILL:** invoke
   `clarifying-intent` with that list, addressed to the capture's decision
   owner. Its answers live where it records them; the capture stays as read.
   Return here when it returns. Never guess an entry, and never promote a
   guess to an acceptance criterion.
2. If the ticket describes a new project or initiative rather than one
   change, **REQUIRED SUB-SKILL:** invoke `define-goals`, which writes its
   own brief file naming the capture's identity, and stop here.
3. If the ticket reports broken behavior whose cause is unknown,
   **REQUIRED SUB-SKILL:** invoke `debugging` before any fix; the acceptance
   criteria stay the done condition.
4. If the work spans several steps or files, or the user calls it too big
   for one go, **REQUIRED SUB-SKILL:** invoke `writing-plans`. Put the
   capture's identity on the plan's `Bound inputs` line; trace each
   acceptance criterion, cited by that identity, to a task's Evaluator (the
   check that task names as the one that must accept its result) or to the
   plan's **Acceptance** check; and make the plan's last task re-read the
   ticket (Step 4).
5. Otherwise, **REQUIRED SUB-SKILL:** invoke `using-git-worktrees`, then
   `test-driven-development` and `yagni` before the first edit. Take the
   first test from the first acceptance criterion, or, when the capture
   says `none stated`, from the done condition `clarifying-intent` settled,
   wherever it recorded it.

## Step 4: Before the work is called done

1. Re-read the ticket the way Step 1 read it.
2. If the text, the criteria, or the comments differ from the capture, the
   capture is stale. Write a successor capture (Step 2) in its own new file,
   naming the predecessor; add a `superseded` row to the predecessor's
   ledger; and return to Step 3, because a plan or a test bound to the old
   identity is bound to the old ticket.
3. If nothing changed, say so, with the identity and the time of the
   re-read; then **REQUIRED SUB-SKILL:** invoke
   `verification-before-completion`, listing each acceptance criterion as an
   item. It judges each criterion against evidence; this skill never does.

## Gotchas

- A ticket's title, its description, and its last comment can disagree, and
  the latest comment often carries the current ask; a capture made from the
  title alone binds the wrong work — shows when a ticket's final comment
  narrows the scope.
- `git hash-object` can bind only a file in the project, so the identity
  names the capture, never the ticket; the recorded read time and means are
  what tell a later reader which version of the ticket it was — shows when a
  ticket is edited between capture and review.
- A criterion written as "should" or "ideally" still binds; dropping it as
  optional can ship a change the ticket's owner rejects — shows when a ticket's
  only latency requirement is phrased as "ideally".

## Common mistakes

- Paraphrasing the ticket into the capture: copy the text instead; a
  paraphrase belongs under `Unclear`, as a question.
- Writing the answers to unclear points into the capture: the capture is
  the ticket as read; answers live where `clarifying-intent` records them.
