# Performance claims

Read this before measuring speed, memory, or size. It holds the conditions a
measurement must meet before `../SKILL.md` Step 3 may call it `observed`.

## State the comparison

Write the claim as a comparison before measuring: the metric (wall time,
peak memory, artifact size), the workload and its input size, the baseline,
and the difference that would matter. "Faster" with no baseline is not a
claim a run can check.

## Change one thing

- Measure the baseline; never recall it or quote an earlier session. Run a
  separate checkout of the base revision through the same harness.
- Hold the rest equal: machine, build mode, inputs, data size, dependency
  versions, configuration. Measure an optimized build when that is what
  ships; a debug build measures the debug build.
- Take baseline and candidate in the same session and alternate them (A, B,
  A, B). Load on the machine drifts, and two blocks measured apart measure
  the drift.
- Use the project's benchmark harness when one exists. Otherwise write a
  scratch driver outside the repository. Never add a benchmarking dependency
  to the project to answer a question.

## Make the number mean something

- Discard warm-up runs: caches, lazy loading, connection setup, and runtime
  compilation make the first runs slower. When the claim is about a cold
  start, measure a fresh process each time and say so.
- Repeat each side at least ten times, or five when one run takes more than
  a minute. Report the median and the range, never the best run and never a
  single run.
- A difference smaller than the range between runs of one side is "no
  measurable difference".
- Check the work happened. A result nobody reads can be skipped by the
  compiler or the runtime, and a cached answer returns without doing the
  work: use the output and assert its value in the driver.
- Use an input of the size the claim is about. A tiny input measures call
  overhead. For a claim about how cost grows, measure at least three sizes.
- Memory: report peak use of a fresh process per run, and say which figure
  it is (resident or allocated).
- Size: measure the artifact as it is delivered, compressed if it ships
  compressed, never the source.
- On a shared runner, a laptop on battery, or a machine under other load,
  say so and raise the repeat count. If the range stays wider than the
  difference, the verdict is `inconclusive`.

## Report

```text
measured: {{metric}} on {{workload and input size}}; {{machine, build mode}}
baseline {{revision}}: median {{value}}, range {{min}} to {{max}}, n={{n}}
candidate {{revision}}: median {{value}}, range {{min}} to {{max}}, n={{n}}
verdict: {{faster by n% | slower by n% | no measurable difference | inconclusive: reason}}
```

The measurement holds for this workload on this machine. A claim about
production needs a run on production-like load and data; without one, label
that part `read`.
