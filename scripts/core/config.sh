#!/usr/bin/env bash
# Global configuration - single source of truth for versions

set -euo pipefail

# System settings
readonly HOME_DIR="${HOME}"
readonly BACKUP_DIR="${HOME}/.dotfiles-backup"
readonly TEMP_DIR="/tmp/linux-dev-installer"
readonly NVM_DIR="${HOME}/.nvm"

# Tool categories
readonly CATEGORIES=(
    "apt"
    "python"
    "anaconda"
    "node"
    "go"
    "rust"
    "haskell"
    "java"
    "dotnet"
    "docker"
    "lean"
    "dotfiles"
)

# =========== Version pinning ===========

# Python ecosystem
readonly PYTHON_VERSION="3.12"  # system python3
readonly UV_VERSION="0.6.4"     # uv package manager
readonly PYENV_VERSION="2.4.13" # pyenv (optional, for version switching)

# Node.js (via NVM)
readonly NODE_VERSION="24.12.0"
readonly NVM_VERSION="0.40.1"

# Go (tarball)
readonly GO_VERSION="1.23.5"
readonly GO_ARCH="${ARCH}"      # amd64 or arm64
readonly GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
readonly GO_INSTALL_PATH="/usr/local"

# Rust (via rustup)
readonly RUST_CHANNEL="stable"
readonly RUSTUP_INIT_URL="https://sh.rustup.rs"

# Java / JVM
readonly OPENJDK_VERSION="21"
readonly MAVEN_VERSION="3.9.8"
readonly GRADLE_VERSION="8.9"

# .NET
readonly DOTNET_VERSION="10.0"

# Haskell (via GHCup)
readonly GHCUP_VERSION="0.1.23.0"
readonly GHC_VERSION="9.10.1"
readonly CABAL_VERSION="3.12.1.0"

# Lean 4 (via elan)
readonly ELAN_VERSION="1.4.17"
readonly LEAN_VERSION="latest"
readonly ELAN_INIT_URL="https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh"

# Anaconda / Miniconda
readonly ANACONDA_VERSION="2024.12-1"
readonly ANACONDA_ARCH="${ARCH}"    # x86_64 or aarch64
readonly ANACONDA_INSTALLER="Anaconda3-${ANACONDA_VERSION}-Linux-${ANACONDA_ARCH}.sh"
readonly ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_INSTALLER}"
readonly ANACONDA_INSTALL_PATH="${HOME}/anaconda3"

# Docker
readonly DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
readonly DOCKER_REPO="deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# =========== Architecture ===========
readonly ARCH="$(get_architecture)"

log_debug "Configuration loaded for ${ARCH} architecture"