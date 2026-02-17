# Kitty

[Kitty](https://sw.kovidgoyal.net/kitty/) is a GPU-accelerated terminal emulator that supports ligatures, image rendering, and tiling layouts natively. It's fast, highly configurable, and integrates well with Neovim.

## Prerequisites

- [Kitty](https://sw.kovidgoyal.net/kitty/binary/)
- [JetBrains Mono NL Nerd Font](https://www.nerdfonts.com/)
- [Noto Color Emoji](https://fonts.google.com/noto/specimen/Noto+Color+Emoji) font (for emoji rendering)

### Optional (for Neovim integration)

- Neovim `lib/navigate.lua` module -- seamless pane navigation between Kitty, tmux, and Neovim
- [kitty-scrollback.nvim](https://github.com/mikesmithgh/kitty-scrollback.nvim) -- browse terminal scrollback in Neovim

## Overview

| Setting | Value |
|---------|-------|
| Font | JetBrains Mono NL Nerd Font Mono |
| Font size | 12 (Linux) / 14 (macOS) |
| Scrollback | 10,000 lines (50 MB history) |
| Tab bar | Powerline style, angled separators |
| Theme | Catppuccin Mocha |
| Remote control | Enabled (for Neovim integration) |

## Key Bindings

| Binding | Action |
|---------|--------|
| `Ctrl+h/j/k/l` | Navigate between Kitty/Neovim splits |
| `Alt+h/j/k/l` | Resize panes |
| `kitty_mod+Enter` | New window with current working directory |
| `kitty_mod+Alt+Enter` | New window (home directory) |
| `kitty_mod+h` | Browse scrollback in Neovim |
| `kitty_mod+g` | Show last command output in Neovim |
| `kitty_mod+/` | Show all keyboard shortcuts |

`kitty_mod` is `Ctrl+Shift` by default.

## Files

| File | Purpose |
|------|---------|
| `kitty.conf.tmpl` | Main configuration (platform-conditional) |
| `current-theme.conf` | Catppuccin Mocha color definitions |
| `ssh.conf` | SSH-specific settings (editor, shell variables) |
| `keymap.py` | Python kitten that displays keyboard shortcuts in a formatted table |
| `relative_resize.py` | Python kitten for relative window resizing (`Alt+h/j/k/l`) |
