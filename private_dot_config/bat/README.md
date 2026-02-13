# bat

[bat](https://github.com/sharkdp/bat) is a `cat` replacement with syntax highlighting, line numbers, and git integration. When you view a file with `bat`, it renders the contents with color-coded syntax and shows git modifications in the margin.

## Prerequisites

- [bat](https://github.com/sharkdp/bat)

## Overview

Configuration is minimal -- the only customization is setting the theme to **Catppuccin Mocha**. The theme file itself is downloaded automatically by chezmoi (see `.chezmoiexternal.toml`), and the theme cache is rebuilt on each `chezmoi apply` via a `run_after_bat-cache.sh` script at the repo root.
