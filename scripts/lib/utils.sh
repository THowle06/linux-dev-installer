#!/usr/bin/env bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_version_line() {
    "$1" --version 2>/dev/null | head -n 1 || true
}

backup_file() {
    local file="$1"
    local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

    if [[ -e "$file" && ! -L "$file" ]]; then
        mkdir -p "$backup_dir"
        cp -a "$file" "$backup_dir/"
        log_info "Backed up $(basename "$file") to $backup_dir"
    fi

    return 0
}