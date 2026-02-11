# tmux

[tmux](https://github.com/tmux/tmux) is a terminal multiplexer that lets you run multiple terminal sessions inside a single window, detach and reattach to sessions, and split panes. It keeps your work running even if your terminal closes.

## Prerequisites

- [tmux](https://github.com/tmux/tmux) >= 3.0
- [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager) -- clone it into `~/.config/tmux/plugins/tpm`:
  ```sh
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  ```
  Then press `prefix + I` inside tmux to install plugins.

## Plugins

- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) -- sensible default settings
- [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key) -- shows available keybindings after pressing the prefix
- [catppuccin/tmux](https://github.com/catppuccin/tmux) -- Catppuccin Macchiato color theme (pinned to v2.1.3)

## Key Bindings

The prefix key is remapped to `Ctrl+Space` (default tmux uses `Ctrl+b`).

| Binding | Action |
|---------|--------|
| `prefix + \|` | Split pane horizontally |
| `prefix + -` | Split pane vertically |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + c` | New window (inherits current path) |
