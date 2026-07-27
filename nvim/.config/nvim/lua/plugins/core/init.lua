-- ~/.config/nvim/lua/plugins/init.lua

vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
require("plugins.formatting")

vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })
require("plugins.linting")

vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
require("plugins.mason")

vim.pack.add({ "https://github.com/mason-org/mason-lspconfig.nvim" })

vim.pack.add({
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
})
require("plugins.completion")

vim.pack.add({ "https://github.com/folke/lazydev.nvim" })
require("plugins.lazydev")

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })
require("plugins.lsp")

vim.pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })
require("plugins.treesitter")

vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-lualine/lualine.nvim",
})
require("plugins.lualine")

vim.pack.add({
	"https://github.com/nvim-mini/mini.files",
	"https://github.com/nvim-mini/mini.pairs",
	"https://github.com/nvim-mini/mini.notify",
	"https://github.com/nvim-mini/mini.indentscope",
})
require("plugins.mini")

vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
require("plugins.fzf")

vim.pack.add({ "https://github.com/folke/which-key.nvim" })
require("plugins.whichkey")

vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
})

vim.pack.add({ "https://github.com/goolord/alpha-nvim" })
require("plugins.alpha")
