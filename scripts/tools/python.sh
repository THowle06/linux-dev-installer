#!/usr/bin/env bash
set -euo pipefail

# Python ecosystem: system python3, pip, uv

python_install() {
    log_step "Installing Python ecosystem..."

    # System python3 + pip should be installed via apt already
    if ! command_exists python3; then
        log_error "python3 not found. Ensure apt tool ran first."
        return 1
    fi

    # Verify pip is available
    if ! command_exists pip3; then
        log_error "pip3 not found. Ensure python3-pip is installed via apt."
        return 1
    fi

    log_info "System python3 and pip3 already present"

    _ensure_pipx
    _install_uv

    log_success "Python ecosystem installed"
}

python_update() {
    log_step "Update Python ecosystem..."

    if ! command_exists python3; then
        log_error "python3 not found"
        return 1
    fi

    log_info "Updating uv via pipx..."
    pipx upgrade uv

    log_success "Python ecosystem updated"
}

python_verify() {
    log_step "Verifying Python ecosystem..."

    local issues=0

    if ! command_exists python3; then
        log_warn "python3 not found"
        ((issues++))
    else
        local py_version
        py_version=$(python3 --version 2>&1 | awk '{print $2}')
        log_info "python3 version: $py_version"
    fi

    if ! command_exists pip3; then
        log_warn "pip3 not found"
        ((issues++))
    else
        local pip_version
        pip_version=$(pip3 --version 2>&1 | awk '{print $2}')
        log_info "pip3 version: $pip_version"
    fi

    if ! command_exists uv; then
        log_warn "uv not found"
        ((issues++))
    else
        local uv_version
        uv_version=$(uv --version 2>&1 | awk '{print $2}')
        log_info "uv version: $uv_version"
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Python ecosystem verified"
    else
        return 1
    fi
}

python_uninstall() {
    log_step "Uninstalling Python ecosystem..."

    log_info "Keeping system python3 and pip3 (required by system)"

    # Remove uv
    if command_exists uv; then
        log_info "Removing uv..."
        require_sudo
        sudo pip3 uninstall -y uv || log_warn "Failed to uninstall uv via pip"
    fi

    log_success "Python ecosystem uninstalled (system python3/pip3 retained)"
}

# Helper: install or update uv
_install_uv() {
    local mode=${1:-install}

    if [[ "$mode" == "update" ]] && ! command_exists uv; then
        log_info "uv not installed, skipping update"
        return 0
    fi

    log_info "Installing/updating uv via pip3..."
    require_sudo

    sudo pip3 install --upgrade uv

    # Verify installation
    if ! command_exists uv; then
        log_error "uv installation failed"
        return 1
    fi

    log_success "uv installed/updated"
}

# Helper: ensure pipx is installed
_ensure_pipx() {
    if command_exists pipx; then return 0; fi
    log_info "Installing pipx via apt..."
    require_sudo
    sudo apt-get install -y pipx
    # Make pipx available in current shell
    export PATH="$HOME/.local/bin:${PATH}"
}

# Helper: install or update uv via pipx
_install_uv() {
    if ! command_exists pipx; then
        _ensure_pipx
    fi
    log_info "Installing/updating uv via pipx..."
    pipx install --force uv
    if ! command_exists uv; then
        log_error "uv installation failed"
        return 1
    fi
    log_success "uv installed/updated"
}
