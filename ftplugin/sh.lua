vim.opt_local.formatprg = "shfmt -ci -s -bn"
require("neovim-config.lsp").start_server("bashls")
