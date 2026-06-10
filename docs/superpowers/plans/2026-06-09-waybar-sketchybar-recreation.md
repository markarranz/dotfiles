# Waybar SketchyBar Recreation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Catppuccin Mocha Waybar config for Hyprland that recreates the floating, rounded-pill look and the modules of the macOS SketchyBar config, and replace ashell entirely.

**Architecture:** Hybrid — native Waybar modules for solved problems (workspaces, window, network, volume, battery, clock, tray); custom shell scripts only for CPU, Arch updates, mic-active, and layout toggle; full styling in GTK CSS. Power menu via `wlogout`.

**Tech Stack:** Waybar (JSONC config + GTK CSS), POSIX/bash scripts, Hyprland (`hyprctl`), WirePlumber/PipeWire (`wpctl`/`pactl`), pacman-contrib (`checkupdates`) + `yay`, `wlogout`, chezmoi, JetBrains Mono Nerd Font.

**Environment note:** This repo lives on the target Arch/Hyprland machine. Verification launches the real `waybar`/scripts under the live session. Source files use chezmoi prefixes (`private_dot_config/`, `executable_`); they reach `~/.config/...` via `chezmoi apply`. Validate source files directly where possible, and use `chezmoi apply` + a Waybar reload (`killall -SIGUSR2 waybar`) for live checks.

**Commit convention:** `[waybar] <imperative>` (or `[hypr]`/`[install]` for those files). No `Co-Authored-By` trailer (repo override).

---

## File Structure

```
private_dot_config/waybar/
├── config.jsonc                      # bar + modules + behavior
├── style.css                         # Catppuccin Mocha styling
├── README.md                         # tool doc
└── scripts/
    ├── executable_cpu.sh             # CPU % + top process → JSON
    ├── executable_updates.sh         # pacman/yay update count → JSON
    ├── executable_mic.sh             # mic in-use/mute → JSON
    └── executable_layout.sh          # dwindle/master read + toggle

private_dot_config/wlogout/
├── layout                            # menu entries
└── style.css                         # Catppuccin Mocha theme
```

Modified: `private_dot_config/hypr/hyprland.lua`, `.chezmoiignore.tmpl`, `install.sh`, `private_dot_config/hypr/README.md`, `private_dot_config/hypr/AGENTS.md`, `CLAUDE.md`. Deleted: `private_dot_config/ashell/`.

---

## Task 1: Scaffold the bar (skeleton that launches)

**Files:**
- Create: `private_dot_config/waybar/config.jsonc`
- Create: `private_dot_config/waybar/style.css`

- [ ] **Step 1: Write the skeleton config**

Create `private_dot_config/waybar/config.jsonc`:

```jsonc
{
  "layer": "top",
  "position": "top",
  "height": 36,
  "margin-top": 6,
  "margin-left": 8,
  "margin-right": 8,
  "spacing": 4,

  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["hyprland/window"],
  "modules-right": ["clock"],

  "hyprland/window": {
    "format": "{title}",
    "max-length": 100,
    "separate-outputs": true
  },

  "clock": {
    "interval": 10,
    "format": "{:%a, %d %b %I:%M %p}",
    "tooltip-format": "<tt><small>{calendar}</small></tt>"
  }
}
```

- [ ] **Step 2: Write a minimal stylesheet**

Create `private_dot_config/waybar/style.css`:

```css
* {
  font-family: "JetBrainsMono Nerd Font", sans-serif;
  font-size: 13px;
  font-weight: 600;
  min-height: 0;
}

window#waybar {
  background: transparent;
  color: #cdd6f4;
}

.modules-left, .modules-center, .modules-right {
  background: #1e1e2e;
  border: 2px solid rgba(69, 71, 90, 0.6);
  border-radius: 10px;
  padding: 0 6px;
}

#clock, #window {
  padding: 0 8px;
}
```

- [ ] **Step 3: Validate JSONC parses**

Run: `python3 -c "import json,re,sys; t=open('private_dot_config/waybar/config.jsonc').read(); t=re.sub(r'//[^\n]*','',t); json.loads(t); print('OK')"`
Expected: `OK` (comment-stripped config is valid JSON)

