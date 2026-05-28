-- ~/.config/nvim/lua/plugins/lsp.lua

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 3 },
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "require" },
			},
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("bashls", {
	capabilities = capabilities,
	filetypes = { "bash", "sh", "zsh" },
})

vim.lsp.config("intelephense", {
	capabilities = capabilities,
	settings = {
		stubs = {
			"apache",
			"bcmath",
			"bz2",
			"calendar",
			"Core",
			"curl",
			"date",
			"dom",
			"filter",
			"gd",
			"hash",
			"iconv",
			"json",
			"libxml",
			"mbstring",
			"mysqli",
			"mysqlnd",
			"openssl",
			"pcre",
			"PDO",
			"pdo_mysql",
			"session",
			"standard",
			"xml",
			"zip",
		},
		searchPaths = {
			"app",
		},
	},
})

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "php",
-- 	desc = "Forcefully start Intelephense",
-- 	callback = function()
-- 		local root = vim.fs.root(0, { "composer.json", ".git" })
-- 		local final_root = root or vim.fn.getcwd()
--
-- 		vim.lsp.start({
-- 			name = "intelephense",
-- 			cmd = { "intelephense", "--stdio" },
-- 			filetypes = { "php" },
-- 			root_dir = final_root,
-- 			capabilities = capabilities,
-- 			settings = {
-- 				intelephense = {
-- 					telemetry = { enabled = false },
-- 				},
-- 			},
-- 		})
-- 	end,
-- })

require("mason-lspconfig").setup({
	ensure_installed = {
		"clangd",
		"jdtls",
		"pyright",
		"intelephense",
		"lua_ls",
		"html",
		"cssls",
		"ts_ls",
		"bashls",
	},
	automatic_enable = false,
})

vim.lsp.enable("clangd")
vim.lsp.enable("jdtls")
vim.lsp.enable("pyright")
vim.lsp.enable("lua_ls")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("intelephense")
vim.lsp.enable("bashls")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		map("gd", vim.lsp.buf.definition, "Goto Definition")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("<leader>cr", vim.lsp.buf.rename, "Rename")
		map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
	end,
})
