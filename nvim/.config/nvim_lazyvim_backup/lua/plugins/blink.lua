return {
  "saghen/blink.cmp",
  optional = true,
  opts = {
    keymap = {
      preset = "default",
      ["<C-Space>"] = {
        "show",
        "show_documentation",
        "hide_documentation",
      },
      ["<CR>"] = {
        "accept",
        "fallback",
      },
    },
    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
        },
        providers = {
          buffer = {
            min_keyword_length = 3,
            score_offset = -2,
          },
        },
      },
    },
  },
}
