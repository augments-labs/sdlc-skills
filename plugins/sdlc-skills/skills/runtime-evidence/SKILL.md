---
name: runtime-evidence
description: "Answers a question about how existing code behaves by running it, and backs a claim about speed, memory, or size with a controlled measurement. Use when asked what a function returns, whether a case is handled, which branch or code path runs, why an output appears, what a setting resolves to at runtime, or how an installed dependency behaves, and before saying code is faster, lighter, or smaller. Skip when the question is about intent, design, or history, when something is broken and the cause is unknown, or when the code does not exist yet."
---

# Runtime Evidence

A reading of code is a prediction of what it does. When the code can be run,
run it, and answer with what you observed.

## When to use

- The user asks how existing code behaves: what a call returns, whether a
  case is handled, which path runs, what a setting resolves to, how a
  dependency behaves at its installed version.
- You are about to say that code is faster, lighter, or smaller than
  something else.
- **Skip** a question about intent, design, naming, or history: answer it
  from the code and its history.
- If something is broken and the cause is unknown, invoke `debugging`. If
  the code does not exist yet, invoke `prototyping`.
- When nothing can be run, Step 3's labels still apply.

## Step 1: Turn the question into a prediction

1. Write each claim the answer rests on as one sentence that a run can
   check: the input, the state it starts from, and the result your reading
   predicts. Write it before running anything, so a surprise shows.
2. For each claim, pick the smallest run whose output would differ if the
   prediction were wrong, taking the first that exists: a test that asserts
   this exact case; one call through the project's own interpreter, shell,
   or test runner; a scratch driver outside the repository. A run that
   prints the same thing either way checks nothing.

## Step 2: Run it where the question lives

1. Run the state the question is about: the working tree as it is,
   uncommitted changes included. For another revision, run a separate
   checkout of it and remove it afterwards; never switch the user's
   checkout.
2. Use the project's own environment: its interpreter, the versions its
   lockfile resolves, its configuration. Never install or upgrade anything
   to make the run start.
3. Print, in the same run, what was loaded: the file the code under
   question resolved to, and the version of any dependency the claim is
   about. For built code, rebuild first or show the artifact came from this
   tree.
4. Change nothing outside scratch: no write to a shared database, queue,
   remote service, or the user's files. If the run needs one, use the
   project's test fixture, or label the claim `read` in Step 3. Never edit
   the checkout to watch it: raise the project's own log level, attach a
   debugger or tracer, or run a scratch copy. Afterwards
   `git status --short` prints what it printed before.
5. Read `references/performance-claims.md` before measuring speed, memory,
   or size.
6. If the run fails to start for a reason unrelated to the claim, correct
   the invocation and rerun, twice at most. Then label the claim `read` and
   say what blocked the run.

## Step 3: Answer with labels

1. Lead with the answer. Then give each claim one line:

   ```text
   observed: {{claim}} — `{{command}}` at {{revision, plus "dirty" with uncommitted changes}} printed {{the raw line}}
   read: {{claim}} — not run: {{what blocked it}}; the run that settles it: {{command or setup}}
   ```

2. If the output contradicts the prediction, the output is the answer. Say
   what the reading got wrong and what misled it: a comment, a name, a
   document. Fix neither the code nor the document unasked.
3. An observation covers the inputs that ran. "Handles every such input",
   drawn from one run, is a `read` claim; label it so.
4. Never state a `read` claim as plain fact about behavior.

## Gotchas

- The definition you read may not be the one that runs: a decorator, a
  patch applied at import, an injected implementation, an override in a
  subclass, or an installed copy of the package can replace it. Step 2.3's
  printed path is the check.
- A default in the source is not the value at runtime: an environment
  variable, a configuration file, a flag, or a command-line option
  overrides it. Print the resolved value in the run.
- A passing test named for the behavior is an observation only when it
  asserts the case asked about and does not replace the code under question
  with a double. Read its assertion.
- What you recall of a dependency describes some release, not the one the
  lockfile resolves.
- Ordering, timing, and anything read from a clock, a random source, an
  unordered collection, or the network can differ between runs. Run it
  again before calling one output the behavior.
