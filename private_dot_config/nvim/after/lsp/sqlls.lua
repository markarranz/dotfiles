return {
	filetypes = vim.fn.executable("ssql-ls-full") == 1 and {} or { "sql" },
}
