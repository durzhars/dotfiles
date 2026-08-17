-- =============================================================================
-- Built-in Terminal Keymaps — Headless Edition
-- Mirrors full nvim config terminal handling
-- =============================================================================

local augroup = vim.api.nvim_create_augroup("headless-terminal", { clear = true })

-- Terminal buffer settings
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        pcall(function() vim.opt_local.statuscolumn = "" end)
        vim.cmd("startinsert")
    end,
})

-- Clean up terminal buffers on exit
vim.api.nvim_create_autocmd("TermClose", {
    group = augroup,
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
})

-- Terminal escape and window navigation
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
    end,
})

-- ── Floating Terminal Toggle ───────────────────────────────────────

local terminal_state = { buf = nil, win = nil, is_open = false }

local function toggle_terminal()
    -- Close if already open
    if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
        vim.api.nvim_win_close(terminal_state.win, false)
        terminal_state.is_open = false
        return
    end

    -- Create buffer if needed
    if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
        terminal_state.buf = vim.api.nvim_create_buf(false, true)
        vim.bo[terminal_state.buf].bufhidden = "hide"
    end

    -- Calculate float dimensions
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Open float
    terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    -- Start terminal if buffer is empty
    if vim.bo[terminal_state.buf].buftype ~= "terminal" then
        vim.fn.termopen(os.getenv("SHELL") or "/bin/sh")
    end

    terminal_state.is_open = true
    vim.cmd("startinsert")

    -- Auto-close on focus loss
    vim.api.nvim_create_autocmd("BufLeave", {
        group = vim.api.nvim_create_augroup("FloatingTermLeave_" .. terminal_state.win, { clear = true }),
        buffer = terminal_state.buf,
        once = true,
        callback = function()
            if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
                vim.api.nvim_win_close(terminal_state.win, false)
                terminal_state.is_open = false
            end
        end,
    })
end

vim.keymap.set("n", "<leader>t", toggle_terminal, { desc = "Toggle floating terminal", silent = true })
vim.keymap.set("t", "<C-q>", function()
    if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
        vim.api.nvim_win_close(terminal_state.win, false)
        terminal_state.is_open = false
    end
end, { desc = "Close floating terminal", silent = true })
