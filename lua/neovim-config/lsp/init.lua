local M = {}

function M.setup()
	-- Set to true for debug logging in LSP:
	vim.g.neovim_config_lsp_debug = false

	-- Use LspAttach event:
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("neovim-config-lsp-on-attach", {}),
		callback = function(ev)
			require("neovim-config.lsp").on_attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf)
		end,
	})

	-- Configure servers here:
	vim.g.neovim_config_lsp = {
		cssls = {
			snippets = true,
		},
		eslint = {
			snippets = true,
		},
		html = {
			snippets = true,
		},
		jsonls = {
			filetypes = { "json", "jsonc" },
			snippets = true,
		},
		lua_ls = {
			snippets = true,
			settings = {
				Lua = {
					completion = { callSnippet = "Both" },
					workspace = {
						-- Make the server aware of Neovim runtime files
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
						},
					},
					-- Do not send telemetry data containing a randomized but unique identifier
					telemetry = { enable = false },
					runtime = {
						version = "LuaJIT",
					},
				},
			},
		},
		standardrb = {
			single_file_support = true,
		},
		vimls = {
			init_options = {
				isNeovim = true,
				diagnostic = {
					enable = false,
				},
			},
			snippets = true,
		},
	}
	-- To boot a server, run: require("neovim-config.lsp").start_server(<lspconfig configuration name>) in the appropriate ftplugins file

end

M.start_server = require("neovim-config.lsp.start_server")
M.on_attach = require("neovim-config.lsp.on_attach")

return M
