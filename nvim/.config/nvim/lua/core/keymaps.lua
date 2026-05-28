local map = vim.keymap.set

-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear search highlights on escape
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Quick window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })

-- Visual Mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move block down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move block up" })
