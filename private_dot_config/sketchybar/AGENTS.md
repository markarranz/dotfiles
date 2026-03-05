# SketchyBar (macOS) — AGENTS.md

Lua-scripted macOS menu bar replacement using SBarLua. Adapted from FelixKratz/dotfiles. Catppuccin Mocha palette. Includes a C helper for CPU monitoring via Mach messaging.

## Structure

```
sketchybar/
├── executable_sketchybarrc   # Entry point (Lua, loaded by SBarLua)
├── config/
│   ├── init.lua              # Config loader
│   ├── bar.lua               # Bar appearance (height, position, padding)
│   ├── colors.lua            # Catppuccin Mocha color palette (hex 0xAARRGGBB)
│   ├── default.lua           # Default item styling (font, padding, background)
│   ├── icons.lua             # SF Symbols + Nerd Font icon definitions
│   └── settings.lua          # Font family, padding constants
├── items/
│   ├── init.lua              # Item loader (registers all items + widgets)
│   ├── apple.lua             # Apple menu with popup (Preferences, Lock Screen)
│   ├── front_app.lua         # Active application display
│   ├── spaces.lua            # Workspace indicators (yabai integration)
│   └── widgets/
│       ├── init.lua          # Widget loader
│       ├── battery.lua       # Charge level with color indicators
│       ├── brew.lua          # Outdated package count
│       ├── calendar.lua      # Date/time + zen mode toggle
│       ├── cpu.lua           # CPU graph with top process (uses C helper)
│       ├── github.lua        # Notification bell with popup (requires gh CLI)
│       ├── volume.lua        # Slider + audio device switching
│       └── wifi.lua          # Connection status + IP display
├── lib/
│   └── app_icons.lua         # App name → Nerd Font icon mapping
└── helper/
    ├── helper.c              # C helper: CPU monitoring via Mach messaging
    ├── cpu.h                 # CPU sampling header
    ├── sketchybar.h          # SketchyBar Mach IPC header
    └── makefile              # Builds helper binary
```

## Where to Look

| Task | Location |
|------|----------|
| Add new widget | `items/widgets/new_widget.lua` + register in `items/widgets/init.lua` |
| Change colors | `config/colors.lua` — all hex values, 0xAARRGGBB format |
| Change fonts/padding | `config/settings.lua` |
| Add bar item (left/center) | `items/new_item.lua` + register in `items/init.lua` |
| Modify bar appearance | `config/bar.lua` |
| Change app icon mapping | `lib/app_icons.lua` (also auto-updated via chezmoiexternal) |
| Modify CPU helper | `helper/helper.c` + rebuild |

## Conventions

- **Color format**: `0xAARRGGBB` (alpha, red, green, blue) — not CSS hex
- **Item registration**: Each item file returns nothing; side-effects via `sbar.add()` calls
- **Config modules**: Loaded via `require("config.module_name")`
- **Widget interactions**: Click/right-click/hover handlers defined per-widget
- **Popup pattern**: `sbar.add("item", { popup = { ... } })` with toggle on click

## Anti-Patterns

- **Don't hardcode colors** — always reference `config/colors.lua` values
- **Don't add items without registering** in the appropriate `init.lua`
- **C helper is compiled at runtime** by SketchyBar — don't distribute binaries

## Notes

- **yabai integration**: `spaces.lua` queries yabai for workspace state. Requires yabai running.
- **github.lua**: Requires `gh auth login` — widget hides if not authenticated.
- **volume.lua**: Uses `SwitchAudioSource` for device switching (optional dep).
- **zen mode**: `calendar.lua` click toggles most widgets on/off.
- **C helper receives colors** from `sketchybarrc` Lua config — theme changes propagate automatically.
- **SBarLua**: Must be installed to `~/.local/share/sketchybar_lua/` (see README).
