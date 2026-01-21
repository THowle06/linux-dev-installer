#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"
source "${CORE_DIR}/registry.sh"

uninstall_main() {
    log_header "Uninstall orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none} confirm=${CONFIRM} restore_backups=${RESTORE_BACKUPS}"
    if [[ "${CONFIRM:-0}" -ne 1 ]]; then
        confirm "Proceed with uninstall?" || { log_info "Aborted."; return 0; }
    fi
    _dispatch_tools "uninstall"
    if [[ "${RESTORE_BACKUPS:-0}" -eq 1 ]]; then
        log_info "Requested backup restoration (not yet implemented)."
    fi
}