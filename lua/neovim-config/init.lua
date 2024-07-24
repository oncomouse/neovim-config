local M = {}
function M.setup()
	-- Formatting:
	vim.api.nvim_create_user_command("Format", function(args)
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.opt_local.filetype:get()
		local has_formatter, config = pcall(require, "formatter.config")
		if has_formatter and config.values.filetype[ft] ~= nil then
			require("formatter.format").format(args.args, args.mod, args.line1, args.line2)
		elseif vim.b.neovim_config_lsp_can_format then
			vim.lsp.buf.format({
				bufnr = buf,
			})
		else
			vim.api.nvim_feedkeys("mxgggqG`x", "x", true)
		end
	end, {
		desc = "Formatting with formatter.nvim, lsp, fallback",
		force = true,
		range = "%",
		nargs = "?",
	})

	-- Adjust Spacing:
	vim.api.nvim_create_user_command("Spaces", function(args)
		local wv = vim.fn.winsaveview()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = tonumber(args.args)
		vim.opt_local.softtabstop = tonumber(args.args)
		vim.opt_local.shiftwidth = tonumber(args.args)
		vim.cmd("silent execute '%!expand -it" .. args.args .. "'")
		vim.fn.winrestview(wv)
		vim.cmd("setlocal ts? sw? sts? et?")
	end, {
		force = true,
		nargs = 1,
	})
	vim.api.nvim_create_user_command("Tabs", function(args)
		local wv = vim.fn.winsaveview()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = tonumber(args.args)
		vim.opt_local.softtabstop = tonumber(args.args)
		vim.opt_local.shiftwidth = tonumber(args.args)
		vim.cmd("silent execute '%!unexpand -t" .. args.args .. "'")
		vim.fn.winrestview(wv)
		vim.cmd("setlocal ts? sw? sts? et?")
	end, {
		force = true,
		nargs = 1,
	})

	vim.api.nvim_create_user_command("LazyGit", ":terminal lazygit<cr>", {
		force = true
	})
	-- LSP
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

	-- Turn on debug-level logging for LSP:
	if vim.g.neovim_config_lsp_debug then
		vim.lsp.set_log_level("trace")
	end

	-- Diagnostics

	-- Configuration
	vim.diagnostic.config({
		underline = true,
		virtual_text = true,
		signs = false,
		severity_sort = true,
	})

	--Signs
	local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	-- Add diagnostics to loclist:
	vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
		group = vim.api.nvim_create_augroup("neovim-config-attach_diagnostics", {}),
		pattern = "*",
		callback = function()
			vim.diagnostic.setloclist({ open = false })
		end,
	})

end

return M
