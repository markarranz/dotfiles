# AGENTS.md - Development Guidelines for This Repository

This is a **chezmoi-managed dotfiles repository**. It contains configuration files for development tools (Neovim, Zsh, Git, tmux, etc.) and desktop environments (Hyprland, yabai, SketchyBar).

## Table of Contents
1. [Repository Overview](#repository-overview)
2. [Build/Lint/Test Commands](#buildlinttest-commands)
3. [Code Style Guidelines](#code-style-guidelines)
   - [Git Commit Messages](#git-commit-messages)
4. [Template Conventions](#template-conventions)
5. [Tool-Specific Guidelines](#tool-specific-guidelines)

---

## Repository Overview

- **Manager**: [chezmoi](https://www.chezmoi.io/) — dotfile manager using Go templates
- **Platforms**: macOS and Linux (Arch-based)
- **Structure**:
  - `dot_*` files → map to `~/.*` (e.g., `dot_gitconfig.tmpl` → `~/.gitconfig`)
  - `private_dot_*` files → map to `~/.*` (private, not in git)
  - `private_dot_config/*` → map to `~/.config/*`
  - `.tmpl` suffix → Go template files with conditional logic

---

## Build/Lint/Test Commands

### Chezmoi Operations

```bash
# Apply dotfiles (dry run)
chezmoi diff

# Apply dotfiles (for real)
chezmoi apply

# Edit a dotfile source
chezmoi edit ~/.gitconfig

# Add a new file to chezmoi
chezmoi add ~/.somefile

# Check template syntax
chezmoi data  # Shows rendered template data
```

### Shell Script Linting

This repo uses shell scripts for installation and hooks. Install [shellcheck](https://www.shellcheck.net/):

```bash
# macOS
brew install shellcheck

# Arch Linux
sudo pacman -S shellcheck

# Run linting on a shell script
shellcheck install.sh
shellcheck dot_claude/modify_settings.json
```

### Single Test (Template Rendering)

To test a specific template file renders correctly:

```bash
# Render a specific template and see the output
chezmoi cat ~/.gitconfig

# Or check the source template
chezmoi cat-config templates.dot_gitconfig
```

### Neovim (LazyVim) Plugin Sync

```bash
# Inside Neovim
:Lazy  # Opens LazyVim plugin manager
:Lazy sync  # Sync all plugins
```

### Tmux Plugin Installation

```bash
# Inside tmux: press prefix + I (Ctrl+Space then I)
```

---

## Code Style Guidelines

### Git Commit Messages

Format: `[<scope>] <description>`

Examples:
- `[ashell] fix updates widget to run yay in kitty properly`
- `[neovim] add golangci-lint fix for go.work workspaces`
- `[sketchybar] auto-update app font icon map via chezmoi external`

Rules:
- Use lowercase for scope and description
- Use imperative mood ("add" not "added")
- Keep subject line under 72 characters
- Multi-agent beneficial changes start with `[ai]` (e.g., AGENTS.md updates)

---

### General Principles

1. **No comments unless required** — Avoid adding explanatory comments; code should be self-documenting
2. **Use meaningful names** — Variables and functions should have descriptive names
3. **Keep files focused** — Each file should have a single purpose
4. **Platform-agnostic by default** — Use chezmoi templates for platform-specific logic

### Shell Script Conventions

Follow these conventions for shell scripts (e.g., `install.sh`, hooks):

```bash
#!/usr/bin/env bash
set -euo pipefail  # Always use strict mode

# Function naming: lowercase with underscores
function setup_common() { ... }

# Local variables: prefix with local
local current_shell
current_shell="$(basename "$SHELL")"

# Colors: use for user-facing output only
RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Helper functions for output
info()    { printf "${BLUE}::${RESET} %s\n" "$*"; }
success() { printf "${GREEN}::${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}:: %s${RESET}\n" "$*"; }
error()   { printf "${RED}:: %s${RESET}\n" "$*" >&2; }
```

**Error handling**:
- Always use `set -euo pipefail`
- Check command exit status explicitly when needed: `command || error "Failed"`
- Use `command_exists()` helper before running commands

**Quotes**:
- Always quote variables: `"$var"` not `$var`
- Use single quotes for literal strings

### Go Template Conventions

Templates use [chezmoi templating](https://www.chezmoi.io/reference/templates/):

```tmpl
{{- $chassisType := "desktop" }}
{{- if eq .chezmoi.os "darwin" }}
{{-   if contains "MacBook" (output "sysctl" "-n" "hw.model") }}
{{-     $chassisType = "laptop" }}
{{-   end }}
{{- end }}

[data]
chassisType = {{ $chassisType | quote }}
```

**Rules**:
- Use `{{-` to strip leading whitespace (preferred)
- Use `-}}` to strip trailing whitespace
- Access chezmoi variables via `.chezmoi.*`
- Access custom data via `..*`
- Use `env "VAR_NAME"` to read environment variables
- Use `output "cmd" "arg1" "arg2"` for command output

### Lua Conventions

Used in Neovim (LazyVim) and SketchyBar:

```lua
-- Use snake_case for variables and functions
local function setup_statusline()
  local status = require("status")
end

-- Prefer explicit returns
local M = {}
M.setup = function()
  -- setup code
end
return M
```

### YAML Conventions

Used in lazygit, yazi, kitty:

```yaml
# Use 2-space indentation
key: value

# Arrays use inline format for short lists
plugins:
  - tmux
  - git

# Use comments sparingly to explain non-obvious config
```

### TOML Conventions

Used in starship, ashell, bat:

```toml
# Use = with spaces around it
key = "value"

# Tables for grouping
[table]
key = "value"

# Inline tables for short configs
plugins = ["git", "tmux"]
```

---

## Template Conventions

### File Naming

| Source File | Target File |
|-------------|-------------|
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_zshenv.tmpl` | `~/.zshenv` |
| `private_dot_config/nvim/` | `~/.config/nvim/` |
| `.chezmoi.toml.tmpl` | `.chezmoi.toml` |

### Conditional Logic

```tmpl
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific config
{{- end }}
```

### Hostname-Based Configuration

```tmpl
{{- if eq .chezmoi.hostname "work-machine" }}
# Work-specific settings
{{- end }}
```

---

## Tool-Specific Guidelines

### Neovim (LazyVim)

- Modify via `private_dot_config/nvim/`
- Use Lua in `lua/plugins/` for custom plugins
- See `externally_modified/nvim/` for manually tracked overrides

### Git Configuration

- Template in `dot_gitconfig.tmpl`
- Use conditional includes for different identities
- Delta as pager: `git config --global core.pager delta`

### Terminal (Kitty)

- Config in `private_dot_config/kitty/`
- Uses `kitty.conf` syntax
- Fonts: JetBrains Mono NL Nerd Font

### Desktop Environments

**macOS**: yabai, skhd, SketchyBar, Karabiner-Elements, JankyBorders
**Linux**: Hyprland, ashell, rofi, kanata, qt6ct

---

## Common Tasks

### Adding a New Dotfile

```bash
# Add existing file to chezmoi
chezmoi add ~/.newconfig

# Create from scratch
touch ~/.config/newtool/config.toml
chezmoi add ~/.config/newtool/config.toml
```

### Updating External Dependencies

Edit `.chezmoiexternal.toml.tmpl` to change versioned external files.

### Testing Changes

```bash
# Preview changes
chezmoi diff

# Apply and verify
chezmoi apply
```
