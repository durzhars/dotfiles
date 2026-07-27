-- =============================================================================
-- Netrw Configuration — Headless File Explorer
-- Tuned netrw as a lightweight replacement for mini.files / nvim-tree
-- =============================================================================

-- Tree-style listing
vim.g.netrw_liststyle = 3

-- Open files in the previous window
vim.g.netrw_browse_split = 0

-- 25% width sidebar
vim.g.netrw_winsize = 25

-- Remove the banner
vim.g.netrw_banner = 0

-- Keep the current directory in sync
vim.g.netrw_keepdir = 0

-- Human-readable file sizes
vim.g.netrw_sizestyle = "H"

-- Sort case-insensitively
vim.g.netrw_sort_options = "i"

-- Hide dotfiles by default (toggle with gh)
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]

-- Preview in vertical split
vim.g.netrw_preview = 1
vim.g.netrw_alto = 0
