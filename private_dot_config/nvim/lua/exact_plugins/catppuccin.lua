return {
	{
		"catppuccin/nvim",
		opts = {
			custom_highlights = function(colors)
				return {
					WinSeparator = { fg = colors.flamingo },
					LazygitInactiveBorder = { fg = colors.overlay1 },
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
			highlight_ignore_patterns = {
				"WinSeparator",
				"Status.*",
				"lualine_.*",
			},
		},
		config = function(_, opts)
			local tint = require("tint")
			tint.setup(opts)

			local function untint_current()
				local ok, win = pcall(vim.api.nvim_get_current_win)
				if ok and vim.api.nvim_win_is_valid(win) then
					tint.untint(win)
				end
			end

			local function untint_current_after_close()
				vim.schedule(untint_current)
				vim.defer_fn(untint_current, 20)
			end

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
					untint_current()
				end,
			})
			vim.api.nvim_create_autocmd({ "TermClose", "WinClosed" }, {
				group = group,
				callback = untint_current_after_close,
			})
		end,
	},
}
