#!/usr/bin/env bash
# -------------------------------------------------
# Tool registry
# Single source of truth for managed tools
# -------------------------------------------------

# -------------------------------
# Core system tools
# -------------------------------
TOOLS_CORE=(
    gcc
    make
    git
    curl
    wget
)

# -------------------------------
# Python
# -------------------------------
TOOLS_PYTHON=(
    python3
    pip
    uv
)

# -------------------------------
# Node.js
# -------------------------------
TOOLS_NODE=(
    node
    npm
)

# -------------------------------
# Go
# -------------------------------
TOOLS_GO=(
    go
)

# -------------------------------
# Rust
# -------------------------------
TOOLS_RUST=(
    rustc
    cargo
)

# -------------------------------
# Java
# -------------------------------
TOOLS_JAVA=(
    java
    javac
    mvn
    gradle
)

# -------------------------------
# Haskell
# -------------------------------
TOOLS_HASKELL=(
    ghcup
    ghc
    cabal
)

# -------------------------------
# .NET SDK
# -------------------------------
TOOLS_DOTNET=(
    dotnet
)

# -------------------------------
# Containers
# -------------------------------
TOOLS_CONTAINERS=(
    docker
)

# -------------------------------
# Editors / terminal
# -------------------------------
TOOLS_EDITORS=(
    nvim
    tmux
)

# -------------------------------
# Aggregate list
# -------------------------------
ALL_TOOLS=(
    "${TOOLS_CORE[@]}"
    "${TOOLS_PYTHON[@]}"
    "${TOOLS_NODE[@]}"
    "${TOOLS_GO[@]}"
    "${TOOLS_RUST[@]}"
    "${TOOLS_JAVA[@]}"
    "${TOOLS_HASKELL[@]}"
    "${TOOLS_DOTNET[@]}"
    "${TOOLS_CONTAINERS[@]}"
    "${TOOLS_EDITORS[@]}"
)