vim.opt_local.matchpairs = vim.opt_local.matchpairs + "<:>"
vim.opt_local.formatprg = "prettier --use-tabs --parser html"
require("neovim-config.lsp").start_server("html")
