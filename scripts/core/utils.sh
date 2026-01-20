#!/usr/bin/env bash
# Utility functions

# Check is a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if running with sudo/root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Require sudo for a command
require_sudo() {
    if ! is_root && ! sudo -n true 2>/dev/null; then
        log_info "Administrator privileges required. You may be prompted for your password."
        sudo -v
    fi
}

# Retry a command with exponential backoff
retry() {
    local max_attempts=${1:-3}
    local delay=${2:-2}
    local attempt=1
    shift 2

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0;
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            log_warn "Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s ..."
            sleep "$delay"
            delay=$((delay * 2))
        fi

        attempt=$((attempt + 1))
    done

    log_error "Command failed after $max_attempts attempts: $*"
    return 1
}

# Confirm action with user
confirm() {
    local prompt="${1:-Are you sure?}"
    local response

    read -r -p "${prompt} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get system architecture
get_architecture() {
    local arch
    arch=$(uname -m)

    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
        esac
}