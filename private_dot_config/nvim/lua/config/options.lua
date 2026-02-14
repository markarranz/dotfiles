-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.colorcolumn = "+1"
vim.o.formatoptions = "j/ncroql"

vim.o.sidescroll = 1

vim.o.list = true
vim.opt.listchars = {
	tab = "  »",
	lead = "•",
	trail = "•",
	space = "•",
	eol = "",
}

-- Python Extras:
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

vim.filetype.add({
	extension = {
		gotmpl = "gotmpl",
		rasi = "rasi",
	},
	pattern = {
		[".*/hypr/.*%.conf"] = "hyprlang",
	},
})

-- bacon-ls
vim.g.lazyvim_rust_diagnostics = "bacon-ls"

-- googlesql-lsp
vim.lsp.enable("googlesql")
