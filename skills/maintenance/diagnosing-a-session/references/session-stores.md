# Finding a session's transcript

Harnesses are named nowhere here. They are grouped by how they record a
session, because that is what decides the search. Work down the families in
order and stop at the first one that yields a file matching the intake.

## Family A — a per-project directory under a per-user state directory

The most common shape. A state directory in the user's home holds one
subdirectory per project, named after the project's absolute path with the
path separators replaced by a single character, and often with a leading
separator character kept as a leading marker. Inside it, one file per
session, named by the session's identifier. A session that spawned
subagents may also have a same-named subdirectory holding their records.

Find the state directory by looking for a home-level directory belonging to
the running agent tool that contains a `projects`-like subdirectory, then
the project subdirectory whose name is this project's absolute path with
separators substituted:

```bash
proj=$(pwd | sed 's|/|-|g')            # the usual encoding of the path
ls -lt "$HOME"/.*/projects/*"$proj"*/ 2>/dev/null | head -20
```

Newest modification time first is the ordering you want; the current
session is the file whose size grows between two listings a few seconds
apart.

## Family B — a flat session directory keyed by identifier

One directory holds every session for every project, each file named by a
session identifier only. The project is not in the filename, so select by
modification time first and confirm by content:

```bash
ls -lt "$STORE" | head -20
grep -ln "$(basename "$PWD")" "$STORE"/* 2>/dev/null | head
```

## Family C — a workspace-local record

The record lives inside the project, usually in a tool-owned dot-directory
next to the source. It moves with the checkout, so a worktree has its own.
Look for a dot-directory holding dated or identifier-named files that are
not configuration.

## Family D — no local record

Some harnesses keep the run server-side or nowhere. Exporting it, when the
tool offers an export, is the user's action and not something to perform on
their behalf. No local record is a reportable outcome: say which families
were searched and where.

## What a line looks like

The common on-disk format is JSON Lines: one self-contained JSON object per
line, appended as the session runs. The fields that matter for a diagnosis,
under whatever names a given format gives them:

| What it carries | Typical field | Why it matters |
| --- | --- | --- |
| Record kind | `type` | separates a user turn, an agent turn, and the tool's own bookkeeping |
| Wall-clock time | `timestamp` | builds the timeline |
| Identity and parent | `uuid`, `parentUuid` | reconstructs order when lines interleave |
| Side-thread marker | an `isSidechain`-style boolean | marks a subagent's work rather than the main thread |
| Working directory and branch | `cwd`, `gitBranch` | shows where a write landed |
| The turn itself | `message` with a role and content blocks | holds the prompt text, the agent's text, tool calls, and tool results |

A tool call and its result are separate blocks, usually on separate lines: a
call with no matching result line is itself a finding.

Some formats are one JSON array, or a markdown log. The method does not
change: search for the term, print a line range around the hit, cut long
lines by column.

## Searching without loading the file

```bash
wc -l "$T"                                   # size first, always
grep -n "phrase from the symptom" "$T" | head -20
sed -n '1200,1240p' "$T" | cut -c1-400       # a slice, clipped
```

For a JSON Lines file, extracting one field per line keeps a scan cheap:

```bash
grep -n '"type":"user"' "$T" | cut -c1-200 | head -40
```

Every hit gives a line number. That number, with a short distinctive
fragment of the line, is the citation.
