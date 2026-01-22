#!/usr/bin/env bash
set -euo pipefail

# Node.js ecosystem: NVM + pinned Node version

node_install() {
    log_step "Installing Node.js via NVM..."

    # Install NVM if not present
    if ! command_exists nvm; then
        _install_nvm
    else
        log_info "NVM already installed"
    fi

    # Source NVM to make it available in this shell
    _source_nvm

    # Install pinned Node version
    _install_node_version

    log_success "Node.js ecosystem installed"
}

node_update() {
    log_step "Updating Node.js..."

    _source_nvm

    # Update NVM itself
    log_info "Updating NVM..."
    (cd "$NVM_DIR" && git fetch --quiet origin && git checkout --quiet "$(git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1))")

    # Install/update Node to pinned version
    _install_node_version

    log_success "Node.js updated"
}

node_verify() {
    log_step "Verifying Node.js ecosystem"

    _source_nvm

    local issues=0

    if ! command_exists nvm; then
        log_warn "NVM not found"
        ((issues++))
    else
        log_info "NVM installed"
    fi

    if ! command_exists node; then
        log_warn "node not found"
        ((issues++))
    else
        local node_version
        node_version=$(node --version)
        log_info "node version: $node_version"
    fi

    if ! command_exists npm; then
        log_warn "npm not found"
        ((issues++))
    else
        local npm_version
        npm_version=$(npm --version)
        log_info "npm version: $npm_version"
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Node.js ecosystem verified"
    else
        return 1
    fi
}

node_uninstall() {
    log_step "Uninstalling Node.js..."

    if [[ -d "$NVM_DIR" ]]; then
        log_info "Removing NVM directory: $NVM_DIR"
        rm -rf "$NVM_DIR"
    fi

    # Remove NVM sourcing from shell rc files
    log_info "Removing NVM from shell configuration..."
    sed -i '/export NVM_DIR/d' "${HOME}/.bashrc" 2>/dev/null || true
    sed -i '/\[ -s "$NVM_DIR\/nvm.sh" \]/d' "${HOME}/.bashrc" 2>/dev/null || true

    log_success "Node.js uninstalled"
}

# Helper: install NVM
_install_nvm() {
    log_info "Downloading and installing NVM ${NVM_INSTALL_VERSION}..."

    mkdir -p "$NVM_DIR"

    # Download NVM
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_INSTALL_VERSION}/install.sh" | bash

    # Verify installation
    if [[ ! -f "${NVM_DIR}/nvm.sh" ]]; then
        log_error "NVM installation failed"
        return 1
    fi
    
    log_success "NVM ${NVM_INSTALL_VERSION} installed"
}

# Helper: source NVM in current shell
_source_nvm() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}

# Helper: install pinned Node version
_install_node_version() {
    log_info "Installing Node.js ${NODE_VERSION}..."

    _source_nvm

    nvm install "${NODE_VERSION}"
    nvm use "${NODE_VERSION}"
    nvm alias default "${NODE_VERSION}"

    log_success "Node.js ${NODE_VERSION} installed and set as default"
}