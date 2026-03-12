#! /usr/bin/env bash

# Skip during display transitions (restore_spaces.sh holds the lock)
[[ -f /tmp/yabai_display_transition ]] && exit 0

yabai -m query --spaces --display |
  jq -re 'map(select(."is-native-fullscreen" == false)) | length > 1' &&
  # wait for any native fullscreen apps to get added back to their original workspace
  sleep 2 &&
  yabai -m query --spaces |
  jq -re 'map(select(."windows" == [] and ."has-focus" == false).index) | reverse | .[] ' |
    xargs -I % sh -c 'yabai -m space % --destroy'
