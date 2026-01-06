#!/usr/bin/env bash

#######################################
# Colour-aware logging utilities
#######################################

# Enable colours only if stdout is a terminal
if [[ -t 1 ]]; then
    COLOR_RESET="\033[0m"
    COLOR_INFO="\033[1;34m"     # Blue
    COLOR_WARN="\033[1;33m"     # Yellow
    COLOR_ERROR="\033[1;31m"    # Red
else
    COLOR_RESET=""
    COLOR_INFO=""
    COLOR_WARN=""
    COLOR_ERROR=""
fi

log_info() {
    echo -e "\n${COLOR_INFO}[INFO]${COLOR_RESET}  $1"
}

log_warn() {
    echo -e "${COLOR_WARN}[WARN]${COLOR_RESET}  $1"
}

log_error() {
    echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $1" >&2
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}