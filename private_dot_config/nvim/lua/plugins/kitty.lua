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

			-- Fix kitty next_pane to use built-in focus-window instead of broken kitten
			local kitty = require("smart-splits.mux.kitty")
			local kitty_dir_map = { left = "left", right = "right", up = "top", down = "bottom" }
			kitty.next_pane = function(direction)
				if not kitty.is_in_session() then
					return false
				end
				local kitty_dir = kitty_dir_map[direction] or direction
				local result = vim.system(
					{ "kitty", "@", "focus-window", "--match", "neighbor:" .. kitty_dir },
					{ text = true }
				):wait()
				return result.code == 0
			end

			-- Fix navigation from embedded floating windows (e.g. snacks explorer).
			-- The default uses wincmd which doesn't navigate geometrically from
			-- floating windows, and the edge detection breaks when other floating
			-- panels resize the explorer. Instead, find the correct target window
			-- by geometry, falling back to kitty if no neovim window exists.
			local utils = require("smart-splits.utils")
			local ss = require("smart-splits")

			local function find_win_in_direction(direction)
				local cur = vim.api.nvim_get_current_win()
				local pos = vim.api.nvim_win_get_position(cur)
				local h, w = vim.api.nvim_win_get_height(cur), vim.api.nvim_win_get_width(cur)
				local top, left = pos[1], pos[2]
				local bot, right = top + h, left + w
				local best, best_dist = nil, math.huge
				for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
					if win == cur then
						goto continue
					end
					local cfg = vim.api.nvim_win_get_config(win)
					if cfg.focusable == false then
						goto continue
					end
					local wh = vim.api.nvim_win_get_height(win)
					local ww = vim.api.nvim_win_get_width(win)
					if wh <= 1 or ww <= 1 then
						goto continue
					end
					local wp = vim.api.nvim_win_get_position(win)
					local wt, wl = wp[1], wp[2]
					local wb, wr = wt + wh, wl + ww
					local valid, dist = false, 0
					if direction == "down" then
						local overlap = math.min(right, wr) > math.max(left, wl)
						if wt >= bot - 1 and overlap then
							valid, dist = true, wt - bot
						end
					elseif direction == "up" then
						local overlap = math.min(right, wr) > math.max(left, wl)
						if wb <= top + 1 and overlap then
							valid, dist = true, top - wb
						end
					elseif direction == "right" then
						local overlap = math.min(bot, wb) > math.max(top, wt)
						if wl >= right - 1 and overlap then
							valid, dist = true, wl - right
						end
					elseif direction == "left" then
						local overlap = math.min(bot, wb) > math.max(top, wt)
						if wr <= left + 1 and overlap then
							valid, dist = true, left - wr
						end
					end
					if valid and dist < best_dist then
						best, best_dist = win, dist
					end
					::continue::
				end
				return best
			end

			for _, direction in ipairs({ "left", "right", "up", "down" }) do
				local method = "move_cursor_" .. direction
				local original = ss[method]
				ss[method] = function(move_opts)
					if not utils.is_embedded_floating_window() then
						return original(move_opts)
					end
					local target = find_win_in_direction(direction)
					if target then
						vim.api.nvim_set_current_win(target)
					else
						kitty.next_pane(direction)
					end
				end
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
