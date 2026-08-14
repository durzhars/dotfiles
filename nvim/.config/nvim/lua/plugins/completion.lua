-- ~/.config/nvim/lua/plugins/completion.lua

local cmp = require("blink.cmp")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip").filetype_extend("php", { "laravel", "blade", "html" })
cmp.build():wait(60000)
cmp.setup({
	keymap = {
		preset = "default",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	completion = {
		menu = { auto_show = true },
		trigger = { show_on_keyword = true },
		documentation = { auto_show = false },
		list = {
			selection = {
				auto_insert = false, -- Prevents it from typing into your buffer
			},
		},
		ghost_text = {
			enabled = true,
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	snippets = { preset = "luasnip" },
})
