-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- SMART-SPLITS.NVIM
local function ss(method)
  return function() require("smart-splits")[method]() end
end

-- resizing splits
vim.keymap.set("n", "<A-h>", ss("resize_left"))
vim.keymap.set("n", "<A-j>", ss("resize_down"))
vim.keymap.set("n", "<A-k>", ss("resize_up"))
vim.keymap.set("n", "<A-l>", ss("resize_right"))
-- moving between splits
vim.keymap.set("n", "<C-h>", ss("move_cursor_left"))
vim.keymap.set("n", "<C-j>", ss("move_cursor_down"))
vim.keymap.set("n", "<C-k>", ss("move_cursor_up"))
vim.keymap.set("n", "<C-l>", ss("move_cursor_right"))
vim.keymap.set("n", "<C-\\>", ss("move_cursor_previous"))
-- buffer-local terminal keymaps (higher priority than global tmaps)
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    for key, method in pairs({
      ["<C-h>"] = "move_cursor_left",
      ["<C-j>"] = "move_cursor_down",
      ["<C-k>"] = "move_cursor_up",
      ["<C-l>"] = "move_cursor_right",
    }) do
      vim.keymap.set("t", key, ss(method), { buffer = ev.buf })
    end
  end,
})
-- swapping buffers between windows
vim.keymap.set("n", "<C-A-h>", ss("swap_buf_left"))
vim.keymap.set("n", "<C-A-j>", ss("swap_buf_down"))
vim.keymap.set("n", "<C-A-k>", ss("swap_buf_up"))
vim.keymap.set("n", "<C-A-l>", ss("swap_buf_right"))
