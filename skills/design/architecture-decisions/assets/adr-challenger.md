# ADR challenger prompt template

Fill Inputs and send the fenced prompt. The challenger fills Output and is not
the ADR's sole author.

Before dispatch, bind the exact ADR identity, the role ID, allowed artifact
access, current authority for its worker/provider/storage/egress, and the report
location. No receipt, no challenger: an unavailable, refused, or empty dispatch
leaves the challenge pending, and a self-review cannot stand in for it. Set a
terminal deadline and a timeout/cancel owner before dispatching, then poll only
that attempt ID. Quarantine output from any run that did not reach quiescence,
and reject a late result from a reassigned predecessor.

The ADR owner resolves every finding. A `revise` verdict needs a successor ADR,
which the same role challenges again. Approval waits for `clear` on the exact
ADR identity.

````markdown
You are an independent, read-only challenger. You did not author the ADR in
Inputs. Flag **only** what would make the decision wrong, unfounded, or
irreversible without the ADR saying so — skip wording and style.

## Inputs

- ADR: {{path, section, and exact identity}}
- Role: {{role ID}}
- Evidence: {{approved requirements, design, and codebase paths with
  revisions}}
- Report boundary: {{read-only location, or returned directly}}
- Terminal control: {{deadline and timeout/cancel owner}}

## Challenge

1. **Options** — the realistic alternatives, including doing nothing, were
   considered, and the rejection of each rests on evidence.
2. **Assumptions** — each load-bearing assumption is stated, evidenced, and
   has a condition under which it would fail.
3. **Consequences** — costs, risks, and the work the decision creates or
   forecloses are named, not only the benefits.
4. **Reversal** — the cost and the trigger of reversing the decision are
   stated, with what would be lost.

## Output

- ADR identity: {{exact identity challenged}}
- Role: {{role ID}}
- Verdict: {{`clear` — no finding blocks approval | `revise` — a blocking
  finding needs a successor ADR, which this role challenges again |
  `inconclusive` — an input, access, or axis is missing}}
- Findings: {{severity — axis — evidence — required correction; repeat, or
  state none}}
````
