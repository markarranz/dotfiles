#!/bin/bash
# Dispatcher for kitty's open_url_with.
# file:// URLs open in nvim in a new kitty tab; everything else falls through
# to macOS `open`.

set -u

url="$1"

case "$url" in
  file://*)
    raw="${url#file://}"
    # Strip leading host (e.g. "localhost") if present
    raw="${raw#localhost}"
    path="$(/usr/bin/python3 -c 'import sys,urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$raw")"

    # Optional line/column from common patterns: file://path:LINE or :LINE:COL
    line=""
    col=""
    if [[ "$path" =~ ^(.+):([0-9]+):([0-9]+)$ ]]; then
      path="${BASH_REMATCH[1]}"; line="${BASH_REMATCH[2]}"; col="${BASH_REMATCH[3]}"
    elif [[ "$path" =~ ^(.+):([0-9]+)$ ]]; then
      path="${BASH_REMATCH[1]}"; line="${BASH_REMATCH[2]}"
    fi

    cwd="$(dirname "$path")"
    [[ -d "$cwd" ]] || cwd="$HOME"

    nvim_args=()
    if [[ -n "$line" ]]; then
      nvim_args+=("+call cursor($line, ${col:-1})")
    fi
    nvim_args+=("$path")

    KITTY=/Applications/kitty.app/Contents/MacOS/kitty

    # Try to open as a new tab in the current kitty instance; fall back to a
    # standalone OS window if remote control isn't reachable.
    if [[ -n "${KITTY_LISTEN_ON:-}" ]] && \
       "$KITTY" @ --to "$KITTY_LISTEN_ON" launch --type=tab --cwd="$cwd" nvim "${nvim_args[@]}" >/dev/null 2>&1; then
      :
    else
      "$KITTY" -d "$cwd" -- nvim "${nvim_args[@]}" &
    fi
    ;;
  *)
    /usr/bin/open "$url"
    ;;
esac
