# Zsh

[Zsh](https://www.zsh.org/) is a powerful Unix shell with advanced tab completion, globbing, and scripting capabilities. This configuration uses the [Oh My Zsh](https://ohmyz.sh/) framework for plugins, aliases, and shell enhancements.

## Prerequisites

- [Zsh](https://www.zsh.org/)
- [Starship](https://starship.rs/) prompt
- [fzf](https://github.com/junegunn/fzf) for fuzzy finding
- [zoxide](https://github.com/ajeetdsouza/zoxide) for smart directory jumping
- [eza](https://github.com/eza-community/eza) (aliased as `ls`)
- [bat](https://github.com/sharkdp/bat) (used by fzf previews)

Oh My Zsh itself is downloaded automatically by chezmoi (see `.chezmoiexternal.toml`) into `~/.config/omz/`, which is set as `ZDOTDIR`.

## Overview

Zsh configuration is split across several files, loaded in this order by `.zshrc`:

| File | Purpose |
|------|---------|
| `prompt.zsh` | Initializes the Starship shell prompt |
| `exports.zsh.tmpl` | Environment variables and tool initialization (Rust, Go, Node, Python, fzf, zoxide) |
| `plugins.zsh.tmpl` | Oh My Zsh plugin loader |
| `aliases.zsh.tmpl` | Shell aliases (`ls` -> eza, `cd` -> zoxide, git helpers, etc.) |

The entry point `~/.zshenv` (managed by `dot_zshenv.tmpl` at the repo root) sets up XDG base directories, the default editor (Neovim), and history settings.

## Plugins

Oh My Zsh plugins (managed by chezmoi): `aliases`, `direnv`, `docker`, `git`, `rust`, and `brew` (macOS only).

Additional plugins:

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -- inline command suggestions based on history
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) -- real-time syntax coloring as you type
- [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) -- Vi/Vim keybindings in the shell
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) -- replaces the default tab completion menu with fzf

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Modern `ls` with icons and git status |
| `cd` | `zoxide` | Smart directory jumping |
| `s` | `kitten ssh` | SSH via Kitty's kitten for proper rendering |
| `cz` | `chezmoi` | Shorthand for the dotfile manager |

## Adding OMZ Plugins

To add a new Oh My Zsh plugin:

1. Add the plugin name to the `OMZ_PLUGINS` array in [`plugins.zsh`](./plugins.zsh)
2. Add the plugin name to the `includes` array in [`.chezmoiexternal.toml`](../../.chezmoiexternal.toml.tmpl)
