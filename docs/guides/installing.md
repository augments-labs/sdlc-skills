# Installing, updating, and removing

Installation differs by agent. If you use more than one agent, install the
library in each. The commands below are the same as in the
[README](../../README.md#installation); this page adds what each agent does
with the files, how to update, and how to remove the library where the agent
offers a way.

Several agents install from a local copy of this repository. For those,
clone it first:

```bash
git clone https://github.com/augments-labs/sdlc-skills.git
```

When you are done, [Your first session](first-session.md) shows how to check
that the skills loaded.

## Claude Code

Register the marketplace, then install the plugin:

```text
/plugin marketplace add augments-labs/sdlc-skills
/plugin install sdlc-skills@augments-labs
```

Claude Code keeps its own copy of the plugin. To update, refresh the
marketplace first and then update the plugin; the new version applies on the
next restart:

```bash
claude plugin marketplace update augments-labs
claude plugin update sdlc-skills@augments-labs
```

## Codex CLI

Codex installs from a local clone. Register the clone as a marketplace, then
install the plugin:

```bash
codex plugin marketplace add /path/to/sdlc-skills
codex plugin add sdlc-skills@augments-labs-dev
```

Codex installs the plugin directory inside the repository
(`plugins/sdlc-skills/`), not the repository root. It keeps its own copy, so
pulling the clone does not change what is installed; install again after
you pull.

## Kimi Code

Install from this repository, then reload:

```text
/plugins install https://github.com/augments-labs/sdlc-skills
/reload
```

You can also use the `/plugins` manager and its Custom tab.

## OpenCode

Add the plugin to your `opencode.json`, either the global one or the project
one, then restart OpenCode. The key is named differently in the two
generations.

OpenCode 1.x:

```json
{
  "plugin": ["sdlc-skills@git+https://github.com/augments-labs/sdlc-skills.git"]
}
```

OpenCode 2.x:

```json
{
  "plugins": ["sdlc-skills@git+https://github.com/augments-labs/sdlc-skills.git"]
}
```

To use a local clone instead, name `.opencode/plugins/sdlc-skills.js` inside
the clone on 1.x, or the clone directory itself on 2.x.

If the skills do not show up, run `opencode run --print-logs` on 1.x or
`opencode run --standalone --print-logs` on 2.x, and look for the line that
names the plugin entry point.

## Grok Build

Grok installs from a local clone and needs one extra file, because it has no
session-start hook that can hand the routing skill to the agent.

1. Install the plugin:

   ```bash
   grok plugin install /path/to/sdlc-skills --trust
   ```

2. Create `$GROK_HOME/rules/using-sdlc-skills.md` (the default location is
   `~/.grok/rules/`) containing this line:

   ```text
   Invoke the `using-sdlc-skills` skill before acting.
   ```

The install copies the clone into Grok's own directory, so pulling the clone
later does not change what is installed; install again after you pull. The
rules file is read for every project, whether or not the folder is trusted.

## Muse Code

Muse installs from a local clone. From inside the clone, run:

```bash
bash scripts/sh/install-muse-skills.sh
```

To remove the skills later:

```bash
bash scripts/sh/install-muse-skills.sh --remove
```

Muse 1.3.0 does not load plugins, so the script installs the skills one at a
time and the agent can see them, but nothing hands it the routing skill.
Start each session by asking the agent to invoke `using-sdlc-skills`. Running
the script again overwrites the installed skills, which is how you update.

A Muse build that ships plugin support installs `.muse-plugin/plugin.json`
instead, which declares the session-start hook. This has not been observed on
a real build.

## pi

pi installs from a local clone:

```bash
pi install /path/to/sdlc-skills
```

Add `-l` to register it for the current project only.

pi registers the clone by reference and copies nothing, so keep the clone
where it is. Running `git pull` inside it updates the skills.

## Devin

Devin installs the plugin directory inside this repository, not the
repository root. Devin's plugin commands refuse to run signed out, even for a
local directory, so sign in first with `devin auth login`. Then run:

```bash
devin plugins install augments-labs/sdlc-skills#plugins/sdlc-skills
```

This adds the plugin to your personal plugins, which follow your account to
other machines. To install from a local clone on this machine only:

```bash
devin plugins install --local /path/to/sdlc-skills/plugins/sdlc-skills
```

A local install links the folder in place: Devin creates a symlink to it in
its plugin cache. Keep the clone where it is, because removing it breaks the
install. Running `git pull` inside it updates the skills. The install also
checks your organisation's plugin policy over the network.

## Antigravity

Antigravity installs the plugin directory inside this repository, not the
repository root:

```bash
agy plugin install https://github.com/augments-labs/sdlc-skills/tree/main/plugins/sdlc-skills
```

To install from a local clone instead:

```bash
agy plugin install /path/to/sdlc-skills/plugins/sdlc-skills
```

Either way, Antigravity copies the directory into
`~/.gemini/config/plugins/sdlc-skills/`. A local install needs no sign-in and
no network. Antigravity runs no session-start hook from a plugin, so the
plugin ships an always-on rule telling the agent to invoke
`using-sdlc-skills` before acting.

Because the install is a copy, pulling a newer clone does not change it. To
update, run `agy plugin uninstall sdlc-skills` and install again.

## Hermes

```bash
hermes plugins install augments-labs/sdlc-skills --enable
```

Hermes installs from a catalog name, a git URL, or `owner/repo`, never from a
local path. It clones the repository into `$HERMES_HOME/plugins/sdlc-skills`
and, with `--enable`, turns the plugin on.

Two things you will see during the install:

- Hermes asks whether to install Node dependencies, because the repository
  has a `package.json`. Answer no: the plugin needs none.
- Hermes logs a warning that it could not parse `.muse-plugin/plugin.json`.
  That file belongs to another agent. The warning is harmless and the plugin
  loads as usual.

## Cursor

Cursor loads plugins cloned into its local plugins folder:

```bash
git clone https://github.com/augments-labs/sdlc-skills.git ~/.cursor/plugins/local/sdlc-skills
```

Cursor ignores a symlink there that points outside that folder, so clone into
it rather than linking an existing clone. To update, run `git pull` inside
it. To remove, delete the folder.

## Other agents

Every skill follows the open Agent Skills format: a directory with a
`SKILL.md` file and YAML frontmatter. An agent that reads that format can
load the skills. [Using the skills on another agent](other-agents.md)
explains what you need beyond making the files visible.
