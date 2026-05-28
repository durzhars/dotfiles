require("conform").setup({
	formatters_by_ft = {
		php = { "php_cs_fixer" },
		html = { "prettier" },
		css = { "prettier" },
		javascript = { "prettier" },
		json = { "prettier" },
		markdown = { "prettier" },
	},
	formatters = {
		php_cs_fixer = {
			args = { "fix", "$FILENAME", "--rules=@PSR12", "--using-cache=no", "--no-interaction" },
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ lsp_fallback = true, async = false })
end, { desc = "Format file or range" })
