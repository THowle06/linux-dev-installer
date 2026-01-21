#!/usr/bin/env bash
set -euo pipefail

DOCKER_KEYRING="/etc/apt/keyrings/docker.gpg"
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"

_is_wsl() {
    grep -qi "microsoft" /proc/sys/kernel/osrelease 2>/dev/null
}

docker_install() {
    log_step "Installing Docker..."

    if _is_wsl; then
        log_info "WSL detected with Docker Desktop integration expected."
        log_info "Skipping Docker Engine install; ensure Docker Desktop WSL integration is enabled."
        if ! command_exists docker; then
            log_warn "docker CLI not found. Launch Docker Desktop once to install the CLI into this distro."
            return 1
        fi
        log_success "Docker CLI available via Docker Desktop"
        return 0
    fi

    require_sudo
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "${DOCKER_GPG_URL}" | sudo gpg --dearmor -o "${DOCKER_KEYRING}"
    sudo chmod a+r "${DOCKER_KEYRING}"
    echo "${DOCKER_REPO}" | sudo tee "${DOCKER_LIST}" >/dev/null

    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    log_success "Docker Engine installed"
}

docker_update() {
    log_step "Updating Docker..."

    if _is_wsl; then
        log_info "WSL detected; Docker Engine managed by Docker Desktop. Skipping update."
        return 0
    fi
    
    require_sudo
    sudo apt-get update -qq
    sudo apt-get install --only-upgrade -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    log_success "Docker updated"
}

docker_verify() {
    log_step "Verifying Docker..."

    local issues=0

    if ! command_exists docker; then
        log_warn "docker CLI not found"
        ((issues++))
    else
        log_info "docker version: $(docker --version 2>/dev/null || true)"
    fi

    # Check socket availability
    if docker info >/dev/null 2>&1; then
        log_info "docker info: OK"
    else
        log_warn "docker info failed: Is Docker Desktop running and WSL integration enabled?"
        ((issues++))
    fi

    if docker compose version >/dev/null 2>&1; then
        log_info "docker compose: $(docker compose version 2>/dev/null | head -n1)"
    else
        log_warn "docker compose not available"
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Docker verified"
    else
        return 1
    fi
}

docker_uninstall() {
    log_step "Uninstalling Docker..."

    if _is_wsl; then
        log_info "WSL detected; Docker Desktop manages the engine. No uninstall performed."
        return 0
    fi

    require_sudo
    sudo apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
    sudo rm -f "${DOCKER_LIST}" "${DOCKER_KEYRING}"
    log_success "Docker uninstalled (volumes not removed)"
}