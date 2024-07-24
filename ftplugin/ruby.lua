vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.listchars = vim.opt_local.listchars - "tab:| "
vim.opt_local.listchars = vim.opt_local.listchars + "multispace:│ "

vim.opt_local.formatprg = "rufo --filename=%"
require("neovim-config.lsp").start_server("standardrb")
