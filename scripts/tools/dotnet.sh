#!/usr/bin/env bash
set -euo pipefail

# .NET: installed via apt (Microsoft repository)

dotnet_install() {
    log_step "Installing .NET SDK..."

    # .NET should be installed via apt already
    if ! command_exists dotnet; then
        log_error "dotnet not found. Ensure dotnet-sdk-${DOTNET_VERSION} is installed via apt."
        return 1
    fi

    log_success ".NET SDK installed"
}

dotnet_update() {
    log_step "Updating .NET SDK..."

    require_sudo
    sudo apt-get update -qq
    sudo apt-get install --only-upgrade -y dotnet-sdk-${DOTNET_VERSION}

    log_success ".NET SDK updated"
}

dotnet_verify() {
    log_step "Verifying .NET SDK..."

    if ! command_exists dotnet; then
        log_warn "dotnet not found"
        return 1
    fi

    local dotnet_version
    dotnet_version=$(dotnet --version)
    log_info "dotnet version: $dotnet_version"

    # List installed SDKs
    log_info "Installed SDKs:"
    dotnet --list-sdks | while read -r line; do
        log_info "  - $line"
    done

    log_success ".NET SDK verified"
}

dotnet_uninstall() {
    log_step "Uninstalling .NET SDK"

    log_info "Keeping .NET SDK (managed by apt)"
    log_info "Use 'sudo apt-get remove dotnet-sdk-${DOTNET_VERSION}' if needed"
}