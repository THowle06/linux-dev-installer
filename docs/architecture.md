# Architecture & Design

## Overview

The installer uses a **modular, registry-based dispatch system** with version pinning and idempotent operation.

## Repository Structure

```text
linux-dev-installer/
├── main.sh                 # CLI entry point
├── scripts/
│   ├── core/
│   │   ├── bootstrap.sh    # Initialize environment, load utilities
│   │   ├── logging.sh      # Color-coded logging functions
│   │   ├── utils.sh        # Helpers (retry, command_exists, etc.)
│   │   ├── config.sh       # Version pinning (single source of truth)
│   │   └── registry.sh     # Tool registry and dispatch logic
│   ├── commands/
│   │   ├── install.sh      # Install orchestrator
│   │   ├── update.sh       # Update orchestrator
│   │   ├── verify.sh       # Verify orchestrator
│   │   ├── doctor.sh       # Diagnostics
│   │   └── uninstall.sh    # Uninstall orchestrator
│   └── tools/
│       ├── apt.sh          # System packages
│       ├── python.sh       # Python + uv
│       ├── anaconda.sh     # Miniconda
│       ├── node.sh         # Node.js via NVM
│       ├── go.sh           # Go language
│       ├── rust.sh         # Rust via rustup
│       ├── haskell.sh      # Haskell via GHCup
│       ├── java.sh         # Java ecosystem
│       ├── dotnet.sh       # .NET SDK
│       ├── docker.sh       # Docker tooling
│       ├── lean.sh         # Lean 4 via elan
│       └── dotfiles.sh     # Configuration symlinks
├── dotfiles/
│   ├── bash/
│   │   ├── .bashrc         # Shell configuration
│   │   └── .bash_aliases   # Command aliases
│   └── git/
│       └── .gitconfig      # Git configuration
├── packages/
│   └── apt.txt             # APT package list
└── docs/
    ├── installation.md
    ├── cli.md
    ├── architecture.md
    ├── troubleshooting.md
    └── uninstall.md
```

## Core Concepts

### 1. Bootstrap System

**`scripts/core/bootstrap.sh`**

- Enforces strict mode (`set -euo pipefail`)
- Sets up directory constants (`SCRIPTS_DIR`, `TOOLS_DIR`, etc.)
- Loads all core utilities in order:
  1. `logging.sh` - Color logging
  2. `utils.sh` - Helper functions
  3. `config.sh` - Version pinning + get_architecture()
- Validates OS (Ubuntu 24.04)

**Purpose:** Every script sources bootstrap to get a consistent environment.

### 2. Logging System

**`scripts/core/logging.sh`**

Functions with color codes and log levels:

```bash
log_debug()    # [DEBUG] - lowest priority
log_info()     # [INFO]
log_success()  # [✓]
log_warn()     # [WARN]
log_error()    # [ERROR]
log_step()     # →
log_header()   # ==>
```

Controlled by `$LOG_LEVEL` env var (default: INFO).

### 3. Utility Functions

**`scripts/core/utils.sh`**

- `command_exists()` - Check if command in PATH
- `is_root()` - Check if running as root
- `require_sudo()` - Prompt for sudo if needed
- `retry()` - Exponential backoff retry (3 attempts, 2s → 4s → 8s)
- `confirm()` - User confirmation prompt
- `get_architecture()` - Detect amd64/arm64

### 4. Configuration & Version Pinning

**`scripts/core/config.sh`**

Single source of truth for all versions:

```bash
readonly NODE_VERSION="24.12.0"
readonly GO_VERSION="1.23.5"
readonly RUST_CHANNEL="stable"
# ... etc
```

**Benefits:**

- Easy to update versions
- Consistent across reinstalls
- Clear what's pinned vs. dynamic

### 5. Tool Registry

**`scripts/core/registry.sh`**

Defines all tools and their metadata:

```bash
TOOLS=(
    "apt:apt:apt"           # tool:category:script_file
    "python:python:python"
    "node:node:node"
    # ...
)
```

**Dispatch System:**

```bash
_dispatch_tools "install"   # Calls <tool>_install() for each tool
_dispatch_tools "update"    # Calls <tool>_update()
_dispatch_tools "verify"    # Calls <tool>_verify()
```

**Filtering:**

```bash
_tool_selected "rust" "rust"  # Check if tool passes --only/--exclude
```

### 6. Tool Implementation Pattern

