#!/usr/bin/env bash
set -euo pipefail

# Resolve dotfiles root directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Load core libraries
source "$DOTFILES_DIR/scripts/lib/logging.sh"
source "$DOTFILES_DIR/scripts/lib/utils.sh"
source "$DOTFILES_DIR/scripts/lib/config.sh"
source "$DOTFILES_DIR/scripts/lib/checks.sh"