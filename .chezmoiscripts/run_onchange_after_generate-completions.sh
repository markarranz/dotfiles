#!/usr/bin/env bash
# Generate shell completions for tools that aren't covered by Homebrew
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run_onchange_after_generate-completions.sh [--help]

Generate zsh completions for tools installed outside the system package manager.

Package managers usually install zsh completions automatically when packages
ship them:
  - macOS/Homebrew: /opt/homebrew/share/zsh/site-functions or zsh-completions
  - Arch pacman/yay: /usr/share/zsh/site-functions

Do not add package-manager-provided completions here. Add one registry line for
tools installed another way:

  generate_completion _tool tool completion zsh

The first argument is the target file in $ZSH_COMPLETIONS_DIR. The remaining
arguments are the command that writes completion output to stdout.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

completion_dir="${ZSH_COMPLETIONS_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions}"
mkdir -p "$completion_dir"

warn() {
  printf 'generate-completions: %s\n' "$*" >&2
}

generate_completion() {
  local target="$1"
  shift

  command -v "$1" >/dev/null 2>&1 || return 0

  local tmp
  tmp=$(mktemp "${TMPDIR:-/tmp}/zsh-completion.${target}.XXXXXX")
  if "$@" >"$tmp"; then
    if [[ -s "$tmp" ]]; then
      mv "$tmp" "$completion_dir/$target"
    else
      warn "$target generated empty output"
      rm -f "$tmp"
    fi
  else
    warn "failed to generate $target"
    rm -f "$tmp"
  fi
}

# Only add tools installed outside package managers here.
# Homebrew and pacman/yay packages usually install completions into fpath dirs.
generate_completion _kubectl kubectl completion zsh
generate_completion _opencode opencode completion zsh
generate_completion _cargo rustup completions zsh cargo
generate_completion _rustup rustup completions zsh
