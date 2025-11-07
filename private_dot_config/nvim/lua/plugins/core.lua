return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
	{
		"askinsho/bufferline.nvim",
		opts = {
			options = {
				indicator = { style = "underline" },
				separator_style = "slant",
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			-- Show relative filepath
			local c = opts.sections.lualine_c
			c[#c - 1] = { "filename", path = 1 }

			-- Change date format to 12-hour AM/PM
			opts.sections.lualine_z = {
				function()
					return " " .. os.date("%I:%M %p")
				end,
			}
		end,
	},
}
