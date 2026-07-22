#!/bin/sh
set -eu

# Once a tracked Tuple screen-share window closes, return focus to the space
# active before it opened, if its space is now empty and still focused, so
# clean_empty_spaces.sh (wired to space_changed) reaps it. Paired with
# tuple_share_open.sh.

TRACK_FILE="/tmp/yabai-tuple-shares"
LOCK_DIR="/tmp/yabai-tuple-shares.lock"

window_id=${1:?usage: tuple_share_close.sh <window id>}

[ -f "$TRACK_FILE" ] || exit 0

lock_held=0
trap '[ "$lock_held" -eq 1 ] && rmdir "$LOCK_DIR" 2>/dev/null' EXIT

i=0
while ! mkdir "$LOCK_DIR" 2>/dev/null; do
  lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || echo 0) ))
  [ "$lock_age" -gt 10 ] && rmdir "$LOCK_DIR" 2>/dev/null
  i=$((i + 1))
  [ "$i" -ge 50 ] && exit 0
  sleep 0.1
done
lock_held=1

entry=$(grep "^$window_id " "$TRACK_FILE" 2>/dev/null) || exit 0

tmp_file="${TRACK_FILE}.tmp.$$"
grep -v "^$window_id " "$TRACK_FILE" > "$tmp_file" 2>/dev/null || true
mv -f "$tmp_file" "$TRACK_FILE"

share_space=$(printf '%s\n' "$entry" | awk '{print $2}')
return_space=$(printf '%s\n' "$entry" | awk '{print $3}')
case "$share_space" in ''|*[!0-9]*) exit 0 ;; esac
case "$return_space" in ''|*[!0-9]*) exit 0 ;; esac

space=$(yabai -m query --spaces --space "$share_space" 2>/dev/null) || exit 0
[ "$(printf '%s\n' "$space" | jq -r '.windows == []')" = "true" ] || exit 0
[ "$(printf '%s\n' "$space" | jq -r '."has-focus"')" = "true" ] || exit 0

yabai -m space --focus "$return_space" 2>/dev/null || true
