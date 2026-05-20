#!/usr/bin/env bash
#
# set_env_vars.sh
#
# Appends configured environment variables to shell configuration files.
#

set -o errexit
set -o nounset
set -o pipefail

# ==========================================
# CONFIGURATION
# ==========================================
# Add your environment variables below.
# Format: "KEY=value"
# For values containing spaces, quote the value: "KEY=\"value with spaces\""
declare -ar ENV_VARS=(
  # Example:
  # "MY_TOOL_HOME=/opt/my-tool"
  # "MY_TOOL_PATH=\${HOME}/.my-tool/bin"
  OPENCODE_DISABLE_EXTERNAL_SKILLS=1
)

# ==========================================
# DEFAULT TARGET FILES
# ==========================================
declare -ar ALL_TARGETS=(
  "${HOME}/.zshrc"
  "${HOME}/.zprofile"
  "${HOME}/.bashrc"
  "${HOME}/.bash_profile"
)

# Runtime state
FORCE=false
VERBOSE=false
declare -a TARGETS=()

# ==========================================
# FUNCTIONS
# ==========================================

usage() {
  \cat <<'EOF'
Usage: set_env_vars.sh [OPTIONS]

Appends configured environment variables to shell configuration files.

Options:
  -s, --shell <bash|zshell|all>  Target shell (can be used multiple times)
  -f, --force                 Overwrite existing variable definitions
  -v, --verbose               Print detailed output
  -h, --help                  Show this help message

Examples:
  set_env_vars.sh                      # Update all shell configs
  set_env_vars.sh -s bash              # Update ~/.bashrc and ~/.bash_profile
  set_env_vars.sh -s zshell            # Update ~/.zshrc and ~/.zprofile
  set_env_vars.sh -s bash -s zshell    # Update both bash and zshell configs
  set_env_vars.sh -s all               # Update all shell configs
EOF
}

log_info() {
  if [[ "${VERBOSE}" == "true" ]]; then
    \printf "[INFO] %s\n" "$1"
  fi
}

log_error() {
  \printf "[ERROR] %s\n" "$1" >&2
}

# Check if a variable name is already defined in a file.
variable_defined_in_file() {
  local file="${1}"
  local key="${2}"

  if [[ ! -f "${file}" ]]; then
    return 1
  fi

  \grep --quiet --extended-regexp "^[[:space:]]*(export[[:space:]]+)?${key}[[:space:]]*=" "${file}"
}

# Append environment variables to a file.
append_vars_to_file() {
  local file="${1}"

  \printf "\n# --- Environment variables added by set_env_vars.sh ---\n" >> "${file}"
  local var
  for var in "${ENV_VARS[@]}"; do
    \printf "export %s\n" "${var}" >> "${file}"
  done
}

# Remove existing definitions of the configured variables from a file.
remove_existing_vars() {
  local file="${1}"

  if [[ ! -f "${file}" ]]; then
    return 0
  fi

  local var
  for var in "${ENV_VARS[@]}"; do
    local key
    key="$(\printf '%s\n' "${var}" | \cut --delimiter='=' --fields=1)"

    # Remove lines that define this variable
    \sed --in-place="" "/^[[:space:]]*\(export[[:space:]]\+\)\?${key}[[:space:]]*=/d" "${file}" || true
  done
}

process_file() {
  local file="${1}"
  local has_existing=false

  if [[ ! -f "${file}" ]]; then
    \touch -- "${file}"
    log_info "Created ${file}"
  fi

  # Check if any variables already exist
  local var
  for var in "${ENV_VARS[@]}"; do
    local key
    key="$(\printf '%s\n' "${var}" | \cut --delimiter='=' --fields=1)"
    if variable_defined_in_file "${file}" "${key}"; then
      has_existing=true
      break
    fi
  done

  if [[ "${has_existing}" == "true" && "${FORCE}" == "true" ]]; then
    log_info "Replacing variables in ${file}"
    remove_existing_vars "${file}"
    append_vars_to_file "${file}"
    \printf "Updated (forced): %s\n" "${file}"
  elif [[ "${has_existing}" == "true" ]]; then
    \printf "Skipped: %s (variables already defined, use --force to overwrite)\n" "${file}"
  else
    log_info "Appending variables to ${file}"
    append_vars_to_file "${file}"
    \printf "Updated: %s\n" "${file}"
  fi
}

# Resolve a target name to the corresponding config files.
resolve_target() {
  local target="${1}"
  case "${target}" in
    bash)
      TARGETS+=("${HOME}/.bashrc" "${HOME}/.bash_profile")
      ;;
    zshell)
      TARGETS+=("${HOME}/.zshrc" "${HOME}/.zprofile")
      ;;
    *)
      log_error "Unknown target: ${target}. Valid targets are 'bash', 'zshell', and 'all'."
      exit 1
      ;;
  esac
}

# ==========================================
# MAIN
# ==========================================

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--shell)
        if [[ -z "${2:-}" || "${2:-}" == -* ]]; then
          log_error "Option $1 requires an argument (bash, zshell, or all)."
          usage
          exit 1
        fi
        if [[ "$2" == "all" ]]; then
          TARGETS=("${ALL_TARGETS[@]}")
        else
          resolve_target "$2"
        fi
        shift 2
        ;;
      -f|--force)
        FORCE=true
        shift
        ;;
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Default to all targets if none specified
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    TARGETS=("${ALL_TARGETS[@]}")
  fi

  # Validate that at least one variable is configured
  if [[ ${#ENV_VARS[@]} -eq 0 ]]; then
    log_error "No environment variables configured."
    log_error "Please edit the ENV_VARS array in this script before running."
    exit 1
  fi

  local target
  for target in "${TARGETS[@]}"; do
    process_file "${target}"
  done
}

main "$@"
