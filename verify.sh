#!/usr/bin/env bash
set -euo pipefail

#######################################
# Bootstrap
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib/logging.sh"

#######################################
# Helpers
#######################################

ok() {
    echo -e "\033[1;32m✔ $1\033[0m"
}

fail() {
    echo -e "\033[1;31m✘ $1\033[0m"
}

check_cmd() {
    local name="$1"
    local cmd="$1"
    local version_output=""
    if command_exists "$cmd"; then
        if version_output=$($cmd --version 2>/dev/null | head -n1); then
            ok "$name: $version_output"
        else
            ok "$name: installed"
        fi
    else
        fail "$name is not installed"
        MISSING_TOOLS+=("$name")
    fi
}

#######################################
# Main
#######################################

main() {
    MISSING_TOOLS=()

    log_info "Verifying system tooling"
    check_cmd "gcc" gcc
    check_cmd "make" make
    check_cmd "git" git
    check_cmd "curl" curl

    log_info "Verifying Python"
    check_cmd "python3" python3
    check_cmd "pip" pip
    check_cmd "uv" uv

    log_info "Verifying Node.js"
    check_cmd "node" node
    check_cmd "npm" npm

    log_info "Verifying Go"
    check_cmd "go" go

    log_info "Verifying Rust"
    check_cmd "rustc" rustc
    check_cmd "cargo" cargo

    log_info "Verifying Java"
    check_cmd "java" java
    check_cmd "javac" javac
    check_cmd "mvn" mvn
    check_cmd "gradle" gradle

    log_info "Verifying Haskell"
    check_cmd "ghcup" ghcup
    check_cmd "ghc" ghc
    check_cmd "cabal" cabal

    log_info "Verifying Containers"
    check_cmd "docker" docker

    log_info "Verifying Editors & Shell"
    check_cmd "tmux" tmux
    check_cmd "nvim" nvim

    if [ "${#MISSING_TOOLS[@]}" -eq 0 ]; then
        log_info "Verification complete - all tools are installed"
    else
        log_warn "Verification complete - some tools are missing:"
        for tool in "${MISSING_TOOLS[@]}"; do
            echo "  - $tool"
        done
        log_warn "Consider running /.install.sh or update.sh to fix missing tools"
    fi
}

main "$@"
