# Waybar Recreation of SketchyBar (Linux/Hyprland)

**Date:** 2026-06-09
**Status:** Design approved, pending spec review

## Goal

Recreate the look and feel of the custom macOS SketchyBar configuration
(`private_dot_config/sketchybar/`) as a Waybar bar for Linux/Hyprland, and
**replace the existing ashell bar entirely**. The signature SketchyBar
aesthetic — a floating, rounded-pill Catppuccin Mocha bar with per-workspace
app icons and a grouped "status" cluster — is the primary must-have.

## Approach

Hybrid: use built-in Waybar modules wherever a solid native equivalent exists
(workspaces, window, network, volume, battery, clock); write custom shell
scripts only where Waybar has no equivalent or where fidelity matters
(CPU %+top-process, Arch updates count, mic-active state, layout toggle); and
carry the full Catppuccin Mocha styling in GTK CSS. Power/session menu via
`wlogout`.

Rejected alternatives:
- **All-custom** (reimplement every widget): high maintenance, reinvents
  solved problems (battery, network, clock).
- **Native-first, lean** (minimal styling): sacrifices the floating
  rounded-pill look, which is a must-have.

## Bar Appearance

Floating bar mirroring SketchyBar's `y_offset`/`margin` look:

- Position: `top`
- Floating: outer `margin` + `border-radius` + `border` applied to the Waybar
  `window` (and/or `#waybar`) in CSS, not a full-width edge-to-edge bar.
- Background: Catppuccin Base `#1e1e2e`
- Border: Catppuccin Surface1 `#45475a` (with alpha to match SketchyBar's
  `0x6045475a`)
- Height: ~36–40px content; tuned to approximate SketchyBar's 45px bar with its
  negative margin/offset.

## Layout

| Section | Modules (left→right) |
|---------|----------------------|
| left    | `custom/power`, `hyprland/workspaces`, `custom/layout` |
| center  | `hyprland/window` |
| right   | `custom/cpu`, `custom/updates`, **status group** {`network`, `custom/mic`, `wireplumber`}, `battery`, `tray`, `clock` |

### Module specifications

**`custom/power`** — Apple-logo replacement.
- Icon: Arch Linux logo glyph `` (`nf-linux-archlinux`, ``) from the
  installed Nerd Font.
- Color: Catppuccin blue/sky.
- `on-click`: launch `wlogout` (lock / logout / suspend / reboot / shutdown).
- `wlogout` gets its own themed config in the repo (layout + Catppuccin CSS) so
  the menu matches the bar.

