-- ~/.config/nvim/lua/plugins/conform.lua
require("conform").setup({
	formatters_by_ft = {
		php = { "php_cs_fixer" },
		html = { "prettier" },
		css = { "prettier" },
		javascript = { "prettier" },
		json = { "prettier" },
		markdown = { "prettier" },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ lsp_fallback = true, async = false })
end, { desc = "Format file or range" })
