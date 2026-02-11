# Ashell

[Ashell](https://github.com/MalpenZibo/ashell) is a status bar and notification panel for Hyprland. It displays workspaces, the focused window title, system info, a tray, clock, and more along the top of the screen.

## Prerequisites

- [Ashell](https://github.com/MalpenZibo/ashell)
- [Hyprland](https://hyprland.org/) -- the Wayland compositor this panel is designed for
- [walker](https://github.com/abenz1267/walker) -- used as the app launcher triggered from the panel
- [hyprlock](https://github.com/hyprwm/hyprlock) -- triggered by the lock button in settings
- [playerctl](https://github.com/altdesktop/playerctl) -- pauses media on lock
- [pwvucontrol](https://github.com/saivert/pwvucontrol) -- PipeWire volume control (opened from audio settings)
- [nm-connection-editor](https://wiki.gnome.org/Projects/NetworkManager) -- network settings
- [blueman](https://github.com/blueman-project/blueman) -- Bluetooth manager

## Overview

| Module Position | Modules |
|----------------|---------|
| Left | App launcher, Updates, Workspaces |
| Center | Window title |
| Right | System info, Tray, Clock, Privacy, Settings |

### Key Configuration

- **Clock format:** `%a, %d %b %I:%M %p` (e.g. "Mon, 11 Feb 02:30 PM")
- **Update check:** `checkupdates; yay -Sy` (Arch Linux with AUR)
- **Scale factor:** 1.3
- **Style:** Solid, Catppuccin Mocha color palette
