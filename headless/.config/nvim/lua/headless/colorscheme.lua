-- =============================================================================
-- Colorscheme — Headless Edition
-- Catppuccin Mocha-inspired using only terminal colors + guicolors
-- No external plugins — pure highlight definitions
-- =============================================================================

-- Palette (Catppuccin Mocha)
local c = {
    rosewater = "#f5e0dc",
    flamingo  = "#f2cdcd",
    pink      = "#f5c2e7",
    mauve     = "#cba6f7",
    red       = "#f38ba8",
    maroon    = "#eba0ac",
    peach     = "#fab387",
    yellow    = "#f9e2af",
    green     = "#a6e3a1",
    teal      = "#94e2d5",
    sky       = "#89dceb",
    sapphire  = "#74c7ec",
    blue      = "#89b4fa",
    lavender  = "#b4befe",
    text      = "#cdd6f4",
    subtext1  = "#bac2de",
    subtext0  = "#a6adc8",
    overlay2  = "#9399b2",
    overlay1  = "#7f849c",
    overlay0  = "#6c7086",
    surface2  = "#585b70",
    surface1  = "#45475a",
    surface0  = "#313244",
    base      = "#1e1e2e",
    mantle    = "#181825",
    crust     = "#11111b",
    none      = "NONE",
}

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- ── Base UI ────────────────────────────────────────────────────────

hi("Normal",       { fg = c.text,     bg = c.none })
hi("NormalFloat",  { fg = c.text,     bg = c.surface0 })
hi("FloatBorder",  { fg = c.blue,     bg = c.surface0 })
hi("FloatTitle",   { fg = c.blue,     bg = c.surface0, bold = true })
hi("Cursor",       { fg = c.base,     bg = c.text })
hi("CursorLine",   { bg = c.surface0 })
hi("CursorLineNr", { fg = c.lavender, bold = true })
hi("LineNr",       { fg = c.overlay0 })
hi("SignColumn",   { fg = c.surface1, bg = c.none })
hi("ColorColumn",  { bg = c.surface0 })
hi("Visual",       { bg = c.surface1 })
hi("VisualNOS",    { bg = c.surface1 })

-- ── Syntax Highlighting ────────────────────────────────────────────

hi("Comment",      { fg = c.overlay0, italic = true })
hi("Constant",     { fg = c.peach })
hi("String",       { fg = c.green })
hi("Character",    { fg = c.teal })
hi("Number",       { fg = c.peach })
hi("Boolean",      { fg = c.peach })
hi("Float",        { fg = c.peach })
hi("Identifier",   { fg = c.flamingo })
hi("Function",     { fg = c.blue })
hi("Statement",    { fg = c.mauve })
hi("Conditional",  { fg = c.mauve })
hi("Repeat",       { fg = c.mauve })
hi("Label",        { fg = c.sapphire })
hi("Operator",     { fg = c.sky })
hi("Keyword",      { fg = c.mauve })
hi("Exception",    { fg = c.mauve })
hi("PreProc",      { fg = c.pink })
hi("Include",      { fg = c.mauve })
hi("Define",       { fg = c.mauve })
hi("Macro",        { fg = c.mauve })
hi("PreCondit",    { fg = c.pink })
hi("Type",         { fg = c.yellow })
hi("StorageClass", { fg = c.yellow })
hi("Structure",    { fg = c.yellow })
hi("Typedef",      { fg = c.yellow })
hi("Special",      { fg = c.pink })
hi("SpecialChar",  { fg = c.pink })
hi("Tag",          { fg = c.lavender })
hi("Delimiter",    { fg = c.overlay2 })
hi("SpecialComment", { fg = c.overlay0, italic = true })
hi("Debug",        { fg = c.red })
hi("Underlined",   { fg = c.text, underline = true })
hi("Bold",         { bold = true })
hi("Italic",       { italic = true })
hi("Error",        { fg = c.red })
hi("Todo",         { fg = c.base, bg = c.yellow, bold = true })

-- ── Diffs ──────────────────────────────────────────────────────────

hi("DiffAdd",      { bg = "#2a3834" })
hi("DiffChange",   { bg = "#2a2d3d" })
hi("DiffDelete",   { fg = c.red,    bg = "#3b2838" })
hi("DiffText",     { bg = "#3a3d52" })

-- ── Search & Matching ──────────────────────────────────────────────

