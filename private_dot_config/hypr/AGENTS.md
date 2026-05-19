# Hyprland (Linux) — AGENTS.md

Dynamic tiling Wayland compositor with companion utilities (hyprlock, hypridle, hyprpaper, hyprsunset). Catppuccin Mocha theme. Hardware-conditional config via chezmoi template.

## Structure

```
hypr/
├── hyprland.lua          # Main compositor config (keybinds, rules, autostart)
├── hardware.lua.tmpl     # Monitor/input config (laptop vs desktop conditional)
├── theme.lua             # Catppuccin color palette used by Hyprland Lua config
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
| Add keybinding | `hyprland.lua` — `hl.bind(...)` section |
| Window/workspace rules | `hyprland.lua` + `hardware.lua.tmpl` — `hl.window_rule(...)` |
| Monitor/input config | `hardware.lua.tmpl` — chassis-type conditional |
| Idle/lock behavior | `hypridle.conf` (timeouts) + `hyprlock.conf.tmpl` (appearance) |
| Autostart programs | `hyprland.lua` — `hl.on("hyprland.start", ...)` |
| Wallpaper | `hyprpaper.conf` |

## Conventions

- **Config language**: Hyprland Lua (`hyprland.lua`) — use `hl.config`, `hl.bind`, `hl.window_rule`, `hl.monitor`
- **Require split**: `hyprland.lua` requires `theme.lua` and `hardware.lua`
- **Hardware split**: All monitor/input/touchpad config lives in `hardware.lua.tmpl` — never in `hyprland.lua`
- **Template variables**: `.chassisType` (laptop vs desktop), `.chezmoi.os` (always linux here)
- **Autostart**: `hl.on("hyprland.start", ...)` for daemons (ashell, walker, kitty)
- **Default programs**: `$terminal=kitty --single-instance`, `$menu=walker`, `$browser=firefox`

## Anti-Patterns

- **Don't put hardware-specific config in `hyprland.lua`** — use `hardware.lua.tmpl` with chassis conditional
- **Don't edit Catppuccin theme source** — sourced from chezmoiexternal-managed path
- **Don't add Linux-only logic outside templates** — `.chezmoiignore.tmpl` already excludes hypr/ on macOS

## Notes

- **Integration chain**: Hyprland → Ashell (status bar) → Walker (app launcher) via Unix socket.
- **Home-row mods**: Kanata runs at OS level before Hyprland sees keys — same layout as macOS Karabiner.
- **Lock screen**: `hyprlock.conf.tmpl` varies layout by chassis (laptop shows battery, desktop doesn't).
- **Idle chain**: `hypridle.conf` → dim after N min → lock → suspend. Inhibited during audio/fullscreen.
