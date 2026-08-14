# AI Agent Guidelines

This repository serves as a centralized hub for configuring, extending, and orchestrating various AI coding assistants and agents. It contains custom instructions, specialized skills, custom agent definitions, and utility scripts to enhance AI productivity.

## Core Directories

- **[Gemini](/configs/gemini)**: Antigravity / Gemini CLI settings and configurations (`.gemini/antigravity-cli/settings.json`).
- **[OpenCode](/configs/opencode)**: Configurations, skills, subagents, and instruction files for the `opencode` CLI.
- **[Pi](/configs/pi)**: Keybindings, settings, and agent configurations for the `pi` CLI.
- **[Oh-My-Pi](/configs/oh-my-pi)**: Configurations and extension settings for the `oh-my-pi` CLI.
- **[Common](/configs/common)**: Universal skills, prompt templates, ignore patterns, and cross-platform permissions.

## Key Utility Scripts

- **`install-configs.sh`**: Automated installer to sync agent configurations and common skills into user home directories (`~/.gemini`, `~/.config/opencode`, `~/.pi/agent`, `~/.omp/agent`, `~/.agents/skills`).
- **`set_env_vars.sh`**: Helper script to configure environment variables across shell configurations (`.bashrc`, `.zshrc`, etc.).

## Guidelines

1. **Shared Skills**: Universal skills reside in `configs/common/.agents/skills/`. Each skill directory MUST contain a `SKILL.md` file with standard instructions.
2. **Tool-Specific Configurations**: Assistant-specific agent definitions, TUI settings, and custom providers belong in their respective root directories (`configs/gemini/`, `configs/opencode/`, `configs/pi/`, `configs/oh-my-pi/`).
3. **Security**: Never commit API keys, personal access tokens, or environment secrets.