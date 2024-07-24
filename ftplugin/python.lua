vim.opt_local.listchars = vim.opt_local.listchars - "tab:| "
vim.opt_local.listchars = vim.opt_local.listchars + "multispace:│   "
vim.opt_local.formatprg = "black --quiet -|reorder-python-imports -"
require("neovim-config.lsp").start_server("pyright")
