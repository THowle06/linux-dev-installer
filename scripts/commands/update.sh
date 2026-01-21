#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"
source "${CORE_DIR}/registry.sh"

update_main() {
    log_header "Update orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none} dry_run=${DRY_RUN}"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log_info "Dry run: no actions executed"
        return 0
    fi
    _dispatch_tools "update"
}