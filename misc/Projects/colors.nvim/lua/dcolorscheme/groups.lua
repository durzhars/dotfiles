local M = {}

M.setup = function()
	local colors = require("dcolorscheme.neovim")
	return {
		-- ==========================================
		-- CORE UI
		-- ==========================================
		Normal = { fg = colors.fg, bg = colors.bg },
		NormalFloat = { fg = colors.fg, bg = colors.bg_alt },
		FloatBorder = { fg = colors.border, bg = colors.bg_alt },
		ColorColumn = { bg = colors.bg_alt },
		CursorLine = { bg = colors.bg_alt },
		CursorLineNr = { fg = colors.primary_bold, bold = true },
		LineNr = { fg = colors.fg_dim },
		SignColumn = { bg = colors.bg_alt },
		WinSeparator = { fg = colors.border },

		-- Search & Selection
		Search = { fg = colors.bg, bg = colors.secondary },
		IncSearch = { fg = colors.bg, bg = colors.primary },
		Visual = { bg = colors.bg_float },

		-- ==========================================
		-- BASE SYNTAX (Fallbacks for non-TS buffers)
		-- ==========================================
		Comment = { fg = colors.fg_dim, italic = true },
		String = { fg = colors.secondary },
		Number = { fg = colors.error_muted },
		Boolean = { fg = colors.error, bold = true },
		Identifier = { fg = colors.variable },
		Function = { fg = colors.primary, bold = true },
		Statement = { fg = colors.primary },
		Keyword = { fg = colors.primary_bold, italic = true },
		Conditional = { fg = colors.primary, italic = true },
		Operator = { fg = colors.primary_muted },
		Type = { fg = colors.tertiary, bold = true },
		Constant = { fg = colors.error_bold, bold = true },
		PreProc = { fg = colors.tertiary_muted },

		-- ==========================================
		-- TREESITTER
		-- ==========================================
		-- Identifiers (variable Family)
		["@variable"] = { fg = colors.variable },
		["@variable.builtin"] = { fg = colors.variable, bold = true },
		["@variable.parameter"] = { fg = colors.variable },
		["@variable.member"] = { fg = colors.variable_muted, italic = true },

		-- Constants (Error/Warm Family)
		["@constant"] = { fg = colors.error },
		["@constant.builtin"] = { fg = colors.error_bold, italic = true },
		["@constant.macro"] = { fg = colors.error_bold, bold = true },
		["@module"] = { fg = colors.fg_light },
		["@label"] = { fg = colors.primary_muted, italic = true },

		-- Literals (Secondary & Error Families)
		["@string"] = { fg = colors.fg_light },
		["@string.documentation"] = { fg = colors.secondary_muted, italic = true },
		["@string.regexp"] = { fg = colors.error_bold },
		["@string.escape"] = { fg = colors.primary, bold = true },
		["@character"] = { fg = colors.secondary },
		["@boolean"] = { fg = colors.error, italic = true },
		["@number"] = { fg = colors.error_muted },
		["@number.float"] = { fg = colors.error_muted },

		-- Types (Tertiary Family)
		["@type"] = { fg = colors.tertiary, bold = true },
		["@type.builtin"] = { fg = colors.primary, bold = true },
		["@attribute"] = { fg = colors.tertiary_muted, italic = true },
		["@property"] = { fg = colors.tertiary_bold },

		-- Functions (Primary & Tertiary Families)
		["@function"] = { fg = colors.primary, bold = true },
		["@function.builtin"] = { fg = colors.primary_bold, bold = true, italic = true },
		["@function.call"] = { fg = colors.tertiary_bold, italic = true },
		["@function.method"] = { fg = colors.tertiary, bold = true },
		["@function.method.call"] = { fg = colors.tertiary_bold },
		["@constructor"] = { fg = colors.primary_bold, bold = true },
		["@operator"] = { fg = colors.primary_muted },

		-- Keywords (Primary Family)
		["@keyword"] = { fg = colors.primary, italic = true },
		["@keyword.coroutine"] = { fg = colors.primary_bold, italic = true, bold = true },
		["@keyword.function"] = { fg = colors.primary_bold, italic = true },
		["@keyword.operator"] = { fg = colors.primary_muted, bold = true },
		["@keyword.import"] = { fg = colors.primary_muted, italic = true },
		["@keyword.type"] = { fg = colors.primary },
		["@keyword.modifier"] = { fg = colors.primary_muted, italic = true },
		["@keyword.repeat"] = { fg = colors.primary, italic = true },
		["@keyword.return"] = { fg = colors.primary_bold, italic = true, bold = true },
		["@keyword.exception"] = { fg = colors.error, italic = true },
		["@keyword.conditional"] = { fg = colors.primary, italic = true },
		["@keyword.directive"] = { fg = colors.fg_dim, italic = true },

		-- Punctuation (Dimmed to reduce visual noise)
		["@punctuation.delimiter"] = { fg = colors.fg_dim },
		["@punctuation.bracket"] = { fg = colors.secondary_bold },
		["@punctuation.special"] = { fg = colors.primary_muted },

		-- Markup & Web (HTML, Markdown, Blade)
		["@tag"] = { fg = colors.primary },
		["@tag.attribute"] = { fg = colors.tertiary_muted, italic = true },
		["@tag.delimiter"] = { fg = colors.fg_dim },
		["@markup.heading"] = { fg = colors.primary_bold, bold = true },
		["@markup.quote"] = { fg = colors.secondary_muted, italic = true },
		["@markup.list"] = { fg = colors.tertiary },
		["@markup.link.label"] = { fg = colors.secondary },
		["@markup.link.url"] = { fg = colors.fg_dim, underline = true },
		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },

		-- Comments
		["@comment.documentation"] = { fg = colors.secondary_muted, italic = true },
		["@comment.documentation.param"] = { fg = colors.primary_muted, italic = true }, -- Catches @param
		["@comment.documentation.variable"] = { fg = colors.variable, italic = true }, -- Catches $path

		-- ==========================================
		-- DOCBLOCKS (phpdoc, jsdoc, luadoc, doxygen)
		-- ==========================================
		["@type.doc"] = { fg = colors.tertiary_muted, italic = true, bold = true },
		["@variable.parameter.doc"] = { fg = colors.variable_muted, italic = true },

		-- ==========================================
		-- DIAGNOSTICS & LSP
		-- ==========================================
		DiagnosticError = { fg = colors.error },
		DiagnosticWarn = { fg = colors.diag_warn },
		DiagnosticInfo = { fg = colors.diag_info },
		DiagnosticHint = { fg = colors.diag_hint },
		DiagnosticUnderlineError = { sp = colors.error, undercurl = true },
		DiagnosticUnderlineWarn = { sp = colors.diag_warn, undercurl = true },
		DiagnosticUnderlineInfo = { sp = colors.diag_info, undercurl = true },
		DiagnosticUnderlineHint = { sp = colors.diag_hint, undercurl = true },
		LspReferenceText = { bg = colors.bg_alt },
		LspReferenceRead = { bg = colors.bg_alt },
		LspReferenceWrite = { bg = colors.bg_alt, underline = true },

		-- ==========================================
		-- GIT (Gitsigns / Diff)
		-- ==========================================
		GitSignsAdd = { fg = colors.secondary },
		GitSignsChange = { fg = colors.diag_warn },
		GitSignsDelete = { fg = colors.error },
		DiffAdd = { bg = colors.bg_alt, fg = colors.secondary },
		DiffChange = { bg = colors.bg_alt, fg = colors.diag_warn },
		DiffDelete = { bg = colors.bg_alt, fg = colors.error },
		DiffText = { bg = colors.secondary_bold, fg = colors.bg },

		-- ==========================================
		-- COMPLETION (Cmp / Blink) & MENUS
		-- ==========================================
		Pmenu = { fg = colors.fg, bg = colors.bg_alt },
		PmenuSel = { fg = colors.bg, bg = colors.primary },
		PmenuSbar = { bg = colors.bg_alt },
		PmenuThumb = { bg = colors.fg_dim },
		CmpItemAbbr = { fg = colors.fg },
		CmpItemAbbrDeprecated = { fg = colors.fg_dim, strikethrough = true },
		CmpItemAbbrMatch = { fg = colors.primary_bold, bold = true },
		CmpItemAbbrMatchFuzzy = { fg = colors.primary_bold, bold = true },
		CmpItemKind = { fg = colors.tertiary },
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
		TelescopeSelection = { bg = colors.bg_alt, fg = colors.primary_bold, bold = true },
		TelescopeMatching = { fg = colors.primary_bold, bold = true },

		-- ==========================================
		-- SNACKS.NVIM & ICONS
		-- ==========================================
		SnacksPickerDir = { fg = colors.secondary_muted },
		SnacksPickerFile = { fg = colors.fg_light },
		SnacksPickerMatch = { fg = colors.primary_bold, bold = true },
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
