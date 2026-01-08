#!/usr/bin/env bash
set -euo pipefail

#######################################
# Bootstrap
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"

#######################################
# System Updates
#######################################

update_system() {
    log_info "Updating system packages"

    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
}

#######################################
# Node.js (NVM)
#######################################

update_node() {
    if [ -d "$HOME/.nvm" ]; then
        log_info "Updating Node.js via NVM"

        export NVM_DIR="$HOME/.nvm"
        ## shellcheck disable=SC1090
        source "$NVM_DIR/nvm.sh"

        nvm install --lts
        nvm alias default lts/*
    else
        log_warn "NVM not installed, skipping Node.js update"
    fi
}

#######################################
# Rust
#######################################
update_rust() {
    if command_exists rustup; then
        log_info "Updating Rust toolchain"
        rustup update
    else
        log_warn "Rust not installed, skipping"
    fi
}

#######################################
# Go
#######################################

update_go() {
    if command_exists go; then
        log_info "Go detected"
        go version
        log_info "Go updates are managed via install.sh (official binaries)"
    else
        log_warn "Go not installed, skipping"
    fi
}

#######################################
# Haskell
#######################################

update_haskell() {
    if command_exists ghcup; then
        log_info "Updating Haskell toolchain via ghcup"
        ghcup upgrade
    else
        log_warn "ghcup not installed, skipping"
    fi
}

#######################################
# Python Tooling
#######################################

update_python() {
    log_info "Updating Python tooling"

    python3 -m pip install --user --upgrade pip

    if command_exists uv; then
        uv self update
    else
        log_warn "uv not installed, skipping"
    fi
}

#######################################
# Dotfiles
#######################################

relink_dotfiles() {
    log_info "Re-linking dotfiles"

    ln -sf "$SCRIPT_DIR/bash/.bashrc" "$HOME/.bashrc"
    ln -sf "$SCRIPT_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
    ln -sf "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig"
}

#######################################
# Main
#######################################

main() {
    update_system
    update_node
    update_rust
    update_go
    update_haskell
    update_python
    relink_dotfiles

    log_info "Update complete. Restart shell if needed."
}

main "$@"