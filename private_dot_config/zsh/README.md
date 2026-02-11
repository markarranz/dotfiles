# Zsh

[Zsh](https://www.zsh.org/) is a powerful Unix shell with advanced tab completion, globbing, and scripting capabilities. This configuration uses the [Zap](https://github.com/zap-zsh/zap) minimal plugin manager and loads plugins from [Oh My Zsh](https://ohmyz.sh/).

## Prerequisites

- [Zsh](https://www.zsh.org/)
- [Zap](https://github.com/zap-zsh/zap) plugin manager
- [Starship](https://starship.rs/) prompt
- [fzf](https://github.com/junegunn/fzf) for fuzzy finding
- [zoxide](https://github.com/ajeetdsouza/zoxide) for smart directory jumping
- [eza](https://github.com/eza-community/eza) (aliased as `ls`)
- [bat](https://github.com/sharkdp/bat) (used by fzf previews)

## Setup

### Install Zap

```sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

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

Loaded via Zap:

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -- inline command suggestions based on history
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) -- real-time syntax coloring as you type
- [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) -- Vi/Vim keybindings in the shell
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) -- replaces the default tab completion menu with fzf
- [zap-zsh/supercharge](https://github.com/zap-zsh/supercharge) -- sensible Zsh defaults
- [zap-zsh/exa](https://github.com/zap-zsh/exa) -- eza/exa integration

Oh My Zsh plugins (loaded from a downloaded archive): `aliases`, `direnv`, `docker`, `git`, `rust`, and `brew` (macOS only).

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Modern `ls` with icons and git status |
| `cd` | `zoxide` | Smart directory jumping |
| `s` | `kitten ssh` | SSH via Kitty's kitten for proper rendering |
| `cz` | `chezmoi` | Shorthand for the dotfile manager |

## OMZ Plugin Support

To add oh-my-zsh plugins:

1. Add the plugin name to the `OMZ_PLUGINS` array in [`plugins.zsh`](./plugins.zsh)
2. Add the plugin name to the `includes` array in [`.chezmoiexternal.toml`](../../.chezmoiexternal.toml.tmpl)
