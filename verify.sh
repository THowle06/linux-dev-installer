#!/usr/bin/env bash
set -euo pipefail

#######################################
# Logging
#######################################

log() {
    echo -e "\n\033[1;34m==> $1\033[0m"
}

ok() {
    echo -e "  \033[1;32m✔ $1\033[0m"
}

fail() {
    echo -e "  \033[1;31m✘ $1\033[0m"
    exit 1
}

check_cmd() {
    local name="$1"
    local cmd="$2"

    if command -v "$cmd" >/dev/null 2>&1; then
        ok "$name: $($cmd --version 2>/dev/null | head -n 1)"
    else
        fail "$name is not installed"
    fi
}

#######################################
# Verification
#######################################

log "System tooling"
check_cmd "gcc" gcc
check_cmd "make" make
check_cmd "git" git
check_cmd "curl" curl

log "Python"
check_cmd "python3" python3
check_cmd "pip" pip
check_cmd "uv" uv

log "Node.js"
check_cmd "node" node
check_cmd "npm" npm

log "Go"
check_cmd "go" go

log "Rust"
check_cmd "rustc" rustc
check_cmd "cargo" cargo

log "Java"
check_cmd "java" java
check_cmd "javac" javac
check_cmd "mvn" mvn
check_cmd "gradle" gradle

log "Haskell"
check_cmd "ghcup" ghcup
check_cmd "ghc" ghc
check_cmd "cabal" cabal

log "Containers"
check_cmd "docker" docker

log "Editors & Shell"
check_cmd "tmux" tmux
check_cmd "nvim" nvim

log "Verification complete - environment looks healthy"