- [ ] **Step 4: Apply and launch to verify it renders**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall waybar 2>/dev/null; waybar >/tmp/waybar.log 2>&1 &
sleep 2; grep -i "error\|warn" /tmp/waybar.log || echo "no errors"
```
Expected: a floating bar appears at top showing workspaces / window title / clock; `no errors` (or only benign warnings).

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/waybar/config.jsonc private_dot_config/waybar/style.css
git commit -m "[waybar] scaffold floating bar skeleton"
```

---

## Task 2: Native right-side modules (network, volume, battery, tray)

**Files:**
- Modify: `private_dot_config/waybar/config.jsonc`

- [ ] **Step 1: Add the modules to `modules-right`**

Replace the `"modules-right"` line in `config.jsonc` with:

```jsonc
  "modules-right": ["group/status", "battery", "tray", "clock"],
```

- [ ] **Step 2: Add the status group and its module definitions**

Insert these objects after the `"clock"` block (before the closing `}`), each preceded by a comma:

```jsonc
  "group/status": {
    "orientation": "horizontal",
    "modules": ["network", "custom/mic", "wireplumber"]
  },

  "network": {
    "format-wifi": "  {essid}",
    "format-ethernet": " {ipaddr}",
    "format-disconnected": " ",
    "tooltip-format-wifi": "{essid} ({signalStrength}%)\n{ipaddr}",
    "tooltip-format-ethernet": "{ifname}\n{ipaddr}",
    "tooltip-format-disconnected": "Disconnected",
    "on-click": "nm-connection-editor"
  },

  "wireplumber": {
    "format": "{icon}  {volume}%",
    "format-muted": " muted",
    "format-icons": ["", "", ""],
    "scroll-step": 5,
    "on-click": "pwvucontrol",
    "on-click-right": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  },

  "battery": {
    "states": { "warning": 25, "critical": 10 },
    "format": "{icon}",
    "format-charging": "",
    "format-icons": ["", "", "", "", ""],
    "tooltip-format": "{capacity}% — {timeTo}"
  },

  "tray": {
    "icon-size": 16,
    "spacing": 8
  }
```

Note: `custom/mic` is referenced here but defined in Task 6; until then it produces no output (harmless).

- [ ] **Step 3: Validate JSONC parses**

Run: `python3 -c "import json,re; t=open('private_dot_config/waybar/config.jsonc').read(); t=re.sub(r'//[^\n]*','',t); json.loads(t); print('OK')"`
Expected: `OK`

- [ ] **Step 4: Apply and reload to verify**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 1; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: network, volume, battery, tray, clock visible on the right; no parse errors.

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/waybar/config.jsonc
git commit -m "[waybar] add network, volume, battery, tray modules"
```

---

## Task 3: Power module + wlogout themed menu

**Files:**
- Modify: `private_dot_config/waybar/config.jsonc`
- Create: `private_dot_config/wlogout/layout`
- Create: `private_dot_config/wlogout/style.css`

- [ ] **Step 1: Add the power module to `modules-left`**

Replace the `"modules-left"` line with:

```jsonc
  "modules-left": ["custom/power", "hyprland/workspaces", "custom/layout"],
```

- [ ] **Step 2: Add the `custom/power` definition**

Insert after the `group/status` block (comma-separated). The icon is the Arch Linux logo glyph (nf-linux-archlinux, U+F303):

```jsonc
  "custom/power": {
    "format": "",
    "tooltip": false,
    "on-click": "wlogout -p layer-shell"
  },
```

- [ ] **Step 3: Create the wlogout layout**

Create `private_dot_config/wlogout/layout`:

```
{ "label": "lock", "action": "hyprlock --immediate-render", "text": "Lock", "keybind": "l" }
{ "label": "logout", "action": "uwsm stop", "text": "Logout", "keybind": "e" }
{ "label": "suspend", "action": "systemctl suspend", "text": "Suspend", "keybind": "u" }
{ "label": "reboot", "action": "systemctl reboot", "text": "Reboot", "keybind": "r" }
{ "label": "shutdown", "action": "systemctl poweroff", "text": "Shutdown", "keybind": "s" }
```

- [ ] **Step 4: Create the wlogout theme**

Create `private_dot_config/wlogout/style.css`:

```css
* {
  font-family: "JetBrainsMono Nerd Font";
  background-image: none;
  transition: 20ms;
}

window {
  background-color: rgba(30, 30, 46, 0.9);
}

