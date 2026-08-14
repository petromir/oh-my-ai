# Android Local Agent Setup

## Install Termux
- Install [Termux](https://github.com/termux/termux-app#installation) from GitHub or F-Droid (not Google Play, that 
version is limited in functionality and has some unresolved bugs)
- Install [Termux:API](https://github.com/termux/termux-api#installation) from GitHub or F-Droid for clipboard and 
  other device integrations

## Install `litert-lm`
Once Termux is installed, open the app and type
```shell
pkg update && pkg upgrade
pkg install uv
uv tool install litert-lm
```

## Check your hardware
I have an Android phone with:
- 12GB RAM (of which 5.5GB are available)
- 10 CPU cores
- GPU with 4GB.

It is enough to load `gemma-4-E4B-it.litertlm` model on the device


## Import the model

**TBD**
```shell

```

## Serve the model
**TBD**

## Install `pi` agent
Follow the [official guideline](https://pi.dev/docs/latest/termux)