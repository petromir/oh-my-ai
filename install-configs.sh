#!/usr/bin/env bash

# Strict Mode: fail fast
set -o errexit
set -o nounset
set -o pipefail

# Get the root directory of the repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${SCRIPT_DIR}"
readonly REPO_ROOT

readonly SKILLS_SOURCE="${REPO_ROOT}/common/.agents/skills"

FORCE=false
ASSISTANT="all"

# Cleanup function
finish() {
  local result=$?
  exit "${result}"
}
trap finish EXIT ERR

usage() {
  printf "Usage: %s [-f] [-a assistant]\n" "${0}"
  printf "  -f: Force override existing skills\n"
  printf "  -a: Specify assistant (gemini, copilot, claude, opencode, pi, oh-my-pi, agents, all). Default: all\n"
}

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
}

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

  local item
  for item in "${src_dir}"/*; do
    [[ -e "${item}" ]] || continue
    copy_if_needed "${item}" "${target_dir}/$(basename "${item}")"
  done
}

install_skill() {
  local skill_path="${1}"
  local skill_name
  skill_name="$(basename "${skill_path}")"

  printf "Installing skill: %s\n" "${skill_name}"

  local -a skill_targets=(
    "gemini:${HOME}/.gemini/skills"
    "copilot:${HOME}/.copilot/skills"
    "claude:${HOME}/.claude/skills"
    "opencode:${HOME}/.config/opencode/skills"
    "pi:${HOME}/.pi/agent/skills"
    "oh-my-pi:${HOME}/.omp/agent/skills"
    "agents:${HOME}/.agents/skills"
  )

  local target key dest
  for target in "${skill_targets[@]}"; do
    IFS=":" read -r key dest <<< "${target}"
    if should_install_assistant "${key}"; then
      mkdir -p -- "${dest}"
      copy_if_needed "${skill_path}" "${dest}/${skill_name}"
    fi
  done
}

main() {
  while getopts "fa:h" opt; do
    case "${opt}" in
      f) FORCE=true ;;
      a) ASSISTANT="${OPTARG}" ;;
      h) usage; exit 0 ;;
      *) usage; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ ! -d "${SKILLS_SOURCE}" ]]; then
    printf "Error: Source directory %s not found.\n" "${SKILLS_SOURCE}" >&2
    exit 1
  fi

  # Assistant configuration sources and targets: "key:Name:SourceDir:TargetDir"
  local -a config_targets=(
    "gemini:Gemini:${REPO_ROOT}/gemini/.gemini:${HOME}/.gemini"
    "opencode:OpenCode:${REPO_ROOT}/opencode/.opencode:${HOME}/.config/opencode"
    "pi:Pi:${REPO_ROOT}/pi/.pi/agent:${HOME}/.pi/agent"
    "oh-my-pi:Oh-My-Pi:${REPO_ROOT}/oh-my-pi/.omp/agent:${HOME}/.omp/agent"
  )

  local cfg key name src dest
  for cfg in "${config_targets[@]}"; do
    IFS=":" read -r key name src dest <<< "${cfg}"
    if should_install_assistant "${key}"; then
      install_config_dir "${name}" "${src}" "${dest}"
    fi
  done

  # Loop through all skills in common directory
  local skill
  for skill in "${SKILLS_SOURCE}"/*; do
    if [[ -d "${skill}" ]]; then
      install_skill "${skill}"
    fi
  done

  printf "All skills processed successfully for assistant(s): %s\n" "${ASSISTANT}"
}

main "$@"
