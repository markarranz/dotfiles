# Waybar

[Waybar](https://github.com/Alexays/Waybar) is the status bar for Hyprland on Linux, recreating the look of the macOS SketchyBar config. Catppuccin Mocha theme, floating rounded pills.

## Layout

| Position | Modules |
|----------|---------|
| Left | Arch power button, workspaces (app icons), layout toggle |
| Center | Focused window title |
| Right | CPU, updates, status group (network/mic/volume), battery, tray, clock |

## Custom Scripts (`scripts/`)

| Script | Module | Purpose |
|--------|--------|---------|
| `cpu.sh` | `custom/cpu` | CPU % + top process (3s) |
| `updates.sh` | `custom/updates` | pacman + AUR update count; click runs `yay` in kitty |
| `mic.sh` | `custom/mic` | Shows mic icon only when a source is recording; red when muted |
| `layout.sh` | `custom/layout` | Dwindle/master indicator; click toggles via `hyprctl` |

## Interactions

- **Arch logo** — click opens `wlogout` (lock/logout/suspend/reboot/shutdown)
- **Workspace** — click to focus
- **Layout** — click toggles dwindle/master
- **Updates** — click opens a `yay` update session in kitty
- **Network** — click opens `nm-connection-editor`
- **Volume** — scroll to adjust, click opens `pwvucontrol`, right-click mutes

## Dependencies

`waybar`, `wlogout`, `pacman-contrib` (checkupdates), `yay`, `wireplumber`/`pipewire-pulse` (`wpctl`/`pactl`), `pwvucontrol`, `nm-connection-editor`, `hyprctl`, `jq`, a Nerd Font (`ttf-jetbrains-mono-nerd`).

## Reload

`killall -SIGUSR2 waybar` reloads config + style without a restart.
