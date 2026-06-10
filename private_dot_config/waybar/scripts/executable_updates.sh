#!/usr/bin/env bash
set -euo pipefail

command_exists() { command -v "$1" >/dev/null 2>&1; }

icon_ok=$''
icon_pending=$''

repo=""
aur=""
command_exists checkupdates && repo=$(checkupdates 2>/dev/null || true)
command_exists yay && aur=$(yay -Qua 2>/dev/null || true)

repo_n=$(printf '%s' "$repo" | grep -c . || true)
aur_n=$(printf '%s' "$aur" | grep -c . || true)
total=$((repo_n + aur_n))

class="none"
if   [ "$total" -ge 60 ]; then class="critical"
elif [ "$total" -ge 30 ]; then class="high"
elif [ "$total" -ge 10 ]; then class="medium"
elif [ "$total" -ge 1 ];  then class="low"
fi

if [ "$total" -eq 0 ]; then
  printf '{"text":"%s ","tooltip":"System up to date","class":"none"}\n' "$icon_ok"
  exit 0
fi

tooltip=$(printf '%s\n%s' "$repo" "$aur" | grep . | head -n40 \
  | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
printf '{"text":"%s %s","tooltip":"%s","class":"%s"}\n' "$icon_pending" "$total" "$tooltip" "$class"
