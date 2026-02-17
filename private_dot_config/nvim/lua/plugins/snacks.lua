return {
	"folke/snacks.nvim",
	opts = {
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
