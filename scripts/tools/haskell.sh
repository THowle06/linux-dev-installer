#!/usr/bin/env bash
set -euo pipefail

# Haskell: GHC, Cabal, Stack via GHCup

GHCUP_INSTALL_URL="https://get-ghcup.haskell.org"
GHCUP_DIR="${HOME}/.ghcup"
GHCUP_BIN="${GHCUP_DIR}/bin/ghcup"

haskell_install() {
  log_step "Installing Haskell via GHCup..."

  if [[ -f "${GHCUP_BIN}" ]]; then
    log_info "GHCup already installed"
  else
    log_info "Running GHCup installer (interactive mode)..."
    log_warn "Follow the prompts to configure your installation."
    curl -fsSL "${GHCUP_INSTALL_URL}" | sh
  fi

  # Source GHCup environment
  [[ -f "${GHCUP_DIR}/env" ]] && source "${GHCUP_DIR}/env"

  if ! command_exists ghcup; then
    log_error "GHCup installation failed or not in PATH"
    log_info "You may need to restart your shell or source ${GHCUP_DIR}/env"
    return 1
  fi

  log_success "Haskell ecosystem installed"
  log_info "Recommended versions: GHC ${GHC_VERSION}, Cabal ${CABAL_VERSION}"
}

haskell_update() {
  log_step "Updating Haskell..."

  if ! command_exists ghcup; then
    log_error "GHCup not found"
    return 1
  fi

  [[ -f "${GHCUP_DIR}/env" ]] && source "${GHCUP_DIR}/env"

  ghcup upgrade

  log_success "Haskell updated"
  log_info "Use 'ghcup tui' to manage GHC/Cabal versions interactively"
}

haskell_verify() {
  log_step "Verifying Haskell..."

  local issues=0

  if ! command_exists ghcup; then
    log_warn "ghcup not found"
    ((issues++))
  else
    log_info "ghcup: $(ghcup --version 2>/dev/null | head -n1)"
  fi

  if ! command_exists ghc; then
    log_warn "ghc not found"
    ((issues++))
  else
    log_info "ghc version: $(ghc --version 2>/dev/null | awk '{print $NF}')"
  fi

  if ! command_exists cabal; then
    log_warn "cabal not found"
    ((issues++))
  else
    log_info "cabal version: $(cabal --version 2>/dev/null | head -n1 | awk '{print $3}')"
  fi

  if [[ $issues -eq 0 ]]; then
    log_success "Haskell verified"
  else
    return 1
  fi
}

haskell_uninstall() {
  log_step "Uninstalling Haskell..."

  if [[ -d "${GHCUP_DIR}" ]]; then
    log_info "Removing GHCup directory: ${GHCUP_DIR}"
    rm -rf "${GHCUP_DIR}"
  fi

  log_success "Haskell uninstalled"
}