# Dotfiles

Personal development environment configurations managed with [chezmoi](https://www.chezmoi.io/). These dotfiles target **macOS** and **Linux** (Arch-based), with chezmoi templates handling platform-specific differences automatically.

A [Catppuccin](https://github.com/catppuccin/catppuccin) color scheme is applied across all tools (Mocha variant in most tools, Macchiato in tmux, Frappe in qt6ct).

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) -- dotfile manager that uses templates to handle cross-platform differences. It maps this repo's source files (e.g. `private_dot_config/git/config.tmpl`) to their real locations (e.g. `~/.config/git/config`).
- [Nerd Font](https://www.nerdfonts.com/) -- many tools here expect a patched Nerd Font for icons and symbols. The configs default to **JetBrains Mono NL Nerd Font**.

## Getting Started

### Automated Install

An install script is included that installs all tools and their prerequisites for the current platform (macOS with Homebrew or Arch Linux with pacman/yay):

```sh
git clone https://github.com/markarranz/dotfiles.git
cd dotfiles
./install.sh
```

The script will prompt before making changes and handles:
- Installing all packages (Homebrew formulae/casks or pacman/AUR packages)
- Setting up plugin managers (TPM for tmux)
- Optionally installing Claude Code CLI
- Applying the dotfiles via chezmoi
- Setting Zsh as the default shell

### Manual Install

If you prefer to install tools yourself:

```sh
# One-liner: install chezmoi and apply these dotfiles
chezmoi init --apply <your-github-username>
```

See the [chezmoi quick start guide](https://www.chezmoi.io/quick-start/) for more details.

## Included Tools

### Cross-Platform

These tools are configured for both macOS and Linux.

| Tool | Description |
|------|-------------|
| [**Neovim**](https://neovim.io/) | A modern, extensible terminal-based text editor forked from Vim. Configured here with the [LazyVim](https://www.lazyvim.org/) distribution, which provides a batteries-included IDE experience with LSP support, syntax highlighting via Tree-sitter, fuzzy finding, and more. |
| [**Zsh**](https://www.zsh.org/) | A powerful Unix shell with advanced tab completion, globbing, and scripting capabilities. The active setup lives in `zsh/` and manually sources plugins from `~/.config/zsh/plugins/`. It provides aliases, autosuggestions, syntax highlighting, and vi-mode keybindings. |
| [**Git**](https://git-scm.com/) | Distributed version control system. Configured with [delta](https://github.com/dandavison/delta) as the pager for improved diffs, conditional includes for separating work and personal identities, and `zdiff3` merge conflict style. |
| [**tmux**](https://github.com/tmux/tmux) | A terminal multiplexer that lets you run multiple terminal sessions inside a single window, detach and reattach to sessions, and split panes. Configured here with `Ctrl+Space` as the prefix key, vim-style pane navigation, and the [TPM](https://github.com/tmux-plugins/tpm) plugin manager. |
| [**Starship**](https://starship.rs/) | A fast, minimal, and highly customizable shell prompt written in Rust. It displays contextual information such as the current git branch, active language runtimes, and exit codes -- all rendered with Nerd Font icons. |
| [**fzf**](https://github.com/junegunn/fzf) | A general-purpose command-line fuzzy finder. It lets you interactively search and select from lists of files, command history, processes, and more. Used here as the backend for shell history search and tab completion. |
| [**zoxide**](https://github.com/ajeetdsouza/zoxide) | A smarter `cd` command that learns which directories you visit most frequently. Type `z foo` and it jumps to the most likely match instead of requiring a full path. |
| [**bat**](https://github.com/sharkdp/bat) | A `cat` replacement with syntax highlighting, line numbers, and git integration. When you `bat` a file, it renders the contents with color-coded syntax, making it much easier to read code in the terminal. |
| [**Yazi**](https://yazi-rs.github.io/) | A blazing-fast terminal file manager written in Rust with image preview support, vim-like keybindings, and a plugin system. Think of it as a modern alternative to `ranger`. |
| [**Kitty**](https://sw.kovidgoyal.net/kitty/) | A GPU-accelerated terminal emulator that supports ligatures, image rendering, and tiling layouts natively. Configured here with a JetBrains Mono Nerd Font, powerline-style tabs, and integration with Neovim for scrollback browsing via [kitty-scrollback.nvim](https://github.com/mikesmithgh/kitty-scrollback.nvim). |
| [**Zathura**](https://pwmt.org/projects/zathura/) | A lightweight, keyboard-driven PDF and document viewer with vim-like navigation. |
| [**btop**](https://github.com/aristocratos/btop) | A resource monitor that shows CPU, memory, disk, network, and process usage with a colorful TUI. A modern alternative to `top` and `htop`. |
| [**delta**](https://github.com/dandavison/delta) | A syntax-highlighting pager for `git diff`, `git log`, and `git show` output. It makes diffs significantly more readable with side-by-side views, line numbers, and language-aware highlighting. Used as the configured git pager. |

### Linux Only

These tools are specific to a Linux (Wayland/Hyprland) desktop environment.

| Tool | Description |
|------|-------------|
| [**Hyprland**](https://hyprland.org/) | A dynamic tiling Wayland compositor (window manager) with smooth animations, rounded corners, and a highly scriptable configuration. It manages window placement, workspaces, keybindings, and multi-monitor setups. Also includes companion utilities: [hyprlock](https://github.com/hyprwm/hyprlock) (lock screen), [hypridle](https://github.com/hyprwm/hypridle) (idle management), [hyprpaper](https://github.com/hyprwm/hyprpaper) (wallpaper), and [hyprsunset](https://github.com/hyprwm/hyprsunset) (blue light filter). |
| [**Ashell**](https://github.com/MalpenZibo/ashell) | A status bar and notification panel for Hyprland. Displays workspaces, the focused window title, system info, a tray, clock, and more along the top of the screen. |
| [**Kanata**](https://github.com/jtroo/kanata) | A software keyboard remapper that runs as a background service. Used here to implement home-row mods -- holding `a`, `s`, `d`, `f` (and their right-hand counterparts) produces Ctrl, Alt, Meta, and Shift, while tapping them types the normal letter. |
| [**Qt6ct**](https://github.com/trialuser02/qt6ct) | A configuration tool for Qt 6 application appearance on non-KDE desktops. Used here to apply the Catppuccin Frappe theme to Qt-based applications so they match the rest of the desktop. |
| Chromium & Electron flags | Configuration files (`chromium-flags.conf`, `electron-flags.conf`) that enable native Wayland support for Chromium-based browsers and Electron apps, preventing them from falling back to XWayland. |

### macOS Only

These tools are specific to a macOS desktop environment.

| Tool | Description |
|------|-------------|
| [**yabai**](https://github.com/koekeishiya/yabai) | A tiling window manager for macOS that uses a scripting addition for advanced features like window opacity, animations, and automatic space management. |
| [**skhd**](https://github.com/koekeishiya/skhd) | A simple hotkey daemon for macOS. It listens for keyboard shortcuts globally and triggers actions like launching apps, focusing windows, or sending commands to yabai. Acts as the keybinding layer for the yabai window manager. |
| [**Karabiner-Elements**](https://karabiner-elements.pqrs.org/) | A powerful, low-level keyboard remapper for macOS. It can remap any key, create complex modification rules (like tap-vs-hold behavior), and handle device-specific configurations. Used here for system-level keyboard customization. |
| [**SketchyBar**](https://github.com/FelixKratz/SketchyBar) | A highly customizable status bar replacement for the macOS menu bar. Configured here with Lua scripts to show workspaces, the focused app, battery, CPU usage, volume, Wi-Fi, GitHub notifications, and more. Integrates with yabai for workspace awareness. |
| [**JankyBorders**](https://github.com/FelixKratz/JankyBorders) | A lightweight utility that draws colored borders around the focused window on macOS, making it easy to see which window is active. Configured with a pink-to-sky gradient for the active window. |

## Repository Structure

```
.
├── install.sh                  # Automated installer for all tools and prerequisites
├── .chezmoi.toml.tmpl          # Chezmoi config: detects OS, chassis type, hostname
├── .chezmoiexternal.toml.tmpl  # External dependencies (themes, plugins, archives)
├── .chezmoiignore.tmpl         # Platform-specific ignore rules
├── .chezmoiscripts/            # chezmoi run scripts (run_once, run_onchange)
├── dot_zshenv.tmpl             # Zsh environment entry point (XDG dirs, etc.)
├── dot_claude/                 # Claude Code IDE settings
├── private_dot_config/         # ~/.config/ directory contents
│   ├── ashell/                 # [Linux] Ashell status bar
│   ├── bat/                    # bat syntax highlighter
│   ├── borders/                # [macOS] JankyBorders
│   ├── elephant/               # [Linux] Elephant data provider (Walker backend)
│   ├── hypr/                   # [Linux] Hyprland compositor + utilities
│   ├── kanata/                 # [Linux] Kanata keyboard remapper
│   ├── karabiner/              # [macOS] Karabiner-Elements (symlink)
│   ├── kitty/                  # Kitty terminal emulator
│   ├── nvim/                   # Neovim (LazyVim)
│   ├── qt6ct/                  # [Linux] Qt6 theming
│   ├── git/                    # Git config, ignore, helper scripts
│   ├── skhd/                   # [macOS] skhd hotkey daemon
│   ├── starship/               # Starship shell prompt
│   ├── systemd/                # [Linux] Systemd user services
│   ├── tmux/                   # tmux terminal multiplexer
│   ├── uwsm/                   # [Linux] UWSM session environment
│   ├── yabai/                  # [macOS] yabai window manager
│   ├── yazi/                   # Yazi file manager
│   ├── zathura/                # Zathura PDF viewer
│   └── zsh/                    # Zsh config (manual plugin sourcing)
│       └── omz/                # Legacy Oh My Zsh artifacts (not active)
└── externally_modified/        # Configs tracked in git but not managed by chezmoi
    ├── karabiner/              # [macOS] Karabiner-Elements
    └── lazyvim/                # LazyVim distribution
```

## Customization

Before applying, you may want to:

1. **Review the chezmoi templates** -- files ending in `.tmpl` contain conditional logic based on OS and hostname. You will likely need to adjust hostname checks (e.g. `digdug`) and monitor configurations to match your hardware.
2. **Swap out personal details** -- the git config references a specific GitHub username and email. Update `private_dot_config/git/config.tmpl` with your own.
3. **Adjust keybindings** -- keybindings are tailored to personal preference. Review the skhd, Hyprland, and Kanata configs to make sure they work for your keyboard and workflow.

## License

This project is licensed under the [MIT License](LICENSE).
