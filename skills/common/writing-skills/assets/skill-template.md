---
name: {{skill-name-kebab}}
description: Use when {{plain trigger conditions}}. {{Optional near-miss exclusion, only when a real one exists.}}
---

# {{Skill Title}}

{{One or two sentences: the core principle, or the problem this prevents.}}

## When to use

- {{trigger condition}}
- **Skip** when {{trivial or out-of-scope case}}.

## Step 1: {{name the act}}

1. {{one-line act}}
2. {{condition}} → {{act}}
3. {{When a handoff is needed: REQUIRED SUB-SKILL, its entry condition, input,
   return value, and the caller step that resumes. Omit otherwise.}}

## Step 2: {{name the act}}

1. {{one-line act}}
2. {{Only when an unresolved material decision needs the user's answer,
   present the choices and wait. Reuse a current answer already given.
   Omit this step for work with no such decision.}}

   ```text
   {{the exact question}}

   1. {{option}}
   2. {{option}}

   Recommendation: {{option}} — {{one sentence}}.
   ```

## Common mistakes

- {{failure mode}} → {{what to do instead}}.
