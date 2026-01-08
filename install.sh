#!/usr/bin/env bash
set -euo pipefail

#######################################
# Bootstrap
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable-SC1091
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"

#######################################
# APT Packages
#######################################

install_apt_packages() {
    log_info "Installing system packages (APT)"

    sudo apt update

    log_info "Installing packages from packages/apt.txt"
    xargs -a "$DOTFILES_DIR/packages/apt.txt" sudo apt install -y
}

#######################################
# Python
#######################################

install_pip_packages() {
    log_info "Setting up Python tooling"

    python3 -m pip install --user --upgrade pip
}

#######################################
# Node.js via NVM
#######################################

install_nvm() {
    log_info "Setting up Node.js via NVM"

    if [ ! -d "$HOME/.nvm" ]; then
        log_info "Installing NVM"
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    else
        log_warn "NVM already installed"
    fi

    export NVM_DIR="$HOME/.nvm"
    #shellcheck disable=SC1090
    source "$NVM_DIR/nvm.sh"

    if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
        log_info "Installing Node.js v$NODE_VERSION"
        nvm install "$NODE_VERSION"
    else
        log_warn "Node.js v$NODE_VERSION already installed"
    fi

    nvm alias default "$NODE_VERSION"
}


#######################################
# Go
#######################################

install_go() {
    log_info "Setting up Go"

    if command_exists go; then
        log_warn "Go already installed: $(go version)"
        return
    fi

    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64) GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    GO_TARBALL="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    GO_URL="https://go.dev/dl/${GO_TARBALL}"

    log_info "Downloading Go ${GO_VERSION}"
    curl -LO "$GO_URL"

    log_info "Installing Go to ${GO_INSTALL_DIR}"
    sudo rm -rf "$GO_INSTALL_DIR"
    sudo tar -C /usr/local -xzf "$GO_TARBALL"

    rm "$GO_TARBALL"

    log_info "Go installed successfully"
}

#######################################
# Rust
#######################################

install_rust() {
    log_info "Setting up Rust toolchain"

    if [[ ! -f "$HOME/.cargo/bin/rustc" ]]; then
        curl https://sh.rustup.rs -sSf | sh -s -- -y
    else
        log_warn "Rust already installed"
    fi
}

#######################################
# uv
#######################################

install_uv() {
    log_info "Setting up uv (Python package manager)"

    if ! command_exists uv; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        log_warn "uv already installed"
    fi
}

#######################################
# Haskell
#######################################

install_haskell() {
    log_info "Setting up Haskell toolchain (ghcup)"

    if [[ ! -d "$HOME/.ghcup" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y
    else
        log_warn "ghcup already installed"
    fi
}

#######################################
# Dotfiles
#######################################

link_dotfiles() {
    log_info "Linking dotfiles"

    mkdir -p "$HOME/.config" "$HOME/.local/bin"

    ln -sf "$SCRIPT_DIR/bash/.bashrc" "$HOME/.bashrc"
    ln -sf "$SCRIPT_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
    ln -sf "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig"
}

#######################################
# Main
#######################################

main() {
    log_info "Starting environment bootstrap"

    install_apt_packages
    install_pip_packages

    install_nvm
    install_go
    install_rust
    install_uv
    install_haskell

    link_dotfiles

    log_info "Environment setup complete."
    log_info "Restart your shell or run: exec bash"
}

main "$@"

