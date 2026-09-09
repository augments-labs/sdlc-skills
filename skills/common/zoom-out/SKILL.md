---
name: zoom-out
description: "Use before working in a region of the codebase whose structure you have not established — map the relevant modules, their callers, and the project's own vocabulary before changing anything. Fires whenever a request names an unfamiliar file, module, or area, even when the user never says they are new to it and never asks to be oriented. A structural question — what reaches this, what it reaches, how a change travels through it — is the same trigger. Skip when the area is already understood."
---

# Zoom Out

Before you touch unfamiliar code, understand its shape. The failure this prevents is editing a region by pattern-matching on syntax while missing how it actually fits together — who calls it, what it owns, where the boundaries are.

## When to use

- You're about to change, debug, or extend a part of the codebase you don't know well.
- **Skip** only when you already understand the region and affected surfaces;
  one changed line can still alter a public, data, security, or release path.

## Procedure

1. **Set breadth from risk.** Before reading anything, say what change you intend
   and how far it could plausibly reach, and why the boundary you picked is wide
   enough to hold that reach. A local edit may need one module; a wide or
   compatibility-sensitive change cannot stop at direct callers.

   Then pin what you are reading against: the repository or working state, and the
   identity of any material external input the map will lean on. Say what makes
   that reading stale.
2. **Go up a layer.** Start at the containing module and its neighbors. Identify
   responsibilities, runtime entry points, callers, collaborators, and the data
   flowing between them.
3. **Inspect affected surfaces.** As the risk warrants, trace generated code and
   build inputs; persistent state and migrations; public contracts and
   consumers; configuration, deployment, and operational paths; tests, CI, and
   other proof surfaces; and relevant ownership or change history. Record an
   evidence-based reason for each material surface excluded.
4. **Use the domain's vocabulary**, not generic "service / handler / util," so
   the map matches the code and its contracts.
5. **Cite the evidence.** Attach each conclusion to current files, symbols,
   searches, commands, or revisions. Separate observed facts from inference and
   mark anything stale or unavailable. The map's input identity covers every
   material source and external fact on which its conclusions rely.
6. **State the boundaries you found:** what the region owns, what it delegates,
   where its seams are, and which downstream obligations a change has to
   preserve.

   The map has a shelf life. Once it is past the freshness limit you set, or a
   material input has changed, revalidate the affected claims against current
   evidence before relying on them. If implementation turns up a caller or a
   surface the map never covered, stop and reorient rather than extending the map
   from memory.

## Common mistakes

- Editing first and understanding later — the pattern-match that looks right and isn't.
- A map of files instead of responsibilities — paths don't tell you what owns what.
- Tracing direct imports while missing generated inputs, stored state, external
  consumers, or deployment paths that carry the real blast radius.
- Presenting remembered architecture as current repository evidence.
- Reusing a previously correct map after its source or external inputs changed.
- Generic vocabulary that doesn't match how the team talks about the code.
