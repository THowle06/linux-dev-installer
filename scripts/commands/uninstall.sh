#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"

uninstall_main() {
    log_header "Uninstall orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none} confirm=${CONFIRM} restore_backups=${RESTORE_BACKUPS}"
    # TODO: confirmation + uninstall via registry
}