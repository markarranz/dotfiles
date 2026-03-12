return {
	cmd = { "ssql-ls-full" },
	filetypes = { "sql" },
	root_markers = { ".googlesql.json", ".git" },
	settings = {},
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
