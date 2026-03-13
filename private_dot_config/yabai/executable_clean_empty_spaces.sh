#! /usr/bin/env bash
set -euo pipefail

# Skip during display transitions (restore_spaces.py holds the lock)
LOCKFILE="/tmp/yabai_display_transition"
if [[ -f "$LOCKFILE" ]]; then
  lock_age=$(( $(date +%s) - $(stat -f %m "$LOCKFILE") ))
  if (( lock_age < 60 )); then
    exit 0  # Active transition, skip cleanup
  else
    rm -f "$LOCKFILE"  # Stale lockfile from crashed script, remove and continue
  fi
fi

yabai -m query --spaces --display |
  jq -re 'map(select(."is-native-fullscreen" == false)) | length > 1' &&
  # wait for any native fullscreen apps to get added back to their original workspace
  sleep 2 &&
  yabai -m query --spaces |
  jq -r 'map(select(."windows" == [] and ."has-focus" == false).index) | reverse | .[] ' |
    xargs -I % sh -c 'yabai -m space % --destroy'
