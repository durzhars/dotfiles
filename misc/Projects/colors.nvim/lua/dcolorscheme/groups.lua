local M = {}

M.setup = function()
	local colors = require("dcolorscheme.neovim")
	return {
		-- ==========================================
		-- CORE UI
		-- ==========================================
		Normal = { fg = colors.fg, bg = colors.bg },
		NormalFloat = { fg = colors.bg, bg = colors.bg_alt },
		FloatBorder = { fg = colors.border, bg = colors.bg_alt },
		ColorColumn = { bg = colors.bg_alt },
		CursorLine = { bg = colors.bg_alt },
		CursorLineNr = { fg = colors.primary, bold = true },
		LineNr = { fg = colors.fg_dim },
		SignColumn = { bg = colors.bg_alt },
		WinSeparator = { fg = colors.border },
		-- Search & Selection
		Search = { fg = colors.bg, bg = colors.secondary },
		IncSearch = { fg = colors.bg, bg = colors.primary },
		Visual = { bg = colors.bg_float },

		-- ==========================================
		-- BASE SYNTAX
		-- ==========================================
		Comment = { fg = colors.fg_dim, italic = true },
		String = { fg = colors.secondary },
		Number = { fg = colors.tertiary },
		Boolean = { fg = colors.tertiary, bold = true },
		Identifier = { fg = colors.fg_light },
		Function = { fg = colors.primary, bold = true },
		Statement = { fg = colors.primary },
		Keyword = { fg = colors.primary, italic = true },
		Conditional = { fg = colors.primary, italic = true },
		Operator = { fg = colors.fg_dim },
		Type = { fg = colors.secondary, bold = true },
		Constant = { fg = colors.tertiary, bold = true },

		-- ==========================================
		-- TREESITTER
		-- ==========================================
		["@variable"] = { fg = colors.primary },
		["@variable.parameter"] = { fg = colors.tertiary, italic = true },
		["@variable.member"] = { fg = colors.secondary }, -- Object properties
		["@function.method"] = { link = "Function" },
		["@function.builtin"] = { fg = colors.primary, italic = true },
		["@type.builtin"] = { fg = colors.secondary, italic = true },
		["@constructor"] = { fg = colors.primary, bold = true },
		["@tag"] = { fg = colors.primary }, -- HTML/XML tags
		["@tag.attribute"] = { fg = colors.secondary, italic = true },
		["@property"] = { fg = colors.secondary, bold = true },

		-- ==========================================
		-- DIAGNOSTICS & LSP
		-- ==========================================
		DiagnosticError = { fg = colors.error },
		DiagnosticWarn = { fg = colors.warning },
		DiagnosticInfo = { fg = colors.info },
		DiagnosticHint = { fg = colors.secondary_dim },
		DiagnosticUnderlineError = { sp = colors.error, undercurl = true },
		DiagnosticUnderlineWarn = { sp = colors.warning, undercurl = true },
		DiagnosticUnderlineInfo = { sp = colors.info, undercurl = true },
		DiagnosticUnderlineHint = { sp = colors.secondary_dim, undercurl = true },
		LspReferenceText = { bg = colors.bg_alt },
		LspReferenceRead = { bg = colors.bg_alt },
		LspReferenceWrite = { bg = colors.bg_alt, underline = true },

		-- ==========================================
		-- GIT (Gitsigns / Diff)
		-- ==========================================
		GitSignsAdd = { fg = colors.primary },
		GitSignsChange = { fg = colors.warning },
		GitSignsDelete = { fg = colors.error },
		DiffAdd = { bg = colors.bg_alt, fg = colors.primary },
		DiffChange = { bg = colors.bg_alt, fg = colors.secondary },
		DiffDelete = { bg = colors.bg_alt, fg = colors.error },
		DiffText = { bg = colors.secondary, fg = colors.bg },

		-- ==========================================
		-- COMPLETION (Cmp / Blink) & MENUS
		-- ==========================================
		Pmenu = { fg = colors.fg, bg = colors.bg_alt },
		PmenuSel = { fg = colors.bg, bg = colors.primary },
		PmenuSbar = { bg = colors.bg_alt },
		PmenuThumb = { bg = colors.fg_dim },
		CmpItemAbbr = { fg = colors.fg },
		CmpItemAbbrDeprecated = { fg = colors.fg_dim, strikethrough = true },
		CmpItemAbbrMatch = { fg = colors.primary, bold = true },
		CmpItemAbbrMatchFuzzy = { fg = colors.primary, bold = true },
		CmpItemKind = { fg = colors.secondary },
		CmpItemMenu = { fg = colors.fg_dim },

		-- ==========================================
		-- TELESCOPE
		-- ==========================================
		TelescopeNormal = { fg = colors.fg, bg = colors.bg },
		TelescopeBorder = { fg = colors.border, bg = colors.bg_float },
		TelescopePromptNormal = { bg = colors.bg_alt },
		TelescopePromptBorder = { fg = colors.bg_alt, bg = colors.bg_alt },
		TelescopePromptTitle = { fg = colors.bg, bg = colors.primary, bold = true },
		TelescopePreviewTitle = { fg = colors.bg, bg = colors.secondary, bold = true },
		TelescopeResultsTitle = { fg = colors.bg, bg = colors.bg, bold = true },
		TelescopeSelection = { bg = colors.bg_alt, fg = colors.primary, bold = true },
		TelescopeMatching = { fg = colors.primary, bold = true },

		-- ==========================================
		-- SNACKS.NVIM & ICONS
		-- ==========================================
		SnacksPickerDir = { fg = colors.secondary },
		SnacksPickerFile = { fg = colors.fg_light },
		SnacksPickerMatch = { fg = colors.primary, bold = true },
		SnacksPickerBorder = { fg = colors.border, bg = colors.bg_alt },
		SnacksPickerTitle = { fg = colors.primary, bg = colors.bg_float, bold = true },
		SnacksPickerListCursorLine = { bg = colors.bg_float },

		Directory = { fg = colors.primary },
		MiniIconsAzure = { link = "Function" },
		MiniIconsBlue = { link = "Function" },
		MiniIconsCyan = { link = "Type" },
		MiniIconsGreen = { link = "String" },
		MiniIconsGrey = { link = "Comment" },
		MiniIconsOrange = { link = "DiagnosticWarn" },
		MiniIconsPurple = { link = "Constant" },
		MiniIconsRed = { link = "DiagnosticError" },
		MiniIconsYellow = { link = "DiagnosticWarn" },
		DevIconDefault = { link = "Type" },
	}
end

return M
