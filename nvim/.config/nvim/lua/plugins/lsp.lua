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
	filetypes = { "bash", "sh" },
})

-- EFM Language Server setup for live Zsh syntax analysis via stdin
vim.lsp.config("efm", {
	capabilities = capabilities,
	filetypes = { "zsh" },
	init_options = { documentFormatting = false },
	settings = {
		rootMarkers = { ".git" },
		languages = {
			zsh = {
				{
					lintCommand = "zsh -n",
					lintStdin = true,
					lintFormats = { "zsh:%l: %m", "%f:%l: %m" },
					lintSource = "zsh",
				},
			},
		},
	},
})

vim.lsp.config("intelephense", {
	capabilities = capabilities,
	settings = {
		intelephense = {
			telemetry = { enabled = false },
			searchPaths = { "app", "vendor", "." },
			files = {
				maxMemory = 2048,
				maxSize = 15000000,
				exclude = {
					"**/.git/**",
					"**/node_modules/**",
					"**/storage/framework/**",
					"**/storage/logs/**",
					"**/bootstrap/cache/**",
					"**/vendor/composer/autoload_classmap.php",
					"**/vendor/composer/autoload_static.php",
					"**/vendor/fakerphp/faker/src/Faker/Provider/nl_BE/Text.php",
				},
			},
		},
	},
})

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
		"efm",
	},
	automatic_enable = false,
})

vim.lsp.enable("clangd")
vim.lsp.enable("jdtls")
vim.lsp.enable("ruff")
vim.lsp.enable("lua_ls")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("intelephense")
vim.lsp.enable("laravel_ls")
vim.lsp.enable("bashls")
vim.lsp.enable("efm")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		-- Navigation & Info
		map("gd", vim.lsp.buf.definition, "Goto Definition")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("gs", vim.lsp.buf.signature_help, "Signature Help")
		-- Diagnostics
		map("<leader>cd", vim.diagnostic.open_float, "Show Line Diagnostics")
		map("<leader>cq", vim.diagnostic.setloclist, "Diagnostics Quickfix List")
	end,
})
