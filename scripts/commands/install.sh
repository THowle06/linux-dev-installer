#!/usr/bin/env bash
set -euo pipefail

# Load bootstrap
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"
source "${CORE_DIR}/registry.sh"

install_main() {
    log_header "Install orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none} dry_run=${DRY_RUN}"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log_info "Dry run: no actions executed"
        return 0
    fi
    _dispatched_tools "install"
}