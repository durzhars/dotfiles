-- ~/.config/nvim/init.lua
-- Core Settings
require("core.keymaps")
require("core.options")

-- require("core.autocmds")

-- Dynamic Color Scheme
vim.opt.rtp:prepend(vim.fn.expand("~/Projects/colors.nvim"))
vim.cmd.colorscheme("dcolorscheme")

-- Plugins
require("plugins.core.init")
