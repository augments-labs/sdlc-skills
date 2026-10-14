---
name: feasibility-check
description: "Checks whether an initiative can be delivered before committing to it: technical, delivery, budget, operational, security, data, and dependency risk. Use when an initiative's feasibility is uncertain, including proven technology under uncertain delivery constraints. Skip when its material feasibility risks are settled and low."
---

# Feasibility Check

Before commitment, assess the killer risks honestly and put a recommendation
backed by evidence to the accountable owner.

## When to use

- Before committing to a project or initiative (the go/no-go moment).
- When feasibility is genuinely uncertain: new technology, hard constraints,
  unknown data.
- **Skip** only when an existing feasibility section already fills every
  dimension row from evidence and no row is `unknown`.
- **Solo owner**: when the user is the only stakeholder, they own every
  dimension row and every go-if condition, so Step 1.1's owner lookup is
  skipped.

## Step 1: Assess

Open `assets/feasibility-section.md` before starting; each step fills its
section.

1. Fill every dimension row with its accountable owner: technical, delivery
   and budget, operations and recovery, security and compliance, data,
   external dependencies. "Technically possible" answers one row, not the
   others. Every owner this section names, go-if conditions included, comes
   from the approved goals' decision rule and stakeholder roles. If no owner
   is named there, ask the user who owns it; never invent one.
2. List the killer assumptions: the assumptions that sink the goal if they
   are false. Rank them by likelihood × impact. For each risk, record the
   evidence source, its freshness (the date the evidence was taken), and the
   confidence. `unknown` is a valid confidence.
3. Turn the top unknown into a bounded question for `prototyping`, not into
   more discussion. One spike answers one dimension.
4. Fill Option Zero with evidence for whether not building, an existing
   tool, configuration, or process, or a smaller initiative meets the goal
   and guardrails.

## Step 2: Recommend and present

1. Write go / no-go / go-if, bound to the exact version of the
   recommendation. For each go-if condition, record a stable ID, its gate
   (the check that must accept the condition) or its evidence, an owner, an
   expiry, its state, `pending / satisfied / failed`, and the abort response.
2. Write the `## Feasibility` section, which is never edited after it is
   written, to `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` or the
   user-set path, and leave the approved sections around it untouched.
3. Present:

   ```text
   Feasibility {{path}} — version {{identity (per template)}}
   Recommendation: {{go | no-go | go-if}}
   Top risks: {{list with confidence}}
   Conditions: {{each with owner and gate}}

   1. Go
   2. Go-if every named condition is met
   3. No-go
   4. Cancel

   Recommendation: {{option}} — {{one sentence of evidence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
4. On a go-if, only the named evidence and owner move a condition's external
   state (its state in the ledger the template names: add to it, never
   rewrite it). On expiry, or on any change to a bound input, gate,
   evidence, owner, or freshness, the condition is invalid and the decision
   is reopened.
5. **REQUIRED SUB-SKILL:** on a direct go, or a go-if with every condition
   `satisfied`, invoke `scoping` when the boundary is next. Never impose a
   phase already complete.

## Gotchas

- Filling in Option Zero with a bare assertion ("no existing tool fits")
  instead of the same evidence the other dimensions require still counts
  as skipped in substance; it only looks done.
- Giving a risk a confidence level it has not earned, rather than recording
  "unknown", passes off a risk with no real evidence as one that reads as
  already assessed.
