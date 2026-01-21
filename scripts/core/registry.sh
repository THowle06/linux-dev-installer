#!/usr/bin/env bash
set -euo pipefail

# Define tool metadata: name, category, functions
# Ensure each tool file defines: <tool>_install, _update, _verify, _uninstall
TOOLS=(
    "python:python:python"
    "node:node:node"
    "go:go:go"
    "rust:rust:rust"
    "haskell:haskell:haskell"
    "java:java:java"
    "dotnet:dotnet:dotnet"
    "docker:docker:docker"
    "lean:lean:lean"
    "dotfiles:dotfiles:dotfiles"
)

# Load all tool modules
for tool_def in "${TOOLS[@]}"; do
    IFS=':' read -r _ _ file_basename <<<"$tool_def"
    source "${TOOLS_DIR}/${file_basename}.sh"
done

# Parse comma-separated filters into array (lowercased)
_parse_filter() {
    local raw="$1"
    local -n out_ref="$2"
    out_ref=()
    [[ -z "$raw" ]] && return 0
    IFS=',' read -ra parts <<<"$raw"
    for p in "${parts[@]}"; do
        out_ref+=("$(echo "$p" | tr '[:upper:]' '[:lower:]')")
    done
}

# Determine if a tool is selected by filters
_tool_selected() {
    local tool="$1" category="$2"
    local -a only_list exclude_list
    _parse_filter "${FILTER_ONLY:-}" only_list
    _parse_filter "${FILTER_EXCLUDE:-}" exclude_list

    # Exclude wins
    for ex in "${exclude_list[@]}"; do
        if [[ "$tool" == "$ex" || "$category" == "$ex" ]]; then
            return 1
        fi
    done
    # If only list is empty, all included
    if [[ ${#only_list[@]} -eq 0 ]]; then
        return 0
    fi
    for on in "${only_list[@]}"; do
        if [[ "$tool" == "$on" || "$category"  == "$on" ]]; then
            return 0
        fi
    done
    return 1
}

# Dispatch helper
_dispatch_tools() {
    local action="$1" # install|update|verify|uninstall|doctor
    for tool_def in "${TOOLS[@]}"; do
        IFS=':' read -r tool category file_basename <<<"$tool_def"
        if _tool_selected "$tool" "$category"; then
            local fn="${tool}_${action}"
            if declare -F "$fn" >/dev/null 2>&1; then
                log_step "${action^}: $tool"
                "$fn"
            else
                log_warn "No ${action} function for $tool"
            fi
        else
            log_debug "Skipping $tool (filtered)"
        fi
    done
}