-- Projects/colors.nvim/lua/dcolorscheme/lualine.lua
local colors = require("dcolorscheme.neovim")

local transparent_bg = colors.bg

return {
	normal = {
		a = { bg = colors.primary, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_alt, fg = colors.primary },
		c = { bg = transparent_bg, fg = colors.fg },
	},
	insert = {
		a = { bg = colors.tertiary, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_alt, fg = colors.tertiary },
		-- 'c' is inherited from normal
	},
	terminal = {
		a = { bg = colors.tertiary, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_alt, fg = colors.tertiary },
	},
	visual = {
		a = { bg = colors.secondary, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_alt, fg = colors.secondary },
	},
	command = {
		a = { bg = colors.secondary, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_alt, fg = colors.warning },
	},
	replace = {
		a = { bg = colors.error, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_alt, fg = colors.error },
	},
	inactive = {
		a = { bg = transparent_bg, fg = colors.primary },
		b = { bg = transparent_bg, fg = colors.fg_dim, gui = "bold" },
		c = { bg = transparent_bg, fg = colors.fg_dim },
	},
}
