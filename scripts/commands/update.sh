#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"

update_main() {
    log_header "Update orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none} dry_run=${DRY_RUN}"
    # TODO: invoke updates via registry
}