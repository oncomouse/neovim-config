vim.opt_local.formatprg = "prettier --use-tabs --parser json"
require("neovim-config.lsp").start_server("jsonls")
