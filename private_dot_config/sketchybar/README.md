# SketchyBar

A customized SketchyBar configuration using SBarLua, adapted from [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles).

## Features

- **Spaces** - Workspace indicators with app icons, yabai integration
- **Front App** - Currently focused application display
- **CPU** - Real-time CPU usage graph with top process
- **GitHub** - Notification bell with popup details
- **Volume** - Slider control with audio device switching
- **WiFi** - Connection status with IP display
- **Battery** - Charge level with color indicators
- **Brew** - Outdated package count
- **Calendar** - Date/time with zen mode toggle

## Project Structure

```
sketchybar/
├── init.lua              # Entry point, starts helper and loads config
├── executable_sketchybarrc  # Shell wrapper (builds helper, runs Lua)
├── config/               # Configuration modules
│   ├── bar.lua           # Bar appearance (height, position, colors)
│   ├── colors.lua        # Color palette (Catppuccin)
│   ├── default.lua       # Default item styling
│   ├── icons.lua         # SF Symbols and icon definitions
│   └── settings.lua      # Font and padding settings
├── items/                # Bar item definitions
│   ├── apple.lua         # Apple menu with popup
│   ├── front_app.lua     # Active application
│   ├── spaces.lua        # Workspace indicators
│   └── widgets/          # Right-side widgets
│       ├── battery.lua
│       ├── brew.lua
│       ├── calendar.lua
│       ├── cpu.lua
│       ├── github.lua
│       ├── volume.lua
│       └── wifi.lua
├── lib/                  # Utility modules
│   └── app_icons.lua     # App name to icon mapping
└── helper/               # C helper for CPU monitoring
    ├── helper.c
    ├── cpu.h
    └── makefile
```

## Requirements

### SketchyBar

```bash
brew install sketchybar
```

### SBarLua Plugin

Builds the Lua module and places it in `~/.local/share/sketchybar_lua/`:

```bash
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
```

### Fonts

```bash
brew install font-sketchybar-app-font
```

### Optional Dependencies

| Dependency | Used By | Install |
|------------|---------|---------|
| `yabai` | Spaces widget | `brew install koekeishiya/formulae/yabai` |
| `gh` | GitHub widget | `brew install gh` (requires `gh auth login`) |
| `jq` | Various widgets | `brew install jq` |
| `SwitchAudioSource` | Volume device switching | `brew install switchaudio-osx` |

## Widget Interactions

### Spaces
- **Click** - Focus space
- **Shift + Click** - Rename space
- **Right Click** - Destroy space

### Volume
- **Click** - Toggle volume slider
- **Right Click / Shift + Click** - Show audio output devices

### WiFi
- **Click** - Toggle IP/SSID display

### Calendar
- **Click** - Toggle zen mode (hides most widgets)

### GitHub Bell
- **Hover** - Show notification popup
- **Click** - Toggle popup

### Apple Logo
- **Click** - Show menu (Preferences, Activity Monitor, Lock Screen)

## Theming

Colors are defined in `config/colors.lua` using the Catppuccin palette. To change themes, modify this file:

```lua
return {
  black = 0xff181926,
  white = 0xffcad3f5,
  red = 0xffed8796,
  green = 0xffa6da95,
  blue = 0xff8aadf4,
  -- ...
}
```

The C helper receives colors from `init.lua`, so theme changes apply everywhere automatically.

## C Helper

The CPU helper (`helper/`) is a native C program that communicates with SketchyBar via Mach messaging for efficient CPU monitoring. It's built automatically when SketchyBar starts and receives color values from the Lua configuration.
