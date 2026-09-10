---
name: coding-standards
description: "Use once per project, or when conventions have drifted, to settle the conventions agents and humans both follow — domain vocabulary, naming, patterns to reach for, things to never do. Fires on a request for a style guide or house rules, on the codebase is inconsistent, and on how should we name this, even if nobody says standards or conventions. Skip when the project already has clear, followed standards, and when the question is proving the code correct — tests, quality gates, CI."
---

# Coding Standards

Set the conventions once so every contributor — human or agent — writes code that reads like one author. The highest-leverage standard is **shared vocabulary**: name things from the domain, consistently, so the same concept is never two words.

## When to use

- Starting a project, or when conventions have drifted and the code reads like several authors.
- **Skip** if the project already has clear standards that are actually followed.

## Step 1: Fix the vocabulary and the patterns

Open `assets/standards-template.md` now. Each step fills its section.

1. Approved `data-model` or domain contract exists → take its concepts and
   terms. Decide only representation, casing, abbreviations, drift
   enforcement. Never their meaning, never a rename. Dispute about what a
   concept is → `data-model`.
2. No contract → derive terms from the domain evidence you can see.
3. Ban a generic label wherever a domain term exists. Keep the glossary
   current.
4. Name the one way this project does each: error handling, validation,
   async, dependency injection, testing seams. One short example each.
5. Write the hard nevers. Keep the list short.

## Step 2: Assign enforcement

1. Per rule: statically detectable → a formatter, linter, type or static
   check, or repository check that fails. Vocabulary, architecture, judgement
   → a named review rubric and a named owner.
2. Set each check's strictness deliberately. Warning budget zero. Never leave
   a permissive default.
3. Point to the exemplar. Run its checks and rubric now. Greenfield with none
   → name the first artifact and owner; adoption stays pending. Never
   fabricate a path.
4. Name which project instruction wins on conflict and who approves an
   exception. Each exception: scope, reason, expiry, compensating check.
5. Name the drift-review cadence or trigger and who updates the standard.

## Step 3: Write and present

1. Write the immutable section to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the project's
   standing conventions path, preserving approved sections around it.
2. Present and end the turn:

   ```text
   Coding standards {{path}} — version {{identity}}
   Vocabulary: {{n}} terms  Patterns: {{n}}  Nevers: {{n}}
   Enforcement: {{n}} automated, {{n}} review  Exemplar gate: {{result}}

   1. Approve
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

3. Only option 1 hands off. Record lifecycle externally. Normative change →
   a successor with a per-ID `added / changed / removed / preserved` delta.
   Removal needs owning approval. Never edit an issued identity.
4. Claim adoption only after enforcement and the exemplar gate run. Record
   `in force / suspended / superseded` externally with fresh evidence.

## Common mistakes

- A long list of rules no one reads — keep it to what actually matters here.
- Standards told but never shown — point to a real exemplar file.
- Generic vocabulary that lets one concept drift into many names.
- “Reviewers will catch it” with no rubric, owner, or checked exemplar.
