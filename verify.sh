#!/usr/bin/env bash
set -euo pipefail

#######################################
# Bootstrap
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/registry/tools.sh"

#######################################
# Main
#######################################

main() {
    MISSING_TOOLS=()

    log_info "Verifying system tooling"
    for tool in "${TOOLS_CORE[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Python"
    for tool in "${TOOLS_PYTHON[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Node.js"
    for tool in "${TOOLS_NODE[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Go"
    for tool in "${TOOLS_GO[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Rust"
    for tool in "${TOOLS_RUST[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Java"
    for tool in "${TOOLS_JAVA[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Haskell"
    for tool in "${TOOLS_HASKELL[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Containers"
    for tool in "${TOOLS_CONTAINERS[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    log_info "Verifying Editors & Shell"
    for tool in "${TOOLS_EDITORS[@]}"; do
        if ! check_tool "$tool" "$tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    if [ "${#MISSING_TOOLS[@]}" -eq 0 ]; then
        log_info "Verification complete - all tools are installed"
    else
        log_warn "Verification complete - some tools are missing:"
        for tool in "${MISSING_TOOLS[@]}"; do
            echo "  - $tool"
        done
        log_warn "Consider running /.install.sh or update.sh to fix missing tools"
        exit 1
    fi
}

main "$@"
