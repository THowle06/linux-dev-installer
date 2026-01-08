#!/usr/bin/env bash
set -euo pipefail

#######################################
# Developer Doctor
# Verify development environment health
#######################################

# Resolve repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib/logging.sh"
source "$SCRIPT_DIR/scripts/lib/utils.sh"

#######################################
# Configuration (override via env)
#######################################

NODE_VERSION="${NODE_VERSION:-24.12.0}"
GO_VERSION="${GO_VERSION:-1.25.5}"
JAVA_MAJOR="${JAVA_MAJOR:-21}"

#######################################
# State
#######################################

WARNINGS=0
ERRORS=0

#######################################
# Helpers
#######################################

check_tool() {
    local name="$1"
    local cmd="$2"
    local expected="${3:-}"

    if command_exists "$cmd"; then
        local version
        version="$($cmd --version 2>/dev/null | head -n 1 | cut -c1-80 || echo "unknown")"

        if [[ -n "$expected" && "$version" != *"$expected"* ]]; then
            log_warn "$name version mismatch"
            log_info "  Found:    $version"
            log_info "  Expected: $expected"
            ((WARNINGS+=1))
        else
            log_ok "$name OK ($version)"
        fi
    else
        log_error "$name is not installed"
        ((ERRORS+=1))
    fi
}

check_path() {
    local label="$1"
    local path="$2"

    if [[ ":$PATH:" == *":$path:"* ]]; then
        log_ok "$label in PATH"
    else
        log_warn "$label missing from PATH ($path)"
        ((WARNINGS+=1))
    fi
}

section() {
    log_info "$1"
}

#######################################
# Checks
#######################################

section "Core system tools"
check_tool "GCC" gcc "gcc"
check_tool "Make" make
check_tool "Git" git "git"
check_tool "Curl" curl "curl"
check_tool "Wget" wget "Wget"

section "Python"
check_tool "Python3" python3
check_tool "pip3" pip "pip"
check_tool "uv" uv

section "Node.js"
check_tool "Node.js" node "v$NODE_VERSION"
check_tool "npm" npm

section "Go"
check_tool "Go" go "go$GO_VERSION"

section "Rust"
check_tool "Rustc" rustc
check_tool "Cargo" cargo

section "Java"
check_tool "Java" java "$JAVA_MAJOR"
check_tool "Javac" javac
check_tool "Maven" mvn
check_tool "Gradle" gradle

section "Haskell"
check_tool "GHCup" ghcup
check_tool "GHC" ghc
check_tool "Cabal" cabal

section "Containers"
check_tool "Docker" docker

section "Editors & Terminal"
check_tool "Neovim" nvim
check_tool "Tmux" tmux

section "PATH sanity"
check_path "Node (NVM)" "$HOME/.nvm/versions/node/v$NODE_VERSION/bin"
check_path "Go" "/usr/local/go/bin"
check_path "Rust (Cargo)" "$HOME/.cargo/bin"
check_path "GHCup" "$HOME/.ghcup/bin"

#######################################
# Summary
#######################################

log_info "Developer Doctor complete"

if [[ "$ERRORS" -gt 0 ]]; then
    log_error "$ERRORS error(s) detected"
fi

if [[ "$WARNINGS" -gt 0 ]]; then
    log_warn "$WARNINGS warning(s) detected"
fi

if [[ "$ERRORS" -eq 0 && "$WARNINGS" -eq 0 ]]; then
    log_ok "Environment is healthy"
else
    log_info "Review warnings/errors above and rerun install.sh or update.sh as needed"
fi