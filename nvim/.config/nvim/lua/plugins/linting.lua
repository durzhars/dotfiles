-- ~/.config/nvim/lua/plugins/linting.lua

local lint = require("lint")

-- 1. Map the linters to your filetypes
lint.linters_by_ft = {
	php = { "phpstan" },
	python = { "ruff" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	-- html and css don't strictly need linters if Prettier is formatting them,
	-- but you can easily add tools like 'stylelint' here later if you want.
}

lint.linters.phpstan.args = {
	"analyse",
	"--error-format=json",
	"--no-progress",
	"--jobs=1",
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

-- THE EVENT FIX: Remove BufEnter.
-- Running heavy static analysis on window-switch is a massive performance trap.
-- Restrict it strictly to when you actually save your changes.
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	group = lint_augroup,
	desc = "Trigger linting automatically on save",
	callback = function()
		lint.try_lint()
	end,
})
