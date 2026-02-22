return {
	"folke/snacks.nvim",
	opts = {
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
