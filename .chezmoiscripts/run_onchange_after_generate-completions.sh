#!/usr/bin/env bash
# Generate shell completions for tools that aren't covered by Homebrew
set -euo pipefail

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

generate_completion _kubectl kubectl completion zsh
generate_completion _opencode opencode completion zsh
generate_completion _cargo rustup completions zsh cargo
generate_completion _rustup rustup completions zsh
