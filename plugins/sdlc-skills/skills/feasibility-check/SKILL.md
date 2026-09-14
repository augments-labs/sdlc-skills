---
name: feasibility-check
description: "Checks whether an initiative can be delivered before committing to it: technical, delivery, budget, operational, security, data, and dependency risk. Use when an initiative's feasibility is uncertain, including proven technology under uncertain delivery constraints. Skip when its material feasibility risks are settled and low."
---

# Feasibility Check

Optimism is not a plan. Before commitment, assess the killer risks honestly and
put an evidence-bound recommendation to the accountable owner.

## When to use

- Before committing to a project or initiative (the go/no-go moment).
- When feasibility is genuinely uncertain — new tech, hard constraints, unknown data.
- **Skip** when the path is well-trodden and the risk is obviously low.

## Step 1: Assess

Open `assets/feasibility-section.md` before starting; each step fills its
section.

1. Fill every dimension row with its accountable owner: technical, delivery
   and budget, operations and recovery, security and compliance, data,
   external dependencies. "Technically possible" answers one row.
2. List the killer assumptions: false → the goal sinks. Rank likelihood ×
   impact. Per risk: evidence source, freshness, confidence. `unknown` is a
   valid confidence.
3. Top unknown → a bounded `prototyping` question, not more discussion. One
   spike answers one dimension.
4. Fill Option Zero: evidence for whether not building, an existing tool,
   configuration, or process, or a smaller initiative meets the goal and
   guardrails.

## Step 2: Recommend and present

1. Write go / no-go / go-if bound to the exact recommendation version. Per
   go-if condition: stable ID, evaluator or evidence, owner, expiry, state
   `pending / satisfied / failed`, abort response.
2. Write the immutable `## Feasibility` section to
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it.
3. Present:

   ```text
   Feasibility {{path}} — version {{identity}}
   Recommendation: {{go | no-go | go-if}}
   Top risks: {{list with confidence}}
   Conditions: {{each with owner and evaluator}}

   1. Go
   2. Go-if every named condition is met
   3. No-go
   4. Cancel

   Recommendation: {{option}} — {{one sentence of evidence}}.
   ```

   Ask through the harness's user-input action when one exists, else print this block; end the turn; `interview-me` owns what closes it.
4. Go-if → only the named evidence and owner move a condition's external
   state. Expiry, or any change to a bound input, evaluator, evidence, owner,
   or freshness → condition invalid, decision reopened.
5. **REQUIRED SUB-SKILL:** on a direct go, or go-if with every condition
   `satisfied`, invoke `scope-it` when the boundary is next. Never impose a
   phase already complete.

## Gotchas

- Filling in Option Zero with a bare assertion ("no existing tool fits")
  instead of the same evidence the other dimensions require still counts
  as skipped in substance — it only looks done.
- Assigning a risk a confidence level it hasn't earned, rather than
  recording "unknown", launders a risk with no real evidence into one
  that reads as already assessed.

## Common mistakes

- Greenlighting on optimism — no named risks means you didn't look.
- Treating "we'll figure it out" as feasibility — name what would make it *infeasible*.
- Endless analysis instead of a cheap spike to kill the biggest unknown.
- Treating a technical proof as delivery, operational, compliance, or recovery
  proof.
- Skipping Option Zero — the cheapest path is sometimes to not build it: an existing tool, a config change, or a smaller change to the problem. Rule it out before greenlighting a build.
