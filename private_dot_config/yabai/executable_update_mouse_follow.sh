#!/bin/bash
set -euo pipefail

command_exists() { command -v "$1" >/dev/null 2>&1; }
command_exists yabai && command_exists osascript || exit 0

# Read current focus instead of trusting a possibly stale app-switch event.
app=$(osascript -l JavaScript -e 'ObjC.import("AppKit"); $.NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier.js')
[[ -n "$app" ]] || exit 0

case "$app" in
  us.zoom.xos) yabai -m config mouse_follows_focus off focus_follows_mouse off ;;
  *) yabai -m config mouse_follows_focus on focus_follows_mouse autofocus ;;
esac
