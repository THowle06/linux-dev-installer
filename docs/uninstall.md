# Uninstall Guide

## Overview

The uninstall command removes managed tools while keeping system packages (APT-managed) for safety.

## Basic Uninstall

### Remove All User-Installed Tools

```bash
./main.sh uninstall
```

You'll be prompted to confirm:

```text
Proceed with uninstall? [y/N] y
```

### Skip Confirmation

```bash
./main.sh uninstall --confirm
```

### Remove Specific Tools

```bash
./main.sh uninstall --only anaconda
./main.sh uninstall --only node,rust,lean
./main.sh uninstall --only python --confirm
```

### Exclude Tools from Removal

```bash
./main.sh uninstall --exclude docker
# Removes everything except docker
```

---

## What Gets Removed

### Removed Tools

| Tool      | Removal            | Location                    |
| --------- | ------------------ | --------------------------- |
| NVM       | ✓ Removed          | `~/.nvm`                    |
| Node.js   | ✓ Removed          | via NVM                     |
| Rust      | ✓ Removed          | `~/.rustup`, `~/.cargo`     |
| Haskell   | ✓ Removed          | `~/.ghcup`                  |
| Lean      | ✓ Removed          | `~/.elan`                   |
| Miniconda | ✓ Removed          | `~/anaconda3`               |
| uv        | ⚠ Manual           | via `pipx uninstall uv`     |
| Dotfiles  | ✓ Symlinks removed | `~/.bashrc`, `~/.gitconfig` |

### Kept (System Packages)

| Package         | Reason         | Remove with                               |
| --------------- | -------------- | ----------------------------------------- |
| openjdk-21-jdk  | System package | `sudo apt remove openjdk-21-jdk`          |
| maven           | System package | `sudo apt remove maven`                   |
| gradle          | System package | `sudo apt remove gradle`                  |
| dotnet-sdk-10.0 | System package | `sudo apt remove dotnet-sdk-10.0`         |
| docker.io       | System package | `sudo apt remove docker.io`               |
| Build tools     | System package | `sudo apt remove build-essential gcc ...` |

**Why kept?**

- System packages may be needed by other tools
- Safer to keep them (user can remove manually)
- Prevents accidental system breakage

### Dotfiles Removal

By default, dotfile symlinks are **removed**:

```bash
~/.bashrc       → Symlink removed (original backed up)
~/.bash_aliases → Symlink removed
~/.gitconfig    → Symlink removed
```

Backups are restored if they exist:

```bash
~/.bashrc       ← Restored from ~/.dotfiles-backup/
```

---

## Uninstall Workflows

### Clean Uninstall (Keep System Tools)

```bash
./main.sh uninstall --confirm
```

Result:

- NVM, Node, Rust, Haskell, Lean, Miniconda removed
- Dotfiles restored
- System packages kept
- Ready for clean reinstall

### Remove Only One Tool

```bash
./main.sh uninstall --only lean --confirm
./main.sh verify  # Verify lean gone, others OK
```

### Remove Multiple Tools

```bash
./main.sh uninstall --only node,rust,haskell --confirm
```

### Full System Cleanup (Dangerous)

Remove everything including system packages:

```bash
# Remove managed tools
./main.sh uninstall --confirm

# Remove system packages manually
sudo apt remove -y build-essential openjdk-21-jdk maven gradle \
                   dotnet-sdk-10.0 docker.io

sudo apt autoremove -y
sudo apt autoclean -y
```

---

## Dotfiles Restoration

### Automatic Restoration

Backups created at `~/.dotfiles-backup/`:

```bash
~/.dotfiles-backup/
├── .bashrc.backup.1705700000
├── .bash_aliases.backup.1705700001
└── .gitconfig.backup.1705700002
```

Uninstall automatically restores if backups exist.

### Manual Restoration

If auto-restore fails:

```bash
# Find backups
ls -la ~/.dotfiles-backup/

# Restore manually
cp ~/.dotfiles-backup/.bashrc.backup.* ~/.bashrc
cp ~/.dotfiles-backup/.gitconfig.backup.* ~/.gitconfig
```

### Preserve Custom Dotfiles

If you have custom `~/.bashrc` before install:

1. **Before installing:**

   ```bash
   cp ~/.bashrc ~/.bashrc.custom
   ```

