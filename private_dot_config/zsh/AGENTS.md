# Zsh — AGENTS.md

Zsh config with manual plugin sourcing (no framework). XDG-compliant (`ZDOTDIR=~/.config/zsh`). Heavy use of chezmoi templates for OS and work conditionals.

## Structure

```
zsh/
├── dot_zshrc.tmpl        # Main interactive config (sourcing order, completions, plugins)
├── dot_zprofile.tmpl     # Login shell (Homebrew shellenv, UWSM/Hyprland on Linux)
├── aliases.zsh.tmpl      # All aliases (utility, eza, git, brew, OS-conditional)
├── exports.zsh.tmpl      # PATH/env vars (OS + work conditional blocks)
├── functions.zsh          # Custom functions (static, no template)
├── exact_plugins/         # Plugin source dirs (chezmoi exact — deletes unmanaged)
└── omz/                   # Legacy Oh My Zsh artifacts (NOT active, kept for reference)
```

Note: `dot_zshenv.tmpl` lives at repo root (sets `ZDOTDIR`, `EDITOR`, `HISTFILE`).

## Where to Look

| Task | Location |
|------|----------|
| Add alias | `aliases.zsh.tmpl` — OS-conditional sections |
| Add function | `functions.zsh` — static, no template needed |
| Add/modify PATH | `exports.zsh.tmpl` — OS + work conditional blocks |
| Change plugin order | `dot_zshrc.tmpl` — sourcing section |
| Login-time setup | `dot_zprofile.tmpl` — Homebrew (macOS), UWSM (Linux) |

## Conventions

### Sourcing Order (critical)
```
zshenv → zprofile (login) → zshrc (interactive)
```

Within `zshrc`:
```
PATH → setopt → compinit → plugins → fzf-tab-config → exports → functions → aliases → direnv → starship → NVM(work)
```

### Plugin Order (breaks if wrong)
```
fzf-tab → fzf-tab-source → autosuggestions → syntax-highlighting → zsh-vi-mode (LAST)
```
`ZVM_SYSTEM_CLIPBOARD` must be set BEFORE sourcing zsh-vi-mode.

### Plugin Management
- 5 plugins via `.chezmoiexternal.toml.tmpl` (168h refresh cycle)
- Manual sourcing with `_zwarn` fallback for missing plugins
- NO plugin manager (no Oh My Zsh, no zinit, no antidote)
- `exact_plugins/` = chezmoi deletes anything not in source state

### Templates
- `aliases.zsh.tmpl`: OS blocks via `{{- if eq .chezmoi.os "darwin" }}`
- `exports.zsh.tmpl`: Linux block, macOS-personal block, macOS-work block, all-platform block
- `functions.zsh`: Static (no template) — never needs OS conditionals

## Anti-Patterns

- **Don't use a plugin manager** — manual sourcing is intentional
- **Don't change plugin order** without testing — fzf-tab must precede syntax-highlighting, vi-mode must be last
- **Don't put OS logic in `functions.zsh`** — it's static; use templates for conditional content
- **Don't add files to `exact_plugins/`** — chezmoi manages this; add to `.chezmoiexternal.toml.tmpl` instead

## Notes

- **`brew()` wrapper**: In `functions.zsh`, wraps Homebrew to trigger SketchyBar update after install/uninstall.
- **`omz/` directory**: Legacy artifacts from Oh My Zsh migration. Not sourced, not active.
- **Error handling**: `_zwarn()` for non-fatal warnings, `$+commands[]` for command existence checks, `[[ -f ]]` for file guards.
- **NVM**: Only sourced when `.forWork = true` (work machines need Node version management).
