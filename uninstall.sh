#!/usr/bin/env bash
set -euo pipefail

#######################################
# Bootstrap
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"

#######################################
# Configuration
#######################################

CONFIRM=false
RESTORE_BACKUPS=false
FILTER_INCLUDE="${FILTER_INCLUDE:-}"
FILTER_EXCLUDE="${FILTER_EXCLUDE:-}"

#######################################
# Category filtering
#######################################

category_enabled() {
    local cat="$1"

    # Include list takes priority
    if [[ -n "$FILTER_INCLUDE" ]]; then
        IFS=',' read -ra inc <<<"$FILTER_INCLUDE"
        for i in "${inc[@]}"; do
            [[ "$e" == "$cat" ]] && return 0
        done
        return 1
    fi

    if [[ -n "$FILTER_INCLUDE" ]]; then
        IFS=',' read -ra exc <<<"$FILTER_EXCLUDE"
        for e in "${exc[@]}"; do
            [[ "$e" == "$cat" ]] && return 1
        done
    fi

    return 0
}

run_category() {
    local cat="$1"; shift
    if category_enabled "$cat"; then
        "$@"
    else
        log_info "Skipping ${cat} (filtered)"
    fi
}

#######################################
# Argument parsing
#######################################

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --confirm)
                CONFIRM=true
                shift
                ;;
            --restore-backups)
                RESTORE_BACKUPS=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
    done
}

usage() {
    cat <<EOF
Usage: ./uninstall.sh [options]

Options:
    --confirm           Skip confirmation prompt
    --restore-backups   Restore original dotfiles from backup
    --only <cats>       Comma-separated categories to remove
    --exclude <cats>    Comma-separated categories to keep
    -h, --help          Show this help

Available categories:
    python, node, go, rust, haskell, editors

This script will remove (selectively):
    - NVM and installed Node versions
    - Rust toolchain (via rustup)
    - uv (Python package manager)
    - Go installation from /usr/local/go
    - Haskell toolchain (via ghcup)
    - Symlinked dotfiles (.bashrc, .bash_aliases, .gitconfig)

Examples:
    ./dotfiles.sh uninstall
    ./dotfiles.sh uninstall --confirm
    ./dotfiles.sh uninstall --confirm --restore-backups
    ./dotfiles.sh uninstall --only node,rust
    ./dotfiles.sh uninstall --exclude haskell
EOF
}

#######################################
# Confirmation
#######################################

confirm_uninstall() {
    if [[ "$CONFIRM" == true ]]; then
        return 0
    fi

    local items=""
    if category_enabled python; then
        items+="  - Python tooling (uv)\n"
    fi
    if category_enabled node; then
        items+="  - NVM and Node.js versions\n"
    fi
    if category_enabled rust; then
        items+="  - Rust toolchain (via rustup)\n"
    fi
    if category_enabled go; then
        items+="  - Go installation (/usr/local/go)\n"
    if
    if category_enabled haskell; then
        items+="  - Haskell toolchain (via ghcup)\n"
    fi
    if category_enabled editors; then
        items+="  - Symlinked dotfiles\n"
    fi

    cat <<EOF

WARNING: This will remove:
$items
EOF

    if [[ "$RESTORE_BACKUPS" == true ]]; then
        echo "Backups will be restored from ~/.dotfiles-backup/ if available."
        echo
    fi

    read -rp "Are you sure you want to proceed? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            log_info "Uninstall cancelled"
            exit 0
            ;;
    esac
}

#######################################
# Uninstall functions
#######################################

unlink_dotfiles() {
    log_info "Unlinking dotfiles"

    for file in .bashrc .bash_aliases .gitconfig; do
        if [[ -L "$HOME/$file" ]]; then
            rm "$HOME/$file"
            log_ok "Unlinked $file"
        else
            log_warn "$file is not a symlink (skipping)"
        fi
    done
}

