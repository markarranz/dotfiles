#!/bin/sh
set -eu

# Wrap a yabai window-move command with signal suppression.
# The flag prevents application_activated from stealing focus
# when the source space auto-focuses a remaining window.
# Usage: move_window.sh 'yabai -m window --space 3 && yabai -m space --focus 3'

touch /tmp/yabai-moving
eval "$1"
(sleep 0.5; rm -f /tmp/yabai-moving) &
