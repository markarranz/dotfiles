-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local nav = require("lib.navigate")
local function move(dir)
	return function()
		nav.move_cursor(dir)
	end
end
local nav_modes = { "n", "x", "s", "o", "i", "c", "t" }

-- moving between splits (and across mux panes at edges)
vim.keymap.set(nav_modes, "<C-h>", move("left"))
vim.keymap.set(nav_modes, "<C-j>", move("down"))
vim.keymap.set(nav_modes, "<C-k>", move("up"))
vim.keymap.set(nav_modes, "<C-l>", move("right"))
vim.keymap.set("n", "<C-\\>", nav.move_cursor_previous)

vim.keymap.set("n", "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame<cr>", {
	desc = "Enable/Disable Blame Virtual Text",
})

vim.keymap.set("x", "<leader>ya", function()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local file = vim.fn.expand("%:.")
	if file == "" then
		file = vim.fn.expand("%:p:t")
	end

	local reference = string.format("%s#%d", file, start_line)
	if end_line ~= start_line then
		reference = string.format("%s-%d", reference, end_line)
	end

	vim.fn.setreg("+", reference)
	vim.notify("Copied " .. reference)
end, {
	desc = "Yank Agent Reference",
})

-- buffer-local terminal keymaps (higher priority than global)
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(ev)
		for key, dir in pairs({ ["<C-h>"] = "left", ["<C-j>"] = "down", ["<C-k>"] = "up", ["<C-l>"] = "right" }) do
			vim.keymap.set("t", key, move(dir), { buffer = ev.buf })
		end
	end,
})

-- <C-Space> in terminal mode: exit to normal mode and open which-key
vim.keymap.set("t", "<C-Space>", function()
	vim.cmd("stopinsert")
	vim.schedule(function()
		require("which-key").show({ keys = " ", loop = true })
	end)
end)

-- resizing splits
vim.keymap.set("n", "<A-h>", function()
	nav.resize("left")
end)
vim.keymap.set("n", "<A-j>", function()
	nav.resize("down")
end)
vim.keymap.set("n", "<A-k>", function()
	nav.resize("up")
end)
vim.keymap.set("n", "<A-l>", function()
	nav.resize("right")
end)

-- swapping buffers between windows
vim.keymap.set("n", "<C-A-h>", function()
	nav.swap_buf("left")
end)
vim.keymap.set("n", "<C-A-j>", function()
	nav.swap_buf("down")
end)
vim.keymap.set("n", "<C-A-k>", function()
	nav.swap_buf("up")
end)
vim.keymap.set("n", "<C-A-l>", function()
	nav.swap_buf("right")
end)