button {
  color: #cdd6f4;
  background-color: #313244;
  border-radius: 12px;
  border: 2px solid #45475a;
  margin: 8px;
  font-size: 16px;
}

button:focus, button:hover {
  background-color: #45475a;
  border-color: #89b4fa;
  color: #89b4fa;
}
```

- [ ] **Step 5: Validate and apply**

Run:
```bash
python3 -c "import json,re; t=open('private_dot_config/waybar/config.jsonc').read(); t=re.sub(r'//[^\n]*','',t); json.loads(t); print('OK')"
chezmoi apply --include=files ~/.config/waybar ~/.config/wlogout
killall -SIGUSR2 waybar; sleep 1
```
Expected: `OK`; Arch logo appears at far left.

- [ ] **Step 6: Verify the menu opens**

Run: `wlogout -p layer-shell &` then press Escape to dismiss.
Expected: themed lock/logout/suspend/reboot/shutdown menu appears.

- [ ] **Step 7: Commit**

```bash
git add private_dot_config/waybar/config.jsonc private_dot_config/wlogout/
git commit -m "[waybar] add arch power button with wlogout menu"
```

---

## Task 4: CPU script + module

**Files:**
- Create: `private_dot_config/waybar/scripts/executable_cpu.sh`
- Modify: `private_dot_config/waybar/config.jsonc`

- [ ] **Step 1: Write the CPU script**

Create `private_dot_config/waybar/scripts/executable_cpu.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

read_idle_total() {
  local cpu user nice system idle iowait irq softirq rest
  read -r cpu user nice system idle iowait irq softirq rest < /proc/stat
  echo "$idle $((user + nice + system + idle + iowait + irq + softirq))"
}

read -r idle1 total1 <<< "$(read_idle_total)"
sleep 0.4
read -r idle2 total2 <<< "$(read_idle_total)"

didle=$((idle2 - idle1))
dtotal=$((total2 - total1))
usage=0
if [ "$dtotal" -gt 0 ]; then
  usage=$(( (100 * (dtotal - didle)) / dtotal ))
fi

top_proc=$(ps -eo comm,pcpu --sort=-pcpu --no-headers | head -n1 | awk '{print $1}')

class="normal"
if [ "$usage" -ge 85 ]; then class="critical"
elif [ "$usage" -ge 60 ]; then class="warning"
fi

tooltip=$(ps -eo comm,pcpu --sort=-pcpu --no-headers | head -n5 \
  | awk '{printf "%s  %s%%\\n", $1, $2}')

printf '{"text":" %s%%  %s","tooltip":"%s","class":"%s"}\n' \
  "$usage" "$top_proc" "$tooltip" "$class"
```

- [ ] **Step 2: Lint and run the script**

Run:
```bash
shellcheck private_dot_config/waybar/scripts/executable_cpu.sh
bash private_dot_config/waybar/scripts/executable_cpu.sh | jq .
```
Expected: no shellcheck errors; valid JSON with `text`, `tooltip`, `class` keys.

- [ ] **Step 3: Add the module to config**

Change `modules-right` to put CPU first:

```jsonc
  "modules-right": ["custom/cpu", "group/status", "battery", "tray", "clock"],
```

Add the definition (comma-separated):

```jsonc
  "custom/cpu": {
    "return-type": "json",
    "interval": 3,
    "exec": "~/.config/waybar/scripts/cpu.sh",
    "tooltip": true
  },
```

- [ ] **Step 4: Apply and verify live**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 4; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: CPU %+process updates on the bar; hover shows top-5 tooltip.

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/waybar/scripts/executable_cpu.sh private_dot_config/waybar/config.jsonc
git commit -m "[waybar] add cpu usage module"
```

---

## Task 5: Arch updates script + module

**Files:**
- Create: `private_dot_config/waybar/scripts/executable_updates.sh`
- Modify: `private_dot_config/waybar/config.jsonc`

- [ ] **Step 1: Write the updates script**

