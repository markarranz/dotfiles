return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			adapters = {
				acp = {
					claude_code = function()
						return require("codecompanion.adapters").extend("claude_code", {
							env = {
								CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read 'op://Employee/Claude Code OAuth Token/credential' --no-newline",
							},
						})
					end,
				},
			},
			strategies = {
				chat = { adapter = "claude_code" },
				inline = { adapter = "claude_code" },
			},
		},
		keys = {
			{ "<leader>a", desc = "+AI (CodeCompanion)", mode = { "n", "v" } },
			{ "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat", mode = { "n", "v" } },
			{ "<leader>ap", "<cmd>CodeCompanionActions<cr>", desc = "Action Palette", mode = { "n", "v" } },
			{ "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "Inline Prompt", mode = "n" },
			{ "<leader>ae", "<cmd>CodeCompanionChat Add<cr>", desc = "Add to Chat", mode = "v" },
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		optional = true,
		ft = { "markdown", "codecompanion" },
	},
	{
		"folke/which-key.nvim",
		optional = true,
		opts = function(_, opts)
			opts.spec = opts.spec or {}
			table.insert(opts.spec, { "<leader>a", group = "AI (CodeCompanion)", mode = { "n", "v" } })
		end,
	},
}
