# Kitty Terminal — AGENTS.md

GPU-accelerated terminal with Python kittens for cross-terminal navigation, custom resize, and tab management. Integrates with Neovim and tmux via `navigate.py`.

## Structure

```
kitty/
├── kitty.conf            # Main config (font, tabs, keybinds, includes)
├── current-theme.conf    # Catppuccin Mocha colors (auto-managed by chezmoiexternal)
├── os.conf.tmpl          # Platform-specific overrides (macOS vs Linux)
├── work.conf.tmpl        # Work environment overrides (conditional include)
├── ssh.conf              # Remote host SSH config
├── navigate.py           # Cross-mux navigation kitten (kitty ↔ nvim ↔ tmux)
├── keymap.py             # Keybinding display kitten
├── relative_resize.py    # Window resize kitten (3-unit steps)
├── tab_bar.py            # Custom powerline tab bar renderer
├── executable_tab-select.sh  # fzf-based tab selector
├── macos-launch-services-cmdline  # macOS CLI launch config
└── README.md
```

## Where to Look

| Task | Location |
|------|----------|
| Change font/appearance | `kitty.conf` — top section |
| Platform-specific setting | `os.conf.tmpl` — OS conditional |
| Add keybinding | `kitty.conf` — keybinds section at bottom |
| Modify cross-terminal nav | `navigate.py` — paired with `nvim/lua/lib/navigate.lua` |
| Custom tab bar styling | `tab_bar.py` |
| Window resize behavior | `relative_resize.py` |

## Conventions

- **Kittens**: Custom behavior via Python scripts (`kitten navigate.py`, `kitten relative_resize.py`)
- **Includes**: `kitty.conf` sources `os.conf` and `work.conf` — keep platform logic in templates
- **Remote control**: `allow_remote_control=yes` required for Neovim integration (`IS_NVIM` user var)
- **Layout switching**: `ctrl+shift+1-7` cycles through tall, fat, vertical, horizontal, grid, splits, stack
- **Navigation**: `ctrl+hjkl` → `navigate.py` → detects Neovim (`IS_NVIM` var) → passes through or moves kitty windows

## Anti-Patterns

- **Don't hardcode OS-specific values in `kitty.conf`** — use `os.conf.tmpl`
- **Don't edit `current-theme.conf`** — auto-managed by chezmoiexternal (Catppuccin)
- **Don't break `navigate.py` ↔ `navigate.lua` contract** — both must agree on `IS_NVIM` kitten var

## Notes

- **Navigation chain**: `navigate.py` checks `IS_NVIM` user var → if Neovim, sends keystrokes to Neovim → if not, moves kitty window. Paired with `navigate.lua` in Neovim and tmux passthrough.
- **Tab bar**: `tab_bar.py` draws custom powerline-style angled separators with active/inactive colors.
- **Scrollback**: `kitty_mod+h` opens scrollback in Neovim via `kitty-scrollback.nvim`.
- **`shell_integration no-cursor`**: Kitty doesn't override Neovim's cursor shape.
