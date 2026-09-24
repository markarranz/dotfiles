#!/bin/bash
set -euo pipefail

command_exists() { command -v "$1" >/dev/null 2>&1; }
command_exists yabai && command_exists jq || exit 0

[[ ! -f /tmp/yabai-moving && ! -f /tmp/yabai_display_transition ]] || exit 0
space=$(yabai -m query --spaces --space 2>/dev/null) || exit 0
space_id=$(jq -er '.id' <<<"$space") || exit 0

# Give macOS a chance to focus a remaining window itself.
sleep 0.15
[[ ! -f /tmp/yabai-moving && ! -f /tmp/yabai_display_transition ]] || exit 0
space=$(yabai -m query --spaces --space 2>/dev/null) || exit 0
[[ $(jq -r '.id' <<<"$space") == "$space_id" ]] || exit 0
space_index=$(jq -er '.index' <<<"$space") || exit 0
windows=$(yabai -m query --windows 2>/dev/null) || exit 0

target=$(jq -er --argjson space "$space_index" '
  if any(.[]; ."has-focus" == true) then empty
  else
    [.[] | select(.space == $space and .role == "AXWindow"
      and .subrole == "AXStandardWindow" and ."has-ax-reference" == true
      and ."is-minimized" == false and ."is-hidden" == false
      and ."is-visible" == true)]
    | sort_by(."stack-index", .id) | first | .id // empty
  end
' <<<"$windows") || exit 0

if yabai -m query --windows --window 2>/dev/null | jq -e '.id > 0' >/dev/null; then
  exit 0
fi
space=$(yabai -m query --spaces --space 2>/dev/null) || exit 0
[[ $(jq -r '.id' <<<"$space") == "$space_id" ]] || exit 0
yabai -m window --focus "$target" 2>/dev/null || true
