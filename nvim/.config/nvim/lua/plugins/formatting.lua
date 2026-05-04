return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        php = { "php_cs_fixer" },
      },
      formatters = {
        php_cs_fixer = {
          -- Force PSR-12 rules and disable cache for standalone files
          args = {
            "fix",
            "$FILENAME",
            "--rules=@PSR12",
            "--using-cache=no",
            "--no-interaction",
          },
        },
      },
    },
  },
}
