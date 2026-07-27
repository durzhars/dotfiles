-- ===================================================================
-- Headless Neovim Configuration — init.lua
-- Lightweight, zero-dependency config for SSH/server environments
-- No plugin manager — pure Neovim built-ins only
-- ===================================================================

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
