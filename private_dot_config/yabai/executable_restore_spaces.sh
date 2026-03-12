#!/bin/zsh

# Restore yabai spaces after a display is added or removed.
# Sets a lockfile so clean_empty_spaces.sh won't destroy spaces mid-transition.

LOCKFILE="/tmp/yabai_display_transition"
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

touch "$LOCKFILE"

# macOS needs a moment to finish rearranging spaces
sleep 3

labels=(chat code docs)

current_count=$(yabai -m query --spaces | jq length)
for ((n = current_count + 1; n <= $#labels; n++)); do
  yabai -m space --create
done

# Collect all space indices ordered by physical display position (left→right), then index
spaces=($(
  yabai -m query --displays | jq -r '
  sort_by(.frame.x) | .[].index' |
    while read -r display; do
      yabai -m query --spaces --display "$display" | jq -r 'sort_by(.index) | .[].index'
    done
))

for ((i = 1; i <= $#labels; i++)); do
  [[ -n "${spaces[$i]:-}" ]] && yabai -m space "${spaces[$i]}" --label "${labels[$i]}"
done

rm -f "$LOCKFILE"
