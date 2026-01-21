#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/bootstrap.sh"
source "${CORE_DIR}/registry.sh"

doctor_main() {
    log_header "Doctor orchestrator"
    log_info "only=${FILTER_ONLY:-all} exclude=${FILTER_EXCLUDE:-none}"
    _dispatch_tools "verify" # later: add deeper diagnostics per tool
}