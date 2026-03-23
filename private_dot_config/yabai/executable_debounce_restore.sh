#!/bin/sh
set -eu

DEBOUNCE_FILE="/tmp/yabai_restore_debounce"
echo $$ > "$DEBOUNCE_FILE"
sleep 3
[ "$(cat "$DEBOUNCE_FILE" 2>/dev/null)" = "$$" ] && \
    "${XDG_CONFIG_HOME:-$HOME/.config}/yabai/restore_spaces.py"
