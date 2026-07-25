-- ~/.config/nvim/lua/plugins/fzf.lua
local fzf = require("fzf-lua")

fzf.setup({
	"default-title",
	winopts = {
		border = "rounded",
		preview = {
			border = "border",
			layout = "flex", -- Automatically adjusts based on screen width
		},
	},
	-- Use your system ripgrep for lightning-fast content searching
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
	},
})

-- 1. Find ANY file in your project (replaces the file explorer for quick jumps)
vim.keymap.set("n", "<leader><space>", fzf.files, { desc = "Fuzzy Find Files" })

-- 2. Search for text/code across the entire project (Crucial for Laravel routing/controllers)
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live Grep (Search Content)" })

-- 3. Switch between open files (This is why you don't need Tabs)
vim.keymap.set("n", "<leader>,", fzf.buffers, { desc = "Find Open Buffers" })

-- 4. Search Neovim documentation
vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "Search Help" })