Each tool file (`scripts/tools/<name>.sh`) implements:

```bash
<tool>_install()    # Install or verify pre-installed
<tool>_update()     # Update to latest or pinned version
<tool>_verify()     # Check availability and report version
<tool>_uninstall()  # Remove tool
```

**Example: Go**

```bash
go_install() {
    log_step "Installing Go..."
    # Download tarball
    curl -fsSL -o "$go_tarball" "${GO_URL}"
    # Extract to /usr/local
    sudo tar -C "${GO_INSTALL_PATH}" -xzf "$go_tarball"
    log_success "Go ${GO_VERSION} installed"
}

go_verify() {
    if ! command_exists go; then
        log_warn "go not in PATH"
        return 1
    fi
    log_success "Go verified"
}
```

## Execution Flow

### Install Flow

```text
main.sh install [--only python,node]
  ↓
scripts/commands/install.sh
  ↓
install_main()
  ↓
_dispatch_tools "install"
  ↓
For each selected tool:
  - _tool_selected()  → Check filters
  - apt_install()     → Run install
  - python_install()
  - node_install()
  - ...
```

### Verify Flow

```text
main.sh verify
  ↓
scripts/commands/verify.sh
  ↓
verify_main()
  ↓
_dispatch_tools "verify"
  ↓
For each tool:
  - <tool>_verify()   → Check if working
  - Report version
  - Log [✓] or [WARN]
```

## Key Design Decisions

### 1. Modular Tools

Each tool is independent:

- Can install/update/verify separately
- Minimal cross-tool dependencies
- Easy to add new tools

### 2. Version Pinning

All versions in `config.sh`:

- Reproducible installs across machines
- Easy to update all at once
- Clear what's managed

### 3. Idempotent Operations

- `install` can run multiple times safely
- Checks for existing installations
- Updates if already present
- No risk of duplicate installs

### 4. Non-Intrusive

- System packages (Java, Maven) kept if installed
- Docker kept (WSL-friendly)
- Original dotfiles backed up before symlink
- Clean uninstall with restoration

### 5. WSL Awareness

`docker.sh` detects WSL and:

- Skips Docker Engine install
- Uses Docker Desktop integration
- Cleaner for Windows+WSL workflow

### 6. Architecture Support

Uses `get_architecture()` to detect amd64/arm64:

- Go, Rust, Docker, Anaconda all arch-specific
- Single script works on both architectures

## Adding a New Tool

1. **Create `scripts/tools/<name>.sh`:**

```bash
#!/usr/bin/env bash
set -euo pipefail

<name>_install() {
    log_step "Installing <Name>..."
    # Install logic
    log_success "<Name> installed"
}

<name>_update() {
    log_step "Updating <Name>..."
    # Update logic
    log_success "<Name> updated"
}

<name>_verify() {
    log_step "Verifying <Name>..."
    if ! command_exists <name>; then
        log_warn "<name> not found"
        return 1
    fi
    log_success "<Name> verified"
}

<name>_uninstall() {
    log_step "Uninstalling <Name>..."
    # Uninstall logic
    log_success "<Name> uninstalled"
}
```

2. **Add version to `scripts/core/config.sh`:**

```bash
readonly <NAME>_VERSION="1.2.3"
```

3. **Register in `scripts/core/registry.sh`:**

```bash
TOOLS=(
    # ...
    "<name>:<category>:<name>"
)
```

4. **Test:**

```bash
./main.sh install --only <name>
./main.sh verify --only <name>
./main.sh uninstall --only <name>
```

## Error Handling

### Retry Logic

Network-dependent commands use `retry`:

```bash
retry 3 5 curl -fsSL -o "$file" "$url"
# Try 3 times, 2s → 4s → 8s delay
```

### Graceful Degradation

Tools that fail in install show warnings but don't stop:

```bash
if ! command_exists uv; then
    log_error "uv installation failed"
    return 1
fi
```

Orchestrator continues with remaining tools.

### Exit Codes

- `0` - Success
- `1` - Fatal error (script stops)

## Performance

- Parallel execution: None (sequential is safer for shell)
- Caching: None (always fresh, supports updates)
- Typical full install: 10-15 minutes (network dependent)

## Testing

Manual verification per tool:

```bash
./main.sh install --only rust --log-level debug
./main.sh verify --only rust
rustc --version
cargo --version
```

For CI/CD: See `.github/workflows/shellcheck.yml` (linting only, no execution).