Create `private_dot_config/waybar/scripts/executable_updates.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

command_exists() { command -v "$1" >/dev/null 2>&1; }

repo=""
aur=""
command_exists checkupdates && repo=$(checkupdates 2>/dev/null || true)
command_exists yay && aur=$(yay -Qua 2>/dev/null || true)

repo_n=$(printf '%s' "$repo" | grep -c . || true)
aur_n=$(printf '%s' "$aur" | grep -c . || true)
total=$((repo_n + aur_n))

class="none"
if   [ "$total" -ge 60 ]; then class="critical"
elif [ "$total" -ge 30 ]; then class="high"
elif [ "$total" -ge 10 ]; then class="medium"
elif [ "$total" -ge 1 ];  then class="low"
fi

if [ "$total" -eq 0 ]; then
  printf '{"text":" ","tooltip":"System up to date","class":"none"}\n'
  exit 0
fi

tooltip=$(printf '%s\n%s' "$repo" "$aur" | grep . | head -n40 \
  | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
printf '{"text":" %s","tooltip":"%s","class":"%s"}\n' "$total" "$tooltip" "$class"
```

- [ ] **Step 2: Lint and run**

Run:
```bash
shellcheck private_dot_config/waybar/scripts/executable_updates.sh
bash private_dot_config/waybar/scripts/executable_updates.sh | jq .
```
Expected: no shellcheck errors; valid JSON.

- [ ] **Step 3: Add the module to config**

Change `modules-right`:

```jsonc
  "modules-right": ["custom/cpu", "custom/updates", "group/status", "battery", "tray", "clock"],
```

Add the definition (the `on-click` ports ashell's update command):

```jsonc
  "custom/updates": {
    "return-type": "json",
    "interval": 1800,
    "exec": "~/.config/waybar/scripts/updates.sh",
    "tooltip": true,
    "on-click": "kitty --single-instance -e zsh -c 'yay; echo; read \"?Press ENTER to close window...\"'"
  },
```

- [ ] **Step 4: Apply and verify**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 2; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: update count (or checkmark) shows; tooltip lists packages; click opens a kitty update session.

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/waybar/scripts/executable_updates.sh private_dot_config/waybar/config.jsonc
git commit -m "[waybar] add arch updates module"
```

---

## Task 6: Mic-active script + module

**Files:**
- Create: `private_dot_config/waybar/scripts/executable_mic.sh`
- Modify: `private_dot_config/waybar/config.jsonc`

- [ ] **Step 1: Write the mic script**

Create `private_dot_config/waybar/scripts/executable_mic.sh`. Shows the mic only when an app is recording (mirrors SketchyBar's draw-when-active); red when muted.

```bash
#!/usr/bin/env bash
set -euo pipefail

in_use=$(pactl list source-outputs short 2>/dev/null | grep -vi monitor | grep -c . || true)

if [ "$in_use" -eq 0 ]; then
  printf '{"text":"","tooltip":""}\n'
  exit 0
fi

muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -c MUTED || true)
if [ "$muted" -ge 1 ]; then
  printf '{"text":"","tooltip":"Microphone muted (in use)","class":"muted"}\n'
else
  printf '{"text":"","tooltip":"Microphone active","class":"active"}\n'
fi
```

- [ ] **Step 2: Lint and run**

Run:
```bash
shellcheck private_dot_config/waybar/scripts/executable_mic.sh
bash private_dot_config/waybar/scripts/executable_mic.sh | jq .
```
Expected: no shellcheck errors; JSON with empty `text` when no app is recording.

- [ ] **Step 3: Add the module definition**

`custom/mic` is already listed inside `group/status` (Task 2). Add its definition (comma-separated):

```jsonc
  "custom/mic": {
    "return-type": "json",
    "interval": 3,
    "exec": "~/.config/waybar/scripts/mic.sh",
    "tooltip": true
  },
```

- [ ] **Step 4: Apply and verify**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 2; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: no mic icon when idle; starting a recording app (or `arecord -d 3 /dev/null`) makes the icon appear within ~3s.

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/waybar/scripts/executable_mic.sh private_dot_config/waybar/config.jsonc
git commit -m "[waybar] add mic-active indicator"
```

---

## Task 7: Layout toggle script + module

**Files:**
- Create: `private_dot_config/waybar/scripts/executable_layout.sh`
- Modify: `private_dot_config/waybar/config.jsonc`

- [ ] **Step 1: Write the layout script**

Create `private_dot_config/waybar/scripts/executable_layout.sh`. With no args it prints state; with `toggle` it switches dwindle⇄master.

