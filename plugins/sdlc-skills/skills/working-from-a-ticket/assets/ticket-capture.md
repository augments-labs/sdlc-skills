# Ticket capture template

`working-from-a-ticket` fills this after reading the ticket and before any
other work on it. Write the filled copy to
`.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{identifier}}-ticket.md` or the user-set
path; no other skill writes that name, and a successor gets its own new file.
Only text that was read goes in: nothing is paraphrased, completed from
memory, or taken from a similar ticket. A section with nothing to hold carries
the exact phrase given under it, and a slot that cannot be filled means the
ticket was not read far enough; read it, or record it under `## Not readable`.

```markdown
# Ticket: {{identifier}} — {{title as written}}

- **Status:** {{captured; lifecycle stays external}}
- **Identity:** recorded in the ledger row, never here: this file's identity
  under the Identity rule of the artifact layout reference
  (`using-sdlc-skills`)
- **Predecessor:** {{identity of the capture this one replaces, or none}}
- **Source:** {{the tracker as the user named it, or "pasted by the user";
  the identifier; the link as given}}
- **Read:** {{date and time}} through {{the user's paste | the tool used}}
- **Decision owner:** {{who answers the unclear points; the user unless the
  ticket names another}}
- **External decision ledger:** {{this file's path with .ledger.md in place
  of .md unless the user sets another; one row per state: captured,
  superseded by a successor capture}}

## Ticket as read

{{the title, description, and comments verbatim, in the order read, each
comment with its author and date as shown}}

## Acceptance criteria as written

1. {{one criterion copied verbatim, with the numbering and wording the
   ticket uses}}
2. {{the next one}}

`none stated` when the ticket gives none; the done condition is then an
entry under `## Unclear`.

## Links and attachments

- {{each link or attachment the ticket carries, and whether it was read}}

`none` when the ticket carries none.

## Not readable

- {{what could not be read, through what, and why}}

`everything above was read in full` when nothing was left out.

## Unclear

- {{one point the text leaves open and the codebase cannot settle, as a
  question}}

`nothing` when the text and the code settle every point. Every entry here
goes to `clarifying-intent`; no entry is answered in this file.
```

The filled copy is never edited; a changed ticket gets a successor capture in its own new file, naming this one as its predecessor.
