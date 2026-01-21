#!/usr/bin/env bash
set -euo pipefail

# APT package manager bootstrap: core system packages

apt_install() {
    log_step "Installing core system packages via apt..."
    require_sudo

    # Update package lists
    sudo apt-get update -qq

    # Read packages from apt.txt, skip comments and empty lines
    local packages
    packages=$(grep -v '^#' "${PACKAGES_DIR}/apt.txt" | grep -v '^[[:space:]]*$' | tr '\n' ' ')

    if [[ -z "$packages" ]]; then
        log_warn "No packages found in ${PACKAGES_DIR}/apt.txt"
        return 1
    fi

    log_info "Installing: $packages"
    sudo apt-get install -y $packages

    log_success "Core system packages installed"
}

apt_update() {
    log_step "Updating core system packages via apt..."
    require_sudo

    sudo apt-get update -qq
    sudo apt-get upgrade -y

    log_success "Core system packages updated"
}

apt_verify() {
    log_step "Verifying core system packages..."

    local missing=()
    local packages
    packages=$(grep -v '^#' "${PACKAGES_DIR}/apt.txt" | grep -v '^[[:space:]]*$')

    while IFS= read -r pkg; do
        if ! dpkg -l | grep -q "^ii.*${pkg}"; then
            missing+=("$pkg")
        fi
    done <<<"$packages"

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "Missing packages: ${missing[*]}"
        return 1
    fi

    log_success "All core system packages verified"
}

apt_uninstall() {
    log_step "Uninstalling core system packages (skipped-too risky)"
    log_info "Use 'sudo apt-get remove <package>' manually if needed"
}