2. **After uninstall:**

   ```bash
   cp ~/.bashrc.custom ~/.bashrc
   ```

Or use `~/.bashrc.local` for custom settings (sourced automatically):

```bash
# ~/.bashrc.local (not managed by installer)
export MY_VAR="value"
alias myalias="command"
```

---

## PATH Cleanup

After uninstall, PATH may still reference removed tools:

```bash
# Check PATH for stale entries
echo $PATH

# Restart shell to reload ~/.bashrc:
exec bash
```

Manual cleanup in `~/.bashrc`:

Remove or comment out sections like:

```bash
# export PATH="/usr/local/go/bin:$PATH"  # Already gone
# export PATH="$HOME/.cargo/bin:$PATH"   # Already gone
```

---

## Reinstalling After Uninstall

### Clean Reinstall

```bash
./main.sh uninstall --confirm
./main.sh install
exec bash
./main.sh verify
```

### Selective Reinstall

```bash
./main.sh uninstall --only rust --confirm
./main.sh install --only rust
```

### Reinstall with Different Versions

1. Edit `scripts/core/config.sh`:

   ```bash
   readonly NODE_VERSION="22.0.0"  # Changed from 24.12.0
   ```

2. Reinstall:

   ```bash
   ./main.sh uninstall --only node --confirm
   ./main.sh install --only node
   ```

---

## Troubleshooting Uninstall

### "Cannot remove X" (Permission denied)

**Cause:** Directory/file owned by another user or process locked.

**Solution:**

```bash
sudo rm -rf ~/.nvm
sudo rm -rf ~/.rustup
# or
./main.sh uninstall --only node --confirm
```

### Dotfiles not restored

**Cause:** No backup found (fresh install, not overwritten).

**Solution:** Restore manually from your own backup or recreate:

```bash
# Recreate default bashrc:
cp /etc/skel/.bashrc ~/.bashrc

# Recreate default gitconfig:
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Tools still in PATH after uninstall

**Cause:** Shell not restarted after uninstall.

**Solution:**

```bash
exec bash
which node  # Should say "not found"
```

### uv uninstall fails

**Cause:** PEP 668 prevents pip from removing globally.

**Solution:**

```bash
pipx uninstall uv
# or manually:
rm -rf ~/.local/share/pipx/venvs/uv
```

---

## Verification After Uninstall

Check tools are gone:

```bash
./main.sh verify
# Should show warnings for uninstalled tools

which node      # not found
which rustc     # not found
which ghcup     # not found

# System tools should still be available:
which java
which dotnet
which docker
```

---

## Disk Space Recovery

After uninstall, manually clean up:

```bash
# Clear pip cache
pip cache purge

# Clear npm cache
npm cache clean --force

# Clear rustup cache
rm -rf ~/.cargo/registry/cache

# Clear Go build cache
go clean -cache

# Clear temp installer files
rm -rf /tmp/linux-dev-installer
```

**Total recovery:** ~1-2 GB depending on what was installed.

---

## Keep Dotfiles, Remove Tools

If you want to keep your dotfile customizations:

```bash
# Don't use --restore-backups, just remove dotfile symlinks manually:
rm ~/.bashrc ~/.gitconfig ~/.bash_aliases

# Dotfiles are still in repo for future reinstalls
ls dotfiles/bash/
```

---

## Completely Remove Everything (Nuclear Option)

```bash
# Backup anything custom first:
cp ~/.bashrc ~/.bashrc.custom
cp ~/.gitconfig ~/.gitconfig.custom

# Remove all installer-managed items
./main.sh uninstall --confirm

# Remove system packages
sudo apt remove -y build-essential git curl wget python3-pip pipx \
                   openjdk-21-jdk maven gradle dotnet-sdk-10.0 docker.io \
                   tmux neovim fzf ripgrep jq tree htop

# Remove installer repo
cd ~
rm -rf linux-dev-installer

# Restore custom configs if desired
cp ~/.bashrc.custom ~/.bashrc
```

---

## Next Steps

After uninstall:

- **Reinstall:** Run `./main.sh install` again
- **Switch distros:** Clone repo on new system and reinstall
- **Keep dotfiles:** Copy `dotfiles/` to new setup
- **Update versions:** Edit `config.sh` before reinstalling
