-- ~/.config/nvim/lua/plugins/treesitter.lua

require("nvim-treesitter").setup({
	ensure_installed = {
		"c",
		"cpp",
		"java",
		"python",
		"php",
		"php_only",
		"phpdoc", -- For Laravel
		"html",
		"css",
		"javascript",
		"json",
		"bash",
		"yaml",
		"toml",
		"lua",
	},
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
})
