---
name: {{skill-name-kebab}}
description: Use when {{trigger conditions — when this applies}}. {{One sentence on what it does.}} Skip when {{negative trigger}}.
---

# {{Skill Title}}

{{One or two sentences: the core principle, or the problem this prevents.}}

## When to use

- {{trigger condition}}
- **Skip** when {{trivial or out-of-scope case}}.

## Step 1: {{name the act}}

1. {{one-line act}}
2. {{condition}} → {{act}}
3. **REQUIRED SUB-SKILL:** invoke `{{skill}}` {{at this point; what this skill never does itself}}

## Step 2: {{name the act}}

1. {{one-line act}}
2. Present and end the turn:

   ```text
   {{the exact question}}

   1. {{option}}
   2. {{option}}

   Recommendation: {{option}} — {{one sentence}}.
   ```

## Common mistakes

- {{failure mode}} → {{what to do instead}}.
