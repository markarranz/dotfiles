#!/bin/sh
# Generate shell completions for tools that aren't covered by Homebrew
set -eu

dir="$HOME/.local/share/zsh/completions"
mkdir -p "$dir"

if command -v opencode >/dev/null 2>&1; then
  opencode completion zsh >"$dir/_opencode"
fi
