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
# APT Packages
#######################################

install_apt_packages() {
    log_info "Installing system packages (APT)"

    sudo apt update

    log_info "Installing packages from packages/apt.txt"
    xargs -a "$DOTFILES_DIR/packages/apt.txt" sudo apt install -y

    log_ok "System packages installed successfully"
}

#######################################
# Python
#######################################

install_pip_packages() {
    log_info "Setting up Python tooling"

    python3 -m pip install --user --upgrade pip

    log_ok "Python tooling updated successfully"
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
    # shellcheck disable=SC1090
    source "$NVM_DIR/nvm.sh"

    if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
        log_info "Installing Node.js v$NODE_VERSION"
        nvm install "$NODE_VERSION"
    else
        log_warn "Node.js v$NODE_VERSION already installed"
    fi

    nvm alias default "$NODE_VERSION"

    log_ok "Node.js v$NODE_VERSION configured successfully"
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

    log_ok "Go ${GO_VERSION} installed successfully"
}

#######################################
# Rust
#######################################

install_rust() {
    log_info "Setting up Rust toolchain"

    if command_exists rustc; then
        log_warn "Rust already installed: $(rustc --version)"
        return
    fi

    log_info "Installing Rust via rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"

    log_ok "Rust installed successfully"
}

#######################################
# uv
#######################################

install_uv() {
    log_info "Setting up uv (Python package manager)"

    if command_exists uv; then
        log_warn "uv already installed: $(uv --version)"
        return
    fi

    log_info "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh

    log_ok "uv installed successfully"
}

#######################################
# Haskell
#######################################

install_haskell() {
    log_info "Setting up Haskell via GHCup"

    if command_exists ghcup; then
        log_warn "GHCup already installed"
        return
    fi

    log_info "Installing GHCup"
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

    # shellcheck disable=SC1091
    source "$HOME/.ghcup/env"

    log_info "Installing GHC, Cabal, and Stack"
    ghcup install ghc recommended
    ghcup install cabal recommended
    ghcup install stack recommended

    log_ok "Haskell toolchain installed successfully"
}

#######################################
# .NET SDK
#######################################

install_dotnet() {
    log_info "Setting up .NET SDK"

    if command_exists dotnet; then
        log_warn ".NET already installed: $(dotnet --version)"
        return
    fi

    log_info "Adding Microsoft package repository"
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb

    log_info "Installing .NET SDK ${DOTNET_VERSION}"
    sudo apt update
    sudo apt install -y dotnet-sdk-10.0

    log_ok ".NET SDK ${DOTNET_VERSION} installed successfully"
}

#######################################
# Dotfiles
#######################################

link_dotfiles() {
    log_info "Linking dotfiles"

    mkdir -p "$HOME/.config" "$HOME/.local/bin"

    # Backup existing files before linking
    backup_file "$HOME/.bashrc"
    backup_file "$HOME/.bash-aliases"
    backup_file "$HOME/.gitconfig"

    ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
    ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

    log_ok "Dotfiles linked successfully"
}

#######################################
# Main
#######################################

main() {
    log_info "Starting environment bootstrap"

    install_apt_packages
    run_category python install_pip_packages
    run_category node       install_nvm
    run_category go         install_go
    run_category rust       install_rust
    run_category python     install_uv
    run_category haskell    install_haskell
    run_category dotnet     install_dotnet
    run_category editors    link_dotfiles

    log_info "Installation complete! Please restart your shell or run: source ~/.bashrc"
}

main "$@"

