#!/usr/bin/env bash
set -euo pipefail

#######################################
# Configuration
#######################################

NODE_VERSION="24.12.0"
JAVA_PACKAGE="openjdk-21-jdk"

#######################################
# Helper Functions
#######################################

log() {
    echo -e "\n==> $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#######################################
# APT Packages
#######################################

install_apt_packages() {
    log "Installing APT packages"

    sudo apt update

    sudo apt install -y \
        build-essential \
        gcc \
        g++ \
        make \
        curl \
        wget \
        git \
        ca-certificates \
        pkg-config \
        tmux \
        neovim \
        python3 \
        python3-pip \
        python3-venv \
        "${JAVA_PACKAGE}"
}

#######################################
# Python (pip-level tools only)
#######################################

install_pip_packages() {
    log "Ensuring pip is up to date"

    python3 -m pip install --user --upgrade pip
}

#######################################
# NVM + Node.js
#######################################

install_nvm() {
    log "Setting up NVM and Node.js"

    if [ ! -d "$HOME/.nvm" ]; then
        log "Installing NVM"
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    else
        echo "NVM already installed"
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
        log "Installing Node.js v$NODE_VERSION"
        nvm install "$NODE_VERSION"
    else
        echo "Node.js v$NODE_VERSION already installed"
    fi

    nvm alias default "$NODE_VERSION"
}

#######################################
# Rust
#######################################

install_rust() {
    log "Setting up Rust toolchain"

    if [ ! -f "$HOME/.cargo/bin/rustc" ]; then
        echo "Installing Rust via rustup"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
    else
        echo "Rust already installed"
    fi
}

#######################################
# uv (Python package manager)
#######################################

install_uv() {
    log "Setting up uv"

    if ! command_exists uv; then
        log "Installing uv"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo "uv already installed"
    fi
}

#######################################
# Haskell (ghcup)
#######################################

install_haskell() {
    log "Setting up Haskell toolchain (ghcup)"

    if [ ! -d "$HOME/.ghcup" ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y
    else
        echo "ghcup already installed"
    fi
}

#######################################
# Dotfiles
#######################################

link_dotfiles() {
    log "Linking dotfiles"

    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"

    # Bash
    if [ -f "$DOTFILES_DIR/bash/.bashrc" ]; then
        ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    fi

    # Git
    if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
        ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi 
}

#######################################
# Main
#######################################

main() {
    install_apt_packages
    install_pip_packages

    install_nvm
    install_rust
    install_uv
    install_haskell

    link_dotfiles

    log "Environment setup complete."
    echo "Restart your shell or run: exec bash"
}

main "$@"

