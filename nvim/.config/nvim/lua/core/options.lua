-- ~/.config/nvim/lua/core/options.lua
local opt = vim.opt

-- General UI & Structure
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 500
opt.ttimeoutlen = 50

-- Standardize indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Window Splits & Space Context
opt.scrolloff = 10
opt.sidescrolloff = 10
opt.splitbelow = true
opt.splitright = true

-- Search Behavior
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Completion & Command UI
opt.pumheight = 10
opt.pumblend = 10
opt.showmode = false

-- File Backups & Persistent Undo
opt.swapfile = false
opt.backup = false

local undodir = vim.fn.expand("~/.local/state/nvim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end
opt.undofile = true
opt.undodir = undodir

opt.clipboard = "unnamedplus"

-- Custom Character Rendering & Structural Bars
opt.list = true
opt.listchars:append({
	tab = "│ ",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
})

opt.fillchars:append({
	eob = " ",
})

-- Dynamically calculate leadmultispace based on the buffer's shiftwidth
vim.api.nvim_create_autocmd({ "BufEnter", "OptionSet" }, {
	callback = function()
		local sw = vim.bo.shiftwidth
		if sw == 0 then
			sw = vim.bo.tabstop
		end
		if sw > 0 then
			local lms = "│" .. string.rep(" ", sw - 1)
			vim.opt_local.listchars:append({ leadmultispace = lms })
		end
	end,
})
