-- ~/.config/nvim/lua/plugins/formatting.lua

require("conform").setup({
	formatters_by_ft = {
		php = { "php_cs_fixer" },
		c = { "clang_format" },
		cpp = { "clang_format" },
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
			prepend_args = { "-style=file", "-fallback-style=LLVM" },
		},
		php_cs_fixer = {
			prepend_args = { "--using-cache=yes", "-n" },
		},
		shfmt = { append_args = { "-i", "4", "-ci", "-bn" } },
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
		lsp_format = "fallback",
	},
})