```bash
#!/usr/bin/env bash
set -euo pipefail

current() { hyprctl getoption general:layout -j | jq -r '.str'; }

if [ "${1:-}" = "toggle" ]; then
  if [ "$(current)" = "dwindle" ]; then
    hyprctl keyword general:layout master >/dev/null
  else
    hyprctl keyword general:layout dwindle >/dev/null
  fi
  exit 0
fi

layout=$(current)
if [ "$layout" = "master" ]; then
  printf '{"text":" ","tooltip":"Layout: master","class":"master"}\n'
else
  printf '{"text":" ","tooltip":"Layout: dwindle","class":"dwindle"}\n'
fi
```

- [ ] **Step 2: Lint and run both modes**

Run:
```bash
shellcheck private_dot_config/waybar/scripts/executable_layout.sh
bash private_dot_config/waybar/scripts/executable_layout.sh | jq .
```
Expected: no shellcheck errors; JSON reflecting current layout.

- [ ] **Step 3: Add the module definition**

`custom/layout` is already in `modules-left` (Task 3). Add its definition (comma-separated):

```jsonc
  "custom/layout": {
    "return-type": "json",
    "interval": 5,
    "exec": "~/.config/waybar/scripts/layout.sh",
    "on-click": "~/.config/waybar/scripts/layout.sh toggle",
    "tooltip": true
  },
```

- [ ] **Step 4: Apply and verify toggle**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 2; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: layout icon shows; clicking it toggles dwindle/master (visible window rearrange) and the icon updates within ~5s.

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/waybar/scripts/executable_layout.sh private_dot_config/waybar/config.jsonc
git commit -m "[waybar] add hyprland layout toggle"
```

---

## Task 8: Workspaces with per-workspace app icons

**Files:**
- Modify: `private_dot_config/waybar/config.jsonc`

- [ ] **Step 1: Replace the bare `hyprland/workspaces` with an app-icon config**

Add this definition (comma-separated). `window-rewrite` maps window class → Nerd Font glyph; `format` renders the workspace id plus its window icons.

```jsonc
  "hyprland/workspaces": {
    "format": "{id} {windows}",
    "format-window-separator": " ",
    "window-rewrite-default": "",
    "window-rewrite": {
      "class<firefox>": "",
      "class<kitty>": "",
      "class<.*[Cc]ode.*>": "",
      "class<org.gnome.Nautilus>": "",
      "class<[Ss]potify>": "",
      "class<discord>": "",
      "class<.*[Ss]lack.*>": "",
      "class<zathura>": "",
      "title<.*[Yy]ou[Tt]ube.*>": ""
    },
    "on-click": "activate",
    "persistent-workspaces": {}
  },
```

- [ ] **Step 2: Validate JSONC parses**

Run: `python3 -c "import json,re; t=open('private_dot_config/waybar/config.jsonc').read(); t=re.sub(r'//[^\n]*','',t); json.loads(t); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Apply and verify icons appear per workspace**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 2; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: each occupied workspace shows its id followed by glyphs for the apps running in it; switching/opening apps updates the icons; clicking a workspace focuses it.

- [ ] **Step 4: Commit**

```bash
git add private_dot_config/waybar/config.jsonc
git commit -m "[waybar] show per-workspace app icons"
```

---

## Task 9: Full Catppuccin Mocha styling

**Files:**
- Modify: `private_dot_config/waybar/style.css`

- [ ] **Step 1: Replace `style.css` with the full theme**

Overwrite `private_dot_config/waybar/style.css`:

