#!/usr/bin/env bash
set -euo pipefail

ANACONDA_BLOCK_START="# >>> anaconda initialize >>>"
ANACONDA_BLOCK_END="# <<< anaconda initialize <<<"

_anaconda_arch() {
  case "${ARCH}" in
    amd64) echo "x86_64" ;;
    arm64) echo "aarch64" ;;
    *) log_error "Unsupported ARCH: ${ARCH}"; return 1 ;;
  esac
}

_anaconda_url() {
  local arch
  arch="$(_anaconda_arch)"
  if [[ "${ANACONDA_EDITION}" == "miniconda" ]]; then
    echo "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${arch}.sh"
  else
    echo "https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-${arch}.sh"
  fi
}

anaconda_install() {
  log_step "Installing ${ANACONDA_EDITION}..."

  mkdir -p "${TEMP_DIR}"
  local url installer
  url="$(_anaconda_url)" || return 1
  installer="${TEMP_DIR}/$(basename "$url")"

  log_info "Downloading $(basename "$url")..."
  retry 3 5 curl -fsSL -o "${installer}" "${url}"

  log_info "Running installer (batch mode) to ${ANACONDA_INSTALL_PATH}..."
  if [[ -d "${ANACONDA_INSTALL_PATH}" ]]; then
    log_info "Existing installation detected; updating..."
    bash "${installer}" -b -u -p "${ANACONDA_INSTALL_PATH}"
  else
    bash "${installer}" -b -p "${ANACONDA_INSTALL_PATH}"
  fi

  rm -f "${installer}"

  _ensure_conda_shell_in_rc

  log_success "${ANACONDA_EDITION^} installed at ${ANACONDA_INSTALL_PATH}"
  log_info "Open a new shell or 'source ~/.bashrc' to activate conda."
}

anaconda_update() {
  log_step "Updating conda (base)..."
  if ! command_exists conda; then
    log_warn "conda not found; install first."
    return 1
  fi

  # Source conda if installed
  if [[ -f "${ANACONDA_INSTALL_PATH}/etc/profile.d/conda.sh" ]]; then
    source "${ANACONDA_INSTALL_PATH}/etc/profile.d/conda.sh"
  fi

  # Accept TOS for Anaconda channels
  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

  conda update -n base -y conda
  log_success "conda updated"
}

anaconda_verify() {
  log_step "Verifying conda..."

  # Source conda if installed
  if [[ -f "${ANACONDA_INSTALL_PATH}/etc/profile.d/conda.sh" ]]; then
    source "${ANACONDA_INSTALL_PATH}/etc/profile.d/conda.sh"
  fi

  if ! command_exists conda; then
    log_warn "conda not found"
    return 1
  fi
  log_info "conda version: $(conda --version 2>/dev/null)"
  log_success "conda verified"
}

anaconda_uninstall() {
  log_step "Uninstalling ${ANACONDA_EDITION^}..."
  if [[ -d "${ANACONDA_INSTALL_PATH}" ]]; then
    rm -rf "${ANACONDA_INSTALL_PATH}"
    log_info "Removed ${ANACONDA_INSTALL_PATH}"
  else
    log_info "Anaconda not present at ${ANACONDA_INSTALL_PATH}"
  fi
  _remove_conda_shell_in_rc
  log_success "${ANACONDA_EDITION^} uninstalled"
}

_ensure_conda_shell_in_rc() {
  local rc="${HOME}/.bashrc"
  # Ensure home exists
  if [[ ! -d "${HOME}" ]]; then
    log_warn "HOME directory not found; skipping conda init block"
    return 0
  fi
  # Create ~/.bashrc if missing
  if [[ ! -f "${rc}" ]]; then
    if ! touch "${rc}" 2>/dev/null; then
      log_warn "Cannot create ${rc}; skipping conda init block. You can add it manually."
      return 0
    fi
  fi
  # Skip if block already present
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