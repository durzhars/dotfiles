-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- Auto-open Snacks Explorer forced to the opened file's directory
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open Snacks Explorer rooted at the opened file's directory",
  callback = function()
    -- Grab the absolute path of the buffer that Neovim just opened.
    -- This sidesteps the argv() LSP warnings entirely.
    local file = vim.api.nvim_buf_get_name(0)
    -- Check if it is a valid, readable file (not an empty buffer or directory)
    if file ~= "" and vim.fn.filereadable(file) == 1 then
      local file_dir = vim.fn.fnamemodify(file, ":p:h")
      vim.schedule(function()
        -- 1. Save your file's window ID
        local file_win = vim.api.nvim_get_current_win()
        -- 2. Launch Snacks Explorer
        Snacks.explorer({ cwd = file_dir })
        -- 3. Hard-delay the focus switch by 50ms to outwait the Snacks UI
        vim.defer_fn(function()
          if vim.api.nvim_win_is_valid(file_win) then
            vim.api.nvim_set_current_win(file_win)
          end
        end, 10)
      end)
    end
  end,
})
