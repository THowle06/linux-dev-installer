#!/usr/bin/env bash
set -euo pipefail

#######################################
# Configuration
#######################################

NODE_VERSION="24.12.0"
GO_VERSION="1.25.5"
GO_INSTALL_DIR="/usr/local/go"

#######################################
# Paths
#######################################

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#######################################
# Logging Helpers
#######################################

log() {
    echo -e "\n\033[1;34m==> $1\033[0m"
}

log_step() {
    echo -e "  \033[1;32m]→ $1\033[0m"
}

log_skip() {
    echo -e "  \033[1;33m↪ $1 (skipped)\033[0m"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#######################################
# APT Packages
#######################################

install_apt_packages() {
    log "System packages (APT)"

    log_step "Updating package lists"
    sudo apt update

    log_step "Installing packages from packages/apt.txt"
    xargs -a "$DOTFILES_DIR/packages/apt.txt" sudo apt install -y
}

#######################################
# Python
#######################################

install_pip_packages() {
    log "Python tooling"

    log_step "Upgrading pip (user scope)"
    python3 -m pip install --user --upgrade pip
}

#######################################
# Node.js via NVM
#######################################

install_nvm() {
    log "Node.js (NVM)"

    if [ ! -d "$HOME/.nvm" ]; then
        log_step "Installing NVM"
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    else
        log_skip "NVM already installed"
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
        log_step "Installing Node.js v$NODE_VERSION"
        nvm install "$NODE_VERSION"
    else
        log_skip "Node.js v$NODE_VERSION already installed"
    fi

    log_step "Setting Node.js default version"
    nvm alias default "$NODE_VERSION"
}


#######################################
# Go
#######################################

install_go() {
    log "Go"

    if command_exists go; then
        log_skip "Go already installed ($(go version))"
        return
    fi

    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64) GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    GO_TARBALL="go${GO_VERSION}.linux-${GO_ARCH}.tar.gx"
    GO_URL="https://go.dev/dl/${GO_TARBALL}"

    log_step "Downloading Go ${GO_VERSION}"
    curl -LO "$GO_URL"

    log_step "Installing to ${GO_INSTALL_DIR}"
    sudo rm -rf "$GO_INSTALL_DIR"
    sudo tar -C /usr/local -xzf "$GO_TARBALL"

    rm "$GO_TARBALL"

    log_step "Go installed successfully"
}

#######################################
# Rust
#######################################

install_rust() {
    log "Rust toolchain"

    if [ ! -f "$HOME/.cargo/bin/rustc" ]; then
        log_step "Installing Rust via rustup"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
    else
        log_skip "Rust already installed"
    fi
}

#######################################
# uv
#######################################

install_uv() {
    log "uv (Python package manager)"

    if ! command_exists uv; then
        log_step "Installing uv"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        log_skip "uv already installed"
    fi
}

#######################################
# Haskell
#######################################

install_haskell() {
    log "Haskell toolchain (ghcup)"

    if [ ! -d "$HOME/.ghcup" ]; then
        log_step "Installing ghcup"
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y
    else
        log_skip "ghcup already installed"
    fi
}

#######################################
# Dotfiles
#######################################

link_dotfiles() {
    log "Dotfiles"

    mkdir -p "$HOME/.config" "$HOME/.local/bin"

    log_step "Linking .bashrc"
    ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    
    log_step "Linking .bash_aliases"
    ln -sf "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"

    log_step "Linking .gitconfig"
    ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
}

#######################################
# Main
#######################################

main() {
    log "Starting environment bootstrap"

    install_apt_packages
    install_pip_packages

    install_nvm
    install_go
    install_rust
    install_uv
    install_haskell

    link_dotfiles

    log "Environment setup complete."
    echo "Restart your shell or run: exec bash"
}

main "$@"

