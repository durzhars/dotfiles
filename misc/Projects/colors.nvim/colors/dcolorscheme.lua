package.loaded["dcolorscheme.neovim"] = nil
package.loaded["dcolorscheme.groups"] = nil
package.loaded["dcolorscheme.lualine"] = nil

-- 1. Clear existing highlights
vim.cmd("hi clear")

-- 2. Reset syntax
if vim.g.syntax_on ~= nil then
	vim.cmd("syntax reset")
end

-- 3. Declare the colorscheme name for Neovim's internal engine
vim.g.colors_name = "dcolorscheme"

require("dcolorscheme").setup()
