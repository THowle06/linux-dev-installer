#!/usr/bin/env bash
set -euo pipefail

# Go: installed via tarball from golang.org

go_install() {
    log_step "Installing Go..."

    # Remove old Go if present
    if [[ -d "${GO_INSTALL_PATH}/go" ]]; then
        log_info "Removing previous Go installation..."
        require_sudo
        sudo rm -rf "${GO_INSTALL_PATH}/go"
    fi

    # Download and extract tarball
    log_info "Downloading Go ${GO_VERSION}..."
    local go_tarball="${TEMP_DIR}/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    mkdir -p "${TEMP_DIR}"

    retry 3 5 curl -fsSL -o "$go_tarball" "${GO_URL}" || {
        log_error "Failed to download Go"
        return 1
    }

    # Extract to install path
    log_info "Extracting Go to ${GO_INSTALL_PATH}..."
    require_sudo
    sudo tar -C "${GO_INSTALL_PATH}" -xzf "$go_tarball"

    # Clean up tarball
    rm "$go_tarball"

    # Verify installation
    if ! "${GO_INSTALL_PATH}/go/bin/go" version >/dev/null 2>&1; then
        log_error "Go installation verification failed"
        return 1
    fi

    log_success "Go ${GO_VERSION} installed"
}

go_update() {
    log_step "Updating Go..."

    # Same as install (replace old version)
    go_install
}

go_verify() {
    log_step "Verifying Go installation..."

    if ! command_exists go; then
        log_warn "go not in PATH"
        log_info "Ensure ${GO_INSTALL_PATH}/go/bin is in your \$PATH"
        return 1
    fi

    local go_version
    go_version=$(go version | awk '{print $3}')
    log_info "Go version: $go_version"

    if ! command_exists gofmt; then
        log_warn "gofmt not found"
        return 1
    fi

    log_success "Go verified"
}

go_uninstall() {
    log_step "Uninstalling Go..."

    if [[ -d "${GO_INSTALL_PATH}/go" ]]; then
        log_info "Removing Go from ${GO_INSTALL_PATH}..."
        require_sudo
        sudo rm -rf "${GO_INSTALL_PATH}/go"
        log_success "Go uninstalled"
    else
        log_info "Go not found at ${GO_INSTALL_PATH}/go"
    fi
}