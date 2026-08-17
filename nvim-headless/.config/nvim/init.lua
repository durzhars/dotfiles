-- ===================================================================
-- Headless Neovim Configuration — init.lua
-- Lightweight, zero-dependency config for SSH/server environments
-- No plugin manager — pure Neovim built-ins only
-- ===================================================================

-- Guard for older Neovim versions (< 0.7.0) lacking modern Lua APIs
if vim.fn.has("nvim-0.7.0") == 0 then
    vim.cmd([[
        set number relativenumber cursorline expandtab shiftwidth=4 tabstop=4
        set ignorecase smartcase hlsearch incsearch undofile
    ]])
    return
end

-- Set leader keys BEFORE anything else
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load modules
require("headless.options")
require("headless.keymaps")
require("headless.statusline")
require("headless.terminal")
require("headless.autocmds")
require("headless.netrw")
require("headless.colorscheme")
