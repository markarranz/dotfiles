#!/usr/bin/env bash
set -euo pipefail

error() {
  printf 'toggle-micpipe: %s\n' "$*" >&2
}

micpipe_cmd="${MICPIPE:-$HOME/.local/bin/micpipe}"

if [ ! -x "$micpipe_cmd" ]; then
  if command -v micpipe >/dev/null 2>&1; then
    micpipe_cmd="$(command -v micpipe)"
  else
    error "missing required command: micpipe"
    exit 1
  fi
fi

status="$("$micpipe_cmd" status 2>&1 || true)"

case "$status" in
  running*)
    "$micpipe_cmd" stop
    ;;
  *)
    "$micpipe_cmd" start
    ;;
esac
