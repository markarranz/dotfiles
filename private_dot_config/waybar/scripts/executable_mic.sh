#!/usr/bin/env bash
set -euo pipefail

icon_on=$''
icon_muted=$''

in_use=$(pactl list source-outputs short 2>/dev/null | grep -vi monitor | grep -c . || true)

if [ "$in_use" -eq 0 ]; then
  printf '{"text":"","tooltip":""}\n'
  exit 0
fi

muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -c MUTED || true)
if [ "$muted" -ge 1 ]; then
  printf '{"text":"%s","tooltip":"Microphone muted (in use)","class":"muted"}\n' "$icon_muted"
else
  printf '{"text":"%s","tooltip":"Microphone active","class":"active"}\n' "$icon_on"
fi
