local M = {}

-- Detect the immediate multiplexer (prefer tmux when nested inside kitty)
local mux = nil
if vim.env.TMUX then
	mux = "tmux"
elseif vim.env.KITTY_LISTEN_ON then
	mux = "kitty"
end

-- Set IS_NVIM kitty user variable so kitty kittens (navigate.py,
-- relative_resize.py) pass Ctrl+hjkl and Alt+hjkl through to neovim
-- instead of handling them at the kitty level.
if vim.env.KITTY_LISTEN_ON then
	local set_seq = "\x1b]1337;SetUserVar=IS_NVIM=MQ==\x07"
	local clear_seq = "\x1b]1337;SetUserVar=IS_NVIM=\x07"
	if vim.env.TMUX then
		-- DCS passthrough: inner ESCs doubled so tmux forwards to kitty
		set_seq = "\x1bPtmux;\x1b\x1b]1337;SetUserVar=IS_NVIM=MQ==\x07\x1b\\"
		clear_seq = "\x1bPtmux;\x1b\x1b]1337;SetUserVar=IS_NVIM=\x07\x1b\\"
	end
	io.stdout:write(set_seq)
	io.stdout:flush()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			if vim.env.TMUX then
				-- Re-enable passthrough (consumed by the set_seq above)
				vim.system({ "tmux", "set", "-p", "allow-passthrough", "single" }):wait()
			end
			io.stdout:write(clear_seq)
			io.stdout:flush()
		end,
	})
end

local wincmd_dir = { left = "h", right = "l", up = "k", down = "j" }
local tmux_flag = { left = "-L", right = "-R", up = "-U", down = "-D" }
local tmux_edge_var = { left = "pane_at_left", right = "pane_at_right", up = "pane_at_top", down = "pane_at_bottom" }

local function is_floating(win)
	return vim.api.nvim_win_get_config(win or 0).relative ~= ""
end

-- Embedded floating windows have zindex < 50 (e.g. snacks explorer sidebar)
local function is_embedded_float(win)
	if not is_floating(win) then
		return false
	end
	local cfg = vim.api.nvim_win_get_config(win or 0)
	return cfg.zindex ~= nil and cfg.zindex < 50
end

local function at_vim_edge(dir)
	return vim.fn.winnr() == vim.fn.winnr(wincmd_dir[dir])
end

local function mux_move(dir)
	if not mux then
		return false
	end
	if mux == "kitty" then
		local r = vim.system(
			{ "kitty", "@", "action", "kitten", "navigate.py", "--no-passthrough", dir },
			{ text = true }
		):wait()
		return r.code == 0
	elseif mux == "tmux" then
		local edge = vim.system(
			{ "tmux", "display-message", "-p", "#{" .. tmux_edge_var[dir] .. "}" },
			{ text = true }
		):wait()
		if edge.code == 0 and vim.trim(edge.stdout or "") == "1" then
			return false
		end
		return vim.system({ "tmux", "select-pane", tmux_flag[dir] }, { text = true }):wait().code == 0
	end
	return false
end

-- Track which window we navigated from (mirrors kitty navigate.py's came_from_id)
local _nav_prev = {}

-- Find the nearest focusable window in a direction using screen geometry.
-- When multiple candidates exist, prefers the window we previously came from.
local function find_win_in_direction(dir, prefer)
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

		if dir == "down" then
			local overlap = math.min(right, wr) > math.max(left, wl)
			if wt >= bot - 1 and overlap then
				valid, dist = true, wt - bot
			end
		elseif dir == "up" then
			local overlap = math.min(right, wr) > math.max(left, wl)
			if wb <= top + 1 and overlap then
				valid, dist = true, top - wb
			end
		elseif dir == "right" then
			local overlap = math.min(bot, wb) > math.max(top, wt)
			if wl >= right - 1 and overlap then
				valid, dist = true, wl - right
			end
		elseif dir == "left" then
			local overlap = math.min(bot, wb) > math.max(top, wt)
			if wr <= left + 1 and overlap then
				valid, dist = true, left - wr
			end
		end

		if valid then
			if prefer and win == prefer then
				return win
			end
			if dist < best_dist then
				best, best_dist = win, dist
			end
		end
		::continue::
	end
	return best
end

function M.move_cursor(dir)
	local cur = vim.api.nvim_get_current_win()

	-- Regular floating windows (snacks terminal): always delegate to mux
	if is_floating() and not is_embedded_float() then
		mux_move(dir)
		return
	end

	-- Embedded floats and normal splits: geometric navigation with recency preference
	local target = find_win_in_direction(dir, _nav_prev[cur])
	if target then
		_nav_prev[target] = cur
		vim.api.nvim_set_current_win(target)
	else
		mux_move(dir)
	end
end

function M.move_cursor_previous()
	local prev = vim.fn.win_getid(vim.fn.winnr("#"))
	if prev and vim.api.nvim_win_is_valid(prev) then
		vim.api.nvim_set_current_win(prev)
	end
end

function M.resize(dir, amount)
	amount = amount or 3
	if dir == "left" or dir == "right" then
		local at_edge = vim.fn.winnr() == vim.fn.winnr("l")
		local grow = (dir == "right") ~= at_edge
		vim.cmd("vertical resize " .. (grow and "+" or "-") .. amount)
	else
		local at_edge = vim.fn.winnr() == vim.fn.winnr("j")
		local grow = (dir == "down") ~= at_edge
		vim.cmd("resize " .. (grow and "+" or "-") .. amount)
	end
end

function M.swap_buf(dir)
	if is_floating() then
		return
	end
	if at_vim_edge(dir) then
		return
	end

	local buf1 = vim.api.nvim_get_current_buf()
	local win1 = vim.api.nvim_get_current_win()

	vim.cmd("wincmd " .. wincmd_dir[dir])
	local buf2 = vim.api.nvim_get_current_buf()
	local win2 = vim.api.nvim_get_current_win()

	if win1 == win2 then
		return
	end

	vim.api.nvim_win_set_buf(win1, buf2)
	vim.api.nvim_win_set_buf(win2, buf1)
end

return M
