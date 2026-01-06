#!/usr/bin/env bash
set -euo pipefail

#######################################
# Developer Doctor: Verify environment
#######################################

# Determine repo/script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load shared logging if available
if [ -f "$SCRIPT_DIR/scripts/shared_logging.sh" ]; then
    source "$SCRIPT_DIR/scripts/shared_logging.sh"
else
    # Fallback logging
    log_info() { echo -e "\n\033[1;34m==> $1\033[0m"; }
    log_warn() { echo -e "\033[1;33m[WARN] $1\033[0m"; }
    log_error() { echo -e "\033[1;31m[ERROR] $1\033[0m"; }
    log_ok() { echo -e "\033[1;32m✔ $1\033[0m"; }
fi

# Configuration defaults (can override with env vars)
NODE_VERSION="${NODE_VERSION:-24.12.0}"
GO_VERSION="${GO_VERSION:-1.25.5}"
JAVA_PACKAGE="${JAVA_PACKAGE:-openjdk-21-jdk}"

#######################################
# Helpers
#######################################

command_exists() { command -v "$1" >/dev/null 2>&1; }

check_tool() {
    local name="$1"
    local cmd="$2"
    local expected="${3:-}"

    if command_exists "$cmd"; then
        local version
        version=$($cmd --version 2>/dev/null | head -n 1 || echo "unknown")
        if [[ -n "$expected" && "$version" != *"$expected"* ]]; then
            log_warn "$name version mismatch: $version (expected $expected)"
        else
            log_ok "$name OK ($version)"
        fi
    else
        log_error "$name is not installed"
    fi
}

check_path_var() {
    local name="$1"
    local path="$2"
    if [[ ":$PATH:" != *":$path:"* ]]; then
        log_warn "$name missing from PATH: $path"
    else
        log_ok "$name in PATH"
    fi
}

#######################################
# Doctor checks
#######################################

log_info "=== Developer Doctor: Verifying environment ==="

# Core tools
check_tool "GCC" gcc "gcc"
check_tool "Make" make
check_tool "Git" git "git"
check_tool "Curl" curl "curl"
check_tool "Wget" wget "wget"

# Python
check_tool "Python3" python3 "python3"
check_tool "pip3" pip "pip"
check_tool "uv" uv

# Node.js
check_tool "Node.js" node "v$NODE_VERSION"
check_tool "npm" npm

# Go
check_tool "Go" go "go$GO_VERSION"

# Rust
check_tool "Rustc" rustc
check_tool "Cargo" cargo

# Java
check_tool "Java" java
check_tool "Javac" javac
check_tool "Maven" mvn
check_tool "Gradle" gradle

# Haskell
check_tool "GHCup" ghcup
check_tool "GHC" ghc
check_tool "Cabal" cabal

# Containers
check_tool "Docker" docker

# Editors / terminal
check_tool "Neovim" nvim
check_tool "Tmux" tmux

# PATH checks
check_path_var "NVM Node bin" "$HOME/.nvm/versions/node/v$NODE_VERSION/bin"
check_path_var "Go bin" "/usr/local/go/bin"
check_path_var "Rust Cargo bin" "$HOME/.cargo/bin"
check_path_var "GHCup bin" "$HOME/.ghcup/bin"

log_info "=== Developer Doctor complete ==="
log_info "Review warnings/errors above and fix missing tools or versions."