# CLI Reference

## Usage

```bash
./main.sh <command> [options]
```

## Commands

### `install` - Install Tools

Install all tools or filtered selection:

```bash
./main.sh install
./main.sh install --only python,node
./main.sh install --only rust --log-level debug
```

**Options:**

- `--only <cats>` - Comma-separated categories (e.g., `python,node,rust`)
- `--exclude <cats>` - Exclude categories (e.g., `--exclude docker`)
- `--dry-run` - Show what would be done without executing
- `--log-level <lvl>` - Set verbosity: `debug`, `info`, `warn`, `error`

### `update` - Update Tools

Update all or specific tools to latest versions:

```bash
./main.sh update
./main.sh update --only python
./main.sh update --only anaconda,rust
```

**Options:** Same as `install`

### `verify` - Quick Health Check

Verify all or specific tools are installed and working:

```bash
./main.sh verify
./main.sh verify --only node,go
./main.sh verify --exclude docker
```

Output sample:

```text
✓ apt: core system packages verified
✓ python: Python ecosystem verified
✓ node: Node.js ecosystem verified
✓ go: Go verified
...
```

**Options:** Same as `install`

### `doctor` - Detailed Diagnostics

Comprehensive health check with version information:

```bash
./main.sh doctor
./main.sh doctor --only haskell
```

Shows:

- Tool availability
- Version numbers
- Configuration status
- Warning details if issues found

### `uninstall` - Remove Tools

Remove tools and optionally restore backups:

```bash
./main.sh uninstall
./main.sh uninstall --only anaconda
./main.sh uninstall --confirm --restore-backups
```

**Options:**

- `--only <cats>` - Remove specific categories
- `--exclude <cats>` - Skip categories
- `--confirm` - Skip confirmation prompt
- `--restore-backups` - Restore original dotfiles

**Note:** APT packages (Java, Maven, Gradle, Docker, .NET) are kept for safety.

### `help` - Show Usage

```bash
./main.sh help
```

## Common Workflows

### Fresh Setup

```bash
./main.sh install
exec bash
./main.sh verify
```

### Add a New Tool Later

```bash
./main.sh install --only lean
source ~/.bashrc
./main.sh verify --only lean
```

### Update Everything

```bash
./main.sh update
./main.sh verify
```

### Update Specific Tools

```bash
./main.sh update --only rust,node,go
```

### Dry-Run Before Major Changes

```bash
./main.sh uninstall --only anaconda --dry-run
./main.sh uninstall --only anaconda --confirm
```

### Debug Installation Issues

```bash
./main.sh install --log-level debug
```

### Clean Up and Reinstall Single Tool

```bash
./main.sh uninstall --only python --confirm
./main.sh install --only python
source ~/.bashrc
./main.sh verify --only python
```

## Exit Codes

- `0` - Success
- `1` - Command failed or unknown command

## Tips

**See what will be installed:**

```bash
./main.sh install --only node --dry-run
```

**Get more details during install:**

```bash
./main.sh install --log-level debug
```

**Update only language toolchains (skip system packages):**

```bash
./main.sh update --exclude apt
```

**Verify a specific tool in detail:**

```bash
./main.sh verify --only rust --log-level debug
```
