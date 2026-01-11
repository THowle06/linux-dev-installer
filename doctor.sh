#!/usr/bin/env bash
set -euo pipefail

#######################################
# Developer Doctor
# Verify development environment health
#######################################

# Resolve repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use central bootstrap (logging, utils, config, checks) and tool registry
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/registry/tools.sh"

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
for tool in "${TOOLS_CORE[@]}"; do
    check_tool "$tool" "$tool"
done

section "Python"
for tool in "${TOOLS_PYTHON[@]}"; do
    check_tool "$tool" "$tool"
done

section "Node.js"
for tool in "${TOOLS_NODE[@]}"; do
    check_tool "$tool" "$tool"
done
check_tool "Node.js version" node "v$NODE_VERSION"

section "Go"
for tool in "${TOOLS_GO[@]}"; do
    check_tool "$tool" "$tool"
done
check_tool "Go version" go "go$GO_VERSION"

section "Rust"
for tool in "${TOOLS_RUST[@]}"; do
    check_tool "$tool" "$tool"
done

section "Java"
for tool in "${TOOLS_JAVA[@]}"; do
    check_tool "$tool" "$tool"
done
check_tool "Java version" java "$JAVA_MAJOR"


section "Haskell"
for tool in "${TOOLS_HASKELL[@]}"; do
    check_tool "$tool" "$tool"
done

section ".NET"
for tool in "${TOOLS_DOTNET[@]}"; do
    check_tool "$tool" "$tool"
done
check_tool ".NET version" dotnet "$DOTNET_VERSION"

section "Containers"
for tool in "${TOOLS_CONTAINERS[@]}"; do
    check_tool "$tool" "$tool"
done

section "Editors & Terminal"
for tool in "${TOOLS_EDITORS[@]}"; do
    check_tool "$tool" "$tool"
done

section "PATH sanity"
check_path "Node (NVM)" "$HOME/.nvm/versions/node/v$NODE_VERSION/bin"
check_path "Go" "$GO_INSTALL_DIR/bin"
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