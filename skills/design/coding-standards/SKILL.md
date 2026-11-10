---
name: coding-standards
description: "Settles the conventions agents and humans both follow in a project: domain vocabulary, naming, patterns to reach for, and things to never do. Use when a project needs its conventions settled, once per project or when they have drifted, or when the user asks for a style guide or house rules, says the codebase is inconsistent, or asks how something should be named. Skip when clear standards already exist and are followed, and skip proving the code correct."
---

# Coding Standards

## When to use

- Starting a project, or when conventions have drifted and the code reads like several authors.
- **Skip** if the project already has clear standards that are actually followed.

## Step 1: Settle the vocabulary and the patterns

Open `assets/standards-template.md` before starting. Fill a section only with what this project has; the template says what an empty one carries. Read `references/standards-example.md` when the first draft is written and needs comparing against a filled example.

1. If an approved `data-model` or domain contract exists, take its concepts
   and terms. Decide only their representation (how each term appears in
   code), casing, abbreviations, and the enforcement that catches drift from
   them. Never decide their meaning, and never rename one. If there is a
   dispute about what a concept is, invoke `data-model`.
2. If there is no contract, derive the terms from the domain evidence you
   can see.
3. Ban a generic label wherever a domain term exists. Keep the glossary
   current.
4. Give the one short pattern example the template asks for.
5. Where one thing is done several ways, count each form across the whole
   tree by search, not from sampled files, and record the counts with the
   form chosen.

## Step 2: Assign enforcement

1. Read the project's formatter, linter, and type-check configuration
   first: a rule that disagrees with it changes that configuration in this
   proposal or is dropped. Assign enforcement to each rule. If the rule can
   be detected statically,
   assign a formatter, linter, type or static check, or repository check
   that fails. If the rule is about vocabulary, architecture, or judgement,
   assign a named review rubric and a named owner.
2. The warning budget is zero. Never leave a permissive default. Where
   warnings already exist, record each rule's count today as a Step 2.4
   exception; a change may lower it, never raise it.
3. Point to the exemplar (the file that does all of the above right). Run
   its checks and rubric now. If the project is greenfield and has no
   exemplar, name the first artifact and its owner; adoption stays pending.
   Never fabricate a path.
4. Each exception needs an approver, a scope, a reason, an expiry, and a
   compensating check.

## Step 3: Write and present

1. Write the immutable section (the standard itself: once issued, a change
   to it is a successor version, never an edit) to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` or the user-set path,
   preserving approved sections around it.
2. Present:

   ```text
   Coding standards {{path}} — version {{identity (per template)}}
   Vocabulary: {{n}} terms  Patterns: {{n}}  Nevers: {{n}}
   Enforcement: {{n}} automated, {{n}} review  Exemplar gate: {{result}}

   1. Approve
   2. Request changes
   3. Reject
   4. Cancel

   Recommendation: {{option}} — {{one sentence}}.
   ```

   Ask this and end the turn; `clarifying-intent` owns what closes it.
3. If the answer is option 1, claim adoption only after enforcement and the
   exemplar gate (the exemplar's checks and rubric from Step 2.3) have run.
   Record `in force / suspended / superseded` outside the section, in the
   external adoption ledger the template names (its record of adoption),
   with fresh evidence. Then print the one line that points the project's
   agent instruction file at this path, for the user to add; never edit
   that file.

## Gotchas

- An exception granted with no expiry never comes back for review. The
  carve-out becomes a second, permanent convention living alongside the
  one it was supposed to be an exception to.
- Enforcement usually checks new or changed code, not a one-time sweep of
  everything already there, so banning a generic label going forward can
  leave every existing occurrence exactly as inconsistent as before.

