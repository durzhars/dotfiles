-- =============================================================================
-- Core Neovim Options — Headless (No-Plugin) Edition
-- Mirrors full nvim config options for muscle-memory consistency
-- =============================================================================

local opt = vim.opt

-- UI & Appearance
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false           -- statusline handles this
opt.laststatus = 3             -- global statusline
opt.pumheight = 10
opt.cmdheight = 1

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Editing & Wrapping
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.virtualedit = "block"

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Files & Performance
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 300

-- Ensure undodir exists
local state_dir = pcall(vim.fn.stdpath, "state") and vim.fn.stdpath("state") or vim.fn.stdpath("data")
local undodir = state_dir .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir

-- Clipboard (use system clipboard if available)
opt.clipboard = "unnamedplus"

-- Misc
opt.mouse = "a"
opt.confirm = true
opt.shortmess:append("sI")    -- reduce startup messages

-- Whitespace rendering
opt.list = true
opt.listchars = {
    tab = "│ ",
    trail = "·",
    extends = "⟩",
    precedes = "⟨",
}
opt.fillchars = { eob = " " }

-- Dynamic indent guides via leadmultispace
-- Adjusts the guide character spacing based on each buffer's shiftwidth
vim.api.nvim_create_autocmd({ "BufEnter", "OptionSet" }, {
    group = vim.api.nvim_create_augroup("headless-indent-guides", { clear = true }),
    callback = function()
        local sw = vim.bo.shiftwidth
        if sw == 0 then
            sw = vim.bo.tabstop
        end
        if sw > 0 then
            local lms = "│" .. string.rep(" ", sw - 1)
            pcall(function()
                vim.opt_local.listchars:append({ leadmultispace = lms })
            end)
        end
    end,
})

-- Wildmenu (command-line completion)
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignorecase = true
opt.wildignore:append({
    "*.o", "*.obj", "*.pyc", "*.pyo", "__pycache__",
    "*.swp", "*.bak", "*~",
    ".git/*", "node_modules/*", ".venv/*",
})

-- Built-in completion (omnicomplete + buffer)
opt.completeopt = "menuone,noinsert,noselect,popup"
opt.complete = ".,w,b,u,t"

-- Grep program (use rg if available)
if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
    opt.grepformat = "%f:%l:%c:%m"
end

-- Disable builtin providers (performance)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
