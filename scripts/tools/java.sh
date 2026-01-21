#!/usr/bin/env bash
set -euo pipefail

# Java: OpenJDK, Maven, Gradle (via apt)

java_install() {
    log_step "Installing Java ecosystem..."

    # OpenJDK, Maven, Gradle should be installed via apt already
    if ! command_exists java; then
        log_error "java not found. Ensure openjdk-${OPENJDK_VERSION}-jdk is installed via apt."
        return 1
    fi

    if ! command_exists mvn; then
        log_error "mvn not found. Ensure maven is installed via apt."
        return 1
    fi

    if ! command_exists gradle; then
        log_error "gradle not found. Ensure gradle is installed via apt."
        return 1
    fi

    log_success "Java ecosystem installed"
}

java_update() {
    log_step "Updating Java ecosystem..."

    require_sudo
    sudo apt-get update -qq
    sudo apt-get install --only-upgrade -y openjdk-${OPENJDK_VERSION}-jdk maven gradle

    log_success "Java ecosystem updated"
}

java_verify() {
    log_step "Verifying Java ecosystem..."

    local issues=0

    if ! command_exists java; then
        log_warn "java not found"
        ((issues++))
    else
        local java_version
        java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
        log_info "java version: $java_version"
    fi

    if ! command_exists javac; then
        log_warn "javac not found"
        ((issues++))
    else
        local javac_version
        javac_version=$(javac -version 2>&1 | awk '{print $2}')
        log_info "javac version: $javac_version"
    fi

    if ! command_exists mvn; then
        log_warn "mvn not found"
        ((issues++))
    else
        local mvn_version
        mvn_version=$(mvn -version 2>&1 | head -n 1 | awk '{print $3}')
        log_info "maven version: $mvn_version"
    fi

    if ! command_exists gradle; then
        log_warn "gradle not found"
        ((issues++))
    else
        local gradle_version
        gradle_version=$(gradle -version 2>&1 | grep '^Gradle' | awk '{print $2}')
        log_info "gradle version: $gradle_version"
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Java ecosystem verified"
    else
        return 1
    fi
}

java_uninstall() {
    log_step "Uninstalling Java ecosystem..."

    log_info "Keeping OpenJDK, Maven, Gradle (managed by apt)"
    log_info "Use 'sudo apt-get remove openjdk-${OPENJDK_VERSION}-jdk maven gradle' if needed"
}