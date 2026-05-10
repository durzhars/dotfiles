local M = {}
local watcher_active = false
local last_reload = 0

M.setup = function()
	local groups = require("dcolorscheme.groups").setup()
	for group, settings in pairs(groups) do
		vim.api.nvim_set_hl(0, group, settings)
	end
	if not watcher_active then
		M.watch()
	end
end

M.reload = function()
	vim.cmd("colorscheme dcolorscheme")
	if package.loaded["lualine"] then
		require("lualine").setup({
			options = { theme = require("dcolorscheme.lualine") },
		})
	end
	vim.notify("Dynamic Colors Reloaded", vim.log.levels.INFO)
end

M.watch = function()
	local path = vim.fn.expand("~/Projects/colors.nvim/lua/dcolorscheme/neovim.lua")
	local watcher = vim.uv.new_fs_event()

	if watcher then
		watcher:start(
			path,
			{},
			vim.schedule_wrap(function(err, filename, events)
				if events and events.change then
					local now = vim.uv.now()
					if now - last_reload > 500 then
						last_reload = now
						M.reload()
					end
				end
			end)
		)
		watcher_active = true
	end
end

return M
