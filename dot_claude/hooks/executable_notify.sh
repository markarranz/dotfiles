#!/bin/sh
# Desktop notification for Claude Code — bypasses Neovim terminal limitations
# macOS: terminal-notifier (focuses kitty on click), fallback to osascript
# Linux: notify-send (libnotify)

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

msg=$(echo "$input" | jq -r '.message // empty')
title=$(echo "$input" | jq -r '.title // "Claude Code"')

[ -z "$msg" ] && exit 0

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -message "$msg" -title "$title" \
    -activate net.kovidgoyal.kitty \
    -sender net.kovidgoyal.kitty \
    -sound default >/dev/null 2>&1 &
elif command -v osascript >/dev/null 2>&1; then
  osascript - "$msg" "$title" <<'EOF' 2>/dev/null
on run argv
    display notification (item 1 of argv) with title (item 2 of argv)
end run
EOF
elif command -v notify-send >/dev/null 2>&1; then
  ( action=$(notify-send "$title" "$msg" --action="default=Focus Kitty")
    if [ "$action" = "default" ] && command -v hyprctl >/dev/null 2>&1; then
      hyprctl dispatch focuswindow class:kitty >/dev/null 2>&1
    fi
  ) &
fi

exit 0
