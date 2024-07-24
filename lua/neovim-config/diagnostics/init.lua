local M = {}
function M.setup()
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
