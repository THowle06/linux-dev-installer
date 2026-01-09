#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: ./dotfiles.sh <command> [options]

Commands:
    install             Run installer
    update              Update tools
    verify              Quick verification
    doctor              Full health check
    help                Show this help

Options (reserved for future):
    --only <cats>       Comma-separated categories to include
    --exclude <cats>    Comma-separated categories to skip

Examples:
    ./dotfiles.sh install
    ./dotfiles.sh verify
EOF
}

cmd="${1:-help}"
shift || true

case "$cmd" in
    install) exec "$SCRIPT_DIR/install.sh" "$@" ;;
    update)  exec "$SCRIPT_DIR/update.sh"  "$@" ;;
    verify)  exec "$SCRIPT_DIR/verify.sh"  "$@" ;;
    doctor)  exec "$SCRIPT_DIR/doctor.sh"  "$@" ;;
    help|-h|--help)
        usage
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        usage
        exit 1
        ;;
esac