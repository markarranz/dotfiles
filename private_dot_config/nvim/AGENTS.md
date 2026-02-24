# Neovim (LazyVim) — AGENTS.md

LazyVim distribution with custom overrides layered on top. Base lives in `externally_modified/nvim/` (symlinked via chezmoi); customizations here.

## Structure

```
nvim/
├── lua/
│   ├── config/           # Core config (auto-loaded by LazyVim)
│   │   ├── lazy.lua      # lazy.nvim bootstrap
│   │   ├── options.lua   # Editor opts, filetype detection, LSP/formatter choices
│   │   ├── keymaps.lua   # Cross-terminal navigation (Ctrl+hjkl)
│   │   └── autocmds.lua  # Filetype-specific autocommands
│   ├── plugins/          # Plugin specs (override/extend LazyVim defaults)
│   │   ├── core.lua      # LazyVim, bufferline, conform, lualine overrides
│   │   ├── catppuccin.lua # Colorscheme + tint.nvim (dim inactive windows)
│   │   ├── treesitter.lua # Extra parsers (hyprlang, rasi, gotmpl)
│   │   ├── snacks.lua    # Terminal/picker customization
│   │   ├── kitty.lua     # kitty-scrollback.nvim integration
│   │   ├── venv-selector.lua # Python venv selector
│   │   └── zz_for_work.lua.tmpl # Work-only plugins (template)
│   └── lib/
│       └── navigate.lua  # 208-line cross-mux navigation module
├── after/
│   ├── ftplugin/         # Per-language: python.vim, go.vim, sql.vim, cs.vim, rust.lua, http.vim
│   └── lsp/              # LSP configs: googlesql.lua, sqlls.lua (conditional)
├── queries/gotmpl/       # Tree-sitter injection for Go templates
└── symlink_*.tmpl        # Chezmoi symlinks to externally_modified/nvim/ base
```

## Where to Look

| Task | Location |
|------|----------|
| Add plugin | `lua/plugins/new_plugin.lua` — one file per plugin/feature |
| Override LazyVim default | `lua/plugins/core.lua` — use `opts` merge or `opts` function |
| Per-language indent/textwidth | `after/ftplugin/{lang}.vim` |
| LSP server config | `after/lsp/{server}.lua` |
| Custom filetype detection | `lua/config/options.lua` → `vim.filetype.add()` |
| Cross-terminal navigation | `lua/lib/navigate.lua` + `lua/config/keymaps.lua` |
| Work-only plugins | `lua/plugins/zz_for_work.lua.tmpl` (`.forWork` conditional) |

## Conventions

### Plugin Spec Patterns
```lua
-- opts-based (most common): merged with LazyVim defaults
{ "plugin/name", opts = { key = "value" } }

-- opts function: modify existing defaults
{ "plugin/name", opts = function(_, opts) opts.key = "value" end }

-- config function: full control
{ "plugin/name", config = function(_, opts) require("plugin").setup(opts) end }
```

### Lazy Loading
- `event = "VeryLazy"` — deferred load (default for many)
- `cmd = { "Command" }` — load on command
- `event = { "User CustomEvent" }` — load on custom event

### Per-Language Settings
- Prefer `after/ftplugin/` (Vim script for simple settings, Lua for complex)
- Pattern: `setlocal textwidth=N expandtab shiftwidth=N tabstop=N`

## Anti-Patterns

- **Never edit `externally_modified/nvim/`** for custom overrides — layer via `lua/config/` and `lua/plugins/`
- **No plugin specs in config files** — plugins go in `lua/plugins/`, config in `lua/config/`
- **Avoid disabling LazyVim defaults** without reason — prefer overriding via `opts`
- **Don't add keymaps in plugin files** — centralize in `lua/config/keymaps.lua` (exception: plugin-specific maps in spec)

## Notes

- **navigate.lua**: Detects multiplexer (tmux > kitty), uses geometric window detection, sets `IS_NVIM` kitty user var for passthrough. Handles floating windows, DCS passthrough in tmux.
- **sqlls.lua**: Conditionally disables itself if `googlesql-ls` is available (work environment).
- **`zz_` prefix**: `zz_for_work.lua.tmpl` loads last to ensure work plugins don't conflict.
- **Filetype detection**: Hyprland (`*.conf` under `hypr/`), Go templates (`.gotmpl`), Rofi (`.rasi`).
