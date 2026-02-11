# AeroSpace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) is a tiling window manager for macOS inspired by i3. It organizes windows into workspaces with keyboard-driven navigation and layout management -- no mouse required.

## Prerequisites

- [AeroSpace](https://github.com/nikitabobko/AeroSpace)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) (optional, receives workspace change events)

## Overview

- **Starts at login** automatically
- **Default layout:** tiles (auto-selects horizontal or vertical based on window dimensions)
- **Accordion padding:** 30 px
- **Mouse follows focus** on monitor change

### Gaps

- **Outer gaps:** 45 px top (room for SketchyBar), 10 px sides/bottom
- **Inner gaps:** 15 px between windows

### Key Bindings

All bindings use `Alt` as the primary modifier.

| Binding | Action |
|---------|--------|
| `Alt+h/j/k/l` | Focus window left/down/up/right |
| `Alt+Shift+h/j/k/l` | Move window left/down/up/right |
| `Alt+1-9` | Switch to workspace |
| `Alt+Shift+1-9` | Move window to workspace |
| `Alt+Shift+f` | Toggle fullscreen |
| `Alt+f` | Toggle floating |
| `Alt+/` | Cycle layouts: tiles / horizontal / vertical |
| `Alt+,` | Cycle accordion layouts |
| `Alt+-` / `Alt+=` | Shrink / grow window |
| `Alt+Tab` | Toggle between recent workspaces |
| `Cmd+Enter` | Open Kitty terminal |
| `Cmd+b` | Open browser |
| `Cmd+e` | Open Finder |

### Workspace Change Script

`workspace-change.sh` runs on every workspace switch to:
1. Update SketchyBar with the new workspace
2. Move Firefox Picture-in-Picture windows to the current workspace
