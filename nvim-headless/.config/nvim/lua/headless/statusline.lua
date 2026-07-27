-- =============================================================================
-- Built-in Statusline — Headless Edition
-- Minimal but informative, no external dependencies
-- =============================================================================

-- Mode display names and highlight groups
local mode_map = {
    ["n"]     = { name = "NORMAL",   hl = "StatusLineModeNormal" },
    ["no"]    = { name = "O-PEND",   hl = "StatusLineModeNormal" },
    ["nov"]   = { name = "O-PEND",   hl = "StatusLineModeNormal" },
    ["noV"]   = { name = "O-PEND",   hl = "StatusLineModeNormal" },
    ["no\22"] = { name = "O-PEND",   hl = "StatusLineModeNormal" },
    ["niI"]   = { name = "NORMAL",   hl = "StatusLineModeNormal" },
    ["niR"]   = { name = "NORMAL",   hl = "StatusLineModeNormal" },
    ["niV"]   = { name = "NORMAL",   hl = "StatusLineModeNormal" },
    ["nt"]    = { name = "NORMAL",   hl = "StatusLineModeNormal" },
    ["ntT"]   = { name = "NORMAL",   hl = "StatusLineModeNormal" },
    ["v"]     = { name = "VISUAL",   hl = "StatusLineModeVisual" },
    ["vs"]    = { name = "VISUAL",   hl = "StatusLineModeVisual" },
    ["V"]     = { name = "V-LINE",   hl = "StatusLineModeVisual" },
    ["Vs"]    = { name = "V-LINE",   hl = "StatusLineModeVisual" },
    ["\22"]   = { name = "V-BLOCK",  hl = "StatusLineModeVisual" },
    ["\22s"]  = { name = "V-BLOCK",  hl = "StatusLineModeVisual" },
    ["s"]     = { name = "SELECT",   hl = "StatusLineModeVisual" },
    ["S"]     = { name = "S-LINE",   hl = "StatusLineModeVisual" },
    ["\19"]   = { name = "S-BLOCK",  hl = "StatusLineModeVisual" },
    ["i"]     = { name = "INSERT",   hl = "StatusLineModeInsert" },
    ["ic"]    = { name = "INSERT",   hl = "StatusLineModeInsert" },
    ["ix"]    = { name = "INSERT",   hl = "StatusLineModeInsert" },
    ["R"]     = { name = "REPLACE",  hl = "StatusLineModeReplace" },
    ["Rc"]    = { name = "REPLACE",  hl = "StatusLineModeReplace" },
    ["Rx"]    = { name = "REPLACE",  hl = "StatusLineModeReplace" },
    ["Rv"]    = { name = "V-REPL",   hl = "StatusLineModeReplace" },
    ["Rvc"]   = { name = "V-REPL",   hl = "StatusLineModeReplace" },
    ["Rvx"]   = { name = "V-REPL",   hl = "StatusLineModeReplace" },
    ["c"]     = { name = "COMMAND",  hl = "StatusLineModeCommand" },
    ["cv"]    = { name = "EX",       hl = "StatusLineModeCommand" },
    ["ce"]    = { name = "EX",       hl = "StatusLineModeCommand" },
    ["r"]     = { name = "PROMPT",   hl = "StatusLineModeCommand" },
    ["rm"]    = { name = "MORE",     hl = "StatusLineModeCommand" },
    ["r?"]    = { name = "CONFIRM",  hl = "StatusLineModeCommand" },
    ["!"]     = { name = "SHELL",    hl = "StatusLineModeCommand" },
    ["t"]     = { name = "TERMINAL", hl = "StatusLineModeTerminal" },
}

--- Get git branch name (cached, refreshed on BufEnter/FocusGained)
local git_branch_cache = ""
local function update_git_branch()
    local handle = io.popen("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " branch --show-current 2>/dev/null")
    if handle then
        local branch = handle:read("*l")
        handle:close()
        git_branch_cache = branch and branch ~= "" and (" " .. branch) or ""
    else
        git_branch_cache = ""
    end
end

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("statusline-git", { clear = true }),
    callback = update_git_branch,
})

--- Get diagnostic counts for current buffer
local function get_diagnostics()
    local counts = { 0, 0, 0, 0 }
    for _, d in ipairs(vim.diagnostic.get(0)) do
        counts[d.severity] = (counts[d.severity] or 0) + 1
    end
    local parts = {}
    if counts[1] > 0 then table.insert(parts, "%#DiagnosticError# " .. counts[1]) end
    if counts[2] > 0 then table.insert(parts, "%#DiagnosticWarn# " .. counts[2]) end
    if counts[3] > 0 then table.insert(parts, "%#DiagnosticInfo# " .. counts[3]) end
    if counts[4] > 0 then table.insert(parts, "%#DiagnosticHint# " .. counts[4]) end
    if #parts > 0 then
        return " " .. table.concat(parts, " ") .. " %#StatusLine#"
    end
    return ""
end

--- Build the statusline string
function Statusline()
    local mode_raw = vim.api.nvim_get_mode().mode
    local mode_info = mode_map[mode_raw] or { name = mode_raw:upper(), hl = "StatusLineModeNormal" }

    local parts = {
        -- Left: Mode
        "%#" .. mode_info.hl .. "#",
        " " .. mode_info.name .. " ",
        "%#StatusLine#",

        -- Git branch
        git_branch_cache ~= "" and ("%#StatusLineGit#" .. git_branch_cache .. " %#StatusLine#") or "",

        -- Diagnostics
        get_diagnostics(),

        -- Filename (relative path, modified flag, readonly flag)
        " %<%f",
        "%m%r",

        -- Right side separator
        "%=",

        -- File info
        "%#StatusLineInfo#",
        " %{&filetype != '' ? &filetype : 'none'} ",

        -- Encoding + format
        "%#StatusLine#",
        " %{&fileencoding != '' ? &fileencoding : &encoding}",
        "[%{&fileformat}] ",

        -- Position
        "%#StatusLinePos#",
        " %l:%c %p%% ",
    }

    return table.concat(parts)
end

vim.opt.statusline = "%!v:lua.Statusline()"
