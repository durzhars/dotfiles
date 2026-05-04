return {
  -- Load your local plugin immediately
  {
    dir = "~/Projects/colors.nvim",
    lazy = false, -- Critical: forces it to load during startup
    priority = 1000,
  },
  -- Override LazyVim's default colorscheme setting
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dcolorscheme",
    },
  },
}
