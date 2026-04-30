return {
	"folke/snacks.nvim",
	opts = {
		lazygit = {
			-- Catppuccin doesn't set DiagnosticError.fg directly, so snacks' default
			-- mapping falls back to #ff0000. Point at a highlight with a real fg.
			theme = {
				unstagedChangesColor = { fg = "ErrorMsg" },
				-- FloatBorder fg is mantle (#11111b) — too dark. Use a custom highlight
				-- defined in catppuccin.lua (overlay1 = #7f849c).
				inactiveBorderColor = { fg = "LazygitInactiveBorder" },
			},
		},
		terminal = {
			win = {
				keys = {
					-- Disable LazyVim's term_nav keys so our TermOpen keymaps
					-- (which use navigate.lua for cross-mux navigation) take effect
					nav_h = false,
					nav_j = false,
					nav_k = false,
					nav_l = false,
				},
			},
		},
		picker = {
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
					exclude = { ".git" },
					win = {
						list = {
							keys = {
								["<c-j>"] = false,
								["<c-k>"] = false,
								["<a-h>"] = false,
							},
						},
					},
				},
			},
			hidden = true,
			ignored = true,
			exclude = { ".git" },
		},
	},
}
