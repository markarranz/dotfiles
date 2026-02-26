#!/usr/bin/env bash
# Claude Code status line — OMC HUD with Catppuccin Mocha theming.
# Pipes stdin through the OMC HUD, then substitutes its standard 8-color
# ANSI codes with Catppuccin Mocha 24-bit RGB equivalents.

node ~/.claude/hud/omc-hud.mjs | perl -pe '
  s/\x1b\[31m/\x1b[38;2;243;139;168m/g;  # Red      #F38BA8
  s/\x1b\[32m/\x1b[38;2;166;227;161m/g;  # Green    #A6E3A1
  s/\x1b\[33m/\x1b[38;2;249;226;175m/g;  # Yellow   #F9E2AF
  s/\x1b\[34m/\x1b[38;2;137;180;250m/g;  # Blue     #89B4FA
  s/\x1b\[35m/\x1b[38;2;203;166;247m/g;  # Mauve    #CBA6F7
  s/\x1b\[36m/\x1b[38;2;137;220;235m/g;  # Sky      #89DCEB
  s/\x1b\[37m/\x1b[38;2;205;214;244m/g;  # Text     #CDD6F4
  s/\x1b\[94m/\x1b[38;2;116;199;236m/g;  # Sapphire #74C7EC
  s/\x1b\[95m/\x1b[38;2;245;194;231m/g;  # Pink     #F5C2E7
  s/\x1b\[96m/\x1b[38;2;148;226;213m/g;  # Teal     #94E2D5
'