**`hyprland/workspaces`** — workspace indicators with per-workspace app icons.
- Show occupied/active workspaces; active workspace highlighted (Catppuccin
  highlight color, matching SketchyBar's selected-space styling).
- Per-workspace app icons via `window-rewrite`: map window `class`/`title`
  regex → Nerd Font glyph. A hand-maintained mapping table with a default
  fallback glyph for unknown apps.
- `format-icons` for the workspace number/state.
- Requires an installed Nerd Font (already used by kitty/starship).
- Click focuses the workspace (Waybar default `on-click`).

**`custom/layout`** — Hyprland layout indicator/toggle (parity with the yabai
bsp/stack widget).
- Reads current layout via `hyprctl getoption general:layout` (or equivalent).
- Displays an icon: dwindle vs. master, colored differently (mirroring
  SketchyBar's white/yellow grid/stack icons).
- `on-click`: toggle dwindle⇄master via `hyprctl keyword general:layout …`.
- Script: `scripts/executable_layout.sh` (read mode + toggle mode via arg).

**`hyprland/window`** — front-app title (center). Title only; SketchyBar's app
*icon* next to the title is not reproduced here (no native Waybar support for a
class-based icon inline with the window module). Truncate long titles.

**`custom/cpu`** — CPU usage, text form.
- Output: usage `%` + top process name.
- Tooltip: more detail (e.g., top N processes).
- Color thresholds for high load.
- Implemented as a polling shell script (~3s) reading `/proc/stat` and `ps` —
  no C helper needed. Script: `scripts/executable_cpu.sh`, JSON output
  (`{"text":…, "tooltip":…, "class":…}`).

**`custom/updates`** — Arch update count (brew widget replacement).
- Count outdated packages via `checkupdates` (pacman-contrib) + `yay -Qua`
  (AUR), mirroring ashell's `checkupdates; yay -Sy` behavior.
- Color thresholds like the brew widget: green/checkmark at 0, escalating
  white→yellow→orange→red as count grows.
- `on-click`: run the interactive update command in kitty (ported from ashell:
  `kitty --single-instance -e zsh -c "yay; echo; read …"`).
- Tooltip: list of pending packages.
- Script: `scripts/executable_updates.sh`, JSON output.

**status group** {`network`, `custom/mic`, `wireplumber`} — a Waybar module
group styled with the rounded "bracket" background (mirroring SketchyBar's
`status` bracket grouping brew/github/wifi/volume).
- **`network`** — WiFi status: connected icon + SSID, IP in tooltip (or
  toggled). Disconnected state with distinct icon/color. `on-click` opens
  `nm-connection-editor` (ported from ashell).
- **`custom/mic`** — mic-active indicator mirroring SketchyBar's behavior:
  shown when a source is actively in use, with mute state coloring. Detect via
  `wpctl`/`pactl` (source RUNNING state + mute). Script:
  `scripts/executable_mic.sh`.
- **`wireplumber`** — volume: icon + %, scroll-to-adjust, `on-click` opens
  `pwvucontrol` (ported from ashell). See caveat re: slider.

**`battery`** — charge level with state-based icons/colors (Catppuccin),
charging state. Native module; thresholds approximating SketchyBar's
100/75/50/25/0 + charging icons.

**`tray`** — system tray. SketchyBar had none (macOS menu bar handles it), but
ashell did; included as a sensible Linux default so removing ashell isn't a
regression. Styled to match.

**`clock`** — calendar widget replacement.
- Format: `%a, %d %b %I:%M %p` (matching ashell/SketchyBar).
- Calendar in the tooltip (native Waybar clock feature).

## Styling (GTK CSS)

`style.css` carries the Catppuccin Mocha palette and recreates:
- Floating, rounded, bordered bar window.
- Rounded "pill" backgrounds on modules (SketchyBar `corner_radius` ~9,
  `border_width` 2).
- The status-group bracket background (Catppuccin Surface alpha bg + border),
  grouping network/mic/volume visually.
- Active-workspace highlight, color thresholds for CPU/updates/battery via
  `.class` selectors emitted by the scripts.
- Font: the Nerd Font already in use; sizing tuned to match SketchyBar's
  proportions.

## File Layout

```
private_dot_config/waybar/
├── config.jsonc                      # modules + behavior
├── style.css                         # Catppuccin Mocha styling
├── README.md                         # tool doc (per-tool README pattern)
└── scripts/
    ├── executable_cpu.sh             # % + top process → JSON
    ├── executable_updates.sh         # pacman/yay count → JSON + classes
    ├── executable_mic.sh             # mic active/mute → JSON
    └── executable_layout.sh          # dwindle/master read + toggle
```

`private_dot_config/wlogout/` (themed power menu):
```
private_dot_config/wlogout/
├── layout                            # menu entries (lock/logout/suspend/reboot/shutdown)
└── style.css                         # Catppuccin Mocha theme
```

All shell scripts follow repo conventions: `set -euo pipefail`, quoted
variables, `command_exists()` guards where invoking optional tools.

## Integration Changes

- **`private_dot_config/hypr/hyprland.lua:23`**: change
  `hl.exec_cmd("uwsm app -- ashell")` → `hl.exec_cmd("uwsm app -- waybar")`.
- **`.chezmoiignore.tmpl`**: add `.config/waybar/` and `.config/wlogout/` to the
  Linux-only ignore block (the `ne .chezmoi.os "linux"` branch).
- **Delete `private_dot_config/ashell/`** (reversible via git). Its
  `.config/ashell/` ignore entry is removed.
- **Docs**:
  - `private_dot_config/hypr/README.md` + `AGENTS.md`: ashell → Waybar
    references.
  - root `CLAUDE.md`: structure table (`ashell` → `waybar`), cross-tool
    dependency `Hyprland → Ashell → Walker` → `Hyprland → Waybar → Walker`,
    and the "Where to Look" / config-format tables as needed.
- **`install.sh`**: add `waybar`, `wlogout`, `pacman-contrib` (provides
  `checkupdates`) to the Linux package list.

## Fidelity Caveats (accepted)

- **Volume slider**: Waybar/GTK has no draggable inline slider. Delivered as the
  `wireplumber` module (icon+%, scroll-to-adjust, click → `pwvucontrol`) styled
  as a pill. Not a literal drag slider.
- **CPU graph**: text %+top-process per decision, not the animated dual-graph.
- **Zen mode** (calendar-click hides widgets): no native Waybar support;
  dropped (was not a must-have).
- **GitHub review bell**: skipped per decision. Layout leaves room to add a
  `custom/github` module later (poll `gh api`, count badge + tooltip).
- **App icons**: via `window-rewrite` class→Nerd Font glyph mapping
  (hand-maintained), not SketchyBar's automatic app-font. Same visual effect.
- **Front-app icon**: window module shows title only; no inline app icon.

## Out of Scope

- Touching the macOS SketchyBar config (it stays as-is).
- Any non-Hyprland Wayland compositor support.
- Notification daemon changes (mako stays).
