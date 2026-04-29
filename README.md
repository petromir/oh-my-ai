# Oh my AI

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

## Agents comparison

| Agent          | Installation | Configuration |
|----------------|--------------|---------------|
| Gemini CLI     |              |               |
| GitHub Copilot |              |               |
| OpenCode       |              |               |
| Claude Code    |              |               |
| Hermes Agent   |              |               |
| Pi Agent       |              |               |
| Droid Agent    |              |               |


## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for simple rules and how to get started.

## TODO
- Add testing scripts for skills. Use `promptfoo` or https://github.com/mgechev/skillgrade

## Support my work

<a href="https://ko-fi.com/petromirdzhunev" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/kofi-button.svg" alt="Buy Me A Ko-fi" style="height: 45px !important;width: 163px !important;" ></a>
<a href="https://www.buymeacoffee.com/petromirdzhunev" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/bmc-button.svg" alt="Buy Me A Coffee" style="height: 45px !important;width: 163px !important;" ></a>
<a href="https://github.com/sponsors/petromir" target="_blank"><img src="https://raw.githubusercontent.com/petromir/petromir/refs/heads/master/assets/github-sponsor-button.svg" alt="GitHub Sponsor" style="height: 45px !important;width: 163px !important;" ></a>
