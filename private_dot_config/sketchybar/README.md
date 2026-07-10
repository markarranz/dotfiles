# SketchyBar

[SketchyBar](https://github.com/FelixKratz/SketchyBar) is a highly customizable status bar replacement for the macOS menu bar. It can display workspaces, system stats, notifications, and interactive widgets. This configuration uses [SBarLua](https://github.com/FelixKratz/SbarLua) for Lua-based scripting, adapted from [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles).

## Features

- **Spaces** - Workspace indicators with app icons, yabai integration
- **Front App** - Currently focused application display
- **CPU** - Real-time CPU usage graph with top process
- **GitHub** - Notification bell with popup details
- **Volume** - Slider control with audio device switching
- **Mic** - Mic activity indicator with mute status
- **WiFi** - Connection status with IP display
- **Battery** - Charge level with color indicators
- **Brew** - Outdated package count
- **Calendar** - Date/time with zen mode toggle

## Project Structure

```
sketchybar/
├── sketchybarrc          # Entry point (Lua script)
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
│       ├── mic.lua
│       ├── volume.lua
│       └── wifi.lua
├── lib/                  # Utility modules
│   └── icon_map.lua      # App name to icon mapping (auto-updated)
└── helpers/
    ├── event_provider/   # C helper for CPU monitoring
    └── mic-monitor/      # Swift CoreAudio input activity monitor
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

### Mic Monitor

The mic widget is backed by a per-user LaunchAgent. After applying the dotfiles, build and install it from the rendered config:

```bash
cd ~/.config/sketchybar/helpers/mic-monitor
make install
```

Use `make restart` after changing the Swift monitor and `make uninstall` to remove the LaunchAgent.

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

### Mic
- **Visible** - A process is actively using an audio input device
- **Red icon** - Input volume is muted
- **Hyper + M** - Toggle input mute

### GitHub Bell
- **Hover** - Show notification popup
- **Click** - Toggle popup

### Apple Logo
- **Click** - Show menu (Preferences, Activity Monitor, Lock Screen)

## Theming

Colors are defined in `config/colors.lua` using the Catppuccin Mocha palette. To change themes, modify this file:

```lua
return {
  black = 0xff11111b,   -- Crust
  white = 0xffcdd6f4,   -- Text
  red = 0xfff38ba8,     -- Red
  green = 0xffa6e3a1,   -- Green
  blue = 0xff89b4fa,    -- Blue
  -- ...
}
```

The C helper receives colors from `sketchybarrc`, so theme changes apply everywhere automatically.

## C Helper

The CPU helper (`helpers/event_provider/`) is a native C program that communicates with SketchyBar via Mach messaging for efficient CPU monitoring. It's built automatically when SketchyBar starts and receives color values from the Lua configuration.
