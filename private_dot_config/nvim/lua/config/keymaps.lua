-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local nav = require("lib.navigate")
local function move(dir)
	return function()
		nav.move_cursor(dir)
	end
end

-- moving between splits (and across mux panes at edges)
vim.keymap.set("n", "<C-h>", move("left"))
vim.keymap.set("n", "<C-j>", move("down"))
vim.keymap.set("n", "<C-k>", move("up"))
vim.keymap.set("n", "<C-l>", move("right"))
vim.keymap.set("n", "<C-\\>", nav.move_cursor_previous)

-- buffer-local terminal keymaps (higher priority than global)
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(ev)
		for key, dir in pairs({ ["<C-h>"] = "left", ["<C-j>"] = "down", ["<C-k>"] = "up", ["<C-l>"] = "right" }) do
			vim.keymap.set("t", key, move(dir), { buffer = ev.buf })
		end
	end,
})

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
