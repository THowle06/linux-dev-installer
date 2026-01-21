#!/usr/bin/env bash
set -euo pipefail

# Dotfiles manager: backup existing, symlink tracked

dotfiles_install() {
    log_step "Installing dotfiles (backup + symlink)..."

    # Create backup directory
    mkdir -p "${BACKUP_DIR}"

    # Backup and symlink bash config
    _backup_and_symlink "${HOME}/.bashrc" "${DOTFILES_DIR}/bash/.bashrc"
    _backup_and_symlink "${HOME}/.bash-aliases" "${DOTFILES_DIR}/bash/.bash-aliases"

    # Backup and symlink git config
    _backup_and_symlink "${HOME}/.gitconfig" "${DOTFILES_DIR}/git/.gitconfig"

    log_success "Dotfiles installed and symlinked"
}
dotfiles_update() {
    log_step "Updating dotfiles (re-symlink)..."

    # Remove old symlinks and re-create
    _backup_and_symlink "${HOME}/.bashrc" "${DOTFILES_DIR}/bash/.bashrc" force
    _backup_and_symlink "${HOME}/.bash-aliases" "${DOTFILES_DIR}/bash/.bash-aliases" force
    _backup_and_symlink "${HOME}/.gitconfig" "${DOTFILES_DIR}/git/.gitconfig" force

    log_success "Dotfiles updated"
}

dotfiles_verify() {
    log_step "Verifying dotfiles symlinks..."

    local issues=0

    if [[ ! -L "${HOME}/.bashrc" ]]; then
        log_warn "${HOME}/.bashrc is not a symlink"
        ((issues++))
    fi

    if [[ ! -L "${HOME}/.bash-aliases" ]]; then
        log_warn "${HOME}/.bash-aliases is not a symlink"
        ((issues++))
    fi

    if [[ ! -L "${HOME}/.gitconfig" ]]; then
        log_warn "${HOME}/.gitconfig is not a symlink"
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "All dotfiles properly symlinked"
    else
        return 1
    fi
}

dotfiles_uninstall() {
    log_step "Uninstalling dotfiles (remove symlinks, restore backups)..."

    _restore_from_backup "${HOME}/.bashrc"
    _restore_from_backup "${HOME}/.bash_aliases"
    _restore_from_backup "${HOME}/.gitconfig"

    log_success "Dotfiles uninstalled; backups restored"
}

# Helper: backup existing file and create symlink
_backup_and_symlink() {
    local target=$1 source=$2 force=${3:-}

    if [[ ! -f "$source" ]]; then
        log_error "Source not found: $source"
        return 1
    fi

    # If target is a symlink, remove it
    if [[ -L "$target" ]]; then
        if [[ "$force" == "force" ]]; then
            rm "$target"
        else
            log_debug "$target already symlinked, skipping"
            return 0
        fi
    # If target exists and is a regular file, back it up
    elif [[ -f "$target" ]]; then
        local backup_name
        backup_name="${BACKUP_DIR}/$(basename "$target").backup.$(date +%s)"
        log_info "Backing up $target → $backup_name"
        cp "$target" "$backup_name"
        rm "$target"
    fi

    # Create symlink
    ln -s "$source" "$target"
    log_debug "Symlinked: $target → $source"
}

# Helper: restore file from backup if exists
_restore_from_backup() {
    local target=$1
    local backups

    # Remove symlink if present
    if [[ -L "$target" ]]; then
        rm "$target"
        log_debug "Removed symlink: $target"
    fi

    # Find most recent backup
    backups=$(find "${BACKUP_DIR}" -name "$(basename "$target").backup.*" -type 2>/dev/null | sort -r | head -1)

    if [[ -n "$backups" ]]; then
        cp "$backups" "$target"
        log_info "Restored $target from $backups"
    else
        log_warn "No backups found for $target"
    fi
}