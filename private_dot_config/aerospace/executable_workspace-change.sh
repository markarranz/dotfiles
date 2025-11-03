#!/usr/bin/env bash

# Update sketchybar:
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"

# Move Firefox PiP windows to current workspace:
aerospace list-windows --all |
  grep -E "Picture-in-Picture" |
  awk '{print $1}' |
  while read -r window_id; do
    if [[ -n "$window_id" ]]; then
      aerospace move-node-to-workspace --window-id "$window_id" "$AEROSPACE_FOCUSED_WORKSPACE"
    fi
  done
