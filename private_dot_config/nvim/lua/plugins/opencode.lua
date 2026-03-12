return {
	{
		"nickjvandyke/opencode.nvim",
		version = "*", -- Latest stable release
		dependencies = {
			{ "folke/snacks.nvim", optional = true },
		},
		keys = {
			{
				"<leader>o",
				desc = "+OpenCode",
				mode = { "n", "x" },
			},
			{
				"<leader>oa",
				function()
					require("opencode").ask("@this: ", { submit = true })
				end,
				desc = "Ask OpenCode",
				mode = { "n", "x" },
			},
			{
				"<leader>os",
				function()
					require("opencode").select()
				end,
				desc = "OpenCode Actions",
				mode = { "n", "x" },
			},
			{
				"<leader>ot",
				function()
					require("opencode").toggle()
				end,
				desc = "Toggle OpenCode",
				mode = { "n", "t" },
			},
		},
		config = function()
			vim.g.opencode_opts = {}
			vim.o.autoread = true
		end,
	},
	{
		"folke/which-key.nvim",
		optional = true,
		opts = function(_, opts)
			opts.spec = opts.spec or {}
			table.insert(opts.spec, { "<leader>o", group = "OpenCode", mode = { "n", "x" } })
		end,
	},
}
