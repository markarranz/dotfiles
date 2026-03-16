# Hyprland (Linux) — AGENTS.md

Dynamic tiling Wayland compositor with companion utilities (hyprlock, hypridle, hyprpaper, hyprsunset). Catppuccin Mocha theme. Hardware-conditional config via chezmoi template.

## Structure

```
hypr/
├── hyprland.conf         # Main compositor config (keybinds, rules, autostart)
├── hardware.conf.tmpl    # Monitor/input config (laptop vs desktop conditional)
├── hypridle.conf         # Idle timeouts → lock → suspend chain
├── hyprlock.conf.tmpl    # Lock screen appearance (chassis-conditional layout)
├── hyprpaper.conf        # Wallpaper config
├── hyprsunset.conf       # Blue light filter
├── scripts/              # Helper scripts (screenshot, etc.)
└── README.md
```

## Where to Look

| Task | Location |
|------|----------|
| Add keybinding | `hyprland.conf` — `bind` section |
| Window/workspace rules | `hyprland.conf` — `windowrulev2` section |
| Monitor/input config | `hardware.conf.tmpl` — chassis-type conditional |
| Idle/lock behavior | `hypridle.conf` (timeouts) + `hyprlock.conf.tmpl` (appearance) |
| Autostart programs | `hyprland.conf` — `exec-once` section |
| Wallpaper | `hyprpaper.conf` |

## Conventions

- **Config language**: Hyprlang (not Lua/TOML/JSON) — `keyword = value`, `bind = MODS, key, action, args`
- **Source chaining**: `hyprland.conf` sources `catppuccin/mocha.conf` (theme) + `hardware.conf` (per-machine)
- **Hardware split**: All monitor/input/touchpad config in `hardware.conf.tmpl` — never in `hyprland.conf`
- **Template variables**: `.chassisType` (laptop vs desktop), `.chezmoi.os` (always linux here)
- **Autostart**: `exec-once` for daemons (ashell, walker, kitty), `exec` for re-runnable commands
- **Default programs**: `$terminal=kitty --single-instance`, `$menu=walker`, `$browser=firefox`

## Anti-Patterns

- **Don't put hardware-specific config in `hyprland.conf`** — use `hardware.conf.tmpl` with chassis conditional
- **Don't edit Catppuccin theme source** — sourced from chezmoiexternal-managed path
- **Don't add Linux-only logic outside templates** — `.chezmoiignore.tmpl` already excludes hypr/ on macOS

## Notes

- **Integration chain**: Hyprland → Ashell (status bar) → Walker (app launcher) via Unix socket.
- **Home-row mods**: Kanata runs at OS level before Hyprland sees keys — same layout as macOS Karabiner.
- **Lock screen**: `hyprlock.conf.tmpl` varies layout by chassis (laptop shows battery, desktop doesn't).
- **Idle chain**: `hypridle.conf` → dim after N min → lock → suspend. Inhibited during audio/fullscreen.
