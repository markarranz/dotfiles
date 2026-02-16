return {
	{
		"mrjones2014/smart-splits.nvim",
		build = "./kitty/install-kittens.bash",
		lazy = false,
		opts = {
			at_edge = "stop",
			float_win_behavior = "mux",
		},
		config = function(_, opts)
			require("smart-splits").setup(opts)
			local kitty = require("smart-splits.mux.kitty")
			local dir_map = { left = "left", right = "right", up = "top", down = "bottom" }
			kitty.next_pane = function(direction)
				if not kitty.is_in_session() then
					return false
				end
				local kitty_dir = dir_map[direction] or direction
				local result = vim.system(
					{ "kitty", "@", "focus-window", "--match", "neighbor:" .. kitty_dir },
					{ text = true }
				):wait()
				return result.code == 0
			end
		end,
	},
	{
		"mikesmithgh/kitty-scrollback.nvim",
		enabled = true,
		lazy = true,
		cmd = {
			"KittyScrollbackGenerateKittens",
			"KittyScrollbackCheckHealth",
			"KittyScrollbackGenerateCommandLineEditing",
		},
		event = { "User KittyScrollbackLaunch" },
		-- version = '*', -- latest stable version, may have breaking changes if major version changed
		version = "^6.0.0", -- pin major version, include fixes and features that do not have breaking changes
		config = function()
			require("kitty-scrollback").setup()
		end,
	},
}
