# The trace file

Read this when writing `trace.json` in Step 6. The viewer page renders this
file and nothing else, so what is missing here is missing from the page.

The trace holds the events the triage found, each with its transcript line.
It is not a copy of the transcript. Add an event when it helps the user see
what happened: every user prompt, every event a finding cites, and the events
around them that show order. Twenty to eighty events is typical.

## What never goes in

- Text copied from tool output, file contents, fetched pages, or another
  agent's report. Describe it in your own words. Only `quote` holds copied
  text, and only the user's own words.
- A sensitive value: a credential, token, key, password, connection string,
  or personal data about anyone. This holds in every field, including a
  `fragment` and a `quote` of the user's own prompt. Write its kind and line
  in its place: `[credential, line 412]`. Choose a `fragment` from a part of
  the line that holds none.
- A value you did not read in the transcript. Leave the field out.

## Shape

```json
{
  "schema": "session-trace/1",
  "headline": "The agent pushed before the review it had been told to wait for.",
  "report": ".sdlc-skills/evidence/2026-01-01-early-push/diagnosis.md",
  "session": {
    "which": "yesterday afternoon, branch fix/login",
    "transcript": "/home/me/.agent/projects/shop/1f0c.jsonl",
    "lines": 4180,
    "read_at": "2026-01-02T09:14:00Z",
    "symptom": "The branch was pushed before anyone reviewed it.",
    "expected": "A review, then a question about what to do with the branch.",
    "branch": "fix/login",
    "cwd": "/home/me/shop",
    "workspace": "unchanged"
  },
  "stats": {
    "duration_ms": 2460000,
    "prompts": 4,
    "turns": 61,
    "tool_calls": 118,
    "tool_errors": 3,
    "skills": 2,
    "gates": 1,
    "subagents": 0,
    "compactions": 1
  },
  "events": [
    {
      "id": "e1",
      "line": 12,
      "time": "2026-01-01T14:02:11Z",
      "kind": "prompt",
      "thread": "main",
      "title": "Asks for the login fix and a review before any push",
      "quote": "Fix the login test. Get it reviewed before you push.",
      "fragment": "Get it reviewed before you push"
    },
    {
      "id": "e2",
      "line": 3904,
      "result_line": 3906,
      "time": "2026-01-01T14:41:50Z",
      "duration_ms": 2100,
      "kind": "write",
      "thread": "main",
      "status": "ok",
      "tool": "shell",
      "title": "Pushes the branch",
      "summary": "Ran a push of fix/login to the remote. The remote accepted it.",
      "input": "A push command naming the branch fix/login.",
      "result": "The remote reported a new branch.",
      "expected": "A review request first, then a question to the user.",
      "fragment": "push -u origin fix/login",
      "branch": "fix/login",
      "cwd": "/home/me/shop",
      "files": [],
      "related": [{ "event": "e1", "relation": "contradicts the instruction at" }]
    }
  ],
  "findings": [
    {
      "id": "1",
      "dimension": "Ordering",
      "statement": "The push ran before any review was requested.",
      "shows": "No review request appears between the instruction and the push.",
      "consequence": "The branch reached the remote unreviewed.",
      "evidence": [
        { "line": 12, "fragment": "Get it reviewed before you push" },
        { "line": 3904, "fragment": "push -u origin fix/login" }
      ],
      "steps": [
        { "event": "e1", "note": "The instruction sets the order: review, then push." },
        { "event": "e2", "note": "The push runs. Nothing between line 12 and here requests a review." }
      ]
    }
  ],
  "dimensions": [
    { "name": "Skills invoked", "searched_with": "grep -n for the skill action", "result": "2 invoked, review skill absent" }
  ],
  "unavailable": ["Subagent records: none exist for this session."],
  "notes": [],
  "next_action": "Ask for the review now, on the pushed revision. Owner: the user."
}
```

## Fields

Top level: `schema` is always `session-trace/1`. `headline` answers "what
went wrong" in one sentence. `report` is the path of the written diagnosis.
`session`, `events`, `findings`, and `dimensions` are described below.
`unavailable`, `notes`, and `next_action` repeat the report's sections of the
same name.

| `session` field | Holds |
| --- | --- |
| `which` | which run, in the user's words |
| `transcript` | the absolute path every citation is against |
| `lines` | the line count when read |
| `read_at` | when you read it, UTC |
| `symptom`, `expected` | the intake answers, in the user's words |
| `branch`, `cwd` | where the session ran |
| `workspace` | `unchanged`, or what differed in the status comparison |

`stats` counts the whole session, by search, not the events listed. Leave out
a count you did not take: `duration_ms`, `prompts`, `turns`, `tool_calls`,
`tool_errors`, `skills`, `gates`, `subagents`, `compactions`.

| `events` field | Holds |
| --- | --- |
| `id` | a short unique name; findings and `related` point at it |
| `line` | the transcript line, required |
| `result_line` | the line where a call's result arrived |
| `time` | the recorded timestamp, copied exactly |
| `duration_ms` | result time minus call time |
| `kind` | `prompt`, `reply`, `skill`, `gate`, `tool`, `decision`, `write`, `dispatch`, `boundary`, or `other` |
| `thread` | `main`, or a short name for a subagent's thread |
| `status` | `ok`, `error`, `unanswered`, `missing`, or `unknown` |
| `title` | what happened, in a few words |
| `summary` | what happened, in one to three sentences |
| `quote` | the user's own words, for a `prompt` only |
| `input`, `result` | what a call was given and what came back, described |
| `expected` | what should have happened here instead |
| `fragment` | a short distinctive piece of the line, for the citation |
| `skill`, `tool` | the skill or tool name |
| `branch`, `cwd` | where it ran, when that differs or matters |
| `files` | paths written or read |
| `related` | a list of `event` and `relation` pairs |
| `parent` | the `id` of the event this one happened inside, such as a subagent's work under its dispatch |

The page shows the session as a tree. Each user prompt on the main thread
opens a turn, and the events after it sit inside that turn. Set `parent` only
to nest an event deeper than its turn.

Kinds: a `gate` is a test, check, or validator run. A `decision` is a
question put to the user or a choice the session posed. A `write` changes a
file, a branch, or a remote. A `dispatch` starts a subagent. A `boundary` is
a compaction or a resume.

A step that never happened has no line. Record it as an event with status
`missing` on the line where it should have started, and say so in `summary`.

| `findings` field | Holds |
| --- | --- |
| `id` | `1`, `2`, in the report's order |
| `dimension` | one of the five triage dimensions |
| `statement`, `shows`, `consequence` | the report's finding, same words |
| `evidence` | a list of `line` and `fragment` pairs; never empty |
| `steps` | the events to walk through in order, each an `event` and a `note` saying why it matters |

`dimensions` lists every dimension, each with `name`, `searched_with`, and
`result`. A dimension you could not search says so in `result`.