hi("Search",       { fg = c.base,    bg = c.yellow })
hi("IncSearch",    { fg = c.base,    bg = c.peach })
hi("CurSearch",    { fg = c.base,    bg = c.red })
hi("MatchParen",   { fg = c.peach,   bg = c.surface1, bold = true })
hi("Substitute",   { fg = c.base,    bg = c.red })

-- ── Pmenu (completion menu) ────────────────────────────────────────

hi("Pmenu",        { fg = c.text,     bg = c.surface0 })
hi("PmenuSel",     { fg = c.text,     bg = c.surface1, bold = true })
hi("PmenuSbar",    { bg = c.surface1 })
hi("PmenuThumb",   { bg = c.overlay0 })

-- ── Splits & Tabs ──────────────────────────────────────────────────

hi("VertSplit",    { fg = c.surface1 })
hi("WinSeparator", { fg = c.surface1 })
hi("TabLine",      { fg = c.overlay0, bg = c.mantle })
hi("TabLineFill",  { bg = c.mantle })
hi("TabLineSel",   { fg = c.text,     bg = c.surface0, bold = true })
hi("WinBar",       { fg = c.text,     bg = c.none })
hi("WinBarNC",     { fg = c.overlay0, bg = c.none })

-- ── Folding ────────────────────────────────────────────────────────

hi("Folded",       { fg = c.blue,     bg = c.surface1 })
hi("FoldColumn",   { fg = c.overlay0, bg = c.none })

-- ── Messages & Errors ──────────────────────────────────────────────

hi("ErrorMsg",     { fg = c.red })
hi("WarningMsg",   { fg = c.yellow })
hi("ModeMsg",      { fg = c.text,     bold = true })
hi("MoreMsg",      { fg = c.blue })
hi("Question",     { fg = c.blue })
hi("Title",        { fg = c.blue,     bold = true })
hi("NonText",      { fg = c.overlay0 })
hi("SpecialKey",   { fg = c.overlay0 })
hi("Whitespace",   { fg = c.surface1 })
hi("EndOfBuffer",  { fg = c.base })
hi("Directory",    { fg = c.blue })
hi("Conceal",      { fg = c.overlay1 })
hi("SpellBad",     { undercurl = true, sp = c.red })
hi("SpellCap",     { undercurl = true, sp = c.yellow })
hi("SpellRare",    { undercurl = true, sp = c.green })
hi("SpellLocal",   { undercurl = true, sp = c.blue })
hi("WildMenu",     { fg = c.base,     bg = c.blue })

-- ── Diagnostics ────────────────────────────────────────────────────

hi("DiagnosticError",          { fg = c.red })
hi("DiagnosticWarn",           { fg = c.yellow })
hi("DiagnosticInfo",           { fg = c.sky })
hi("DiagnosticHint",           { fg = c.teal })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.sky })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.teal })

-- ── Statusline Highlights ──────────────────────────────────────────

hi("StatusLine",               { fg = c.text,     bg = c.mantle })
hi("StatusLineNC",             { fg = c.overlay0, bg = c.mantle })
hi("StatusLineModeNormal",     { fg = c.base,     bg = c.blue,     bold = true })
hi("StatusLineModeInsert",     { fg = c.base,     bg = c.green,    bold = true })
hi("StatusLineModeVisual",     { fg = c.base,     bg = c.mauve,    bold = true })
hi("StatusLineModeReplace",    { fg = c.base,     bg = c.red,      bold = true })
hi("StatusLineModeCommand",    { fg = c.base,     bg = c.peach,    bold = true })
hi("StatusLineModeTerminal",   { fg = c.base,     bg = c.teal,     bold = true })
hi("StatusLineGit",            { fg = c.mauve,    bg = c.mantle })
hi("StatusLineInfo",           { fg = c.subtext0, bg = c.surface0 })
hi("StatusLinePos",            { fg = c.base,     bg = c.surface2, bold = true })

-- ── Netrw ──────────────────────────────────────────────────────────

hi("netrwDir",       { fg = c.blue })
hi("netrwClassify",  { fg = c.blue })
hi("netrwLink",      { fg = c.teal })
hi("netrwSymLink",   { fg = c.teal })
hi("netrwExe",       { fg = c.green })
hi("netrwTreeBar",   { fg = c.surface1 })

-- ── Misc ───────────────────────────────────────────────────────────

hi("healthSuccess",  { fg = c.green })
hi("healthWarning",  { fg = c.yellow })
hi("healthError",    { fg = c.red })

-- Set diagnostic signs
vim.diagnostic.config({
    virtual_text = { prefix = "●", spacing = 2 },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
})
