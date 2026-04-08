return {
	{
		"catppuccin/nvim",
		opts = {
			custom_highlights = function(colors)
				return {
					WinSeparator = { fg = colors.flamingo },
				}
			end,
		},
	},
	{
		"levouh/tint.nvim",
		event = "WinEnter",
		opts = {
			tint = -45,
			saturation = 0.6,
			highlight_ignore_patterns = { "WinSeparator" },
		},
		config = function(_, opts)
			local tint = require("tint")
			tint.setup(opts)

			local group = vim.api.nvim_create_augroup("TintFocus", { clear = true })
			vim.api.nvim_create_autocmd("FocusLost", {
				group = group,
				callback = function()
					tint.tint(vim.api.nvim_get_current_win())
				end,
			})
			vim.api.nvim_create_autocmd("FocusGained", {
				group = group,
				callback = function()
					tint.untint(vim.api.nvim_get_current_win())
				end,
			})
		end,
	},
}
