#!/usr/bin/env bash

check_tool() {
    local name="$1"
    local cmd="$2"
    local expected="${3:-}"

    if ! command_exists "$cmd"; then
        log_warn "$name not found (command: $cmd)"
        return 1
    fi

    local version_line
    version_line="$(timeout 5s get_version_line "$cmd" 2>/dev/null || true)"

    if [[ -n "$expected" && "$version_line" != *"$expected"* ]]; then
        log_warn "$name present but version mismatch: expected contains \"$expected\", got \"$version_line\""
        return 1
    fi

    if [[ -z "$version_line" ]]; then
        log_warn "$name present but version check timed out or returned empty"
        return 1
    fi

    if [[ -n "$version_line" ]]; then
        log_ok "$name OK ($version_line)"
    else
        log_ok "$name OK"
    fi
}

check_path() {
    local label="$1"
    local path="$2"

    if [[ ":$PATH:" == *":$path:"* ]]; then
        log_ok "$label in PATH"
    else
        log_warn "$label missing from PATH ($path)"
        return 1
    fi
}