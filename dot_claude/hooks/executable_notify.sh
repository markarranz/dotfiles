#!/bin/bash
# Native macOS notification for Claude Code — bypasses Neovim terminal limitations
# Uses terminal-notifier to focus kitty on click, falls back to osascript

input=$(cat)

if ! command -v jq > /dev/null 2>&1; then
    exit 0
fi

msg=$(echo "$input" | jq -r '.message // empty')
title=$(echo "$input" | jq -r '.title // "Claude Code"')

[ -z "$msg" ] && exit 0

if command -v terminal-notifier > /dev/null 2>&1; then
    terminal-notifier -message "$msg" -title "$title" \
        -activate net.kovidgoyal.kitty \
        -sender net.kovidgoyal.kitty \
        -sound default >/dev/null 2>&1 &
else
    osascript - "$msg" "$title" <<'EOF' 2>/dev/null
on run argv
    display notification (item 1 of argv) with title (item 2 of argv)
end run
EOF
fi

exit 0