```css
/* Catppuccin Mocha */
@define-color base    #1e1e2e;
@define-color surface0 #313244;
@define-color surface1 #45475a;
@define-color surface2 #585b70;
@define-color text    #cdd6f4;
@define-color subtext #9399b2;
@define-color blue    #89b4fa;
@define-color sky     #89dceb;
@define-color green   #a6e3a1;
@define-color yellow  #f9e2af;
@define-color peach   #fab387;
@define-color red     #f38ba8;
@define-color mauve   #cba6f7;

* {
  font-family: "JetBrainsMono Nerd Font", sans-serif;
  font-size: 13px;
  font-weight: 600;
  min-height: 0;
}

window#waybar {
  background: transparent;
  color: @text;
}

/* Each module section is a rounded, bordered pill row */
.modules-left, .modules-center, .modules-right {
  background: @base;
  border: 2px solid alpha(@surface1, 0.6);
  border-radius: 10px;
  padding: 2px 8px;
}

/* Common module padding */
#custom-power, #custom-layout, #custom-cpu, #custom-updates,
#network, #custom-mic, #wireplumber, #battery, #clock, #window, #tray {
  padding: 0 8px;
  color: @text;
}

/* Arch power button */
#custom-power {
  color: @sky;
  font-size: 16px;
  padding-left: 10px;
}

/* Workspaces */
#workspaces button {
  color: @subtext;
  padding: 0 6px;
  border-radius: 8px;
}
#workspaces button.active {
  color: @text;
  background: alpha(@surface2, 0.4);
}
#workspaces button.urgent {
  color: @red;
}

/* Layout indicator */
#custom-layout.master { color: @yellow; }
#custom-layout.dwindle { color: @text; }

/* CPU thresholds */
#custom-cpu.warning  { color: @yellow; }
#custom-cpu.critical { color: @red; }

/* Updates thresholds (mirrors brew widget colors) */
#custom-updates.none     { color: @green; }
#custom-updates.low      { color: @text; }
#custom-updates.medium   { color: @yellow; }
#custom-updates.high     { color: @peach; }
#custom-updates.critical { color: @red; }

/* Status group: the rounded "bracket" background */
#status {
  background: alpha(@surface1, 0.38);
  border: 2px solid alpha(@surface1, 0.6);
  border-radius: 9px;
  padding: 0 4px;
  margin: 2px 0;
}

#custom-mic.active { color: @green; }
#custom-mic.muted  { color: @red; }

/* Battery states */
#battery.warning  { color: @peach; }
#battery.critical { color: @red; }
#battery.charging { color: @green; }

#clock { color: @text; padding-right: 10px; }
```

- [ ] **Step 2: Apply and verify the look**

Run:
```bash
chezmoi apply --include=files ~/.config/waybar
killall -SIGUSR2 waybar; sleep 2; grep -i error /tmp/waybar.log | tail || echo "no errors"
```
Expected: floating rounded bar; left/center/right pill rows; the status cluster (network/mic/volume) has its own bracket background; threshold colors apply to CPU/updates/battery; active workspace highlighted.

- [ ] **Step 3: Commit**

```bash
git add private_dot_config/waybar/style.css
git commit -m "[waybar] apply catppuccin mocha styling"
```

---

## Task 10: README for the waybar config

**Files:**
- Create: `private_dot_config/waybar/README.md`

- [ ] **Step 1: Write the README**

Create `private_dot_config/waybar/README.md` following the per-tool README pattern (see `sketchybar/README.md`):

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add private_dot_config/waybar/README.md
git commit -m "[waybar] add readme"
```

---

## Task 11: Switch Hyprland autostart to Waybar and remove ashell

**Files:**
- Modify: `private_dot_config/hypr/hyprland.lua:23`
- Modify: `.chezmoiignore.tmpl`
- Delete: `private_dot_config/ashell/`

- [ ] **Step 1: Switch the autostart line**

In `private_dot_config/hypr/hyprland.lua`, change line 23 from:

```lua
	hl.exec_cmd("uwsm app -- ashell")
```
to:
```lua
	hl.exec_cmd("uwsm app -- waybar")
```

- [ ] **Step 2: Update `.chezmoiignore.tmpl`**

In the Linux-only block (the `{{- if ne .chezmoi.os "linux" }}` branch), remove the `.config/ashell/` line and add (keeping alphabetical order):

```
.config/waybar/
.config/wlogout/
```

- [ ] **Step 3: Delete the ashell source**

Run: `git rm -r private_dot_config/ashell`
Expected: ashell config + README removed (recoverable via git history).

- [ ] **Step 4: Verify chezmoi state is clean**

Run:
```bash
chezmoi diff | head -40
chezmoi cat ~/.config/hypr/hyprland.lua | grep -n waybar
```
Expected: diff shows ashell removed / waybar present; the rendered hyprland config launches `waybar`.

- [ ] **Step 5: Commit**

```bash
git add private_dot_config/hypr/hyprland.lua .chezmoiignore.tmpl
git commit -m "[hypr] autostart waybar instead of ashell"
```

---

## Task 12: Update install.sh packages

**Files:**
- Modify: `install.sh:128-164`

- [ ] **Step 1: Add pacman packages**

In `install.sh`, in `PACMAN_PACKAGES` under the `# Desktop utilities` section, add:

