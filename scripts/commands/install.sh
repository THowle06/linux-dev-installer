#!/usr/bin/env bash
set -euo pipefail

# Load bootstrap
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"

install_main() {
    log_header "Install orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none} dry_run=${DRY_RUN}"
    # TODO: invoke installs via registry
}