#!/usr/bin/env bash

check_tool() {
    local name="$1"
    local cmd="$2"
    local expected="${3:-}"

    if command_exists "$cmd"; then
        local version
        version="$(get_version_line "$cmd")"

        if [[ -n "$expected" && "$version" != *"$expected"* ]]; then
            log_warn "$name version mismatch: $version (expected $expected)"
        else
            log_ok "$name OK ($version)"
        fi
    else
        log_error "$name is not installed"
        return 1
    fi
}

check_path() {
    local label="$1"
    local path="$2"

    if [[ ":$PATH:" == *":$path:"* ]]; then
        log_ok "$label in PATH"
    else
        log_warn "$label missing from PATH ($path)"
    fi
}