#!/usr/bin/env bash
set -euo pipefail

# SketchyBar spawns children with SIGCHLD ignored, which breaks subprocess
# reaping in Homebrew's Ruby (waitpid returns nil): Hardware::CPU.cores
# crashes and the tap-trust git probe fails, silently dropping third-party
# tap formulae from `brew outdated`. Re-exec once with SIGCHLD restored.
if [[ -z "${BREW_COUNT_SIGCHLD_RESET:-}" ]] && [[ -x /usr/bin/ruby ]]; then
  BREW_COUNT_SIGCHLD_RESET=1 exec /usr/bin/ruby -e 'Signal.trap("CHLD", "DEFAULT"); exec(*ARGV)' "$0" "$@"
fi

usage() {
  cat << 'EOF'
Usage: brew-count.sh

Print the number of outdated Homebrew packages, or "!" if Homebrew cannot
produce a reliable count from SketchyBar's launchd environment.
EOF
}

command_exists() {
  command -v "$1" > /dev/null 2>&1
}

emit_error() {
  printf '!'
  exit 0
}

resolve_home() {
  if [[ -n "${HOME:-}" ]]; then
    printf '%s\n' "$HOME"
    return
  fi

  local username home_path
  username=$(id -un 2> /dev/null || true)
  if [[ -z "$username" ]]; then
    return 1
  fi

  if command_exists dscl; then
    home_path=$(dscl . -read "/Users/$username" NFSHomeDirectory 2> /dev/null | awk '{print $2}' || true)
    if [[ -n "$home_path" ]]; then
      printf '%s\n' "$home_path"
      return
    fi
  fi

  return 1
}

case "${1-}" in
  "")
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

brew_bin=/opt/homebrew/bin/brew
if [[ ! -x "$brew_bin" ]]; then
  brew_bin=$(command -v brew || true)
fi
if [[ -z "$brew_bin" ]]; then
  emit_error
fi

HOME=$(resolve_home) || emit_error
export HOME
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

shellenv_output=$("$brew_bin" shellenv 2> /dev/null) || emit_error
eval "$shellenv_output"

export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1

tmp=$(mktemp "${TMPDIR:-/tmp}/sketchybar-brew-outdated.XXXXXX") || emit_error
err=$(mktemp "${TMPDIR:-/tmp}/sketchybar-brew-outdated.err.XXXXXX") || {
  rm -f "$tmp"
  emit_error
}
trap 'rm -f "$tmp" "$err"' EXIT

status=0
HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet > "$tmp" 2> "$err" || status=$?
count=$(wc -l < "$tmp" | tr -d ' ')

if [[ "$status" -ne 0 ]] || { [[ "$count" == "0" ]] && grep -Eq 'Error:|Failure while executing' "$err"; }; then
  emit_error
fi

printf '%s' "$count"
