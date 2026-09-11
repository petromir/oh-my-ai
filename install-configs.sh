#!/usr/bin/env bash
#
# install-configs.sh - Install or remove AI assistant configs and shared skills
#
# Copies each assistant's configuration directory (from configs/<assistant>)
# and every shared skill (from configs/common/.agents/skills) into that
# assistant's config directory under $HOME (e.g. ~/.gemini, ~/.pi/agent,
# ~/.omp/agent). Existing files/directories are skipped unless -f is given.
#
# The `remove` command undoes this: it deletes only the items this script
# would install, leaving anything else in an assistant's config/skills
# directory untouched.
#
# Usage:
#   ./install-configs.sh [-f] [-s] [-m mode] [-a assistant]
#   ./install-configs.sh remove configs [-a assistant]
#   ./install-configs.sh remove skills [-a assistant]
#
# Commands:
#   (default)       Install assistant configs and shared skills.
#   remove configs  Remove previously installed assistant config directories.
#   remove skills   Remove previously installed shared skills.
#
# Options:
#   -f              Force override existing configs/skills (install only).
#   -s              Skip installing shared skills; assistant configs only
#                   (install only).
#   -m <mode>       Config mode (OpenCode only). Valid value: yolo, which
#                   installs opencode-yolo.jsonc as opencode.jsonc. Omit for
#                   the default behaviour (install opencode.jsonc only).
#   -a <assistant>  Target assistant: gemini, copilot, claude, opencode, pi,
#                   oh-my-pi, agents, or all (default). Accepts a
#                   comma-separated list.
#   -h              Show usage and exit.
#
# Examples:
#   ./install-configs.sh                       # Install for all assistants
#   ./install-configs.sh -a opencode           # Install only for OpenCode
#   ./install-configs.sh -f -a opencode,pi     # Force-install for OpenCode and Pi
#   ./install-configs.sh -s -a gemini          # Install Gemini configs, no skills
#   ./install-configs.sh -m yolo -a opencode   # Install OpenCode in yolo mode
#   ./install-configs.sh remove configs -a pi  # Remove Pi's installed configs
#   ./install-configs.sh remove skills         # Remove shared skills everywhere
#

# Strict Mode: fail fast
set -o errexit
set -o nounset
set -o pipefail

# Get the root directory of the repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${SCRIPT_DIR}"
readonly REPO_ROOT

readonly SKILLS_SOURCE="${REPO_ROOT}/configs/common/.agents/skills"

# Config entries installed through the -m/--mode option rather than copied
# directly by install_config_dir.
readonly -a MODE_MANAGED_FILES=("opencode.jsonc" "opencode-yolo.jsonc")

# Assistant configuration sources and targets: "key:Name:SourceDir:TargetDir"
readonly -a CONFIG_TARGETS=(
  "gemini:Gemini:${REPO_ROOT}/configs/gemini/.gemini:${HOME}/.gemini"
  "opencode:OpenCode:${REPO_ROOT}/configs/opencode/.config/opencode:${HOME}/.config/opencode"
  "pi:Pi:${REPO_ROOT}/configs/pi/.pi/agent:${HOME}/.pi/agent"
  "oh-my-pi:Oh-My-Pi:${REPO_ROOT}/configs/oh-my-pi/.omp/agent:${HOME}/.omp/agent"
)

# Assistant skill targets: "key:SkillsDir"
readonly -a SKILL_TARGETS=(
  "gemini:${HOME}/.gemini/skills"
  "copilot:${HOME}/.copilot/skills"
  "claude:${HOME}/.claude/skills"
  "opencode:${HOME}/.config/opencode/skills"
  "pi:${HOME}/.pi/agent/skills"
  "oh-my-pi:${HOME}/.omp/agent/skills"
  "agents:${HOME}/.agents/skills"
)

FORCE=false
ASSISTANT="all"
SKIP_SKILLS=false
MODE=""
NORMALIZED_ARGS=()

# Cleanup function
finish() {
  local result=$?
  exit "${result}"
}
trap finish EXIT ERR

# Prints CLI usage/help to stdout. Args: none. Output: usage text. Returns: 0.
usage() {
  printf "Usage: %s [-f] [-s] [-m mode] [-a assistant]\n" "${0}"
  printf "       %s remove configs [-a assistant]\n" "${0}"
  printf "       %s remove skills [-a assistant]\n" "${0}"
  printf "  -f: Force override existing configs/skills (install only)\n"
  printf "  -s: Skip installing shared skills (install only)\n"
  printf "  -m: Config mode (OpenCode only): yolo. Default: opencode.jsonc\n"
  printf "  -a: Specify assistant (gemini, copilot, claude, opencode, pi, oh-my-pi, agents, all). Default: all\n"
  printf "  remove configs: Remove previously installed assistant config directories\n"
  printf "  remove skills:  Remove previously installed shared skills\n"
  return 0
}

