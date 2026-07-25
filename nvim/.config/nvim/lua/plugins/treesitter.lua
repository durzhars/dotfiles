-- ~/.config/nvim/lua/plugins/treesitter.lua

require("tree-sitter-manager").setup({
	ensure_installed = {
		"c",
		"cpp",
		"java",
		"python",
		"php",
		"phpdoc", -- For Laravel
		"html",
		"css",
		"javascript",
		"jsdoc",
		"json",
		"bash",
		"yaml",
		"toml",
		"lua",
		"luadoc",
		"doxygen",
		"regex",
		"markdown",
		"markdown_inline",
	},
	auto_install = true,
	highlight = true,
	indent = {
		enable = true,
	},
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Start native Treesitter and fix PHP indents",
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)
		-- If it's a PHP file, turn legacy syntax back on
		-- so GetPhpIndent() can read the code structure.
		if ev.match == "php" then
			vim.bo[ev.buf].syntax = "ON"
		end
	end,
})
