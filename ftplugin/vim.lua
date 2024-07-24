vim.opt_local.foldmethod = "marker"
vim.opt_local.foldlevel = 0
require("neovim-config.lsp").start_server("vimls")
