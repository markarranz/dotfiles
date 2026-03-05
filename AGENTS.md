# AGENTS.md - Development Guidelines for This Repository

Chezmoi-managed dotfiles for macOS and Linux (Arch). Dev tools (Neovim, Zsh, Git, tmux, Kitty, Starship) + desktop environments (Hyprland on Linux, yabai/SketchyBar on macOS). Catppuccin Mocha theme throughout.

## Table of Contents
1. [Structure](#structure)
2. [Where to Look](#where-to-look)
3. [Commands](#commands)
4. [Conventions](#conventions)
5. [Template System](#template-system)
6. [Anti-Patterns](#anti-patterns)
7. [Cross-Tool Dependencies](#cross-tool-dependencies)
8. [Notes & Gotchas](#notes--gotchas)

---

## Structure

```
.
├── .chezmoi.toml.tmpl          # Platform detection (OS, chassis, hostname, work flag)
├── .chezmoiexternal.toml.tmpl  # External deps (Catppuccin themes, zsh/tmux plugins)
├── .chezmoiignore.tmpl         # OS-conditional file exclusion
├── install.sh                  # Cross-platform installer (Homebrew / pacman+yay)
├── install-devcontainer.sh     # Devcontainer bootstrap script
├── dot_zshenv.tmpl             # Zsh entry point (XDG dirs, EDITOR, HISTFILE)
├── dot_claude/                 # Claude Code IDE settings
├── dot_claude/                 # Claude Code IDE settings
├── dot_tuple/                  # Tuple.app triggers and tracked-room scripts
├── .chezmoiscripts/            # chezmoi run scripts (run_once, run_onchange)
├── private_dot_config/
│   ├── nvim/                   # Neovim (LazyVim) — see nvim/README.md
│   ├── sketchybar/             # [macOS] SketchyBar Lua bar — see sketchybar/README.md
│   ├── kitty/                  # Kitty terminal (Python kittens for navigation/resize)
│   ├── hypr/                   # [Linux] Hyprland + hyprlock/hypridle/hyprpaper/hyprsunset
│   ├── zsh/                    # Zsh config (aliases, exports, functions, plugins)
│   ├── tmux/                   # Tmux (Ctrl+Space prefix, vim-style, TPM, Catppuccin)
│   ├── starship/               # Starship prompt (Catppuccin Mocha, 60+ language symbols)
│   ├── yabai/                  # [macOS] yabai tiling WM
│   ├── skhd/                   # [macOS] skhd hotkey daemon
│   ├── kanata/                 # [Linux] Kanata keyboard remapper (home-row mods)
│   ├── ashell/                 # [Linux] Ashell status bar (TOML config)
│   ├── borders/                # [macOS] JankyBorders (pink→sky gradient)
│   ├── private_karabiner/      # [macOS] Karabiner-Elements (symlink to externally_modified)
│   ├── git/                    # Git config, ignore, helper scripts
│   ├── opencode/               # OpenCode local settings
│   └── {bat,delta,lazygit,yazi,zathura,qt6ct,uwsm,systemd}/
└── externally_modified/        # Git-tracked, NOT chezmoi-managed (symlinked in)
    ├── nvim/                   # LazyVim base distribution
    └── karabiner/              # Karabiner-Elements JSON (49k lines)
```

---

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Add new dotfile | `chezmoi add ~/.newconfig` | Creates in chezmoi source dir |
| Platform-specific logic | `.tmpl` files | Use Go template conditionals |
| Add/update external dep | `.chezmoiexternal.toml.tmpl` | Themes: 672h refresh, plugins: 168h |
| Exclude file per-OS | `.chezmoiignore.tmpl` | Conditional ignore blocks |
| Add Neovim plugin | `externally_modified/nvim/lua/plugins/` | Use `private_dot_config/nvim/lua/plugins/` for chezmoi-managed overrides |
| Per-language editor settings | `private_dot_config/nvim/after/ftplugin/` | Vim script or Lua |
| LSP server config | `private_dot_config/nvim/after/lsp/` | Lua files |
| Add shell alias | `private_dot_config/zsh/aliases.zsh.tmpl` | OS-conditional sections |
| Add shell function | `private_dot_config/zsh/functions.zsh` | Static (no template) |
| PATH/exports | `private_dot_config/zsh/exports.zsh.tmpl` | OS + work conditionals |
| Add git helper script | `private_dot_config/git/scripts/` | Shell scripts used by git tooling |
| OpenCode settings | `private_dot_config/opencode/` | JSON config files |
| Kitty keybinding | `private_dot_config/kitty/kitty.conf` | Python kittens for complex behavior |
| Hyprland keybinding | `private_dot_config/hypr/hyprland.conf` | Static config |
| Hyprland hardware config | `private_dot_config/hypr/hardware.conf.tmpl` | Chassis-type conditional |
| macOS hotkey | `private_dot_config/skhd/skhdrc.tmpl` | Template for work/personal |
| SketchyBar widget | `private_dot_config/sketchybar/items/widgets/` | Lua scripts |
| Tmux config | `private_dot_config/tmux/tmux.conf` | Static (no template) |
│ Git identity switching │ `private_dot_config/git/config.tmpl` │ Conditional includes by directory │
| Manually tracked config | `externally_modified/` | Symlinked via `symlink_*.tmpl` |

---

## Commands

```bash
chezmoi diff                    # Preview changes (dry run)
chezmoi apply                   # Apply dotfiles
chezmoi cat ~/.config/git/config # Render template to stdout
chezmoi data                    # Show template variables
chezmoi add ~/.newconfig        # Add file to chezmoi
shellcheck script.sh            # Lint shell scripts
```

---

## Conventions

### Git Commits
Format: `[<scope>] <description>` — lowercase, imperative, <72 chars.
AI changes: `[ai] description`.

### Shell Scripts
- `set -euo pipefail` always
- Quote all variables: `"$var"`
- `command_exists()` check before running tools
- Helper functions: `info()`, `success()`, `warn()`, `error()`

### Go Templates
- `{{-` / `-}}` for whitespace control (always use dash form)
- `.chezmoi.os`, `.chezmoi.hostname` for platform detection
- `.chassisType`, `.forWork`, `.forDevcontainer` for custom data
- `output "cmd" "args"` for command execution, `env "VAR"` for env vars

### Lua (Neovim + SketchyBar)
- `snake_case` for variables/functions
- Explicit `return M` module pattern
- No comments unless non-obvious

### Config Formats by Tool
| Format | Tools |
|--------|-------|
| Lua | Neovim, SketchyBar |
| TOML | Starship, ashell, bat |
| YAML | lazygit, yazi |
| Shell | yabai, skhd, borders, tmux |
| Python | Kitty kittens |
| RASI | Rofi |
| KBD | Kanata |
| Hyprlang | Hyprland |
| JSON | Karabiner |

---

## Template System

### Variables (from `.chezmoi.toml.tmpl`)
| Variable | Values | Used In |
|----------|--------|---------|
| `.chezmoi.os` | `"darwin"`, `"linux"` | Most `.tmpl` files |
| `.chezmoi.hostname` | Machine hostname | Git config (`"digdug"` = work) |
| `.chassisType` | `"laptop"`, `"desktop"` | Hyprland hardware, hyprlock |
| `.forWork` | Boolean | Zsh (NVM), Kitty, Git, Neovim |
| `.forDevcontainer` | Boolean | Zsh, chezmoiignore |

### File Naming
| Prefix/Suffix | Meaning |
|---------------|---------|
| `dot_*` | Maps to `~/.*` |
| `private_dot_*` | Private file (restricted perms) |
| `*.tmpl` | Go template (processed by chezmoi) |
| `executable_*` | Marked executable |
| `symlink_*` | Creates symlink |
| `exact_*` | Exact directory (deletes unmanaged files) |
| `run_once_*` | Runs once when first applied |
| `run_onchange_*` | Runs when source changes |

---

## Anti-Patterns

- **No comments unless required** — code should be self-documenting
- **No hardcoded paths** — use chezmoi variables and XDG conventions
- **No platform logic outside templates** — use `.tmpl` files for OS conditionals
- **No multi-purpose files** — each file has a single focus
- **No unquoted shell variables** — always `"$var"`
- **Keep files focused** — one tool/concern per config file

---

## Cross-Tool Dependencies

```
Kitty ↔ Neovim ↔ Tmux     Ctrl+hjkl seamless navigation (navigate.lua/navigate.py)
Zsh → SketchyBar           brew() wrapper triggers bar update (macOS)
yabai → SketchyBar          42px top padding reserved; workspace state queries
skhd → yabai                Hotkeys send yabai commands
Hyprland → Ashell → Walker  Status bar + app launcher (Unix socket)
Kanata → Hyprland           OS-level key remap before compositor sees keys
Karabiner → skhd            OS-level key remap before hotkey daemon
```

---

## Notes & Gotchas

- **externally_modified/**: LazyVim core and Karabiner JSON are git-tracked but NOT chezmoi-managed. Edit there directly, symlinked via `symlink_*.tmpl`.
- **Zsh config**: `zsh/` is the active setup and uses manually sourced plugins from `~/.config/zsh/plugins/`.
- **Home-row mods on both platforms**: Kanata (Linux) + Karabiner (macOS). Same layout: a/;=Ctrl, s/l=Alt, d/k=Meta, f/j=Shift.
- **Catppuccin variants**: Mocha (most tools), Macchiato (tmux), Frappe (qt6ct).
- **yabai SIP**: Scripting addition requires partial SIP disable on macOS. Cannot be automated.
- **TPM first-time setup**: Press `prefix + I` inside tmux if plugins not auto-installed.
- **Hostname "digdug"**: Triggers work-mode (`.forWork = true`). Affects Git identity, NVM source, Neovim plugins, skhd browser choice.
- **`exact_*` directories**: bat/exact_themes, delta/exact_themes, tmux/exact_plugins, zsh/exact_plugins, qt6ct/exact_colors — chezmoi deletes any files not in source.
- **run_onchange_after_bat-cache.sh**: Auto-rebuilds bat theme cache after apply.
