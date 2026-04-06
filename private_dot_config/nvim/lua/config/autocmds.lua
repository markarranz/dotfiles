-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Prevent the Claude Code terminal from being the only buffer.
-- When the last non-terminal window closes, open the Snacks dashboard beside it.
vim.api.nvim_create_autocmd("WinClosed", {
	callback = function()
		vim.schedule(function()
			local wins = vim.api.nvim_list_wins()
			if #wins == 1 then
				local buf = vim.api.nvim_win_get_buf(wins[1])
				if vim.bo[buf].buftype == "terminal" then
					vim.cmd("vnew")
					Snacks.dashboard()
				end
			end
		end)
	end,
})

-- Add HTML completion to gotmpl files:
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("gotmpl", { clear = true }),
	pattern = { "*.gotmpl" },
	callback = function()
		require("luasnip").filetype_set("gotmpl", { "html", "go" })
	end,
})
