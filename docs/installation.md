# Install Guide

## Prerequisites

### Windows (WSL2)

```powershell
# Enable WSL and install Ubuntu 24.04 LTS
wsl --install
wsl --set-default-version 2

# Install Ubuntu 24.04 LTS from Microsoft Store
# Then launch it once to complete setup
```

### Native Linux

- **OS:** Ubuntu 24.04 LTS
- **Disk Space:** ~10GB free
- **Network:** Internet connection required for downloads
- **Permissions:** sudo access for system packages

## Step-by-Step Installation

### 1. Clone Repository

```bash
cd ~
git clone https://github.com/THowle06/linux-dev-installer.git installer
cd installer
```

### 2. Make Scripts Executable

```bash
chmod +x main.sh 
```

### 3. Run Full Installation

```bash
./main.sh install
```

You may be prompted for your password for `sudo` commands (APT packages, Go, etc.).

### 4. Restart Shell

```bash
exec bash
```

Or open a new terminal. This activates all PATH updates and tool configurations.

### 5. Verify Installation

```bash
./main.sh verify
```

All tools should show ✓ status.

## Selective Installation

Install only specific tools:

```bash
./main.sh install --only python,node,rust
./main.sh install --only go
./main.sh install --only anaconda
```

### Tool Categories

| Category   | Tools                                    | Method                |
| ---------- | ---------------------------------------- | --------------------- |
| `apt`      | Build tools, git, curl, Docker CLI, etc. | APT packages          |
| `python`   | python3, pip, uv                         | System + pipx         |
| `anaconda` | Miniconda (optional)                     | Tarball               |
| `node`     | Node.js, npm                             | NVM                   |
| `rust`     | rustc, cargo                             | rustup                |
| `haskell`  | GHC, Cabal, Stack                        | GHCup                 |
| `java`     | OpenJDK 21, Maven, Gradle                | APT                   |
| `dotnet`   | .NET SDK 10.0                            | APT                   |
| `docker`   | Docker CLI, Compose                      | APT or Docker Desktop |
| `lean`     | Lean 4, elan                             | elan installer        |
| `dotfiles` | .bashrc, .gitconfig                      | Symlinks              |

## Post-Installation Setup

### Configure Git (Optional)

Edit `dotfiles/git/.gitconfig` with your details:

```bash
[user]
    name = Your Name
    email = your.email@example.com
```

Then re-symlink:

```bash
./main.sh install --only dotfiles
```

### Add Machine-Local Overrides

Create `~/.bashrc.local` for machine-specific settings:

```bash
# Example: custom aliases, env vars
export MY_PROJECT_DIRS="$HOME/projects"
alias myproj='cd $MY_PROJECT_DIR'
```

This file is sources automatically and won't be tracked by git.

### Enable Docker Desktop (WSL)

1. Install Docker Desktop for Windows
2. In Docker Desktop settings:
    - **Settings > Resources > WSL integration**
    - Enable your WSL distro
3. Verify:

    ```bash
    docker ps
    docker compose version
    ```

## Customizing Tool Versions

Edit `scripts/core/config.sh` to change pinned versions:

```bash
readonly NODE_VERSIOn="24.12.0"
readonly GO_VERSION="1.25.6"
readonly RUST_CHANNEL="stable"
```

Then reinstall:

```bash
./main.sh uninstall --only go
./main.sh install --only go
```

## Troubleshooting Installation

**"command not found" after install:**

```bash
exec bash
# or
source ~/.bashrc
```

**APT packages fail to install:**

```bash
sudo apt update
sudo apt install -y build-essential # or specific package
./main.sh install
```

**Python: "externally-managed-environment" error:**

This is expected-use `pipx install <package>` for system-wide tools, or create a venv:

```bash
python3 -m venv myenv
source myenv/bin/activate
pip install <package>
```

**NVM/Node not found:**

```bash
exec bash
# or manually source:
source ~/.nvm/nvm.sh
node --version
```

**Go not in PATH:**

Ensure `~/.bashrc` is sourced (see "command not found" above).

**WSL Docker issues:**

1. Docker Desktop must be running
2. WSL integration must be enabled in Docker settings
3. Try: `docker info` (should show "Docker Desktop" in server info)

## Next Steps

- Run verification: `./main.sh verify`
- Check diagnostics: `./main.sh doctor`
- Explore: `./main.sh help`
- See [CLI Reference](cli.md) for all commands
