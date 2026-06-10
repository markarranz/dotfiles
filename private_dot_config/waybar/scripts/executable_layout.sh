#!/usr/bin/env bash
set -euo pipefail

icon_master=$''
icon_dwindle=$''

current() { hyprctl getoption general:layout -j | jq -r '.str'; }

if [ "${1:-}" = "toggle" ]; then
  if [ "$(current)" = "dwindle" ]; then
    hyprctl keyword general:layout master >/dev/null
  else
    hyprctl keyword general:layout dwindle >/dev/null
  fi
  exit 0
fi

layout=$(current)
if [ "$layout" = "master" ]; then
  printf '{"text":"%s ","tooltip":"Layout: master","class":"master"}\n' "$icon_master"
else
  printf '{"text":"%s ","tooltip":"Layout: dwindle","class":"dwindle"}\n' "$icon_dwindle"
fi
