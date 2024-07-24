vim.opt_local.iskeyword = vim.opt_local.iskeyword + "-"
vim.opt_local.formatprg = "prettier --use-tabs --parser css"
require("neovim-config.lsp").start_server("cssls")
