#!/bin/sh
set -eu

DEBOUNCE_FILE="/tmp/yabai_restore_debounce"
echo $$ > "$DEBOUNCE_FILE"
sleep 5
[ "$(cat "$DEBOUNCE_FILE" 2>/dev/null)" = "$$" ] || exit 0

previous_displays=""
stable_count=0
attempts=0
while [ "$attempts" -lt 20 ]; do
    current_displays=$(yabai -m query --displays 2>/dev/null || true)
    if [ -n "$current_displays" ] && [ "$current_displays" = "$previous_displays" ]; then
        stable_count=$((stable_count + 1))
        [ "$stable_count" -ge 2 ] && break
    else
        stable_count=0
        previous_displays="$current_displays"
    fi
    attempts=$((attempts + 1))
    sleep 0.5
done

[ "$(cat "$DEBOUNCE_FILE" 2>/dev/null)" = "$$" ] || exit 0

if "${XDG_CONFIG_HOME:-$HOME/.config}/yabai/restore_spaces.py"; then
    sketchybar --trigger spaces_refresh >/dev/null 2>&1 || true
fi
