# Zsh (Zap)

[Zsh](https://www.zsh.org/) is a powerful Unix shell with advanced tab completion, globbing, and scripting capabilities. This is the [Zap](https://github.com/zap-zsh/zap)-based configuration -- a lightweight alternative to the [Oh My Zsh](https://ohmyz.sh/) setup in the `omz/` directory.

Switch to this config by setting `ZDOTDIR` to `~/.config/zsh` in `~/.zshenv`.

## Prerequisites

- [Zsh](https://www.zsh.org/)
- [Zap](https://github.com/zap-zsh/zap) plugin manager
- [Starship](https://starship.rs/) prompt
- [fzf](https://github.com/junegunn/fzf) for fuzzy finding
- [zoxide](https://github.com/ajeetdsouza/zoxide) for smart directory jumping
- [eza](https://github.com/eza-community/eza) (aliased as `ls`)
- [bat](https://github.com/sharkdp/bat) (used by fzf previews)

### Install Zap

```sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

## Overview

Zsh configuration is split across several files, loaded in order by `.zshrc` via Zap's `plug` command:

| File | Purpose |
|------|---------|
| `prompt.zsh` | Initializes the Starship shell prompt |
| `exports.zsh.tmpl` | Environment variables and tool initialization (Rust, Go, Node, Python, fzf, zoxide) |
| `plugins.zsh.tmpl` | Oh My Zsh plugin loader (uses `plug` to source individual OMZ plugins) |
| `aliases.zsh.tmpl` | Shell aliases (`ls` -> eza, `cd` -> zoxide, git helpers, etc.) |

## Plugins

Loaded via Zap:

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -- inline command suggestions based on history
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) -- real-time syntax coloring as you type
- [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) -- Vi/Vim keybindings in the shell
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) -- replaces the default tab completion menu with fzf
- [zap-zsh/supercharge](https://github.com/zap-zsh/supercharge) -- sensible Zsh defaults
- [zap-zsh/exa](https://github.com/zap-zsh/exa) -- eza/exa integration

Oh My Zsh plugins (loaded individually via `plug`): `aliases`, `direnv`, `docker`, `git`, `rust`, and `brew` (macOS only).

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Modern `ls` with icons and git status |
| `cd` | `zoxide` | Smart directory jumping |
| `s` | `kitten ssh` | SSH via Kitty's kitten for proper rendering |
| `cz` | `chezmoi` | Shorthand for the dotfile manager |
| `gfpr` | `find ... git fetch --prune` | Git fetch prune all subdirectories |
| `glr` | `find ... git pull` | Git pull all subdirectories |

## Adding OMZ Plugins

To add an Oh My Zsh plugin to this config:

1. Add the plugin name to the `OMZ_PLUGINS` array in [`plugins.zsh`](./plugins.zsh.tmpl)
2. Add the plugin name to the `includes` array in [`.chezmoiexternal.toml`](../../.chezmoiexternal.toml.tmpl)
