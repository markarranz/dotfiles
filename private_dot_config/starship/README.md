# Starship

[Starship](https://starship.rs/) is a fast, minimal, and highly customizable shell prompt written in Rust. It shows contextual information like the current git branch, active language runtimes, exit codes, and more -- all rendered with Nerd Font icons.

## Prerequisites

- [Starship](https://starship.rs/guide/#%F0%9F%9A%80-installation)
- A [Nerd Font](https://www.nerdfonts.com/) for icons and symbols

## Overview

The prompt is configured with:

- **Catppuccin Mocha** color palette
- **Nerd Font symbols** for 60+ programming languages and tools
- **OS detection** icons for Linux, macOS, and Windows
- **Vi-mode indicators** -- the prompt character changes between `❯` (insert) and `❮` (normal)
- **Git status** -- branch name, commit hash, and dirty/clean state

## Regenerating Nerd Font Symbols

If you want to reset to the default Nerd Font symbol preset:

```sh
starship preset nerd-font-symbols -o ~/.config/starship.toml
```

Note: this will overwrite custom palette and module settings.
