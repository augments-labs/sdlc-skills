# Deprecation record template

`deprecating-an-api` opens this in its first step, fills Interface and Use
before the replacement ships, Signal when the deprecation change ships, and
Removal when the owner decides; `release-readiness` receives it with the
removal change, and `yagni` and `refactor-architecture` read its Status to
tell a completed deprecation from one in progress. Write it to
`.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-deprecation.md` unless the
user names another place; the owner's removal decision is a row in the
ledger beside it, and nowhere else. No secret, credential, or personal data
of a caller goes in it. An empty section means the thing was not measured,
not shipped, or not decided, so say which; a release decision treats it as
missing rather than fine.

```markdown
# Deprecation record — {{interface-short-name}}

- **Interface:** {{the function, method, class, endpoint, field, flag, key, event, or message type, with its path or route}}
- **Predecessor:** {{an earlier record for the same interface, or none}}
- **Owner:** {{who decides the sunset date and the removal}}
- **Status:** `{{measuring | replacement-shipped | deprecated | sunset-passed | removed}}`
- **Decision ledger:** {{the ledger path beside this record, and the identity of the sunset-date row and the removal row; "no row" until each is decided}}

## Interface

| Item | Value | Source |
| --- | --- | --- |
| Replacement | {{name and where it is documented, or "none: end of support"}} | {{revision or version it shipped in}} |
| Old path calls the new one | {{yes, or no with the reason}} | {{path:line}} |
| Tests of the old path | {{suite and path; kept until the removal change}} | {{revision}} |

## Callers

| Caller | Found by | Told how, when | Migrated |
| --- | --- | --- | --- |
| {{name, repository, client, or version}} | {{search, metric, log, or reported}} | {{channel and date, or "not reachable"}} | {{yes, no, or unknown}} |

## Use

| Read on | Period | Calls | Distinct callers | How counted |
| --- | --- | --- | --- | --- |
| {{date}} | {{span}} | {{n, or unknown}} | {{n, or unknown}} | {{metric or log line, or "nothing counts it"}} |

## Signal

- **Channel:** {{the marker, headers, or warning, and where it is emitted}}
- **Message:** {{the text the caller sees, naming the replacement and the sunset date}}
- **Frequency:** {{once per process, once per caller, or once per run}}
- **Shipped in:** {{version or revision}}
- **Sunset date:** {{date, and the ledger row that set it}}

## Removal

- **Brownout:** {{window, date, and who errored or complained; or "declined by owner"; or "not possible: reason"}}
- **Use at decision:** {{calls and callers over the last read, or unknown}}
- **Who breaks:** {{callers still on the old path and how they recover}}
- **Decision:** {{remove, or hold until the stated condition; the ledger row identity; "no row" until decided}}
- **Removal shipped in:** {{version or revision, or "not shipped"}}

## Not measured

{{Each caller class the count cannot see, and why. "Nothing" is a valid entry.}}

## Next action

{{The single next step and its owner: ship the count, ship the replacement, ask for the sunset date, read the count after sunset, ask for the removal, or ship the removal through `release-readiness`.}}
```
