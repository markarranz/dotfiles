#!/bin/bash
set -euo pipefail
export CHEZMOI_DEVCONTAINER=true

# Install chezmoi to ~/.local/bin
if ! command -v chezmoi &>/dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

chezmoi init --apply --source "$(pwd)"
