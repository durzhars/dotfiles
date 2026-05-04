local M = {}

M.setup = function()
	local colors = require("dcolorscheme.neovim")
	return {
		--
		-- ==========================================
		-- CORE UI
		-- ==========================================
		--
		Normal = { fg = colors.fg, bg = colors.bg },
		NormalFloat = { fg = colors.fg, bg = colors.bg_float },
		FloatBorder = { fg = colors.border, bg = colors.bg_float },
		ColorColumn = { bg = colors.bg_alt },
		CursorLine = { bg = colors.bg_alt },
		CursorLineNr = { fg = colors.primary, bold = true },
		LineNr = { fg = colors.fg_dim },
		SignColumn = { bg = colors.bg_alt },
		WinSeparator = { fg = colors.border },
		-- Autocomplete Menu (Pmenu)
		Pmenu = { fg = colors.fg, bg = colors.bg_alt },
		PmenuSel = { fg = colors.bg, bg = colors.primary },
		PmenuSbar = { bg = colors.bg_alt },
		PmenuThumb = { bg = colors.fg_dim },
		-- Search & Selection
		Search = { fg = colors.bg, bg = colors.secondary },
		IncSearch = { fg = colors.bg, bg = colors.primary },
		Visual = { bg = colors.bg_float },
		--
		-- ==========================================
		-- BASE SYNTAX (Inherited by Treesitter)
		-- ==========================================
		--
		Comment = { fg = colors.fg_dim, italic = true },
		String = { fg = colors.secondary },
		Number = { fg = colors.tertiary },
		Boolean = { fg = colors.tertiary, bold = true },
		Identifier = { fg = colors.fg },
		Function = { fg = colors.primary, bold = true },
		Statement = { fg = colors.primary },
		Keyword = { fg = colors.primary, italic = true },
		Conditional = { fg = colors.primary, italic = true },
		Operator = { fg = colors.fg_dim },
		Type = { fg = colors.secondary, bold = true },
		Constant = { fg = colors.tertiary, bold = true },
		--
		-- ==========================================
		-- TREESITTER SPECIFICS
		-- ==========================================
		--
		["@variable"] = { fg = colors.fg },
		["@variable.parameter"] = { fg = colors.tertiary, italic = true },
		["@variable.member"] = { fg = colors.secondary }, -- Object properties
		["@function.method"] = { link = "Function" },
		["@function.builtin"] = { fg = colors.primary, italic = true },
		["@type.builtin"] = { fg = colors.secondary, italic = true },
		["@constructor"] = { fg = colors.primary, bold = true },
		["@tag"] = { fg = colors.primary }, -- HTML/XML tags
		["@tag.attribute"] = { fg = colors.secondary, italic = true },
		-- Diagnostics
		DiagnosticError = { fg = colors.error },
		DiagnosticWarn = { fg = colors.warning },
		DiagnosticInfo = { fg = colors.info },
	}
end

return M
