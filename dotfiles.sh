#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FILTER_INCLUDE=""
FILTER_EXCLUDE=""
FILTER_ARGS=()

parse_filters() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --only)
                FILTER_INCLUDE="${2:-}"
                shift 2
                ;;
            --exclude)
                FILTER_EXCLUDE="${2:-}"
                shift 2
                ;;
            *)
                FILTER_ARGS+=("$1")
                shift
                ;;
        esac
    done
}

usage() {
    cat <<EOF
Usage: ./dotfiles.sh <command> [options]

Commands:
    install             Run installer
    update              Update tools
    verify              Quick verification
    doctor              Full health check
    uninstall           Remove installed tools
    help                Show this help

Options:
    --only <cats>       Comma-separated categories to include
    --exclude <cats>    Comma-separated categories to skip

Available categories:
    python, node, go, rust, haskell, editors

Examples:
    ./dotfiles.sh install
    ./dotfiles.sh install --only python,node
    ./dotfiles.sh update --exclude haskell,java
    ./dotfiles.sh uninstall --confirm
EOF
}

cmd="${1:-help}"
shift || true

case "$cmd" in
    install)
        parse_filters "$@"
        export FILTER_INCLUDE FILTER_EXCLUDE
        exec "$SCRIPT_DIR/install.sh" "${FILTER_ARGS[@]}"
        ;;
    update)
        parse_filters "$@"
        export FILTER_INCLUDE FILTER_EXCLUDE
        exec "$SCRIPT_DIR/update.sh"  "${FILTER_ARGS[@]}"
        ;;
    verify) exec "$SCRIPT_DIR/verify.sh" "$@" ;;
    doctor) exec "$SCRIPT_DIR/doctor.sh" "$@" ;;
    uninstall)
        parse_filters "$@"
        export FILTER_INCLUDE FILTER_EXCLUDE
        exec "$SCRIPT_DIR/uninstall.sh" "${FILTER_ARGS[@]}"
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        usage
        exit 1
        ;;
esac