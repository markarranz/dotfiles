-- Disable sqlls when googlesql-ls is available
return {
	filetypes = vim.fn.executable("googlesql-ls") == 1 and {} or { "sql" },
}
