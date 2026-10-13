# Rollout record template

`rollout-controls` fills this in its last step, once the switch and the signals
exist in code and their tests pass, or in its first step with Status `declined`
when the owner declines a draft; `release-readiness` reads it to bind the
rollout policy and its signals. Write it to
`.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-rollout.md` unless the user names
another place; drafted terms get their acceptance or decline as a row in the
ledger beside it, naming who decided, when, and the terms they saw, while terms
copied from an existing policy need no row. No secret value, token, or personal data goes
in it. A section left empty means the thing was not built or not found: say
which, and the release decision treats it as missing rather than fine.

```markdown
# Rollout record — {{change-short-name}}

- **Change:** {{branch or revision the switch and signals are built into}}
- **Predecessor:** {{earlier rollout record for the same change, or none}}
- **Inputs:** {{release policy document and version, plan task, or the request that asked for the rollout}}
- **Owner:** {{the owner who accepted or declined the drafted terms; for terms from policy, the policy's owner}}
- **Status:** `{{terms from policy | terms accepted | declined}}`
- **Decision ledger:** {{the ledger path beside this record and the row naming who accepted or declined the drafted terms, when, and the terms they saw; only terms from policy have no row}}

## Policy

- **Source:** {{the project's policy, document and version, or "drafted here" with who accepted or declined it, and the date}}
- **Mechanism:** {{flag | canary | partition | staged publication | phased rollout}}
- **Target state:** {{what full rollout looks like}}
- **Authority:** {{who may expand a stage; who may abort}}

## Switch

| | |
| --- | --- |
| Name | {{the flag or configuration key, exactly as the code reads it}} |
| Facility | {{the project's flag or configuration mechanism it is read through}} |
| Default | {{off, or the safe state the terms name}} |
| Off action | {{the exact runtime action that turns it off, with no deploy}} |
| Off-state test | {{path and test name proving off restores the prior behaviour}} |
| On-state test | {{path and test name proving on does the new work}} |

## Guarded paths

| Path | Kind | Where the switch is read | Side effect it precedes |
| --- | --- | --- | --- |
| {{handler, job, consumer, scheduled task, migration step, retry, cache fill}} | {{kind}} | {{path:line}} | {{what would otherwise run}} |

## Signals and baseline

| Signal | Measures | Threshold it serves | Carries switch state | Test |
| --- | --- | --- | --- | --- |
| {{name under the project's convention}} | {{correctness or error; safety: data integrity, security or privacy; latency or resource; business or operational outcome}} | {{the success or failure threshold from the terms}} | {{label or field}} | {{path and test name}} |

- **Emitted through:** {{the project's existing telemetry facility}}
- **Baseline source:** {{where the prior behaviour is already measured, or "the off cohort", or "none"}}

## Stages, thresholds, and kill action

| Stage | Cohort | Minimum observation | Success threshold | Failure threshold |
| --- | --- | --- | --- | --- |
| {{1 … n}} | {{selection rule}} | {{duration or volume}} | {{per signal}} | {{per signal; the abort threshold the release decision binds}} |

- **Kill or rollback action:** {{the exact action}}
- **Who may pull it:** {{role or person the terms name}}

## Removal

- **Owner:** {{who deletes the switch and the prior path}}
- **Condition:** {{full rollout observed for the minimum period, or the rollout aborted}}

## Not built

{{Each path, signal, test, or baseline the terms call for that is not in the
change, and why. "Nothing" is a valid entry.}}

## Next action

{{The single next step and its owner: the release decision through
`release-readiness`, or, when declined, nothing further from this skill.}}
```
