# Kanata

[Kanata](https://github.com/jtroo/kanata) is a software keyboard remapper that runs as a background service. It intercepts key events at the OS level and can implement advanced behaviors like tap-hold dual-function keys.

## Prerequisites

- [Kanata](https://github.com/jtroo/kanata)
- `uinput` kernel module (loaded by default on most Linux distributions)
- Your user must have permission to access `/dev/uinput` (typically via a udev rule or the `input` group)

## Overview

This configuration implements **home-row mods** -- the home row keys gain modifier behavior when held, while still typing normally when tapped:

| Key | Tap | Hold |
|-----|-----|------|
| `a` | a | Ctrl |
| `s` | s | Alt |
| `d` | d | Super/Meta |
| `f` | f | Shift |
| `j` | j | Shift |
| `k` | k | Super/Meta |
| `l` | l | Alt |
| `;` | ; | Ctrl |

### Timing

- **Tap time:** 150 ms -- if the key is released within this window, it counts as a tap
- **Hold time:** 200 ms -- the modifier activates after this delay

## Layers

- `base` -- home-row mods enabled
- `plain` -- passthrough layer for games and any app that should see normal keys only

## Systemd Service

Kanata runs as a user service via systemd. To enable:

```sh
systemctl --user enable --now kanata.service
```

The service auto-restarts on failure with a 3-second delay and exposes a local TCP control port on `127.0.0.1:10000` for `hyprkan`.

## hyprkan

[hyprkan](https://github.com/haithium/hyprkan) watches the focused window and switches Kanata layers automatically. The Linux setup here uses:

- `~/.config/kanata/apps.json` -- app rules
- `~/.config/systemd/user/hyprkan.service` -- user service
- `~/.local/share/hyprkan/hyprkan.py` -- pinned upstream script

The default rules switch to the `plain` layer for common gaming windows such as `steam_app_*`, `gamescope`, `heroic`, `lutris`, and `prismlauncher`, then fall back to `base` everywhere else.

To discover extra classes or titles for games you use, run:

```sh
python3 ~/.local/share/hyprkan/hyprkan.py --current-window-info
```
