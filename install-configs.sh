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

# Define source and target base directories
readonly SOURCE_DIR="${REPO_ROOT}/common/.agents/skills"
readonly OPENCODE_SOURCE="${REPO_ROOT}/opencode/.opencode"
readonly PI_SOURCE="${REPO_ROOT}/pi/.pi/agent"
readonly GEMINI_TARGET="${HOME}/.gemini/skills"
readonly COPILOT_TARGET="${HOME}/.copilot/skills"
readonly CLAUDE_TARGET="${HOME}/.claude/skills"
readonly OPENCODE_TARGET="${HOME}/.config/opencode"
readonly AGENTS_TARGET="${HOME}/.agents/skills"
readonly PI_TARGET="${HOME}/.pi/agent"
readonly OH_MY_PI_SOURCE="${REPO_ROOT}/oh-my-pi/.omp/agent"
readonly OH_MY_PI_TARGET="${HOME}/.omp/agent"

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
  local is_dir="${3:-false}"

  if [[ "${FORCE}" == "true" ]]; then
    if [[ "${is_dir}" == "true" ]]; then
      if [[ -d "${dest}" ]]; then
        rm -rf -- "${dest}"
      fi
      cp -Rf -- "${src}" "${dest}"
      printf "Copied directory: %s\n" "${dest}"
    else
      cp -f -- "${src}" "${dest}"
      printf "Copied file: %s\n" "${dest}"
    fi
  else
    if [[ -e "${dest}" ]]; then
      printf "Skipping existing: %s\n" "$(basename "${dest}")"
    else
      if [[ "${is_dir}" == "true" ]]; then
        cp -Rf -- "${src}" "${dest}"
        printf "Copied directory: %s\n" "${dest}"
      else
        cp -f -- "${src}" "${dest}"
        printf "Copied file: %s\n" "${dest}"
      fi
    fi
  fi
}

install_opencode_configs() {
  if [[ ! -d "${OPENCODE_SOURCE}" ]]; then
    printf "OpenCode source directory not found, skipping config installation.\n"
    return
  fi

  printf "Installing OpenCode configurations...\n"
  mkdir -p -- "${OPENCODE_TARGET}"

  for item in "${OPENCODE_SOURCE}"/*; do
    local item_name
    item_name="$(basename "${item}")"
    if [[ -d "${item}" ]]; then
      copy_if_needed "${item}" "${OPENCODE_TARGET}/${item_name}" "true"
    else
      copy_if_needed "${item}" "${OPENCODE_TARGET}/${item_name}" "false"
    fi
  done
}

install_pi_configs() {
  if [[ ! -d "${PI_SOURCE}" ]]; then
    printf "Pi source directory not found, skipping config installation.\n"
    return
  fi

  printf "Installing Pi configurations...\n"
  mkdir -p -- "${PI_TARGET}"

  for item in "${PI_SOURCE}"/*; do
    local item_name
    item_name="$(basename "${item}")"
    if [[ -d "${item}" ]]; then
      copy_if_needed "${item}" "${PI_TARGET}/${item_name}" "true"
    else
      copy_if_needed "${item}" "${PI_TARGET}/${item_name}" "false"
    fi
  done
}

install_oh_my_pi_configs() {
  if [[ ! -d "${OH_MY_PI_SOURCE}" ]]; then
    printf "Oh-My-Pi source directory not found, skipping config installation.\n"
    return
  fi

  printf "Installing Oh-My-Pi configurations...\n"
  mkdir -p -- "${OH_MY_PI_TARGET}"

  for item in "${OH_MY_PI_SOURCE}"/*; do
    local item_name
    item_name="$(basename "${item}")"
    if [[ -d "${item}" ]]; then
      copy_if_needed "${item}" "${OH_MY_PI_TARGET}/${item_name}" "true"
    else
      copy_if_needed "${item}" "${OH_MY_PI_TARGET}/${item_name}" "false"
    fi
  done
}

install_skill() {
  local skill_path="${1}"
  local skill_name
  skill_name="$(basename "${skill_path}")"

  printf "Installing skill: %s\n" "${skill_name}"

  # Gemini install
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"gemini"* ]]; then
    mkdir -p -- "${GEMINI_TARGET}"
    copy_if_needed "${skill_path}" "${GEMINI_TARGET}/${skill_name}" "true"
  fi

  # Copilot install
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"copilot"* ]]; then
    mkdir -p -- "${COPILOT_TARGET}"
    copy_if_needed "${skill_path}" "${COPILOT_TARGET}/${skill_name}" "true"
  fi

  # Claude install
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"claude"* ]]; then
    mkdir -p -- "${CLAUDE_TARGET}"
    copy_if_needed "${skill_path}" "${CLAUDE_TARGET}/${skill_name}" "true"
  fi

  # OpenCode install
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"opencode"* ]]; then
    mkdir -p -- "${OPENCODE_TARGET}/skills"
    copy_if_needed "${skill_path}" "${OPENCODE_TARGET}/skills/${skill_name}" "true"
  fi

  # Pi install (guard: "oh-my-pi" contains the "pi" substring)
  if [[ "${ASSISTANT}" == "all" || ( "${ASSISTANT}" == *"pi"* && "${ASSISTANT}" != *"oh-my-pi"* ) ]]; then
    mkdir -p -- "${PI_TARGET}/skills"
    copy_if_needed "${skill_path}" "${PI_TARGET}/skills/${skill_name}" "true"
  fi

  # Oh-My-Pi install
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"oh-my-pi"* ]]; then
    mkdir -p -- "${OH_MY_PI_TARGET}/skills"
    copy_if_needed "${skill_path}" "${OH_MY_PI_TARGET}/skills/${skill_name}" "true"
  fi

  # .agents install
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"agents"* ]]; then
    mkdir -p -- "${AGENTS_TARGET}"
    copy_if_needed "${skill_path}" "${AGENTS_TARGET}/${skill_name}" "true"
  fi
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

  if [[ ! -d "${SOURCE_DIR}" ]]; then
    printf "Error: Source directory %s not found.\n" "${SOURCE_DIR}" >&2
    exit 1
  fi

  # Install OpenCode configurations
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"opencode"* ]]; then
    install_opencode_configs
  fi

  # Install Pi configurations (guard: "oh-my-pi" contains the "pi" substring)
  if [[ "${ASSISTANT}" == "all" || ( "${ASSISTANT}" == *"pi"* && "${ASSISTANT}" != *"oh-my-pi"* ) ]]; then
    install_pi_configs
  fi

  # Install Oh-My-Pi configurations
  if [[ "${ASSISTANT}" == "all" || "${ASSISTANT}" == *"oh-my-pi"* ]]; then
    install_oh_my_pi_configs
  fi

  # Loop through all skills in the common folder
  for skill in "${SOURCE_DIR}"/*; do
    if [[ -d "${skill}" ]]; then
      install_skill "${skill}"
    fi
  done

  printf "All skills processed successfully for assistant(s): %s\n" "${ASSISTANT}"
}

main "$@"
