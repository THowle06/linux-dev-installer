#!/usr/bin/env bash
# Bootstrap script - loaded by all other scripts
# Enforces strict mode and loads core utilities

if [[ "${BOOTSTRAPPED:-0}" -eq 1 ]]; then
    return 0 2>/dev/null || exit 0
fi

set -euo pipefail
IFS=$'\n\t'
export BOOTSTRAPPED=1

# Get the project root directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
readonly CORE_DIR="${SCRIPTS_DIR}/core"
readonly TOOLS_DIR="${SCRIPTS_DIR}/tools"
readonly COMMANDS_DIR="${SCRIPTS_DIR}/commands"
readonly DOTFILES_DIR="${PROJECT_ROOT}/dotfiles"
readonly PACKAGES_DIR="${PROJECT_ROOT}/packages"

# Load core utilities
source "${CORE_DIR}/logging.sh"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/config.sh"

# Ensure we're on a supported platform
if [[ ! -f /etc/os-release ]]; then
    log_error "Cannot detect OS. This installer requires Ubuntu 24.04 LTS."
    exit 1
fi

source /etc/os-release
if [[ "${ID}" != "ubuntu" ]] || [[ "${VERSION_ID}" != "24.04" ]]; then
    log_warn "Detected ${NAME} ${VERSION_ID}"
    log_warn "This installer is designed for Ubuntu 24.04 LTS"
    log_warn "Proceeding anyway, but issues may occur..."
fi

# Export common variables
export PROJECT_ROOT SCRIPT_DIR CORE_DIR TOOLS_DIR COMMANDS_DIR DOTFILES_DIR PACKAGES_DIR

log_debug "Bootstrap loaded from ${PROJECT_ROOT}"