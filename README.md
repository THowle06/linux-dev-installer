# Dotfiles

This repository provides a **fully reproducible development environment** for Ubuntu-based WSL (Windows Subsystem for Linux).

It is designed ot allow a clean machine to be brought to parity with an existing setup using:

- version-pinned tooling
- tracked dotfiles
- automated installation scripts
- verification and health-check tooling

The setup supports development in:

- **Java** (Maven, Gradle)
- **Python** (python3, pip, uv)
- **C / C++**
- **C#**
- **Go**
- **Rust**
- **JavaScript / TypeScript**
- **Haskell**
- **Docker**
- **VS Code (WSL integration)**

## 1. Prerequisites (Windows)

Before installing anything in WSL, ensure the following on Windows:

### 1.1 Enable WSL 2

Open **Powershell as Administrator**:

```powershell
wsl --install
```

Reboot when prompted.

Ensure WSL 2 is the default:

```powershell
wsl --set-default-version 2
```

### 1.2 Install Ubuntu

Install **Ubuntu 24.04 LTS** from the Microsoft Store.

After installation, launch Ubuntu and create your Linux user.

## 2. Clone This Repository

Inside WSL:

```bash
cd ~
git clone https://gitlab.com/THowle06/dotfiles.git dotfiles
cd dotfiles
```

> :warning: At this point, **do not manually install tools**. Everything is handled by the scripts.

## 3. Make Scripts Executable

```bash
chmod +x install.sh verify.sh update.sh doctor.sh
```

## 4. Run the Installer

```bash
./install.sh
```

This script will:

- install all required APT packages
- install Java (OpenJDK 21)
- install Node.js via **NVM**
- install Rust via **rustup**
- install Go via official binaries
- install Haskell via **ghcup**
- install Python tooling (pip + uv)
- install Docker tooling
- symlink tracked dotfiles

You may be prompted for:

- `sudo` password
- ghcup optional components (can accept defaults)

## 5. Restart Your Shell

After installation:

```bash
exec bash
```

This ensures:

- NVM is loaded
- Cargo paths are active
- Go binaries are in PATH

## 6. Verify the Environment

### 6.1 Quick Verification

```bash
./verify.sh
```

This script checks:

- tools presence
- correct versions
- PATH resolution
- language runtimes

**Do not proceed until verification passes.**

### 6.2 Full Health Check

```bash
./doctor.sh
```

`doctor.sh` provides a **comprehensive developer health check**, including warnings about missing tools, mismatched versions, or missing PATH entries.

## 7. VS Code Integration

### 7.1 Install VS Code on Windows

Download from: [https://code.visualstudio.com/](https://code.visualstudio.com/)

### 7.2 Install WSL Extension

In VS Code (Windows):

- Open Extensions
- Install "**WSL**" by Microsoft

### 7.3 Launch WSL Workspace

From WSL:

```bash
code .
```

VS Code will reopen connected directly to WSL.

## 8. Docker Setup (WSL)

### 8.1 Install Docker Desktop (Windows)

Download: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

During setup:

- Enable **WSL 2 backend**
- Enable integration for your Ubuntu distro

### 8.2 Verify Docker

```bash
docker --version
docker run hello-world
```

## 9. Git Configuration

Git configuration is symlinked from this repository.

Check:

```bash
git config --list
```

## 10. SSH Keys (GitLab)

### 10.1 Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Press Enter to accept defaults.

### 10.2 Start SSH Agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 10.3 Add Key to GitLab

Copy public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Go to:

- GitLab → Preferences → SSH Keys
- Paste the key
- Save

### 10.4 Test Connection

```bash
ssh -T git@gitlab.com
```

Expected output:

```text
Welcome to GitLab, @username!
```

## 11. HTTPS Authentication (Optional)

If you use HTTPS instead of SSH:

```bash
git config --global credential.helper store
```

> :warning: This stores credentials unencrypted. SSH is strongly recommended instead.

## 12. Windows ↔ WSL Downloads Linking (Optional)

### 12.1 Create Windows Folder

On Windows:

```text
C:\Users\<your-user>\WSL-Downloads
```

### 12.2 Link in WSL

```bash
ln -s /mnt/c/Users/<your-user>/WSl-Downloads ~/Downloads
```

This allows seamless file transfer between Windows and WSL.

## 13. Bash Aliases

Aliases are stored in:

```text
bash/.bash_aliases
```

Examples you may enable:

```bash
alias ll='ls -alF'
alias la='ls -A'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gc='git commit'
alias gp='git push'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias doctor='./doctor.sh'
alias verify='./verify.sh'
```

Changes are applied automatically via `.bashrc`.

## 14. Language-Specific Notes

### Python

- `python` → `python3`
- Project isolation via `uv`
- No global pip pollution

### Java

- OpenJDK 21
- Maven & Gradle available
- JavaFX supported

### Go

- Installed from official binaries
- Version pinned in install script

### Rust

- Managed via rustup
- Stable toolchain

### Haskell

- Managed via ghcup
- GHC, Cabal, Stack supported

## 15. Updating the Environment

To update tools:

```bash
git pull
./update.sh
./verify.sh
./doctor.sh
```

- `update.sh` safely updates system packages, Node, Rust, Haskell, Python tooling, and re-links dotfiles.
- `verify.sh` confirms everything is installed and accessible.
- `doctor.sh` highlights warnings, version mismatches, and PATH issues.

The installer and update scripts are **idempotent** - safe to rerun multiple times.

## 16. Repository Structure

```text
.
├── bash/
│   ├── .bashrc
│   └── .bash_aliases
├── git/
│   └── .gitconfig
├── packages/
│   └── apt.txt
├── install.sh
├── update.sh
├── verify.sh
├── doctor.sh
└── README.md
```

## 17. Philosophy

This setup prioritises:

- reproducibility
- explicit versioning
- minimal global state
- portability across machines
- professional tooling parity
