local M = {}
function M.setup()
	require("neovim-config.options").setup()
	require("neovim-config.autocmds").setup()
	require("neovim-config.keymaps").setup()
	require("neovim-config.commands").setup()
	require("neovim-config.diagnostics").setup()
	require("neovim-config.lsp").setup()

	-- Use vim.ui.select to search for digraphs:
	require("select-digraphs").setup()
	-- Theme
	if not pcall(vim.cmd.colorscheme, "catppuccin") then
		vim.cmd([[colorscheme default]])
	end
	-- Filetypes {{{
	vim.filetype.add({
		extension = {
			rasi = "rasi",
		},
		filename = {},
		pattern = {},
	})
	-- }}}
	-- Neovim API Overrides {{{
	function vim.print(...)
		if vim.in_fast_event() then
			print(...)
			return ...
		end
		local output = {}
		for i = 1, select("#", ...) do
			local o = select(i, ...)
			if type(o) == "string" then
				table.insert(output, o)
			else
				table.insert(output, vim.inspect(o, { newline = " ", indent = "" }))
			end
		end
		vim.api.nvim_out_write(table.concat(output, "    "))
		vim.api.nvim_out_write("\n")
		return ...
	end
end

return M