# Copies src to dest unless dest exists and FORCE!=true, replacing any existing
# directory at dest. Args: src, dest. Output: action taken to stdout. Returns: 0.
copy_if_needed() {
  local src="${1}"
  local dest="${2}"

  if [[ "${FORCE}" != "true" && -e "${dest}" ]]; then
    printf "Skipping existing: %s\n" "$(basename "${dest}")"
    return 0
  fi

  if [[ -d "${src}" ]]; then
    if [[ -d "${dest}" ]]; then
      rm -rf -- "${dest}"
    fi
    cp -Rf -- "${src}" "${dest}"
    printf "Copied directory: %s\n" "${dest}"
  else
    cp -f -- "${src}" "${dest}"
    printf "Copied file: %s\n" "${dest}"
  fi
  return 0
}

# Removes dest if present, reporting the outcome either way.
# Args: dest. Output: action taken to stdout. Returns: 0.
remove_if_present() {
  local dest="${1}"

  if [[ -e "${dest}" ]]; then
    rm -rf -- "${dest}"
    printf "Removed: %s\n" "${dest}"
  else
    printf "Not installed, skipping: %s\n" "${dest}"
  fi
  return 0
}

# Tests whether `key` should be processed given the ASSISTANT selection.
# Args: key. Returns: 0 if selected, 1 otherwise.
should_install_assistant() {
  local key="${1}"
  if [[ "${ASSISTANT}" == "all" ]]; then
    return 0
  fi

  # Guard against "oh-my-pi" matching "pi" when only "oh-my-pi" was requested
  if [[ "${key}" == "pi" ]]; then
    if [[ ",${ASSISTANT}," == *",oh-my-pi,"* && ",${ASSISTANT}," != *",pi,"* ]]; then
      return 1
    fi
  fi

  if [[ ",${ASSISTANT}," == *",${key},"* || "${ASSISTANT}" == *"${key}"* ]]; then
    return 0
  fi
  return 1
}

# Tests whether basename is selected by the -m/--mode option.
# Args: basename. Returns: 0 if mode-managed, 1 otherwise.
is_mode_managed_file() {
  local base="${1}"
  local managed
  for managed in "${MODE_MANAGED_FILES[@]}"; do
    if [[ "${base}" == "${managed}" ]]; then
      return 0
    fi
  done
  return 1
}

