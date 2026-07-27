-- =============================================================================
-- Core Keymaps — Headless (No-Plugin) Edition
-- Mirrors the full nvim config's non-plugin keymaps
-- =============================================================================

local map = vim.keymap.set

-- ── Navigation ─────────────────────────────────────────────────────

-- Center screen after vertical motions
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down & center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up & center" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- ── Buffers ────────────────────────────────────────────────────────

map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer", silent = true })
map("n", "<leader>ba", ":%bdelete|edit#|bdelete#<CR>", { desc = "Delete all other buffers", silent = true })

-- ── Editing ────────────────────────────────────────────────────────

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better paste (don't yank replaced text)
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Quick escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Clear search highlights
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

-- Stay in visual mode after indent
map("v", "<", "<gv", { desc = "Indent left & reselect" })
map("v", ">", ">gv", { desc = "Indent right & reselect" })

-- Join line without moving cursor
map("n", "J", "mzJ`z", { desc = "Join line (keep cursor)" })

-- ── Diagnostics ────────────────────────────────────────────────────

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic message" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ── Quickfix / Location List ───────────────────────────────────────

map("n", "]q", ":cnext<CR>zz", { desc = "Next quickfix", silent = true })
map("n", "[q", ":cprev<CR>zz", { desc = "Previous quickfix", silent = true })
map("n", "]l", ":lnext<CR>zz", { desc = "Next location", silent = true })
map("n", "[l", ":lprev<CR>zz", { desc = "Previous location", silent = true })

-- ── Built-in Fuzzy Finder (Neovim 0.11+) ──────────────────────────
-- Uses vim.ui.select + :find for lightweight fuzzy finding

map("n", "<leader>ff", function()
    -- Use :find with wildmenu for file finding
    vim.cmd("find ")
end, { desc = "Find file (:find)" })

map("n", "<leader>fb", function()
    -- List buffers and pick
    local bufs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" then
                name = vim.fn.fnamemodify(name, ":~:.")
            else
                name = "[No Name]"
            end
            table.insert(bufs, { buf = buf, name = string.format("%d: %s", buf, name) })
        end
    end
    vim.ui.select(bufs, {
        prompt = "Switch Buffer:",
        format_item = function(item) return item.name end,
    }, function(choice)
        if choice then
            vim.api.nvim_set_current_buf(choice.buf)
        end
    end)
end, { desc = "Find buffer" })

map("n", "<leader>fg", function()
    -- Grep with built-in :grep
    local pattern = vim.fn.input("Grep: ")
    if pattern ~= "" then
        vim.cmd("silent grep! " .. vim.fn.shellescape(pattern))
        vim.cmd("copen")
    end
end, { desc = "Live grep (:grep)" })

map("n", "<leader>fh", ":help ", { desc = "Help tags" })

map("n", "<leader>fr", function()
    -- Recent files via oldfiles
    local oldfiles = vim.v.oldfiles
    local items = {}
    for i, f in ipairs(oldfiles) do
        if i > 50 then break end
        if vim.fn.filereadable(f) == 1 then
            table.insert(items, f)
        end
    end
    vim.ui.select(items, {
        prompt = "Recent Files:",
        format_item = function(item)
            return vim.fn.fnamemodify(item, ":~:.")
        end,
    }, function(choice)
        if choice then
            vim.cmd("edit " .. vim.fn.fnameescape(choice))
        end
    end)
end, { desc = "Recent files" })

map("n", "<leader>fw", function()
    -- Grep word under cursor
    local word = vim.fn.expand("<cword>")
    if word ~= "" then
        vim.cmd("silent grep! " .. vim.fn.shellescape(word))
        vim.cmd("copen")
    end
end, { desc = "Grep word under cursor" })

-- ── File Explorer ──────────────────────────────────────────────────

map("n", "<leader>E", ":Lexplore 30<CR>", { desc = "Toggle file explorer", silent = true })

-- ── Misc Utilities ─────────────────────────────────────────────────

map("n", "<leader>w", ":write<CR>", { desc = "Save file", silent = true })
map("n", "<leader>x", ":x<CR>", { desc = "Save and quit", silent = true })

-- Yank to end of line (consistent with D and C)
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Select all
map("n", "<leader>a", "ggVG", { desc = "Select all" })
