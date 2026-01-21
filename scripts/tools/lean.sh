#!/usr/bin/env bash
set -euo pipefail

# Lean 4: installed via elan

ELAN_DIR="${HOME}/.elan"
ELAN_BIN="${ELAN_DIR}/bin/elan"

lean_install() {
  log_step "Installing Lean 4 via elan..."

  if [[ -f "${ELAN_BIN}" ]]; then
    log_info "elan already installed"
  else
    log_info "Downloading and installing elan..."
    curl -fsSL "${ELAN_INIT_URL}" | sh -s -- -y --default-toolchain "${LEAN_VERSION}"
  fi

  # Source elan environment
  [[ -f "${ELAN_DIR}/env" ]] && source "${ELAN_DIR}/env"

  if ! command_exists elan; then
    log_error "elan installation failed"
    return 1
  fi

  log_success "Lean 4 installed via elan"
}

lean_update() {
  log_step "Updating Lean 4..."

  if ! command_exists elan; then
    log_error "elan not found"
    return 1
  fi

  [[ -f "${ELAN_DIR}/env" ]] && source "${ELAN_DIR}/env"

  elan self update
  elan update

  log_success "Lean 4 updated"
}

lean_verify() {
  log_step "Verifying Lean 4..."

  local issues=0

  if ! command_exists elan; then
    log_warn "elan not found"
    ((issues++))
  else
    log_info "elan: $(elan --version 2>/dev/null)"
  fi

  if ! command_exists lean; then
    log_warn "lean not found"
    ((issues++))
  else
    log_info "lean version: $(lean --version 2>/dev/null | head -n1)"
  fi

  if ! command_exists lake; then
    log_warn "lake not found"
    ((issues++))
  else
    log_info "lake version: $(lake --version 2>/dev/null | head -n1)"
  fi

  if [[ $issues -eq 0 ]]; then
    log_success "Lean 4 verified"
  else
    return 1
  fi
}

lean_uninstall() {
  log_step "Uninstalling Lean 4..."

  if [[ -d "${ELAN_DIR}" ]]; then
    log_info "Removing elan directory: ${ELAN_DIR}"
    rm -rf "${ELAN_DIR}"
  fi

  log_success "Lean 4 uninstalled"
}