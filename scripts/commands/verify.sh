#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"

verify_main() {
    log_header "Verify orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none}"
    # TODO: invoke verify via registry
}