-- ~/.config/nvim/lua/plugins/linting.lua

local lint = require("lint")

-- 1. Map the linters to your filetypes
lint.linters_by_ft = {
	php = { "phpstan" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	-- html and css don't strictly need linters if Prettier is formatting them,
	-- but you can easily add tools like 'stylelint' here later if you want.
}

-- 2. Create the Background Execution Engine
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	desc = "Trigger linting automatically",
	callback = function()
		-- Try to run the linter for the current filetype
		lint.try_lint()
	end,
})
