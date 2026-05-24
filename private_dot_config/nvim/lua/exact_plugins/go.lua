return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts.servers = opts.servers or {}
			opts.servers.gopls = opts.servers.gopls or {}
			opts.servers.gopls.settings = vim.tbl_deep_extend("force", opts.servers.gopls.settings or {}, {
				gopls = {
					semanticTokens = false,
				},
			})

			opts.setup = opts.setup or {}
			opts.setup.gopls = function() end
		end,
	},
}
