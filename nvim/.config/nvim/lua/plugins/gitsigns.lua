-- ~/.config/nvim/lua/plugins/fzf.lua

require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	on_attach = function(bufnr)
		local gs = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Hunk Navigation
		map("n", "]h", function()
			if vim.wo.diff then
				return "]h"
			end
			vim.schedule(function()
				gs.nav_hunk("next")
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Next Git Hunk" })

		map("n", "[h", function()
			if vim.wo.diff then
				return "[h"
			end
			vim.schedule(function()
				gs.nav_hunk("prev")
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Previous Git Hunk" })

		-- Hunk Actions
		map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage Hunk" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Reset Hunk" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "Blame Line" })
		map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
		map("n", "<leader>hd", gs.diffthis, { desc = "Diff Against Index" })
	end,
})
