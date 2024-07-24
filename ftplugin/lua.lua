vim.opt_local.formatprg = "stylua -"
vim.opt_local.include = [==[^.*require\s*(\{0,1\}["']\zs[^"']\+\ze["']]==]
vim.opt_local.includeexpr = "v:lua.require'neovim-config.lua'.includeexpr(v:fname)"
require("neodev").setup()
require("neovim-config.lsp").start_server("lua_ls")
