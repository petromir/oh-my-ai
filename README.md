# Oh my AI

Scripts, skills, agents, and everything necessary to make AI work better for us, so we can finally have more time   
to go to the beach 🏖️ 

## Usage

To use these configurations, install them into your project or global config directories.

### Installing Configs & Skills

Running `install-configs.sh` does two things in one pass:

1. Copies each assistant's configuration directory from `configs/<assistant>` (e.g. `configs/gemini`, `configs/opencode`, `configs/pi`, `configs/oh-my-pi`) into that assistant's config directory under `$HOME` (`~/.gemini`, `~/.config/opencode`, `~/.pi/agent`, `~/.omp/agent`).
2. Copies every shared skill from `configs/common/.agents/skills` into each assistant's `skills` directory (Gemini, Copilot, Claude, OpenCode, Pi, Oh-My-Pi, and generic `~/.agents/skills`).

```bash
./install-configs.sh
```

By default, the script targets **all** assistants and skips existing files/directories.

> **Note:** Config directories only exist for `gemini`, `opencode`, `pi`, and `oh-my-pi` — Copilot and Claude have no dedicated config folder and only receive shared skills. The Oh-My-Pi key is `oh-my-pi` (no `omp` alias).

#### Options

- `-f`: Force override existing configs/skills.
- `-s`: Skip installing shared skills; only assistant configs are installed.
- `-m <mode>`: Config mode (OpenCode only). The only valid value is `yolo`, which installs `opencode-yolo.jsonc` as `opencode.jsonc`. Omit it for the default behaviour (install `opencode.jsonc` only).
- `-a <assistant>`: Specify target assistant (`opencode`, `pi`, `oh-my-pi`, `agents`, `gemini`, `copilot`, `claude`, or `all`). You can also provide a comma-separated list.

**Examples:**

```bash
# Install only for OpenCode
./install-configs.sh -a opencode
```

```bash
# Install for OpenCode and Pi, forcing override
./install-configs.sh -f -a opencode,pi
```

```bash
# Install assistant configs only, skipping shared skills
./install-configs.sh -s -a gemini
```

```bash
# Install OpenCode in yolo mode
./install-configs.sh -m yolo -a opencode
```

#### Removing Configs &amp; Skills

The install can be undone with the `remove` command. It only deletes the items this script would have installed (e.g. `configs/gemini/.gemini/antigravity-cli`, or a single shared skill directory) — it never wipes an entire `~/.gemini`, `skills`, or config directory, so anything else living alongside it is left untouched.

```bash
# Remove installed assistant configs
./install-configs.sh remove configs

# Remove installed shared skills
./install-configs.sh remove skills
```

`-a <assistant>` scopes either command the same way it scopes installation. `-f` and `-s` do not apply to `remove`.

**Examples:**

```bash
# Remove Pi's installed configs only
./install-configs.sh remove configs -a pi
```

```bash
# Remove shared skills from Gemini and OpenCode only
./install-configs.sh remove skills -a gemini,opencode
```

### Setting Environment Variables

To append environment variables to your shell configuration files (`~/.zshrc`, `~/.zprofile`, `~/.bashrc`, `~/.bash_profile`), run:

```bash
./set_env_vars.sh
```

By default, the script updates **all** shell configs. You can target specific shells or force the overwriting the 
existing definitions.

#### Options

- `-s <shell>`: Specify target shell (`bash`, `zshell`, or `all`). Can be used multiple times.
- `-f`: Force overwrite existing variable definitions.
- `-v`: Enable verbose output.

**Examples:**

```bash
# Update only Bash configs
./set_env_vars.sh -s bash

# Update both Bash and Zsh configs
./set_env_vars.sh -s bash -s zshell

# Update all configs, forcing overwrite
./set_env_vars.sh -f
```

> **Note:** Edit the `ENV_VARS` array inside the script to configure which variables are set.

#### Pre-configured Environment Variables

The script comes with the following environment variables already configured:


| Variable                           | Value | Description                              |
| ---------------------------------- | ----- | ---------------------------------------- |
| `OPENCODE_DISABLE_EXTERNAL_SKILLS` | `1`   | Disables external skills in OpenCode CLI |


These variables are applied to all shell configuration files by default.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for simple rules and how to get started.

## TODO

- Add testing scripts for skills. Use `promptfoo` or [https://github.com/mgechev/skillgrade](https://github.com/mgechev/skillgrade)

## Support my work

<a href="https://ko-fi.com/petromirdzhunev" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/kofi-button.svg" alt="Buy Me A Ko-fi" style="height: 45px !important;width: 163px !important;" >
</a>
<a href="https://www.buymeacoffee.com/petromirdzhunev" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/bmc-button.svg" alt="Buy Me A Coffee" style="height: 45px !important;width: 163px !important;" >
</a>
<a href="https://github.com/sponsors/petromir" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/github-sponsor-button.svg" alt="GitHub Sponsor" style="height: 45px !important;width: 163px !important;" >
</a>

