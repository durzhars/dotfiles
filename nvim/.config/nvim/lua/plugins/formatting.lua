-- ~/.config/nvim/lua/plugins/formatting.lua

require("conform").setup({
	formatters_by_ft = {
		php = { "php_cs_fixer", "prettier" },
		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
	},
	formatters = {
		shfmt = { append_args = { "-i", "2", "-ci", "-bn" } },
		php_cs_fixer = {
			prepend_args = { "--rules=@PSR12", "--using-cache=no", "--no-interaction" },
		},
		prettier = {
			prepend_args = function()
				return {
					"--tab-width",
					"4",
					"--single-quote",
					"--config-precedence",
					"cli-override", -- Forces CLI args to take precedence
				}
			end,
		},
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "first",
	},
})
