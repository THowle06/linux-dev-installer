#!/usr/bin/env bash

# Colours (only if stdout is a terminal)
if [[ -t 1 ]]; then
    BLUE="\033[1;34m"
    GREEN="\033[1;32m"
    YELLOW="\033[1;33m"
    RED="\033[1;31m"
    BOLD="\033[1m"
    RESET="\033[0m"
else
    BLUE="" GREEN="" YELLOW="" RED="" BOLD="" RESET=""
fi

log_info() {
    echo -e "\n${BLUE}${BOLD}==>${RESET} $*"
}

log_ok() {
    echo -e "${GREEN}✔${RESET} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}