---
name: zoom-out
description: "Use before working in a region of the codebase whose structure you have not established — its modules, their callers, and the project's own vocabulary. Fires whenever a request names an unfamiliar file, module, or area, and on any structural question — what reaches this, what it reaches, how a change travels through it — even if nobody asks to be oriented. Skip when the area is already understood."
---

# Zoom Out

Before you touch unfamiliar code, understand its shape. The failure this prevents is editing a region by pattern-matching on syntax while missing how it actually fits together — who calls it, what it owns, where the boundaries are.

## When to use

- You're about to change, debug, or extend a part of the codebase you don't know well.
- **Skip** only when a Step 3 boundary record for this region exists and is
  inside its freshness limit; one changed line can still alter a public,
  data, security, or release path.

## Step 1: Set the boundary

1. Before reading anything, write the intended change, how far it could
   reach, and why the boundary you picked holds that reach. Compatibility-
   sensitive change → never stop at direct callers.
2. Pin the repository or working state and the identity of every material
   external input. Write what makes the reading stale.

## Step 2: Map

1. Start at the containing module and its neighbors: responsibilities,
   runtime entry points, callers, collaborators, data between them.
2. As risk warrants, trace: generated code and build inputs; persistent
   state and migrations; public contracts and consumers; configuration,
   deployment, operational paths; tests, CI, proof surfaces; ownership and
   change history. Per excluded material surface → an evidence-based reason.
3. Use the domain's vocabulary, never "service / handler / util".
4. Attach each conclusion to current files, symbols, searches, commands, or
   revisions. Separate observed from inferred. Mark stale or unavailable.

## Step 3: State the boundaries

1. Write the boundary record: what the region owns, what it delegates, where
   its seams are, which downstream obligations a change must preserve.
2. Set a freshness limit. Past it, or a material input changed → revalidate
   affected claims before relying on them.
3. Implementation finds a caller or surface the map never covered → stop and
   reorient. Never extend the map from memory.

## Common mistakes

- Editing first and understanding later — the pattern-match that looks right and isn't.
- A map of files instead of responsibilities — paths don't tell you what owns what.
- Tracing direct imports while missing generated inputs, stored state, external
  consumers, or deployment paths that carry the real blast radius.
- Presenting remembered architecture as current repository evidence.
- Reusing a previously correct map after its source or external inputs changed.
- Generic vocabulary that doesn't match how the team talks about the code.
