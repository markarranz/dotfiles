local function lualine_tooling()
	local bufnr = vim.api.nvim_get_current_buf()
	local lsps = {}
	local formatters = {}
	local seen_lsps = {}
	local seen_formatters = {}
	local segments = {}

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client.name ~= "copilot" and not seen_lsps[client.name] then
			seen_lsps[client.name] = true
			table.insert(lsps, client.name)
		end
	end

	local ok, conform = pcall(require, "conform")
	if ok then
		local configured_formatters, lsp_fallback = conform.list_formatters_to_run(bufnr)
		for _, formatter in ipairs(configured_formatters) do
			if not seen_formatters[formatter.name] then
				seen_formatters[formatter.name] = true
				table.insert(formatters, formatter.name)
			end
		end

		if lsp_fallback and not seen_formatters.LSP then
			seen_formatters.LSP = true
			table.insert(formatters, "LSP")
		end
	end

	if #lsps > 0 then
		table.insert(segments, "󰒋 LSP: " .. table.concat(lsps, ", "))
	end

	if #formatters > 0 then
		table.insert(segments, "󰏫 FMT: " .. table.concat(formatters, ", "))
	end

	return #segments > 0 and table.concat(segments, " · ") or ""
end

return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
	{
		"akinsho/bufferline.nvim",
		opts = {
			options = {
				indicator = { style = "underline" },
				separator_style = "slant",
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				["html"] = { "prettier" },
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			-- Show relative filepath
			local c = opts.sections.lualine_c
			c[#c - 1] = { "filename", path = 1 }

			-- Show active tooling for current buffer
			opts.sections.lualine_z = {
				lualine_tooling,
			}
		end,
	},
}
