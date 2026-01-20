#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PROJECT_ROOT}/scripts/core/bootstrap.sh"

usage() { cat <<'EOF'
Usage: ./main.sh <command> [options]

Commands:
    install     Install all or filtered categories
    update      Update installed tools
    verify      Quick verification or installed tools
    doctor      Detailed health check
    uninstall   Uninstall tools (with optional backup restoration)
    help        Show this help

Options:
    --only <cats>       Comma-separated categories to include
    --exclude <cats>    Comma-separated categories to exclude
    --dry-run           Show actions without executing
    --confirm           Skip confirmation prompts (uninstall)
    --restore-backups   Restore backups during uninstall
    --log-level <lvl>   debug|info|warn|error (default: info)
    -h, --help          Show this help
EOF
}

if [[ $# -lt 1 ]]; then usage; exit 1; fi
COMMAND="$1"; shift || true
FILTER_ONLY=""; FILTER_EXCLUDE=""; DRY_RUN=0; CONFIRM=0; RESTORE_BACKUPS=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --only) FILTER_ONLY="${2:-}"; shift 2 ;;
        --exclude) FILTER_EXCLUDE="${2:-}"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        --confirm) CONFIRM=1; shift ;;
        --restore-backups) RESTORE_BACKUPS=1; shift ;;
        --log-level)
            case "${2:-}" in
                debug) LOG_LEVEL=0 ;; info) LOG_LEVEL=1 ;; warn) LOG_LEVEL=2 ;; error) LOG_LEVEL=3 ;;
                *) echo "Invalid log level: ${2:-}"; usage; exit 1 ;;
            esac; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

export FILTER_ONLY FILTER_EXCLUDE DRY_RUN CONFIRM RESTORE_BACKUPS LOG_LEVEL

case "$command" in
    install)    source "${COMMANDS_DIR}/install.sh";    install_main ;;
    update)     source "${COMMANDS_DIR}/update.sh";     update_main ;;
    verify)     source "${COMMANDS_DIR}/verify.sh";     verify_main ;;
    doctor)     source "${COMMANDS_DIR}/doctor.sh";     doctor_main ;;
    uninstall)  source "${COMMANDS_DIR}/uninstall.sh";  uninstall_main ;;
    help) usage ;;
    *) echo "Unknown command: $COMMAND"; usage; exit 1 ;;
esac