return {
	"folke/lazydev.nvim",
	opts = function(_, opts)
		local stubs = "/usr/share/hypr/stubs"
		if vim.fn.isdirectory(stubs) == 1 then
			opts.library = opts.library or {}
			table.insert(opts.library, { path = stubs, words = { "hl" } })
		end
	end,
}
