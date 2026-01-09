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
chmod +x dotfiles.sh install.sh verify.sh update.sh doctor.sh
```

## 4. Run the Installer

```bash
./dotfiles.sh install
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
./dotfiles.sh verify
```

This script checks:

- tool presence across all categories
- correct versions
- PATH resolution
- language runtimes

**Do not proceed until verification passes.**

### 6.2 Full Health Check

```bash
./dotfiles.sh doctor
```

`doctor.sh` provides a **comprehensive developer health check**, including warnings about missing tools, mismatched versions, or missing PATH entries.

## 7. CLI Reference

The `dotfiles.sh` script provides a unified entrypoint:

```bash
./dotfiles.sh <command> [options]
```

### Commands

| Command   | Description                        |
| --------- | ---------------------------------- |
| `install` | Run full installation              |
| `update`  | Update all tools                   |
| `verify`  | Quick verification check           |
| `doctor`  | Full health check with diagnostics |
| `help`    | Show usage information             |

### Examples

```bash
# Full installation
./dotfiles.sh install

# Install only specific categories
./dotfiles.sh install --only python,node,rust

# Install everything except certain categories
./dotfiles.sh install --exclude haskell,java

# Quick verification
./dotfiles.sh verify

# Detailed health check
./dotfiles.sh doctor

# Update existing tools
./dotfiles.sh update

# Update only specific categories
./dotfiles.sh update --only node,rust

# Update everything except certain categories
./dotfiles.sh update --exclude haskell

# Show help
./dotfiles.sh help
```

### Options

| Option             | Description                           |
| ------------------ | ------------------------------------- |
| `--only <cats>`    | Comma-separated categories to include |
| `--exclude <cats>` | Comma-separated categories to skip    |

### Available Categories

- `python` - Python tooling (pip, uv)
- `node` - Node.js via NVM
- `go` - Go language
- `rust` - Rust toolchain via rustup
- `haskell` - Haskell toolchain via ghcup
- `java` - Java (installed via APT, not filterable)
- `editors` - Dotfile linking

**Note:** APT packages are always installed (including Java, Docker, build tools).

## 8. VS Code Integration

### 8.1 Install VS Code on Windows

Download from: [https://code.visualstudio.com/](https://code.visualstudio.com/)

### 8.2 Install WSL Extension

In VS Code (Windows):

- Open Extensions
- Install "**WSL**" by Microsoft

### 8.3 Launch WSL Workspace

From WSL:

```bash
code .
```

VS Code will reopen connected directly to WSL.

## 9. Docker Setup (WSL)

### 9.1 Install Docker Desktop (Windows)

Download: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

During setup:

- Enable **WSL 2 backend**
- Enable integration for your Ubuntu distro

### 9.2 Verify Docker

```bash
docker --version
docker run hello-world
```

## 10. Git Configuration

Git configuration is symlinked from this repository.

Check:

```bash
git config --list
```

## 11. SSH Keys (GitLab)

### 11.1 Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Press Enter to accept defaults.

### 11.2 Start SSH Agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 11.3 Add Key to GitLab

Copy public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Go to:

- GitLab → Preferences → SSH Keys
- Paste the key
- Save

### 11.4 Test Connection

```bash
ssh -T git@gitlab.com
```

Expected output:

```text
Welcome to GitLab, @username!
```

## 12. HTTPS Authentication (Optional)

If you use HTTPS instead of SSH:

```bash
git config --global credential.helper store
```

> :warning: This stores credentials unencrypted. SSH is strongly recommended instead.

## 13. Windows ↔ WSL Downloads Linking (Optional)

### 13.1 Create Windows Folder

On Windows:

```text
C:\Users\<your-user>\WSL-Downloads
```

### 13.2 Link in WSL

```bash
ln -s /mnt/c/Users/<your-user>/WSl-Downloads ~/Downloads
```

This allows seamless file transfer between Windows and WSL.

## 14. Bash Aliases

Aliases are stored in:

```text
bash/.bash_aliases
```

Examples included:

```bash
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias g='git'
alias gs='git status'
alias ga='git add'
alias path='echo -e ${PATH//:/\\n}'
```

Changes are applied automatically via `.bashrc`.

## 15. Updating the Environment

To update tools:

```bash
git pull
./dotfiles.sh update
./dotfiles.sh verify
./dotfiles.sh doctor
```

- `update` safely updates system packages, Node, Rust, Haskell, Python tooling, and re-links dotfiles
- `verify` confirms everything is installed and accessible
- `doctor` highlights warnings, version mismatches, and PATH issues

The installer and update scripts are **idempotent** - safe to rerun multiple times.

You can also selectively update categories:

```bash
# Update only Node.js and Rust
./dotfiles.sh update --only node,rust

# Update everything except Haskell
./dotfiles.sh update --exclude haskell
```

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
├── scripts/
│   ├── lib/
│   │   ├── bootstrap.sh      # Central bootstrap loader
│   │   ├── logging.sh        # Consistent logging helpers
│   │   ├── utils.sh          # Command existence checks
│   │   ├── config.sh         # Version configuration
│   │   └── checks.sh         # Tool verification logic
│   └── registry/
│       └── tools.sh          # Tool registry (single source of truth)
├── dotfiles.sh               # CLI entrypoint
├── install.sh                # Installation script
├── update.sh                 # Update script
├── verify.sh                 # Quick verification
├── doctor.sh                 # Full health check
└── README.md
```

## 17. Tool Categories

The tool registry (`scripts/registry/tools.sh`) organises tools into categories:

- **Core**: gcc, make, git, curl, wget
- **Python**: python3, pip, uv
- **Node.js**: node, npm (via NVM)
- **Go**: go
- **Rust**: rustc, cargo (via rustup)
- **Java**: java, javac, mvn, gradle
- **Haskell**: ghcup, ghc, cabal
- **Containers**: docker
- **Editors/Terminal**: nvim, tmux

## 18. Language-Specific Notes

### Python

- `python` → `python3`
- Project isolation via `uv`
- No global pip pollution

### Java

- OpenJDK 21
- Maven & Gradle available
- JavaFX supported

### Go

- Installed from official binaries (version: 1.25.5)
- Architecture-aware (amd64/arm64)
- Version pinned in `scripts/lib/config.sh`

### Rust

- Managed via rustup
- Stable toolchain
- Cargo in PATh after shell restart

### Haskell

- Managed via ghcup
- GHC, Cabal, Stack supported
- Optional components configurable during install

### Node.js

- Managed via NVM (version: 24.12.0)
- Multiple versions supported
- Default version set automatically

## 19. Troubleshooting

### Common Issues

**Tools not found after install:**

```bash
# Restart shell to load new PATH entries
exec bash
```

**Permission denied on scripts:**

```bash
chmod +x dotfiles.sh install.sh update.sh verify.sh doctor.sh
```

**Docker not accessible:**

- Ensure Docker Desktop is running on Windows
- Check WSL integration is enabled in Docker Desktop settings

**NVM command not found:**

```bash
# Manually source NVM
source ~/.nvm/nvm.sh
```

**Version mismatches:**

- Check `scripts/lib/config.sh` for expected versions
- Run `./dotfiles.sh doctor` for detailed diagnostics

## 20. Philosophy

This setup prioritises:

- **Reproducibility**: exact versions, scripted setup
- **Explicit versioning**: single source of truth in config
- **Minimal global state**: language-specific version managers
- **Portability**: works across machines and fresh WSL installs
- **Professional tooling parity**: matches production environments
- **Idempotency**: safe to rerun scripts multiple times
- **Consistency**: unified logging and error handling
- **Flexibility**: selective installation and updates via category filtering
