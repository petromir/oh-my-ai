# AI setup

Script, skills, agents and everything necessary to make AI work better for us, so we can finally have more time 
to go to the beach 🏖️ 

## Usage

To use these configurations, install them into your project or global config directories.

### Installing Skills

To automatically install skills from the `common/skills` folder to your assistant's configuration directories (Gemini, Copilot, Claude), run:

```bash
./common/scripts/install-skills.sh
```

By default, the script installs to **all** assistants and skips existing skills.

#### Options

- `-f`: Force override existing skills.
- `-a <assistant>`: Specify target assistant (`gemini`, `copilot`, `claude`, or `all`). You can also provide a comma-separated list.

**Examples:**

```bash
# Install only for Gemini
./common/scripts/install-skills.sh -a gemini

# Install for Claude and Copilot, forcing override
./common/scripts/install-skills.sh -f -a claude,copilot
``` 

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for simple rules and how to get started.

## TODO
- Add testing scripts for skills. Use `promptfoo` or https://github.com/mgechev/skillgrade
