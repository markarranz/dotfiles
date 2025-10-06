return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
	-- Change date format to 12-hour AM/PM
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			sections = {
				lualine_z = {
					function()
						return " " .. os.date("%I:%M %p")
					end,
				},
			},
		},
	},
}
