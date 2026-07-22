#!/bin/sh
set -eu

# Route Tuple's screen-share window (any Tuple window beyond the main call
# window, excluding the "Host" HUD) to a new space on the built-in display
# and focus it. Paired with tuple_share_close.sh.

TRACK_FILE="/tmp/yabai-tuple-shares"
LOCK_DIR="/tmp/yabai-tuple-shares.lock"

window_id=${1:?usage: tuple_share_open.sh <window id>}

win=$(yabai -m query --windows --window "$window_id" 2>/dev/null) || exit 0
[ "$(printf '%s\n' "$win" | jq -r .app)" = "Tuple" ] || exit 0
[ "$(printf '%s\n' "$win" | jq -r .title)" = "Host" ] && exit 0

others=$(yabai -m query --windows 2>/dev/null |
  jq --argjson wid "$window_id" '[.[] | select(.app == "Tuple" and .title != "Host" and .id != $wid)] | length') || exit 0
case "$others" in ''|*[!0-9]*) exit 0 ;; esac
[ "$others" -ge 1 ] || exit 0

builtin_display=$(yabai -m query --spaces 2>/dev/null |
  jq -r '[.[] | select(.label == "chat")] | first | .display') || exit 0
case "$builtin_display" in ''|null|*[!0-9]*) exit 0 ;; esac

return_space=$(yabai -m query --spaces --space 2>/dev/null | jq -r .index) || exit 0
case "$return_space" in ''|null|*[!0-9]*) exit 0 ;; esac

touch /tmp/yabai-moving
lock_held=0
trap '
  [ "$lock_held" -eq 1 ] && rmdir "$LOCK_DIR" 2>/dev/null
  (sleep 0.5; rm -f /tmp/yabai-moving) &
' EXIT

i=0
while ! mkdir "$LOCK_DIR" 2>/dev/null; do
  lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || echo 0) ))
  [ "$lock_age" -gt 10 ] && rmdir "$LOCK_DIR" 2>/dev/null
  i=$((i + 1))
  [ "$i" -ge 50 ] && exit 0
  sleep 0.1
done
lock_held=1

yabai -m space --create "$builtin_display"
new_space=$(yabai -m query --spaces --display "$builtin_display" | jq 'map(.index) | max')
case "$new_space" in ''|null|*[!0-9]*) exit 0 ;; esac
yabai -m window "$window_id" --space "$new_space"
yabai -m space --focus "$new_space"

echo "$window_id $new_space $return_space" >> "$TRACK_FILE"
