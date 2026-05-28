local minifiles = require("mini.files")
local minipairs = require("mini.pairs")
local indentscope = require("mini.indentscope")

minifiles.setup({
	windows = {
		-- Maximum number of simultaneous columns to show
		max_number = math.huge,
		-- Preview window settings
		preview = true,
		-- Width of columns
		width_focus = 50,
		-- Width of non-focused window
		width_nofocus = 15,
		-- Width of preview window
		width_preview = 50,
	},
	options = {
		-- Whether to delete permanently or use system trash
		use_as_default_explorer = true,
	},
})

minipairs.setup({
	modes = { insert = true, command = false, terminal = false },
})

indentscope.setup({
	draw = {
		delay = 0,
	},
	symbol = "┃",
})

local open_explorer = function()
	local bufname = vim.api.nvim_buf_get_name(0)
	if vim.fn.filereadable(bufname) == 1 then
		minifiles.open(bufname)
	else
		minifiles.open()
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "alpha", "mason", "fzf", "lazy" },
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})

vim.keymap.set("n", "<leader>e", open_explorer, { desc = "Toggle File Explorer" })
