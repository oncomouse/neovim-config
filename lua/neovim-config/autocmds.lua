local M = {}
function M.setup()
	-- Autogroups: {{{
	local augroup = vim.api.nvim_create_augroup("neovim-config-settings", { clear = true })
	-- }}}
	-- Autocommands {{{
	-- Turn Off Line Numbering:
	vim.api.nvim_create_autocmd("TermOpen", { group = augroup, command = "setlocal nonumber norelativenumber" })

	-- Start QuickFix:
	vim.api.nvim_create_autocmd("QuickFixCmdPost", {
		group = augroup,
		pattern = "[^l]*",
		callback = function()
			require("neovim-config.functions").list_toggle("c", 1)
		end,
	})
	vim.api.nvim_create_autocmd("QuickFixCmdPost", {
		group = augroup,
		pattern = "l*",
		callback = function()
			require("neovim-config.functions").list_toggle("c", 1)
		end,
	})

	-- Close Preview Window:
	vim.api.nvim_create_autocmd("CompleteDone", {
		group = augroup,
		callback = function()
			if vim.fn.pumvisible() == 0 then
				vim.cmd("pclose")
			end
		end,
	})
	--}}}
end

return M