```bash
  waybar
  wlogout
  pacman-contrib
```

- [ ] **Step 2: Remove ashell from AUR**

In `AUR_PACKAGES`, delete the `ashell` line.

- [ ] **Step 3: Lint**

Run: `shellcheck install.sh`
Expected: no new errors introduced (pre-existing warnings unchanged).

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "[install] add waybar/wlogout deps, drop ashell"
```

---

## Task 13: Update documentation references

**Files:**
- Modify: `private_dot_config/hypr/README.md`
- Modify: `private_dot_config/hypr/AGENTS.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update hypr docs**

In `private_dot_config/hypr/README.md` and `private_dot_config/hypr/AGENTS.md`, replace ashell references with Waybar:
- README line ~51: `**ashell** -- status bar / system panel` → `**waybar** -- status bar`
- AGENTS line ~37: autostart example `(ashell, walker, kitty)` → `(waybar, walker, kitty)`
- AGENTS line ~48: `Hyprland → Ashell (status bar) → Walker` → `Hyprland → Waybar (status bar) → Walker`

- [ ] **Step 2: Update root `CLAUDE.md`**

- Structure tree: change the `ashell/` line to `waybar/` (status bar for Hyprland) and add a `wlogout/` entry; update the line description from "Ashell status bar (TOML config)" to "Waybar status bar (JSONC + CSS)".
- Cross-Tool Dependencies block: `Hyprland → Ashell → Walker` → `Hyprland → Waybar → Walker`.
- "Where to Look" / config-format table: change Ashell/TOML row to Waybar (JSONC config + GTK CSS, custom scripts in `scripts/`).

- [ ] **Step 3: Verify no stale ashell references remain**

Run: `grep -rni ashell . --exclude-dir=.git || echo "clean"`
Expected: `clean` (or only the spec/plan docs under `docs/superpowers/`, which describe the migration).

- [ ] **Step 4: Commit**

```bash
git add private_dot_config/hypr/README.md private_dot_config/hypr/AGENTS.md CLAUDE.md
git commit -m "[hypr] document waybar replacing ashell"
```

---

## Task 14: Final end-to-end verification

**Files:** none (verification only)

- [ ] **Step 1: Full apply**

Run: `chezmoi apply`
Expected: completes without error; `~/.config/waybar/`, `~/.config/wlogout/` populated; `~/.config/ashell/` removed.

- [ ] **Step 2: Confirm scripts are executable after apply**

Run: `ls -l ~/.config/waybar/scripts/`
Expected: `cpu.sh`, `updates.sh`, `mic.sh`, `layout.sh` all have the executable bit (chezmoi `executable_` prefix applied).

- [ ] **Step 3: Cold-start Waybar**

Run:
```bash
killall waybar 2>/dev/null; waybar >/tmp/waybar.log 2>&1 &
sleep 4; grep -iE "error|critical" /tmp/waybar.log || echo "clean start"
```
Expected: `clean start`; every module renders.

- [ ] **Step 4: Smoke-test interactions**

Manually confirm: Arch logo opens wlogout; workspace click focuses; layout click toggles; updates click opens kitty; volume scroll adjusts; network click opens connection editor.

- [ ] **Step 5: Confirm autostart on a fresh session (optional)**

Log out and back in (or `uwsm stop` then restart session): Waybar launches automatically, ashell does not.

---

## Self-Review Notes

- **Spec coverage:** bar appearance (T1, T9), power/Arch logo+wlogout (T3), workspaces+app icons (T8), layout toggle (T7), window center (T1), CPU (T4), updates (T5), status group network/mic/volume (T2, T6, T9), battery/tray/clock (T2, T1), styling (T9), README (T10), integration—autostart/ignore/ashell delete (T11), install.sh (T12), docs (T13), e2e (T14). All spec sections mapped.
- **Caveats honored:** volume is `wireplumber` (scroll/click, no drag slider); CPU is text %+process; no zen mode; GitHub bell omitted (structure leaves room); app icons via window-rewrite; window module title only.
- **Type/name consistency:** script applied paths (`~/.config/waybar/scripts/<name>.sh`) match `exec`/`on-click` references; CSS classes (`warning`/`critical`/`none`/`low`/`medium`/`high`/`master`/`dwindle`/`active`/`muted`) match the `class` values emitted by each script.
