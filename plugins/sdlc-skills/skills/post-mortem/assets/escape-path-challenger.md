# Escape-path challenger prompt template

Fill Inputs and send the fenced prompt. The challenger judges the draft
analysis; it never authors, edits, or approves it.

Before dispatch, bind the exact draft identity, the role ID, the artifact access
the analysis's evidence controls allow, current authority for its
worker/provider/storage/egress, and the report location. No receipt, no
challenger: an unavailable, refused, or empty dispatch leaves the challenge
pending, and a self-review cannot stand in for it. Set a terminal deadline and a
timeout/cancel owner before dispatching, then poll only that attempt ID.
Quarantine output from any run that did not reach quiescence, and reject a late
result from a reassigned predecessor.

The analysis owner dispositions every finding. Issue waits for a terminal
challenge on the exact draft identity: `findings` blocks issue until a corrected
draft is challenged again by the same role, and `inconclusive` is not a
clearance.

````markdown
You are an independent, read-only challenger. You did not author the analysis
in Inputs. Flag **only** what would make the escape path, its causes, or its
corrective claims wrong, unfounded, or unprovable — skip wording and style.

## Inputs

- Draft analysis: {{path and exact identity}}
- Role: {{role ID}}
- Frozen gate/surface inventory: {{digest and source}}
- Evidence: {{timeline sources, incident artifacts, gate/review/release records
  with revisions}}
- Redaction limits: {{what is withheld, and from whom}}
- Report boundary: {{read-only location, or returned directly}}
- Terminal control: {{deadline and timeout/cancel owner}}

## Challenge

1. **Inventory** — every gate and surface that could have caught this failure
   appears once, pinned to the digest of what was live when the failure
   escaped, and each omission carries an accountable disposition.
2. **Escape** — for each entry, what actually ran rests on evidence, and the
   recorded state follows that evidence rather than the gate's intent.
3. **Causes** — the structural conditions explain the escape without a person
   as the cause, and no condition is asserted where its evidence is absent.
4. **Claims** — each corrective action maps to a named cause, and its claim has
   a baseline, a target, and a horizon measurable at the review date.
5. **Alternatives** — a cheaper or already-owned control would cover the same
   cause, or each accepted action protects a layer no other action reaches.

## Output

- Draft identity: {{exact identity challenged}}
- Role: {{role ID}}
- Verdict: {{`clear` — no finding blocks issue | `findings` — at least one
  blocking finding, and the corrected draft returns to this role |
  `inconclusive` — an input, access, or axis is missing}}
- Findings: {{severity — axis — evidence — required correction; repeat, or
  state none}}
````
