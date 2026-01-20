#!/usr/bin/env bash
set -euo pipefail

#######################################
# Bootstrap
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"

#######################################
# Category filtering
#######################################

category_enabled() {
    local cat="$1"

    # Include list takes priority
    if [[ -n "${FILTER_INCLUDE:-}" ]]; then
        IFS=',' read -ra inc <<<"$FILTER_INCLUDE"
        for i in "${inc[@]}"; do
            [[ "$i" == "$cat" ]] && return 0
        done
        return 1
    fi

    if [[ -n "${FILTER_EXCLUDE:-}" ]]; then
        IFS=',' read -ra exc <<<"$FILTER_EXCLUDE"
        for e in "${exc[@]}"; do
            [[ "$e" == "$cat" ]] && return 1
        done
    fi

    return 0
}

run_category() {
    local cat="$1"; shift
    if category_enabled "$cat"; then
        "$@"
    else
        log_info "Skipping ${cat} (filtered)"
    fi
}

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
# Lean 4
#######################################

update_lean4() {
    if command_exists elan; then
        log_info "Updating Lean 4 toolchain via elan"
        elan update
    else
        log_warn "elan not installed, skipping"
    fi
}

#######################################
# Python Tooling
#######################################

update_python() {
    log_info "Updating Python tooling"

    python3 -m pip install --user --break-system-packages --upgrade pip

    if command_exists uv; then
        uv self update
    else
        log_warn "uv not installed, skipping"
    fi
}

#######################################
# .NET SDK
#######################################

update_dotnet() {
    log_info "Updating .NET SDK"

    if ! command_exists dotnet; then
        log_warn ".NET not installed (skipping)"
        return
    fi

    sudo apt update
    sudo apt upgrade -y dotnet-sdk-10.0

    log_ok ".NET SDK updated"
}

#######################################
# Dotfiles
#######################################

relink_dotfiles() {
    log_info "Re-linking dotfiles"

    # Backup existing files before re-linking
    backup_file "$HOME/.bashrc"
    backup_file "$HOME/.bash_aliases"
    backup_file "$HOME/.gitconfig"

    ln -sf "$SCRIPT_DIR/bash/.bashrc" "$HOME/.bashrc"
    ln -sf "$SCRIPT_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
    ln -sf "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig"

    log_ok "Dotfiles re-linked"
}

#######################################
# Main
#######################################

main() {
    log_info "Starting updates"

    update_system
    run_category node       update_node
    run_category rust       update_rust
    run_category go         update_go
    run_category haskell    update_haskell
    run_category lean       update_lean4
    run_category python     update_python
    run_category dotnet     update_dotnet
    run_category editors    relink_dotfiles

    log_info "Update complete. Restart shell if needed."
}

main "$@"