#!/bin/bash
set -euo pipefail

command_exists() { command -v "$1" >/dev/null 2>&1; }
command_exists yabai && command_exists jq || exit 1
target=${1:?usage: focus_space.sh <space index or selector>}
history="$(dirname "$0")/space_focus_history.py"
python3 "$history" remember || true
if [[ ! "$target" =~ ^[1-9][0-9]*$ ]]; then
  case "$target" in
    prev|next|first|last|recent)
      target=$(yabai -m query --spaces --space "$target" | jq -er '.index') ;;
    *) exit 1 ;;
  esac
fi

spaces=$(yabai -m query --spaces)
current=$(jq -er '.[] | select(."has-focus") | .index' <<<"$spaces")
[[ "$current" != "$target" ]] || exit 0

if ! jq -e --argjson target "$target" 'any(.[]; .index == $target)' <<<"$spaces" >/dev/null; then
  [[ "$target" != 1 ]] || exit 1
  yabai -m space --create
  target=$(yabai -m query --spaces --display | jq -er 'max_by(.index).index')
fi

window=$(python3 "$history" preferred "$target" || true)
if [[ -n "$window" ]] && yabai -m window --focus "$window"; then
  exit 0
fi

windows=$(yabai -m query --windows --space "$target")
window=$(jq -r '
  [.[] | select(.role == "AXWindow" and .subrole == "AXStandardWindow"
    and ."has-ax-reference" == true and ."is-minimized" == false
    and ."is-hidden" == false)]
  | sort_by(."stack-index", .id) | first | .id // empty
' <<<"$windows")

# Focusing only the space can leave the previous app focused on this display.
if [[ -n "$window" ]] && yabai -m window --focus "$window"; then
  exit 0
fi
yabai -m space --focus "$target"