# Copies every top-level entry of src_dir into target_dir via copy_if_needed.
# Entries managed by the -m/--mode option are skipped.
# Args: name, src_dir, target_dir. Output: progress to stdout. Returns: 0.
install_config_dir() {
  local name="${1}"
  local src_dir="${2}"
  local target_dir="${3}"

  if [[ ! -d "${src_dir}" ]]; then
    printf "%s source directory not found, skipping config installation.\n" "${name}"
    return 0
  fi

  printf "Installing %s configurations...\n" "${name}"
  mkdir -p -- "${target_dir}"

  local item base
  for item in "${src_dir}"/*; do
    [[ -e "${item}" ]] || continue
    base="$(basename "${item}")"
    if is_mode_managed_file "${base}"; then
      continue
    fi
    copy_if_needed "${item}" "${target_dir}/${base}"
  done
  return 0
}

# Installs the mode-selected OpenCode config as opencode.jsonc in target_dir.
# Args: src_dir, target_dir. Output: progress to stdout. Returns: 1 if the
# selected source file is missing.
install_opencode_mode_config() {
  local src_dir="${1}"
  local target_dir="${2}"
  local src

  if [[ "${MODE}" == "yolo" ]]; then
    src="${src_dir}/opencode-yolo.jsonc"
  else
    src="${src_dir}/opencode.jsonc"
  fi

  if [[ ! -e "${src}" ]]; then
    printf "Error: %s not found.\n" "${src}" >&2
    return 1
  fi

  copy_if_needed "${src}" "${target_dir}/opencode.jsonc"
  return 0
}

# Removes every target_dir entry that mirrors a top-level src_dir item.
# Args: name, src_dir, target_dir. Output: progress to stdout. Returns: 0.
remove_config_dir() {
  local name="${1}"
  local src_dir="${2}"
  local target_dir="${3}"

  if [[ ! -d "${src_dir}" ]]; then
    printf "%s source directory not found, skipping config removal.\n" "${name}"
    return 0
  fi

  printf "Removing %s configurations...\n" "${name}"

  local item
  for item in "${src_dir}"/*; do
    [[ -e "${item}" ]] || continue
    remove_if_present "${target_dir}/$(basename "${item}")"
  done
  return 0
}

# Installs one skill directory into every selected assistant's skills dir.
# Args: skill_path. Output: progress to stdout. Returns: 0.
install_skill() {
  local skill_path="${1}"
  local skill_name
  skill_name="$(basename "${skill_path}")"

  printf "Installing skill: %s\n" "${skill_name}"

  local target key dest
  for target in "${SKILL_TARGETS[@]}"; do
    IFS=":" read -r key dest <<< "${target}"
    if should_install_assistant "${key}"; then
      mkdir -p -- "${dest}"
      copy_if_needed "${skill_path}" "${dest}/${skill_name}"
    fi
  done
  return 0
}

# Removes one skill directory from every selected assistant's skills dir.
# Args: skill_path. Output: progress to stdout. Returns: 0.
remove_skill() {
  local skill_path="${1}"
  local skill_name
  skill_name="$(basename "${skill_path}")"

  printf "Removing skill: %s\n" "${skill_name}"

  local target key dest
  for target in "${SKILL_TARGETS[@]}"; do
    IFS=":" read -r key dest <<< "${target}"
    if should_install_assistant "${key}"; then
      remove_if_present "${dest}/${skill_name}"
    fi
  done
  return 0
}

# Installs assistant configs, then shared skills unless SKIP_SKILLS=true.
# Args: none. Output: progress to stdout. Returns: 0 (exits 1 if the skills
# source is missing).
do_install() {
  if [[ "${SKIP_SKILLS}" != "true" && ! -d "${SKILLS_SOURCE}" ]]; then
    printf "Error: Source directory %s not found.\n" "${SKILLS_SOURCE}" >&2
    exit 1
  fi

  local cfg key name src dest
  for cfg in "${CONFIG_TARGETS[@]}"; do
    IFS=":" read -r key name src dest <<< "${cfg}"
    if should_install_assistant "${key}"; then
      install_config_dir "${name}" "${src}" "${dest}"
      if [[ "${key}" == "opencode" ]]; then
        install_opencode_mode_config "${src}" "${dest}"
      fi
    fi
  done

  if [[ "${SKIP_SKILLS}" != "true" ]]; then
    local skill
    for skill in "${SKILLS_SOURCE}"/*; do
      if [[ -d "${skill}" ]]; then
        install_skill "${skill}"
      fi
    done
  fi

  printf "All configs/skills processed successfully for assistant(s): %s\n" "${ASSISTANT}"
  return 0
}

# Removes previously installed assistant config directories.
# Args: none. Output: progress to stdout. Returns: 0.
do_remove_configs() {
  local cfg key name src dest
  for cfg in "${CONFIG_TARGETS[@]}"; do
    IFS=":" read -r key name src dest <<< "${cfg}"
    if should_install_assistant "${key}"; then
      remove_config_dir "${name}" "${src}" "${dest}"
    fi
  done

  printf "Configs removed for assistant(s): %s\n" "${ASSISTANT}"
  return 0
}

# Removes previously installed shared skills.
# Args: none. Output: progress to stdout. Returns: 0 (exits 1 if the skills
# source is missing).
do_remove_skills() {
  if [[ ! -d "${SKILLS_SOURCE}" ]]; then
    printf "Error: Source directory %s not found.\n" "${SKILLS_SOURCE}" >&2
    exit 1
  fi

  local skill
  for skill in "${SKILLS_SOURCE}"/*; do
    if [[ -d "${skill}" ]]; then
      remove_skill "${skill}"
    fi
  done

  printf "Skills removed for assistant(s): %s\n" "${ASSISTANT}"
  return 0
}

# Drops a bare `-m` that has no value (last arg or followed by an option) so
# getopts keeps the default mode. Sets NORMALIZED_ARGS. Args: script argv.
# Returns: 0.
normalize_mode_arg() {
  NORMALIZED_ARGS=()
  while [[ $# -gt 0 ]]; do
    if [[ "${1}" == "-m" ]] && { [[ $# -eq 1 ]] || [[ "${2}" == -* ]]; }; then
      shift
    else
      NORMALIZED_ARGS+=("${1}")
      shift
    fi
  done
  return 0
}

# Parses the CLI command/options and dispatches to the matching do_* handler.
# Args: script argv. Returns: 0.
main() {
  local command="install"

  if [[ "${1:-}" == "remove" ]]; then
    shift
    case "${1:-}" in
      configs) command="remove-configs" ;;
      skills) command="remove-skills" ;;
      *)
        printf "Error: 'remove' requires a target: configs or skills\n" >&2
        usage
        exit 1
        ;;
    esac
    shift
  fi

  normalize_mode_arg "$@"
  if [[ ${#NORMALIZED_ARGS[@]} -gt 0 ]]; then
    set -- "${NORMALIZED_ARGS[@]}"
  else
    set --
  fi

  while getopts "fsm:a:h" opt; do
    case "${opt}" in
      f) FORCE=true ;;
      s) SKIP_SKILLS=true ;;
      m) MODE="${OPTARG}" ;;
      a) ASSISTANT="${OPTARG}" ;;
      h) usage; exit 0 ;;
      *) usage; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -n "${MODE}" && "${MODE}" != "yolo" ]]; then
    printf "Error: Invalid mode '%s'. Valid mode: yolo\n" "${MODE}" >&2
    usage
    exit 1
  fi

  if [[ $# -gt 0 ]]; then
    printf "Error: Unexpected argument(s): %s\n" "$*" >&2
    usage
    exit 1
  fi

  case "${command}" in
    install) do_install ;;
    remove-configs) do_remove_configs ;;
    remove-skills) do_remove_skills ;;
  esac
  return 0
}

main "$@"
