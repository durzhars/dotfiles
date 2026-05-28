local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
	"                                                     ",
	"                                                     ",
	"                                                     ",
	"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
	"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
	"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
	"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
	"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
	"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
	"                                                     ",
}

dashboard.section.buttons.val = {
	dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
	dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
	dashboard.button("g", "󰊢  Live grep", ":FzfLua live_grep<CR>"),
	dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua<CR>"),
	dashboard.button("q", "󰅚  Quit Neovim", ":qa<CR>"),
}

dashboard.section.header.opts.hl = "String"
dashboard.section.buttons.opts.hl = "Function"
dashboard.opts.layout = {
	{ type = "padding", val = 5 },
	dashboard.section.header,
	{ type = "padding", val = 2 },
	dashboard.section.buttons,
	{ type = "padding", val = 4 },
	dashboard.section.footer,
}

alpha.setup(dashboard.opts)
