-- ~/.config/nvim/lua/plugins/mini.lua
local minifiles = require("mini.files")
local minipairs = require("mini.pairs")
local indentscope = require("mini.indentscope")
local notify = require("mini.notify")

-- ============================================================================
-- 1. Plugin Setups
-- ============================================================================

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

-- ============================================================================
-- 2. General Keymaps & Autocmds
-- ============================================================================

local open_explorer = function()
	local bufname = vim.api.nvim_buf_get_name(0)
	if vim.fn.filereadable(bufname) == 1 then
		minifiles.open(bufname)
	else
		minifiles.open()
	end
end

vim.keymap.set("n", "<leader>e", open_explorer, { desc = "Toggle File Explorer" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "alpha", "mason", "fzf", "lazy" },
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})

notify.setup({})

vim.notify = notify.make_notify()

vim.keymap.set("n", "<leader>nh", notify.show_history, { desc = "Notification History" })

-- ============================================================================
-- 3. mini.files Git Integration
-- ============================================================================

local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
local autocmd = vim.api.nvim_create_autocmd

-- Cache for git status
local gitStatusCache = {}
local cacheTimeout = 2000 -- in milliseconds
local uv = vim.uv or vim.loop

local function isSymlink(path)
	local stat = uv.fs_lstat(path)
	return stat and stat.type == "link"
end

---@type table<string, {symbol: string, hlGroup: string}>
---@param status string
---@return string symbol, string hlGroup
local function mapSymbols(status, is_symlink)
	local statusMap = {
        -- stylua: ignore start
        [" M"] = { symbol = "•", hlGroup = "MiniDiffSignChange" },
        ["M "] = { symbol = "✹", hlGroup = "MiniDiffSignChange" },
        ["MM"] = { symbol = "≠", hlGroup = "MiniDiffSignChange" },
        ["A "] = { symbol = "+", hlGroup = "MiniDiffSignAdd" },
        ["AA"] = { symbol = "≈", hlGroup = "MiniDiffSignAdd" },
        ["D "] = { symbol = "-", hlGroup = "MiniDiffSignDelete" },
        ["AM"] = { symbol = "⊕", hlGroup = "MiniDiffSignChange" },
        ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange" },
        ["R "] = { symbol = "→", hlGroup = "MiniDiffSignChange" },
        ["U "] = { symbol = "‖", hlGroup = "MiniDiffSignChange" },
        ["UU"] = { symbol = "⇄", hlGroup = "MiniDiffSignAdd" },
        ["UA"] = { symbol = "⊕", hlGroup = "MiniDiffSignAdd" },
        ["??"] = { symbol = "?", hlGroup = "MiniDiffSignDelete" },
        ["!!"] = { symbol = "!", hlGroup = "MiniDiffSignChange" },
		-- stylua: ignore end
	}

	local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
	local gitSymbol = result.symbol
	local gitHlGroup = result.hlGroup

	local symlinkSymbol = is_symlink and "↩" or ""

	local combinedSymbol = (symlinkSymbol .. gitSymbol):gsub("^%s+", ""):gsub("%s+$", "")
	local combinedHlGroup = is_symlink and "MiniDiffSignDelete" or gitHlGroup

	return combinedSymbol, combinedHlGroup
end

---@param cwd string
---@param callback function
---@return nil
local function fetchGitStatus(cwd, callback)
	local clean_cwd = cwd:gsub("^minifiles://%d+/", "")
	local function on_exit(content)
		if content.code == 0 then
			callback(content.stdout)
		end
	end
	vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = clean_cwd }, on_exit)
end

---@param buf_id integer
---@param gitStatusMap table
---@return nil
local function updateMiniWithGit(buf_id, gitStatusMap)
	vim.schedule(function()
		local nlines = vim.api.nvim_buf_line_count(buf_id)
		local cwd = vim.fs.root(buf_id, ".git")
		local escapedcwd = cwd and vim.pesc(cwd)
		escapedcwd = vim.fs.normalize(escapedcwd)

		for i = 1, nlines do
			local entry = minifiles.get_fs_entry(buf_id, i)
			if not entry then
				break
			end
			local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
			local status = gitStatusMap[relativePath]

			if status then
				local symbol, hlGroup = mapSymbols(status, isSymlink(entry.path))
				vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
					sign_text = symbol,
					sign_hl_group = hlGroup,
					priority = 2,
				})

				-- Comment this block out if you don't want the text colored
				local line = vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
				local nameStartCol = line:find(vim.pesc(entry.name)) or 0

				if nameStartCol > 0 then
					vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, nameStartCol - 1, {
						end_col = nameStartCol + #entry.name - 1,
						hl_group = hlGroup,
					})
				end
			end
		end
	end)
end

---@param content string
---@return table
local function parseGitStatus(content)
	local gitStatusMap = {}
	for line in content:gmatch("[^\r\n]+") do
		local status, filePath = string.match(line, "^(..)%s+(.*)")
		local parts = {}
		for part in filePath:gmatch("[^/]+") do
			table.insert(parts, part)
		end
		local currentKey = ""
		for i, part in ipairs(parts) do
			if i > 1 then
				currentKey = currentKey .. "/" .. part
			else
				currentKey = part
			end
			if i == #parts then
				gitStatusMap[currentKey] = status
			else
				if not gitStatusMap[currentKey] then
					gitStatusMap[currentKey] = status
				end
			end
		end
	end
	return gitStatusMap
end

---@param buf_id integer
---@return nil
local function updateGitStatus(buf_id)
	if not vim.fs.root(buf_id, ".git") then
		return
	end
	local cwd = vim.fs.root(buf_id, ".git")
	local currentTime = os.time()

	if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
		updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
	else
		fetchGitStatus(cwd, function(content)
			local gitStatusMap = parseGitStatus(content)
			gitStatusCache[cwd] = {
				time = currentTime,
				statusMap = gitStatusMap,
			}
			updateMiniWithGit(buf_id, gitStatusMap)
		end)
	end
end

---@return nil
local function clearCache()
	gitStatusCache = {}
end

local function augroup(name)
	return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
end

autocmd("User", {
	group = augroup("start"),
	pattern = "MiniFilesExplorerOpen",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		updateGitStatus(bufnr)
	end,
})

autocmd("User", {
	group = augroup("close"),
	pattern = "MiniFilesExplorerClose",
	callback = function()
		clearCache()
	end,
})

autocmd("User", {
	group = augroup("update"),
	pattern = "MiniFilesBufferUpdate",
	callback = function(args)
		local bufnr = args.data.buf_id
		local cwd = vim.fs.root(bufnr, ".git")
		if gitStatusCache[cwd] then
			updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
		end
	end,
})
