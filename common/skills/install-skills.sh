#!/usr/bin/env bash

# Strict Mode: fail fast
set -o errexit
set -o nounset
set -o pipefail

# Get the root directory of the repository
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Define source and target base directories
readonly SOURCE_DIR="${REPO_ROOT}/common/skills"
readonly GEMINI_TARGET="${HOME}/.gemini/skills"
readonly COPILOT_TARGET="${HOME}/.copilot/skills"
readonly CLAUDE_TARGET="${HOME}/.claude/instructions"

FORCE=false
ASSISTANT="all"

# Cleanup function
cleanup() {
  local result=$?
  exit "${result}"
}
trap cleanup EXIT ERR

usage() {
  printf "Usage: %s [-f] [-a assistant]\n" "${0}"
  printf "  -f: Force override existing skills\n"
  printf "  -a: Specify assistant (gemini, copilot, claude, all). Default: all\n"
}

copy_if_needed() {
  local src="${1}"
  local dest="${2}"
  local is_dir="${3:-false}"

  if [[ "${FORCE}" == "true" ]]; then
    if [[ "${is_dir}" == "true" ]]; then
      if [[ -d "${dest}" ]]; then
        printf "\nWARNING: About to delete existing directory:\n  %s\n" "${dest}"
        read -r -p "Are you sure you want to delete this folder and proceed? [y/N] " response
        if [[ ! "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
          printf "Skipped overriding: %s\n" "${dest}"
          return
        fi
        rm -rf -- "${dest}"
      fi
      cp -rf -- "${src}" "${dest}"
    else
      cp -f -- "${src}" "${dest}"
    fi
  else
    if [[ -e "${dest}" ]]; then
      printf "Skipping existing: %s\n" "$(basename "${dest}")"
    else
      if [[ "${is_dir}" == "true" ]]; then
        cp -rf -- "${src}" "${dest}"
      else
        cp -f -- "${src}" "${dest}"
      fi
    fi
  fi
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
    if [[ -f "${skill_path}/SKILL.md" ]]; then
      copy_if_needed "${skill_path}/SKILL.md" "${CLAUDE_TARGET}/${skill_name}.md" "false"
    else
      copy_if_needed "${skill_path}" "${CLAUDE_TARGET}/${skill_name}" "true"
    fi
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

  # Loop through all skills in the common folder
  for skill in "${SOURCE_DIR}"/*; do
    if [[ -d "${skill}" ]]; then
      install_skill "${skill}"
    fi
  done

  printf "All skills processed successfully for assistant(s): %s\n" "${ASSISTANT}"
}

main "$@"
