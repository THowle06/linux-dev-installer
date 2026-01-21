#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"
source "${CORE_DIR}/registry.sh"

verify_main() {
    log_header "Verify orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none}"
    _dispatch_tools "verify"
}