#!/usr/bin/env bash
set -euo pipefail

ANACONDA_BLOCK_START="# >>> anaconda initialize >>>"
ANACONDA_BLOCK_END="# <<< anaconda initialize <<<"

anaconda_install() {
  log_step "Installing Anaconda..."

  mkdir -p "${TEMP_DIR}"
  local installer="${TEMP_DIR}/${ANACONDA_INSTALLER}"

  log_info "Downloading ${ANACONDA_INSTALLER}..."
  retry 3 5 curl -fsSL -o "${installer}" "${ANACONDA_URL}"

  log_info "Running installer (batch mode) to ${ANACONDA_INSTALL_PATH}..."
  bash "${installer}" -b -p "${ANACONDA_INSTALL_PATH}"

  rm -f "${installer}"

  _ensure_conda_shell_in_rc

  log_success "Anaconda installed at ${ANACONDA_INSTALL_PATH}"
  log_info "Open a new shell or 'source ~/.bashrc' to activate conda."
}

anaconda_update() {
  log_step "Updating Anaconda (base conda)..."
  if ! command_exists conda; then
    log_warn "conda not found; install first."
    return 1
  fi
  conda update -n base -y conda
  log_success "Anaconda updated"
}

anaconda_verify() {
  log_step "Verifying Anaconda..."
  if ! command_exists conda; then
    log_warn "conda not found"
    return 1
  fi
  log_info "conda version: $(conda --version 2>/dev/null)"
  log_success "Anaconda verified"
}

anaconda_uninstall() {
  log_step "Uninstalling Anaconda..."
  if [[ -d "${ANACONDA_INSTALL_PATH}" ]]; then
    rm -rf "${ANACONDA_INSTALL_PATH}"
    log_info "Removed ${ANACONDA_INSTALL_PATH}"
  else
    log_info "Anaconda not present at ${ANACONDA_INSTALL_PATH}"
  fi
  _remove_conda_shell_in_rc
  log_success "Anaconda uninstalled"
}

_ensure_conda_shell_in_rc() {
  local rc="${HOME}/.bashrc"
  if grep -q "${ANACONDA_BLOCK_START}" "${rc}" 2>/dev/null; then
    return 0
  fi
  cat <<'EOF' >> "${rc}"
# >>> anaconda initialize >>>
if [ -d "$HOME/anaconda3" ]; then
  . "$HOME/anaconda3/etc/profile.d/conda.sh"
  export PATH="$HOME/anaconda3/bin:$PATH"
fi
# <<< anaconda initialize <<<
EOF
  log_info "Added conda init block to ${rc}"
}

_remove_conda_shell_in_rc() {
  local rc="${HOME}/.bashrc"
  if [[ -f "${rc}" ]]; then
    sed -i "/${ANACONDA_BLOCK_START}/,/${ANACONDA_BLOCK_END}/d" "${rc}"
    log_info "Removed conda init block from ${rc}"
  fi
}