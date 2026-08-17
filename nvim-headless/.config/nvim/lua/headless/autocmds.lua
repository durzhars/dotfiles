-- =============================================================================
-- Autocommands — Headless Edition
-- Quality-of-life automations with zero dependencies
-- =============================================================================

local augroup = vim.api.nvim_create_augroup("headless-autocmds", { clear = true })

-- Highlight on yank (visual feedback)
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "Briefly highlight yanked text",
    callback = function()
        (vim.hl or vim.highlight).on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Return to last edit position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Restore cursor position",
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Auto-resize splits on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "Equalize splits on resize",
    command = "tabdo wincmd =",
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Strip trailing whitespace",
    pattern = "*",
    callback = function()
        -- Don't strip in diff or markdown
        if vim.bo.filetype == "diff" or vim.bo.filetype == "markdown" then
            return
        end
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    end,
})

-- Auto-create parent directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Create parent dirs on save",
    callback = function(args)
        if args.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local dir = vim.fn.fnamemodify(args.file, ":p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})

-- Filetype-specific indentation overrides
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "2-space indent for web/config files",
    pattern = {
        "html", "css", "scss", "javascript", "typescript",
        "json", "yaml", "toml", "lua", "vim",
        "xml", "svg", "markdown",
    },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "Tab-based indent for makefiles and go",
    pattern = { "make", "go" },
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
})

-- Close certain filetypes with just 'q'
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "Close helper windows with q",
    pattern = {
        "help", "qf", "man", "checkhealth",
        "netrw", "notify", "lspinfo",
    },
    callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
            buffer = args.buf,
            silent = true,
        })
    end,
})

-- Large file detection: disable slow features for big files
vim.api.nvim_create_autocmd("BufReadPre", {
    group = augroup,
    desc = "Optimize for large files",
    callback = function(args)
        local uv = vim.uv or vim.loop
        local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > 1024 * 1024 then -- 1MB
            vim.opt_local.swapfile = false
            vim.opt_local.undolevels = -1
            vim.opt_local.undoreload = 0
            vim.opt_local.list = false
            vim.opt_local.foldmethod = "manual"
            vim.opt_local.spell = false
            vim.opt_local.syntax = "OFF"
        end
    end,
})
