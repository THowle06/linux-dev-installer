#!/usr/bin/env bash
# Logging utilities with color support

# Color codes
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_GRAY='\033[0;90m'

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Internal logging function
_log() {
    local level=$1
    local color=$2
    local prefix=$3
    shift 3

    if [[ $level -ge $LOG_LEVEL ]]; then
        echo -e "${color}${prefix}${COLOR_RESET} $*" >&2
    fi
}

log_debug() {
    _log $LOG_LEVEL_DEBUG "$COLOR_GRAY" "[DEBUG] " "$@"
}

log_info() {
    _log $LOG_LEVEL_INFO "$COLOR_BLUE" "[INFO]" "$@"
}

log_success() {
    _log $LOG_LEVEL_INFO "$COLOR_GREEN" "[✓]    " "$@"
}

log_warn() {
    _log $LOG_LEVEL_WARN "$COLOR_YELLOW" "[WARN] " "$@"
}

log_error() {
    _log $LOG_LEVEL_ERROR "$COLOR_RED" "[ERROR]" "$@"
}

log_header() {
    echo ""
    _log $LOG_LEVEL_INFO "$COLOR_CYAN" "==>" "$@"
}

log_step() {
    _log $LOG_LEVEL_INFO "$COLOR_MAGENTA" "  →" "$@"
}