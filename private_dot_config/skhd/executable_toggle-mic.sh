#!/usr/bin/env bash
set -euo pipefail

vol=$(osascript -e 'input volume of (get volume settings)')

if [ "$vol" -gt 0 ]; then
  tmp_file="/tmp/${USER}_mic_vol.tmp"
  echo "$vol" >"$tmp_file"
  mv "$tmp_file" "/tmp/${USER}_mic_vol"
  osascript -e "set volume input volume 0"
else
  mic_vol_file="/tmp/${USER}_mic_vol"
  if [ -f "$mic_vol_file" ]; then
    restore_vol=$(cat "$mic_vol_file")
    if [ "$restore_vol" -eq 0 ]; then
      restore_vol=50
    fi
  else
    restore_vol=50
  fi
  osascript -e "set volume input volume $restore_vol"
fi

sketchybar --trigger mic_mute_changed || true
