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

-- Temporary testing pipelin
local ns = vim.api.nvim_create_namespace("architecture_test")

local function run_arch_test()
	vim.notify("Running Architecture Test...", vim.log.levels.INFO, { title = "ArchTest" })

	vim.system({ "php", "artisan", "test", "--filter=NoMagicStringsArchitectureTest" }, { text = true }, function(obj)
		vim.schedule(function()
			-- Bersihkan diagnostics lama
			vim.diagnostic.reset(ns)

			if not obj.stdout then
				return
			end

			local diagnostics_by_file = {}

			for line in obj.stdout:gmatch("[^\r\n]+") do
				local file_path, line_num, msg = line:match("^([^:]+):(%d+):%s*(.+)$")

				if file_path and line_num and msg then
					local abs_path = vim.fn.fnamemodify(file_path, ":p")

					if not diagnostics_by_file[abs_path] then
						diagnostics_by_file[abs_path] = {}
					end

					table.insert(diagnostics_by_file[abs_path], {
						lnum = tonumber(line_num) - 1,
						col = 0,
						severity = vim.diagnostic.severity.WARN,
						message = msg,
						source = "ArchTest",
					})
				end
			end

			local count = 0
			-- Set diagnostics ke setiap buffer/file terkait
			for file, diags in pairs(diagnostics_by_file) do
				local bufnr = vim.fn.bufadd(file)
				vim.diagnostic.set(ns, bufnr, diags)
				count = count + #diags
			end

			if count > 0 then
				vim.notify(
					"Found " .. count .. " architecture violations!",
					vim.log.levels.WARN,
					{ title = "ArchTest" }
				)
			else
				vim.notify("Architecture Test Passed! Clean code.", vim.log.levels.INFO, { title = "ArchTest" })
			end
		end)
	end)
end

-- Command dan Keymap
vim.api.nvim_create_user_command("ArchTest", run_arch_test, {})
vim.keymap.set("n", "<leader>ca", run_arch_test, { desc = "Run Architecture Test Diagnostics" })
