#!/usr/bin/env bash
set -euo pipefail

# Rust: installed via rustup

rust_install() {
    log_step "Installing Rust via rustup..."

    # Download and run rustup init
    log_info "Downloading rustup..."
    local rustup_init="${TEMP_DIR}/rustup-init.sh"
    mkdir -p "${TEMP_DIR}"

    retry 3 5 curl -fsSL -o "$rustup_init" "${RUSTUP_INIT_URL}" || {
        log_error "Failed to download rustup"
        return 1
    }

    chmod +x "$rustup_init"

    # Run rustup with non-interactive options
    log_info "Running rustup installer..."
    "$rustup_init" -y --default-toolchain "${RUST_CHANNEL}" --no-modify-path

    # Clean up
    rm "$rustup_init"

    # Source Rust environment
    if [[ -f "${HOME}/.cargo/env" ]]; then
        source "${HOME}/.cargo/env"
    fi

    # Verify installation
    if ! command_exists rustc; then
        log_error "Rust installation verification failed"
        return 1
    fi

    log_success "Rust (${RUST_CHANNEL}) installed"
}

rust_update() {
    log_step "Updating Rust..."

    if ! command_exists rustup; then
        log_error "rustup not found"
        return 1
    fi

    rustup update "${RUST_CHANNEL}"

    log_success "Rust updated"
}

rust_verify() {
    log_step "Verifying Rust installation..."

    local issues=0

    if ! command_exists rustc; then
        log_warn "rustc not found"
        ((issues++))
    else
        local rustc_version
        rustc_version=$(rustc --version | awk '{print $2}')
        log_info "rustc version: $rustc_version"
    fi

    if ! command_exists cargo; then
        log_warn "cargo not found"
        ((issues++))
    else
        local cargo_version
        cargo_version=$(cargo --version | awk '{print $2}')
        log_info "cargo version: $cargo_version"
    fi

    if ! command_exists rustup; then
        log_warn "rustup not found"
        ((issues++))
    else
        local rustup_version
        rustup_version=$(rustup --version | awk '{print $1}')
        log_info "rustup: $rustup_version"
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Rust verified"
    else
        return 1
    fi
}

rust_uninstall() {
    log_step "Uninstalling Rust..."

    if command_exists rustup; then
        log_info "Running rustup self uninstall..."
        rustup self uninstall -y
        log_success "Rust uninstalled"
    else
        log_info "rustup not found, skipping uninstall"
    fi
}