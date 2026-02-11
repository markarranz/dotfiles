# yabai

[yabai](https://github.com/koekeishiya/yabai) is a tiling window manager for macOS that uses a scripting addition for advanced features like window opacity, animations, and automatic space management. It is paired with [skhd](https://github.com/koekeishiya/skhd) for keybindings.

## Prerequisites

- [yabai](https://github.com/koekeishiya/yabai)
- [skhd](https://github.com/koekeishiya/skhd) -- hotkey daemon (see the `skhd/` config directory)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) -- status bar (yabai reserves 42 px at the top for it)
- [jq](https://jqlang.github.io/jq/) -- used by helper scripts
- SIP (System Integrity Protection) partially disabled for the scripting addition (see [yabai wiki](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection))

## Overview

| Setting | Value |
|---------|-------|
| Layout | BSP (binary space partition) |
| Split ratio | 50% |
| Window gap | 6 px |
| Padding | 3 px (bottom, left, right), 0 px top |
| Window opacity | 95% normal, 100% active |
| Animation | 0.3 s ease-out-circ |
| Window shadow | Floating windows only |
| Mouse modifier | `fn` key |

### Unmanaged Applications

These apps are excluded from tiling: 1Password, Activity Monitor, App Store, Calculator, Finder preferences, Logi Options, Python, Raycast, Steam, System Settings, VLC, and others.

### Helper Script

`clean_empty_spaces.sh` runs on space change events to automatically remove empty, unfocused spaces, keeping the workspace list clean.
