# Linux Development Environment Installer

A **fully reproducible development environment** for Ubuntu-based systems (WSL/native Linux).

Automated installation and management of development toolchains with version pinning, tracked dotfiles, and health-check tooling.

## Quick Start

### Prerequisites

**Windows (WSL):**

```powershell
wsl --install
wsl --set-default-version 2
# Install Ubuntu 24.04 LTS from Microsoft Store
```

**Native Linux:** Ubuntu 24.04 LTS

### Installation

```bash
# Clone repository
cd ~
git clone https://github.com/THowle06/linux-dev-installer.git installer
cd installer

# Make scripts executable
chmod +x main.sh

# Run installer
./main.sh install

# Restart shell
exec bash

# Verify installation
./main.sh verify
./main.sh doctor
```

## Supported Tools

- **Java** (OpenJDK 21, Maven, Gradle)
- **Python** (python3, pip, uv)
- **C / C++** (gcc, make, cmake)
- **Go** (1.25.6)
- **Rust** (via rustup)
- **JavaScript / TypeScript** (Node.js 24.12.0 via NVM)
- **Haskell** (via ghcup)
- **Lean 4** (via elan)
- **Anaconda / Miniconda** (optional Python distribution)
- **Docker** (with WSL integration)
- **Terminal & Editors** (tmux, neovim, fzf, ripgrep)

## CLI Reference

```bash
./main.sh <command> [options]
```

### Commands

| Command     | Description                        |
| ----------- | ---------------------------------- |
| `install`   | Run full installation              |
| `update`    | Update all tools                   |
| `verify`    | Quick verification check           |
| `doctor`    | Full health check with diagnostics |
| `uninstall` | Remove installed tools             |
| `help`      | Show usage information             |

### Examples

```bash
# Full installation
./main.sh install

# Install only specific categories
./main.sh install --only python,node,rust

# Update all tools
./main.sh update

# Quick verification
./main.sh verify

# Detailed diagnostics
./main.sh doctor

# Uninstalled with confirmation
./main.sh uninstall --confirm

# Uninstall and restore dotfiles
./main.sh uninstall --confirm --restore-backups
```

### Options

| Options             | Description                              |
| ------------------- | ---------------------------------------- |
| `--only <cats>`     | Comma-separated categories to include    |
| `--exclude <cats>`  | Comma-separated categories to exclude    |
| `--dry-run`         | Show actions without executing           |
| `--confirm`         | Skip confirmation prompts                |
| `--restore-backups` | Restore original dotfiles on uninstall   |
| `--log-level <lvl>` | debug, info, warn, error (default: info) |

### Available Categories

- `python` - Python tooling (pip, uv)
- `node` - Node.js via NVM
- `go` - Go language
- `rust` - Rust toolchain via rustup
- `haskell` - Haskell toolchain via ghcup
- `lean` - Lean 4 via elan
- `anaconda` - Anaconda/Miniconda
- `dotnet` - .NET SDK
- `java` - Java ecosystem
- `docker` - Docker tooling
- `dotfiles` - Configuration file linking

**Note:** APT packages (build tools, Java, Docker) are always installed.

## Documentation

- [Installation Guide](docs/installation.md) - Detailed setup and prerequisites
- [CLI Reference](docs/cli.md) - Complete command documentation with examples
- [Architecture](docs/architecture.md) - System design and repository structure
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Uninstall Guide](docs/uninstall.md) - Safe removal and restoration

## Key Features

- [X] **Version pinning** - Exact versions specified in config
- [X] **Automatic backups** - Dotfiles backed up before modification
- [X] **Idempotent scripts** - Safe to rerun multiple times
- [X] **Selective installations** - Install only what you need
- [X] **Health checks** - Comprehensive verification tooling
- [X] **Clean uninstall** - Remove tools with optional restoration
- [X] **Architecture-aware** - Supports amd64 and arm64
- [X] **WSL optimized** - Special handling for Docker Desktop integration

## Repository Strycture

```text
.
├── dotfiles/
│   ├── bash/           # .bashrc, .bash_aliases
│   └── git/            # .gitconfig
├── packages/
│   └── apt.txt         # APT package list
├── scripts/
│   ├── core/           # Bootstrap, logging, utilities, registry
│   ├── tools/          # Individual tool installers
│   └── commands/       # install, update, verify, doctor, uninstall
├── docs/               # Documentation
├── main.sh             # CLI entrypoint
├── LICENSE
├── .gitignore
├── .editorconfig
└── README.md
```

## Design Philosophy

- **Reproducibility** - Exact versions, scripted setup
- **Explicit versioning** - Single source of truth in config
- **Minimal global state** - Language-specific version managers
- **Portability** - Works across machines and fresh installs
- **Idempotency** - Safe to rerun scripts
- **Safety** - Automatic backups before changes
- **Reversibility** - Clean uninstall with restoration

## Troubleshooting

**Scripts not executable:**

```bash
chmod +x main.sh
```

**Tools not found after install:**

```bash
exec bash
```

**For detailed help:** See [Troubleshooting Guide](docs/troubleshooting.md)

## License

MIT - See [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please open issues or pull requests on GitHub.
