# Dotfiles

Personal development environment configurations managed with [chezmoi](https://www.chezmoi.io/). These dotfiles target **macOS** and **Linux** (Arch-based), with chezmoi templates handling platform-specific differences automatically.

A [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) color scheme is applied consistently across all tools.

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) -- dotfile manager that uses templates to handle cross-platform differences. It maps this repo's source files (e.g. `dot_gitconfig.tmpl`) to their real locations (e.g. `~/.gitconfig`).
- [Nerd Font](https://www.nerdfonts.com/) -- many tools here expect a patched Nerd Font for icons and symbols. The configs default to **JetBrains Mono NL Nerd Font**.

## Getting Started

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
| [**Zsh**](https://www.zsh.org/) | A powerful Unix shell with advanced tab completion, globbing, and scripting capabilities. Configured here with the [Zap](https://github.com/zap-zsh/zap) plugin manager and plugins from [Oh My Zsh](https://ohmyz.sh/) for aliases, autosuggestions, syntax highlighting, vi-mode keybindings, and fuzzy tab completion via [fzf-tab](https://github.com/Aloxaf/fzf-tab). |
| [**Git**](https://git-scm.com/) | Distributed version control system. Configured with [delta](https://github.com/dandavella/delta) as the pager for improved diffs, conditional includes for separating work and personal identities, and `zdiff3` merge conflict style. |
| [**tmux**](https://github.com/tmux/tmux) | A terminal multiplexer that lets you run multiple terminal sessions inside a single window, detach and reattach to sessions, and split panes. Configured here with `Ctrl+Space` as the prefix key, vim-style pane navigation, and the [TPM](https://github.com/tmux-plugins/tpm) plugin manager. |
| [**Starship**](https://starship.rs/) | A fast, minimal, and highly customizable shell prompt written in Rust. It displays contextual information such as the current git branch, active language runtimes, and exit codes -- all rendered with Nerd Font icons. |
| [**fzf**](https://github.com/junegunn/fzf) | A general-purpose command-line fuzzy finder. It lets you interactively search and select from lists of files, command history, processes, and more. Used here as the backend for shell history search and tab completion. |
| [**zoxide**](https://github.com/ajeetdsouza/zoxide) | A smarter `cd` command that learns which directories you visit most frequently. Type `z foo` and it jumps to the most likely match instead of requiring a full path. |
| [**bat**](https://github.com/sharkdp/bat) | A `cat` replacement with syntax highlighting, line numbers, and git integration. When you `bat` a file, it renders the contents with color-coded syntax, making it much easier to read code in the terminal. |
| [**Yazi**](https://yazi-rs.github.io/) | A blazing-fast terminal file manager written in Rust with image preview support, vim-like keybindings, and a plugin system. Think of it as a modern alternative to `ranger`. |
| [**Kitty**](https://sw.kovidgoyal.net/kitty/) | A GPU-accelerated terminal emulator that supports ligatures, image rendering, and tiling layouts natively. Configured here with a JetBrains Mono Nerd Font, powerline-style tabs, and integration with Neovim for scrollback browsing via [kitty-scrollback.nvim](https://github.com/mikesmithgh/kitty-scrollback.nvim). |
| [**Zathura**](https://pwmt.org/projects/zathura/) | A lightweight, keyboard-driven PDF and document viewer with vim-like navigation. |
| [**btop**](https://github.com/aristocratos/btop) | A resource monitor that shows CPU, memory, disk, network, and process usage with a colorful TUI. A modern alternative to `top` and `htop`. |
| [**delta**](https://github.com/dandavella/delta) | A syntax-highlighting pager for `git diff`, `git log`, and `git show` output. It makes diffs significantly more readable with side-by-side views, line numbers, and language-aware highlighting. Used as the configured git pager. |

### Linux Only

These tools are specific to a Linux (Wayland/Hyprland) desktop environment.

| Tool | Description |
|------|-------------|
| [**Hyprland**](https://hyprland.org/) | A dynamic tiling Wayland compositor (window manager) with smooth animations, rounded corners, and a highly scriptable configuration. It manages window placement, workspaces, keybindings, and multi-monitor setups. Also includes companion utilities: [hyprlock](https://github.com/hyprwm/hyprlock) (lock screen), [hypridle](https://github.com/hyprwm/hypridle) (idle management), [hyprpaper](https://github.com/hyprwm/hyprpaper) (wallpaper), and [hyprsunset](https://github.com/hyprwm/hyprsunset) (blue light filter). |
| [**Ashell**](https://github.com/MalpenZibo/ashell) | A status bar and notification panel for Hyprland. Displays workspaces, the focused window title, system info, a tray, clock, and more along the top of the screen. |
| [**Rofi**](https://github.com/davatorium/rofi) | An application launcher and window switcher. Press a keybinding and a search bar appears where you can type to find and launch applications, switch windows, browse files, or run shell commands. |
| [**Kanata**](https://github.com/jtroo/kanata) | A software keyboard remapper that runs as a background service. Used here to implement home-row mods -- holding `a`, `s`, `d`, `f` (and their right-hand counterparts) produces Ctrl, Alt, Meta, and Shift, while tapping them types the normal letter. |
| [**Qt6ct**](https://github.com/trialuser02/qt6ct) | A configuration tool for Qt 6 application appearance on non-KDE desktops. Used here to apply the Catppuccin Mocha theme to Qt-based applications so they match the rest of the desktop. |
| Chromium & Electron flags | Configuration files (`chromium-flags.conf`, `electron-flags.conf`) that enable native Wayland support for Chromium-based browsers and Electron apps, preventing them from falling back to XWayland. |

### macOS Only

These tools are specific to a macOS desktop environment.

| Tool | Description |
|------|-------------|
| [**AeroSpace**](https://github.com/nikitabobko/AeroSpace) | A tiling window manager for macOS inspired by i3. It organizes windows into workspaces with keyboard-driven navigation and layout management -- no mouse required. Configured with `Cmd`-based keybindings for window focus, movement, and workspace switching. |
| [**yabai**](https://github.com/koekeishiya/yabai) | Another tiling window manager for macOS that uses a scripting addition for advanced features like window opacity, animations, and automatic space management. Included here alongside AeroSpace as an alternative. |
| [**skhd**](https://github.com/koekeishiya/skhd) | A simple hotkey daemon for macOS. It listens for keyboard shortcuts globally and triggers actions like launching apps, focusing windows, or sending commands to yabai. Acts as the keybinding layer for the yabai window manager. |
| [**Karabiner-Elements**](https://karabiner-elements.pqrs.org/) | A powerful, low-level keyboard remapper for macOS. It can remap any key, create complex modification rules (like tap-vs-hold behavior), and handle device-specific configurations. Used here for system-level keyboard customization. |
| [**SketchyBar**](https://github.com/FelixKratz/SketchyBar) | A highly customizable status bar replacement for the macOS menu bar. Configured here with Lua scripts to show workspaces, the focused app, battery, CPU usage, volume, Wi-Fi, GitHub notifications, and more. Integrates with yabai/AeroSpace for workspace awareness. |
| [**JankyBorders**](https://github.com/FelixKratz/JankyBorders) | A lightweight utility that draws colored borders around the focused window on macOS, making it easy to see which window is active. Configured with a pink-to-sky gradient for the active window. |

## Repository Structure

```
.
├── .chezmoi.toml.tmpl          # Chezmoi config: detects OS, chassis type, hostname
├── .chezmoiexternal.toml.tmpl  # External dependencies (themes, plugins, archives)
├── .chezmoiignore.tmpl         # Platform-specific ignore rules
├── dot_gitconfig.tmpl          # Git configuration
├── dot_gitignore_global        # Global gitignore patterns
├── dot_zshenv.tmpl             # Zsh environment entry point (XDG dirs, etc.)
├── dot_claude/                 # Claude Code IDE settings
├── private_dot_config/         # ~/.config/ directory contents
│   ├── aerospace/              # [macOS] AeroSpace window manager
│   ├── ashell/                 # [Linux] Ashell status bar
│   ├── bat/                    # bat syntax highlighter
│   ├── borders/                # [macOS] JankyBorders
│   ├── hypr/                   # [Linux] Hyprland compositor + utilities
│   ├── kanata/                 # [Linux] Kanata keyboard remapper
│   ├── kitty/                  # Kitty terminal emulator
│   ├── nvim/                   # Neovim (LazyVim)
│   ├── qt6ct/                  # [Linux] Qt6 theming
│   ├── rofi/                   # [Linux] Rofi application launcher
│   ├── sketchybar/             # [macOS] SketchyBar status bar
│   ├── skhd/                   # [macOS] skhd hotkey daemon
│   ├── starship/               # Starship shell prompt
│   ├── systemd/                # [Linux] Systemd user services
│   ├── tmux/                   # tmux terminal multiplexer
│   ├── yabai/                  # [macOS] yabai window manager
│   ├── yazi/                   # Yazi file manager
│   └── zsh/                    # Zsh shell configuration
└── externally_modified/        # Configs tracked in git but not managed by chezmoi
    ├── karabiner/              # [macOS] Karabiner-Elements
    ├── lazyvim/                # LazyVim distribution
    └── hyprpanel/              # [Linux] Hyprpanel configs
```

## Customization

Before applying, you may want to:

1. **Review the chezmoi templates** -- files ending in `.tmpl` contain conditional logic based on OS and hostname. You will likely need to adjust hostname checks (e.g. `WORKMACHINE`) and monitor configurations to match your hardware.
2. **Swap out personal details** -- the git config references a specific GitHub username and email. Update `dot_gitconfig.tmpl` with your own.
3. **Choose your window manager** -- on macOS, both AeroSpace and yabai+skhd are included. Pick one and remove the other, or keep both and switch between them.
4. **Adjust keybindings** -- keybindings are tailored to personal preference. Review the skhd, Hyprland, AeroSpace, and Kanata configs to make sure they work for your keyboard and workflow.

## License

This project is licensed under the [MIT License](LICENSE).
