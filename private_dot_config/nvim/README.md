# Neovim

[Neovim](https://neovim.io/) is a modern, extensible terminal-based text editor forked from Vim. This configuration uses the [LazyVim](https://www.lazyvim.org/) distribution as a base, providing a batteries-included IDE experience with LSP support, syntax highlighting via Tree-sitter, fuzzy finding, and more.

## Prerequisites

- [Neovim](https://neovim.io/) >= 0.10
- [lazy.nvim](https://github.com/folke/lazy.nvim) (installed automatically by LazyVim on first launch)
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- [ripgrep](https://github.com/BurntSushi/ripgrep) for live grep / search
- Language servers, formatters, and linters are managed by [mason.nvim](https://github.com/williamboman/mason.nvim) (bundled with LazyVim)

## Overview

The core LazyVim configuration lives in the `externally_modified/nvim/` directory and is symlinked in via chezmoi templates. Custom overrides are layered on top:

| Path | Purpose |
|------|---------|
| `lua/config/options.lua` | Editor options, filetype detection, LSP/formatter choices |
| `lua/config/keymaps.lua` | Custom key mappings (smart-splits integration) |
| `lua/config/autocmds.lua` | Autocommands (e.g. Go template completion) |
| `lua/plugins/` | Plugin specs that override or extend LazyVim defaults |
| `after/ftplugin/` | Per-language settings (indentation, textwidth) |

## Key Customizations

- **Colorscheme:** [Catppuccin](https://github.com/catppuccin/nvim) Mocha with dimmed inactive windows
- **Kitty integration:** [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) for seamless pane navigation between Neovim and Kitty (`Ctrl+h/j/k/l`), and [kitty-scrollback.nvim](https://github.com/mikesmithgh/kitty-scrollback.nvim) for browsing terminal scrollback in Neovim
- **Language support:** Custom filetype detection for Hyprland configs, Go templates, and Rofi themes
- **Python:** [basedpyright](https://github.com/DetachHead/basedpyright) LSP, [ruff](https://github.com/astral-sh/ruff) formatter, textwidth of 88
- **Rust:** [bacon-ls](https://github.com/crisidev/bacon-ls) for background compilation diagnostics
- **Bufferline:** Underline indicator, slant separators

## Per-Language Settings

| Language | textwidth | Indent |
|----------|-----------|--------|
| Python | 88 | 4 spaces |
| Go | 100 | 4 spaces (tabs) |
| C# | -- | 4 spaces |
| SQL | -- | 4 spaces |
| Rust | -- | (default, single-quote mini.pairs disabled) |
