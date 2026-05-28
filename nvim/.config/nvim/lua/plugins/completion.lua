-- ~/.config/nvim/lua/plugins/completion.lua

local cmp = require("blink.cmp")
cmp.build():wait(60000)
cmp.setup({
	keymap = {
		preset = "default",
		["<Tab>"] = { "select_and_accept", "fallback" },
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	completion = {
		menu = { auto_show = true },
		trigger = { show_on_keyword = true },
		documentation = { auto_show = false },
	},
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
})
