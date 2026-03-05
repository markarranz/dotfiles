# Hyprland

[Hyprland](https://hyprland.org/) is a dynamic tiling Wayland compositor (window manager) with smooth animations, rounded corners, and a highly scriptable configuration. It manages window placement, workspaces, keybindings, and multi-monitor setups.

## Prerequisites

- [Hyprland](https://hyprland.org/)
- [hyprlock](https://github.com/hyprwm/hyprlock) -- lock screen
- [hypridle](https://github.com/hyprwm/hypridle) -- idle management (dim screen, lock, suspend)
- [hyprpaper](https://github.com/hyprwm/hyprpaper) -- wallpaper manager
- [hyprsunset](https://github.com/hyprwm/hyprsunset) -- blue light filter (night mode)
- [uwsm](https://github.com/Vladimir-csp/uwsm) -- session manager for Hyprland
- [Kitty](https://sw.kovidgoyal.net/kitty/) -- default terminal
- [walker](https://github.com/abenz1267/walker) -- application launcher + clipboard (via [Elephant](https://github.com/abenz1267/elephant))
- [nautilus](https://apps.gnome.org/Nautilus/) -- file manager
- [Firefox](https://www.mozilla.org/firefox/) -- default browser
- [brightnessctl](https://github.com/Haikarainen/brightnessctl) -- keyboard backlight control (laptop)

## Overview

The main config is static, with hardware-specific settings sourced from `hardware.conf.tmpl` (adapts to chassis type):

| Setting | Laptop | Desktop |
|---------|--------|---------|
| Monitor | 2880x1800 @ 60 Hz, 1.5x scale | 3840x1600 @ 175 Hz, 10-bit |
| Gaps | 0 px | 5 px |
| Blur | Disabled (performance) | Enabled, 3 passes |

### Layout

- **Tiling:** dwindle (binary split)
- **Border:** 3 px gradient (pink to sky)
- **Rounding:** 5 px corner radius
- **Snap:** Enabled

### Companion Utilities

| File | Purpose |
|------|---------|
| `hyprland.conf` | Main compositor config (static: keybindings, rules, appearance) |
| `hardware.conf.tmpl` | Hardware-specific overrides (monitor, gaps, blur, touchpad, screenshots) |
| `hyprlock.conf.tmpl` | Lock screen appearance (background image, clock, input field) |
| `hypridle.conf` | Idle timers: dim at 2.5 min, lock at 5 min, screen off at 5.5 min, suspend at 10 min |
| `hyprpaper.conf` | Wallpaper assignment |
| `hyprsunset.conf` | Color temperature schedule (6000 K daytime, 4000 K evening) |
| `scripts/kbbacklight` | Keyboard backlight brightness control script |
| `themes/` | Catppuccin Mocha theme files (external submodule) |

### Autostarted Programs

- **ashell** -- status bar / system panel
- **walker** -- application launcher daemon (listens on a Unix socket)
