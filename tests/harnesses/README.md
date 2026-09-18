# tests/harnesses/

One file per coding-agent CLI, holding **only what differs between them** in how
the plugin is installed and discovered. `tests/run-plugin-smoke.sh` sources the
file for the harness it is given; nothing executes these files directly, and
none of them decides anything — judging an observation belongs to the runner.

## The contract

```text
tests/harnesses/
  claude-code.sh
  codex.sh
  kimi-code.sh
  opencode.sh
```

Required:

- `adapter_check` — return 3 when the CLI is not on `PATH`.
- `adapter_install` — take the plugin source and install it into a throwaway
  home recorded in `harness_home`, which the runner removes. A harness that
  loads a tree in place also sets `plugin_dir`. CLI errors go to the runner's
  `$errlog`.

Optional:

- `adapter_component_inventory` — print the skill names the CLI itself resolved
  from the plugin. Without it the smoke test counts `SKILL.md` files in the
  installed layout, which cannot prove the manifest entries were accepted.

An install never writes to the operator's own CLI home; credentials are copied
into the throwaway home.

## Adding a harness

Add `{{name}}.sh` implementing the contract above.
Bindings alone do not make a harness supported — what one has to prove before
claiming support is in `docs/harness-support.md`.

## Regression net

Run plugin smoke whenever an adapter changes.
