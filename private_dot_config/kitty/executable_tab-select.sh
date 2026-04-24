#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

mru_file="${XDG_STATE_HOME:-$HOME/.local/state}/kitty-tab-mru"
mkdir -p "$(dirname "$mru_file")"
touch "$mru_file"

tabs=$(kitty @ ls | jq -r '.[].tabs[] | "\(.id)|\(.is_focused)|\(.title)"')
focused_id=$(echo "$tabs" | grep '|true|' | cut -d'|' -f1)

# Build tab list excluding focused tab
tab_list=$(echo "$tabs" | grep -v '|true|' | cut -d'|' -f1,3)

# Sort by MRU: tabs in state file first (in order), then the rest
sorted=""
while IFS= read -r mru_id; do
  match=$(echo "$tab_list" | grep "^${mru_id}|" || true)
  [ -n "$match" ] && sorted="${sorted}${match}"$'\n'
done <"$mru_file"

# Append any tabs not in MRU
while IFS= read -r line; do
  id=$(echo "$line" | cut -d'|' -f1)
  if ! grep -q "^${id}$" "$mru_file"; then
    sorted="${sorted}${line}"$'\n'
  fi
done <<<"$tab_list"

selected=$(echo "$sorted" |
  sed '/^$/d' |
  column -t -s'|' |
  fzf --no-multi --prompt="Tab > " --layout=reverse --border=rounded)

tab_id=$(echo "$selected" | awk '{print $1}')

if [ -n "$tab_id" ]; then
  # Update MRU: put focused tab (the one we're leaving) at the top
  {
    echo "$focused_id"
    grep -v "^${focused_id}$" "$mru_file" || true
  } >"${mru_file}.tmp"
  mv "${mru_file}.tmp" "$mru_file"
  kitty @ focus-tab --match id:"$tab_id"
fi
