#!/usr/bin/env bash
set -euo pipefail

tabs=$(kitty @ ls | jq -r '.[].tabs[] | "\(.id)|\(.is_focused)|\(.title)"')

selected=$(echo "$tabs" |
  grep -v '|true|' |
  cut -d'|' -f1,3 |
  column -t -s'|' |
  fzf --no-multi --prompt="Tab > " --layout=reverse --border=rounded --height=100% --margin=30%,35% --padding=1)

tab_id=$(echo "$selected" | awk '{print $1}')
[ -n "$tab_id" ] && kitty @ focus-tab --match id:"$tab_id"
