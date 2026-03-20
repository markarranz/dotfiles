#!/bin/sh
set -eu

# Output the index of the neighboring display (coordinate-sorted).
# Usage: display_neighbor.sh prev|next
# Exits non-zero if no neighbor in that direction.

direction=${1:?usage: display_neighbor.sh prev|next}

yabai -m query --displays | jq -re --arg dir "$direction" \
  --argjson cur "$(yabai -m query --displays --display | jq '.index')" '
  [sort_by(.frame.x) | .[].index] as $s | ($s | index($cur)) as $i |
  if $dir == "prev" then
    if $i > 0 then $s[$i - 1] else empty end
  else
    if $i < ($s | length) - 1 then $s[$i + 1] else empty end
  end'
