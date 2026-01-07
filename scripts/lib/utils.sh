#!/usr/bin/env bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_version_line() {
    "$1" --version 2>/dev/null | head -n 1 || true
}