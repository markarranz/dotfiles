# Zsh

[Zsh](https://www.zsh.org/) is a powerful Unix shell with advanced tab completion, globbing, and scripting capabilities. This configuration uses the [Oh My Zsh](https://ohmyz.sh/) framework for plugins, aliases, and shell enhancements.

## Prerequisites

- [Zsh](https://www.zsh.org/)
- [Starship](https://starship.rs/) prompt
- [fzf](https://github.com/junegunn/fzf) for fuzzy finding and history search
- [zoxide](https://github.com/ajeetdsouza/zoxide) for smart directory jumping
- [eza](https://github.com/eza-community/eza) (aliased as `ls` via OMZ plugin)
- [bat](https://github.com/sharkdp/bat) (used by fzf previews)
- [direnv](https://direnv.net/) for per-directory environment variables

Oh My Zsh itself is downloaded automatically by chezmoi (see `.chezmoiexternal.toml`) into `~/.config/omz/ohmyzsh/`. No manual OMZ install is needed.

## Overview

`ZDOTDIR` is set to `~/.config/omz` (in `dot_zshenv.tmpl` at the repo root), so Zsh reads its dotfiles from there. The entry point `~/.zshenv` also sets up XDG base directories, the default editor (Neovim), and history settings.

### File Layout

| File | Purpose |
|------|---------|
| `dot_zshrc` | Main shell config: sets `$ZSH`, loads plugins, sources OMZ, configures fzf history and completion fallback |
| `dot_zprofile.tmpl` | Login shell profile: auto-starts Hyprland (Linux) or initializes Homebrew (macOS) |
| `custom/exports.zsh.tmpl` | Environment variables and tool initialization (Rust, Go, Node, Python, Starship, zsh-vi-mode) |
| `custom/aliases.zsh.tmpl` | Shell aliases (`s` -> kitten ssh, `chm` -> chezmoi, `kdiff` -> git difftool) |
| `custom/functions.zsh` | Custom functions (e.g. SketchyBar brew wrapper) |

### How OMZ is Loaded

1. `$ZSH` points to `$ZDOTDIR/ohmyzsh` (the chezmoi-managed OMZ install)
2. `$ZSH_CUSTOM` points to `$ZDOTDIR/custom` (where exports, aliases, and functions live)
3. The `plugins` array declares all active plugins
4. `source $ZSH/oh-my-zsh.sh` activates everything
5. OMZ auto-updates are disabled (`zstyle ':omz:update' mode disabled`) since chezmoi manages the install

## Plugins

All plugins are declared in the `plugins` array in `.zshrc`:

| Plugin | Description |
|--------|-------------|
| [aliases](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases) | Alias listing and search |
| [alias-finder](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/alias-finder) | Suggests existing aliases for commands you type |
| [brew](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew) | Homebrew completions and aliases |
| [chezmoi](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/chezmoi) | Chezmoi completions |
| [direnv](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/direnv) | Automatic environment loading per directory |
| [docker](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker) | Docker completions and aliases |
| [eza](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/eza) | `ls` replacement with icons and git status |
| [fzf](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf) | Fuzzy finder integration |
| [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git) | Git aliases and completions |
| [starship](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/starship) | Starship prompt initialization |
| [zoxide](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/zoxide) | Smart directory jumping |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Inline command suggestions based on history |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Real-time syntax coloring as you type |

[zsh-completions](https://github.com/zsh-users/zsh-completions) is also installed (via chezmoi external) and loaded via `fpath` before `compinit`.

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `s` | `kitten ssh` | SSH via Kitty's kitten for proper terminal rendering |
| `chm` | `chezmoi` | Shorthand for the dotfile manager |
| `kdiff` | `git difftool --no-symlinks --dir-diff` | Git diff via Kitty's diff kitten |

Plus all aliases provided by the `git`, `docker`, `brew`, and `eza` OMZ plugins.

## Adding Plugins

**For built-in OMZ plugins:** Add the plugin name to the `plugins` array in `.zshrc`.

**For third-party plugins:** Add the plugin name to the `plugins` array in `.zshrc` **and** add a download entry in [`.chezmoiexternal.toml`](../../.chezmoiexternal.toml.tmpl) to place it in `~/.config/omz/custom/plugins/`.
