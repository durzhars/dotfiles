return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = true,
      virtual_text = {
        spacing = 3,
        source = "if_many",
        prefix = "●",
      },
    },
  },
}
