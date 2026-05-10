# OpenCode Configurations

This directory contains specialized configurations and custom tools for the `opencode` CLI.

- `opencode.json` - Main configuration (models, tools, permissions, MCP servers).
- `tui.json` - TUI-specific settings (themes, keybinds, scroll behavior).
- `skills/` - Custom agent skills. Each skill is a folder containing a `SKILL.md` file with YAML frontmatter.
- `agents/` - Custom agents for specialized tasks.
  - `java-modernizer.md`: Expert Java application modernization specialist.

## Custom Providers

### MLX-LM Provider
Install [mlx-lm](https://github.com/ml-explore/mlx-lm)
```
uv tool install mlx-lm
```

### Edit OpenCode config
Open `~/.config/opencode/opencode.json` and past the following (if you already have a config just add the provider):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "Unsloth MLX (local)": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Unsloth MLX (local)",
      "options": {
        "baseURL": "http://127.0.0.1:8080/v1"
      },
      "models": {
        "unsloth/gemma-4-26b-a4b-it-UD-MLX-4bit": {
          "name": "Gemma-4-26b-a4b-it-UD-MLX-4bit"
        }
      }
    }
  }
}
```

### Run the desired model
```bash
mlx_lm.server --model unsloth/gemma-4-26b-a4b-it-UD-MLX-4bit
```

### Select the provider and model
Type `opencode` in the desired repo and then:
1. Enter `/connect`
2. Type `Unsloth MLX (local)` and select it
3. For the API key enter `whatever`
4. Select the model
5. Can't wait to see what you will create 😊
