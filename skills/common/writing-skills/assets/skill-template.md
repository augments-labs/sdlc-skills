---
name: {{skill-name-kebab}}
description: "{{What the skill does}}. Use when {{situations in the user's words, with the keywords a task would contain}}. {{Optional near-miss exclusion, only when a real one exists.}}"
---

# {{Skill Title}}

{{One or two sentences: the core principle, or the problem this prevents.}}

## When to use

- {{trigger condition}}
- **Skip** when {{trivial or out-of-scope case}}.

## Step 1: {{name the act}}

1. {{one-line act}}
2. {{condition}} → {{act}}
3. Read `references/{{file}}.md` when {{condition}}.
4. {{When a handoff is needed: REQUIRED SUB-SKILL, its entry condition, input,
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

## Step 3: {{check the result}}

1. {{do the work}}.
2. Run {{the check}} and read what it reports.
3. It fails → fix the cause, then run it again. Repeat until it passes.

## Gotchas

- {{a fact the agent gets wrong when untold}} — prevents {{the failure}};
  reproduced by {{the probe or scenario}}.

## Common mistakes

- {{a failure mode the steps do not already forbid}} → {{what to do instead}}.