restore_dotfile_backups() {
    if [[ "$RESTORE_BACKUPS" != true ]]; then
        return 0
    fi

    log_info "Restoring dotfiles from backup"

    local backup_dir="$HOME/.dotfiles-backup"
    if [[ ! -d "$backup_dir" ]]; then
        log_warn "No backup directory found at $backup_dir"
        return 0
    fi

    # Find the most recent backup
    local latest_backup
    latest_backup=$(find "$backup_dir" -maxdepth 1 -type d -name "2*" | sort -r | head -n 1)

    if [[ -z "$latest_backup" ]]; then
        log_warn "No timestamped backups found in $backup_dir"
        return 0
    fi

    log_info "Restoring from: $latest_backup"

    for file in .bashrc .bash_aliases .gitconfig; do
        if [[ -f "$latest_backup/$file" ]]; then
            cp -a "$latest_backup/$file" "$HOME/$file"
            log_ok "Restored $file"
        fi
    done
}

remove_nvm() {
    log_info "Removing NVM"

    if [[ -d "$HOME/.nvm" ]]; then
        rm -rf "$HOME/.nvm"
        log_ok "NVM removed"
    else
        log_warn "NVM directory not found (skipping)"
    fi
}

remove_rust() {
    log_info "Removing Rust toolchain"

    if command_exists rustup; then
        rustup self uninstall -y
        log_ok "Rust removed"
    else
        log_warn "rustup not found (skipping)"
    fi
}

remove_uv() {
    log_info "Removing uv"

    if [[ -f "$HOME/.cargo/bin/uv" ]]; then
        rm "$HOME/.cargo/bin/uv"
        log_ok "uv removed"
    else
        log_warn "uv not found (skipping)"
    fi

    # Clean up any remaining uv data
    if [[ -d "$HOME/.local/share/uv" ]]; then
        rm -rf "$HOME/.local/share/uv"
    fi
}

remove_go() {
    log_info "Removing Go"

    if [[ -d "$GO_INSTALL_DIR" ]]; then
        sudo rm -rf "$GO_INSTALL_DIR"
        log_ok "Go removed from $GO_INSTALL_DIR"
    else
        log_warn "Go installation not found at $GO_INSTALL_DIR (skipping)"
    fi
}

remove_haskell() {
    log_info "Removing Haskell toolchain"

    if command_exists ghcup; then
        ghcup nuke
        log_ok "Haskell toolchain removed"
    else
        log_warn "ghcup not found (skipping)"
    fi
}

remove_lean4() {
    log_info "Removing Lean 4"

    if [ -d "$HOME/.elan" ]; then
        log_info "Removing elan from ~/.elan"
        rm -rf "$HOME/.elan"
        log_ok "Lean 4 removed"
    else
        log_warn "elan not found"
    fi
}

remove_dotnet() {
    log_info "Removing .NET SDK"

    if command_exists dotnet; then
        sudo apt remove -y dotnet-sdk-10.0
        sudo apt autoremove -y

        # Optionally remove Microsoft rep
        if [[ -f /etc/apt/sources.list.d/microsoft-prod.list ]]; then 
            sudo rm /etc/apt/sources.list.d/microsoft-prod.list
        fi

        log_ok ".NET SDK removed"
    else
        log_warn ".NET SDK not found (skipping)"
    fi
}

#######################################
# Main
#######################################

main() {
    parse_args "$@"
    confirm_uninstall

    log_info "Starting uninstall process"

    run_category python     remove_uv
    run_category node       remove_nvm
    run_category rust       remove_rust
    run_category go         remove_go
    run_category haskell    remove_haskell
    run_category lean       remove_lean4
    run_category editors    unlink_dotfiles
    run_category editors    restore_dotfile_backups
    
    log_info "Uninstall complete"
    log_info "You may want to remove APT packages manually with: sudo apt remove <package>"
    log_info "Restart your shell or run: exec bash"
}

main "$@"