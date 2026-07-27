-- ~/.config/nvim/lua/plugins/formatting.lua

require("conform").setup({
	formatters_by_ft = {
		php = { "php_cs_fixer" },
		c = { "clang_format" },
		blade = { "blade-formatter" },
		python = { "ruff" },
		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd" },
		html = { "prettierd" },
		css = { "prettierd" },
		json = { "prettierd" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
	},
	formatters = {
		clang_format = {
			prepend_args = { "-style={BasedOnStyle: Google, IndentWidth: 4, UseTab: Never, IndentCaseLabels: true}" },
		},
		shfmt = { append_args = { "-i", "4", "-ci", "-bn" } },
		php_cs_fixer = {
			prepend_args = { "--rules=@PSR12", "--using-cache=no", "--no-interaction" },
		},
		prettierd = {
			prepend_args = function()
				return {
					"--tab-width",
					"4",
					"--single-quote",
				}
			end,
		},
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 1500,
		lsp_format = "first",
	},
})
