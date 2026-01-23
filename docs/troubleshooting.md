# Troubleshooting

## General Issues

### "Command not found" after install

**Cause:** PATH updates not loaded in current shell session.

**Solution:**

```bash
exec bash
# or
source ~/.bashrc
```

### Scripts not executable

**Error:** `Permission denied` when running `./main.sh`

**Solution:**

```bash
chmod +x main.sh
```

### Wrong distro/version detected

**Warning:** `Detected <distro> <version>. This installer is designed for Ubuntu 24.04 LTS`

**Solution:**

- Upgrade to Ubuntu 24.04 LTS, or
- Install manually on your distro, or
- Proceed anyway (may have issues)

---

## Language-Specific Issues

### Python

#### "externally-managed-environment" error

**Cause:** PEP 668 prevents pip from installing globally in system Python.

**Solution:** Use `pipx` for user-level installs:

```bash
pipx install <package>
# Tools available in ~/.local/bin
```

Or create a venv:

```bash
python3 -m venv myenv
source myenv/bin/activate
pip install <package>
```

#### `uv` command not found

**Cause:** pipx venv not in PATH.

**Solution:**

```bash
source ~/.bashrc
# or check PATH:
echo $PATH | grep .local/bin
```

### Node.js / NVM

#### `nvm` not found

**Cause:** NVM not sourced in current shell.

**Solution:**

```bash
exec bash
# or manually:
source ~/.nvm/nvm.sh
nvm --version
```

#### `node` version changes unexpectedly

**Cause:** NVM switching versions between shells.

**Solution:** Set default version:

```bash
nvm alias default 24.12.0
```

#### NVM git update fails

**Cause:** Network or git issue in ~/.nvm.

**Solution:**

```bash
./main.sh uninstall --only node --confirm
./main.sh install --only node
```

### Go

#### `go` not in PATH

**Cause:** `~/.bashrc` not sourced or PATH not updated.

**Solution:**

```bash
# Verify Go is installed:
ls -la /usr/local/go/bin/go

# Load bashrc:
exec bash

# Manual PATH update:
export PATH="/usr/local/go/bin:$PATH"
```

#### Go version mismatch

**Cause:** Old Go still in PATH.

**Solution:**

```bash
./main.sh update --only go
# or
sudo rm -rf /usr/local/go
./main.sh install --only go
```

### Rust

#### `cargo` not found

**Cause:** Rust installed but ~/.cargo/env not sourced.

**Solution:**

```bash
exec bash
# or:
source ~/.cargo/env
```

#### Rust update fails

**Cause:** rustup self-update conflict.

**Solution:**

```bash
rustup self update-check
rustup self update
./main.sh update --only rust
```

### Haskell / GHCup

#### GHCup interactive installer

**Cause:** GHCup requires user interaction for initial setup.

**Expected:** Press Enter to confirm defaults, then shell restart.

**Solution:**

```bash
exec bash
ghcup --version
```

#### Cabal/GHC version conflicts

**Solution:** Use GHCup TUI to manage versions:

```bash
ghcup tui
```

### Lean / elan

#### `elan` installation fails

**Cause:** Network issue or permissions.

**Solution:**

```bash
./main.sh uninstall --only lean --confirm
./main.sh install --only lean
```

#### Lean tools not updating

**Cause:** elan self-update incomplete.

**Solution:**

```bash
elan self update
lean --version
```

### Java / Maven / Gradle

#### `java` command not found

**Cause:** OpenJDK not installed via APT.

**Solution:**

```bash
sudo apt install openjdk-21-jdk
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
```

#### Maven/Gradle versions old

**Solution:**

```bash
./main.sh update --only java
mvn --version
gradle --version
```

### Docker

#### `docker` command not available

**Cause (WSL):** Docker Desktop not running or integration not enabled.

**Solution:**

1. Start Docker Desktop
2. Verify WSL integration: Docker → Settings → Resources → WSL integration
3. Test: `docker ps`

**Cause (Native Linux):** Docker engine not installed.

**Solution:**

```bash
./main.sh install --only docker
sudo usermod -aG docker $USER
newgrp docker
```

#### `docker compose` not found

**Cause:** Docker Compose V2 not installed.

**Solution:**

```bash
./main.sh update --only docker
docker compose version
```

#### Permission denied when running docker

**Cause:** User not in docker group (native Linux).

**Solution:**

```bash
sudo usermod -aG docker $USER
newgrp docker
# or restart shell
exec bash
```

### .NET

#### `dotnet` command not found

**Cause:** .NET SDK not installed via APT.

**Solution:**

```bash
sudo apt install dotnet-sdk-10.0
```

#### Multiple .NET versions installed

**Solution:**

```bash
dotnet --list-sdks
# To remove old versions:
sudo apt remove dotnet-sdk-<version>
```

---

## Dotfiles Issues

### Symlinks not created

**Error:** `~/.bashrc` is a regular file, not a symlink.

**Solution:**

```bash
./main.sh install --only dotfiles
# If conflicts:
./main.sh uninstall --only dotfiles --confirm
./main.sh install --only dotfiles
```

### Git configuration not applied

**Cause:** `.gitconfig` not symlinked or wrong.

**Solution:**

```bash
cat ~/.gitconfig  # Should show your config
# If not, reinstall:
./main.sh install --only dotfiles
```

### Custom shell settings lost

**Cause:** Dotfile overwrite.

**Solution:** Use `~/.bashrc.local` for machine-specific settings:

```bash
# ~/.bashrc.local
export MY_VAR="value"
alias myalias="command"
```

This file is sourced automatically and not managed by installer.

---

## Installation Failures

### APT packages fail to install

**Error:** `Unable to locate package` or `E: Couldn't get lock`

**Solution:**

```bash
sudo apt update
sudo apt install -y build-essential  # or specific package
./main.sh install --only apt
```

### Network timeouts during download

**Error:** `curl: (28) Operation timeout`

**Solution:**

```bash
# Retry manually or use --log-level debug to see URLs:
./main.sh install --log-level debug

# Manually download if needed:
curl -fsSL https://... -o file.tar.gz
```

### Insufficient disk space

**Error:** `No space left on device`

**Solution:**

```bash
df -h
# Clean old downloads:
rm -rf /tmp/linux-dev-installer
# or make space and retry
```

---

## Verification Failures

### `./main.sh verify` shows warnings

**Typical causes:**

- Tool not in PATH (run `exec bash`)
- Tool installed but not sourced (dotfiles/bashrc)
- Version mismatches (expected, usually safe)

**Solution:**

```bash
./main.sh verify --log-level debug
# Shows exact failure per tool
```

---

## Uninstall Issues

### Cannot remove system packages

**Expected:** APT packages (Java, Maven, Gradle, Docker, .NET) are kept for safety.

**To remove manually:**

```bash
sudo apt remove openjdk-21-jdk maven gradle
```

### Dotfiles restoration fails

**Cause:** No backup exists (fresh install).

**Expected:** Original files don't exist, so nothing to restore.

**Solution:** None needed.

---

## Getting Help

1. **Check the logs:**

   ```bash
   ./main.sh install --log-level debug 2>&1 | tee install.log
   ```

2. **Run diagnostics:**

   ```bash
   ./main.sh doctor
   ```

3. **Verify specific tool:**

   ```bash
   ./main.sh verify --only <tool> --log-level debug
   ```

4. **Test manually:**

   ```bash
   go version
   rustc --version
   node --version
   ```

5. **Open an issue** on GitHub with:
   - OS/distro version
   - Error message and logs
   - Steps to reproduce
   - Output of `./main.sh doctor`
