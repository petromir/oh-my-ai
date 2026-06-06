# Oh my AI

Script, skills, agents and everything necessary to make AI work better for us, so we can finally have more time 
to go to the beach 🏖️ 

## Usage

To use these configurations, install them into your project or global config directories.

### Installing Skills

To automatically install skills from the `common/skills` folder to your assistant's configuration directories (Gemini, Copilot, Claude), run:

```bash
./install-configs.sh
```

By default, the script installs to **all** assistants and skips existing skills.

#### Options

- `-f`: Force override existing skills.
- `-a <assistant>`: Specify target assistant (`gemini`, `copilot`, `claude`, or `all`). You can also provide a comma-separated list.

**Examples:**

```bash
# Install only for OpenCode
./install-configs.sh -a opencode
```

```bash
# Install for Claude and Copilot, forcing override
./install-configs.sh -f -a claude,copilot
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
|------------------------------------|-------|------------------------------------------|
| `OPENCODE_DISABLE_EXTERNAL_SKILLS` | `1`   | Disables external skills in OpenCode CLI |

These variables are applied to all shell configuration files by default.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for simple rules and how to get started.

## TODO
- Add testing scripts for skills. Use `promptfoo` or https://github.com/mgechev/skillgrade

## Support my work

<a href="https://ko-fi.com/petromirdzhunev" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/kofi-button.svg" alt="Buy Me A Ko-fi" style="height: 45px !important;width: 163px !important;" ></a>
<a href="https://www.buymeacoffee.com/petromirdzhunev" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/bmc-button.svg" alt="Buy Me A Coffee" style="height: 45px !important;width: 163px !important;" ></a>
<a href="https://github.com/sponsors/petromir" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/github-sponsor-button.svg" alt="GitHub Sponsor" style="height: 45px !important;width: 163px !important;" ></a>
