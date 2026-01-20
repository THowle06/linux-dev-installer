#!/usr/bin/env bash
# Global configuration - single source of truth for versions

# System settings
readonly HOME_DIR="${HOME}"
readonly BACKUP_DIR="${HOME}/.dotfiles-backup"
readonly TEMP_DIR="/tmp/linux-dev-installer"

# Tool categories
readonly CATEGORIES=(
    "python"
    "node"
    "go"
    "rust"
    "haskell"
    "java"
    "dotnet"
    "lean"
    "docker"
    "dotfiles"
)

# Version configuration
# TODO: We'll populate these as we implement each tool
readonly NODE_VERSION="24.12.0"
readonly GO_VERSION="1.25.5"
readonly RUST_CHANNEL="stable"
readonly DOTNET_VERSION="10.0"
readonly LEAN_VERSION="latest"

# Architecture
readonly ARCH="$(get_architecture)"

log_debug "Configuration loaded for ${ARCH} architecture"